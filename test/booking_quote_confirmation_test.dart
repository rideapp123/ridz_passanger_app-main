import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/core/enums/ride.dart';
import 'package:ridzs_passenger_app/core/theme/light_theme.dart';
import 'package:ridzs_passenger_app/core/theme/ridzs_theme.dart';
import 'package:ridzs_passenger_app/models/response/price_response.dart';
import 'package:ridzs_passenger_app/models/ride/booking_quote.dart';
import 'package:ridzs_passenger_app/services/booking_quote_service.dart';
import 'package:ridzs_passenger_app/services/ride_service.dart';
import 'package:ridzs_passenger_app/stores/map/map_store.dart';
import 'package:ridzs_passenger_app/view/home/widget/booking_quote_sheet.dart';
import 'booking_quote_test.dart' as fixtures;

Map<String, dynamic> bookable({bool expired = false}) => fixtures.fixture(
    created:
        DateTime.now().toUtc().subtract(Duration(seconds: expired ? 130 : 1)))
  ..['bookingSupported'] = true
  ..['fare'] = {'total': 12.35, 'surgeMultiplier': 1.5};

class QuoteStore extends MapStore {
  QuoteStore(Dio dio, Future<String?> Function() token)
      : super(
            rideService: RideService.withClient(dio),
            recoveryDio: dio,
            sessionTokenReader: token,
            bookingQuotesEnabled: true,
            rideNotice: (_) {}) {
    selectedPrice = Price(
        taxes: TaxesModel(serviceCharge: 0, gst: 0),
        vehicleType: CarType.standard,
        basePrice: 1,
        minimumFare: 1,
        perKilometer: 1,
        perMinute: 1,
        waitingChargePerMinute: 0,
        cancellationFee: 0,
        peakHourMultiplier: 1,
        nightChargeMultiplier: 1,
        isActive: true,
        lastUpdatedBy: 'test',
        surgeMultipliers: [],
        specialZones: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        id: 'rate');
  }
  Map<String, dynamic> trip = fixtures.trip();
  @override
  bool get hasValidLocations => true;
  @override
  Map<String, dynamic> quoteRequest() => trip;
  @override
  Future<void> resumeRideResources() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('Poppins')
          ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
          ..addFont(rootBundle.load('assets/fonts/Poppins-Medium.ttf'))
          ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf')))
        .load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });
  late Dio dio;
  late BookingQuoteService service;
  late Object? session;
  late Map<String, dynamic> quote;
  late List<RequestOptions> requests;
  late Future<Map<String, dynamic>> Function(RequestOptions) respond;
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    session = Object();
    quote = bookable();
    requests = [];
    dio = Dio(BaseOptions(baseUrl: 'https://example.test/passenger'));
    service = BookingQuoteService(dio: dio, sessionReader: () => session);
    respond = (request) async => request.path == '/ride-quotes'
        ? {'quote': jsonDecode(jsonEncode(quote))}
        : {
            'ride': {
              'id': 'ride1',
              'status': 'searching',
              'version': 1,
              'payment': {'method': 'wallet', 'status': 'authorized'},
              'fare': {
                'total': 12.35,
                'currency': 'usd',
                'quoteId': quote['id'],
                'quoteFingerprint': quote['fingerprint']
              }
            }
          };
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      requests.add(options);
      try {
        handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {'success': true, 'data': await respond(options)}));
      } on DioException catch (error) {
        handler.reject(error);
      }
    }));
  });
  tearDown(() {
    service.dispose();
    dio.close(force: true);
  });

  Future<void> sheet(WidgetTester tester,
      {double scale = 1, double width = 390}) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: RidzsTheme.refine(ThemeData(
            useMaterial3: true,
            colorScheme: flexSchemeLight,
            fontFamily: 'Poppins')),
        home: Scaffold(
            backgroundColor: Colors.white,
            body: MediaQuery(
          data: MediaQueryData(
              size: Size(width, 844), textScaler: TextScaler.linear(scale)),
          child: BookingQuoteSheet(
              service: service,
              request: fixtures.trip(),
              paymentLabel: 'Wallet'),
        ))));
    await tester.pumpAndSettle();
  }

  testWidgets('only the explicit confirmation returns the accepted quote',
      (tester) async {
    BookingQuote? accepted;
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () async {
                      accepted = await showModalBottomSheet<BookingQuote>(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => BookingQuoteSheet(
                              service: service,
                              request: fixtures.trip(),
                              paymentLabel: 'Wallet'));
                    },
                    child: const Text('Open'))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(accepted, isNull);
    await tester.tap(find.text('Confirm ride'));
    await tester.pumpAndSettle();
    expect(accepted?.amountMinor, 1235);
    expect(service.owns(accepted!), true);
    expect(requests.map((r) => r.path), ['/ride-quotes']);
    await tester.pumpWidget(const SizedBox());
  });

  for (final width in [360.0, 412.0]) {
    testWidgets('expired fare review golden at $width', (tester) async {
      quote = bookable(expired: true);
      await sheet(tester, width: width);
      expect(tester.takeException(), isNull);
      await expectLater(find.byType(Scaffold),
          matchesGoldenFile('goldens/quote_expired_${width.toInt()}.png'));
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets(
      'review displays authoritative price, driving metrics and surge without booking',
      (tester) async {
    await sheet(tester);
    expect(find.text('USD 12.35'), findsOneWidget);
    expect(find.text('4.5 km  /  10 min'), findsOneWidget);
    expect(find.text('Demand multiplier 1.50x'), findsOneWidget);
    expect(find.text('Confirm ride'), findsOneWidget);
    expect(requests.map((r) => r.path), ['/ride-quotes']);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('expired quote refresh needs a separate confirmation and new key',
      (tester) async {
    quote = bookable(expired: true);
    await sheet(tester);
    expect(find.text('Confirm ride'), findsNothing);
    final key = requests.single.headers['Idempotency-Key'];
    quote = bookable()..['id'] = 'd' * 64;
    quote['amountMinor'] = 2000;
    quote['fare'] = {'total': 20.0, 'surgeMultiplier': 1.5};
    await tester.tap(find.text('Refresh fare'));
    await tester.pumpAndSettle();
    expect(find.text('USD 20.00'), findsOneWidget);
    expect(find.text('Confirm ride'), findsOneWidget);
    expect(requests.last.headers['Idempotency-Key'], isNot(key));
    expect(requests.every((r) => r.path == '/ride-quotes'), true);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
      'failed quote retry keeps the same key and never falls back to booking',
      (tester) async {
    respond = (options) async => throw DioException(
        requestOptions: options, type: DioExceptionType.receiveTimeout);
    await sheet(tester);
    expect(find.text('Fare unavailable. No ride has been booked.'),
        findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(requests, hasLength(2));
    expect(requests.first.headers['Idempotency-Key'],
        requests.last.headers['Idempotency-Key']);
    expect(requests.every((r) => r.path == '/ride-quotes'), true);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('compact large-text review is scrollable without overflow',
      (tester) async {
    await sheet(tester, scale: 2, width: 320);
    await tester.ensureVisible(find.text('Confirm ride'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('session change removes confirmation permission', (tester) async {
    await sheet(tester);
    session = Object();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Confirm ride'), findsNothing);
    expect(find.text('Session ended. Sign in again.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('unavailable capability is never treated as a confirmed price',
      (tester) async {
    quote['bookingSupported'] = false;
    await sheet(tester);
    expect(find.text('Confirm ride'), findsNothing);
    expect(find.text('Quoted booking is unavailable.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  test(
      'map store submits only accepted quote identity, amount assertion and payment',
      () async {
    final store = QuoteStore(dio, () async => 'token');
    final quoteSession = await store.createQuoteSession();
    final accepted = await quoteSession.issue(store.quoteRequest(), 'q-key');
    expect(
        await store.createRideRequest(PaymentMethod.wallet,
            quote: accepted, quoteSession: quoteSession),
        true);
    final booking = requests.last;
    expect(booking.path, '/rides');
    expect(booking.data, {
      'quoteId': quote['id'],
      'quoteFingerprint': quote['fingerprint'],
      'quoteAmountMinor': 1235,
      'paymentMethod': 'wallet'
    });
    expect(requests.first.extra['expectedAuthToken'], 'token');
    store.endQuoteSession(quoteSession);
    store.dispose();
  });
  test('changed trip, missing confirmation or foreign session cannot book',
      () async {
    final store = QuoteStore(dio, () async => 'token');
    expect(await store.createRideRequest(PaymentMethod.wallet), false);
    final quoteSession = await store.createQuoteSession();
    final accepted = await quoteSession.issue(store.quoteRequest(), 'q-key');
    store.trip = fixtures.trip()..['vehicleType'] = 'xl';
    expect(
        await store.createRideRequest(PaymentMethod.wallet,
            quote: accepted, quoteSession: quoteSession),
        false);
    store.trip = fixtures.trip();
    expect(
        await store.createRideRequest(PaymentMethod.wallet,
            quote: accepted, quoteSession: service),
        false);
    expect(requests.every((r) => r.path == '/ride-quotes'), true);
    store.endQuoteSession(quoteSession);
    store.dispose();
  });
  test('timeout retains original quote booking after quote session ends',
      () async {
    final store = QuoteStore(dio, () async => 'token');
    final normal = respond;
    final quoteSession = await store.createQuoteSession();
    final accepted = await quoteSession.issue(store.quoteRequest(), 'q-key');
    respond = (r) async => throw DioException(
        requestOptions: r, type: DioExceptionType.receiveTimeout);
    expect(
        await store.createRideRequest(PaymentMethod.wallet,
            quote: accepted, quoteSession: quoteSession),
        false);
    expect(store.booking.pending.value, true);
    await expectLater(store.createQuoteSession(), throwsStateError);
    final first = requests.last;
    store.endQuoteSession(quoteSession);
    respond = normal;
    await store.retryBookingConfirmation();
    expect(store.booking.pending.value, false);
    expect(requests.last.data, first.data);
    expect(requests.last.headers['Idempotency-Key'],
        first.headers['Idempotency-Key']);
    expect(requests.where((r) => r.path == '/ride-quotes'), hasLength(1));
    store.dispose();
  });
  test(
      'wrong fare acknowledgement keeps uncertainty instead of clearing the journal',
      () async {
    final store = QuoteStore(dio, () async => 'token');
    final normal = respond;
    final quoteSession = await store.createQuoteSession();
    final accepted = await quoteSession.issue(store.quoteRequest(), 'q-key');
    respond = (request) async {
      final data = await normal(request);
      (data['ride']['fare'] as Map)['total'] = 99.0;
      return data;
    };
    expect(
        await store.createRideRequest(PaymentMethod.wallet,
            quote: accepted, quoteSession: quoteSession),
        false);
    expect(store.booking.pending.value, true);
    expect(store.currentRide, isNull);
    store.endQuoteSession(quoteSession);
    store.dispose();
  });
  test('reviewed uncreated closure permits only a fresh quoted booking',
      () async {
    final store = QuoteStore(dio, () async => 'token');
    final normal = respond;
    final originalSession = await store.createQuoteSession();
    final accepted = await originalSession.issue(store.quoteRequest(), 'q-key');
    respond = (request) async => throw DioException(
        requestOptions: request, type: DioExceptionType.receiveTimeout);
    expect(
        await store.createRideRequest(PaymentMethod.wallet,
            quote: accepted, quoteSession: originalSession),
        false);
    final original = requests.last;
    store.endQuoteSession(originalSession);
    respond = (request) async => throw DioException(
        requestOptions: request,
        response: Response(
            requestOptions: request,
            statusCode: 409,
            data: {'code': 'BOOKING_UNCONFIRMED'}));
    await store.retryBookingConfirmation();
    expect(store.booking.pending.value, true);
    await expectLater(store.createQuoteSession(), throwsStateError);
    respond = (request) async => throw DioException(
        requestOptions: request,
        response: Response(
            requestOptions: request,
            statusCode: 409,
            data: {'code': 'BOOKING_REJECTED'}));
    await store.retryBookingConfirmation();
    expect(requests.last.data, original.data);
    expect(requests.last.headers['Idempotency-Key'],
        original.headers['Idempotency-Key']);
    expect(store.booking.pending.value, false);
    expect(store.currentRide, isNull);
    quote = bookable()..['id'] = 'd' * 64;
    respond = normal;
    final nextSession = await store.createQuoteSession();
    final nextQuote = await nextSession.issue(store.quoteRequest(), 'new-q-key');
    expect(
        await store.createRideRequest(PaymentMethod.wallet,
            quote: nextQuote, quoteSession: nextSession),
        true);
    expect(requests.last.data['quoteId'], 'd' * 64);
    expect(requests.last.headers['Idempotency-Key'],
        isNot(original.headers['Idempotency-Key']));
    store.endQuoteSession(nextSession);
    store.dispose();
  });
  test('signed-out token cannot create quote session or send requests',
      () async {
    final store = QuoteStore(dio, () async => null);
    await expectLater(store.createQuoteSession(), throwsStateError);
    expect(requests, isEmpty);
    store.dispose();
  });
}
