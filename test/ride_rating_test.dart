import 'dart:async';
import 'package:ridzs_passenger_app/core/theme/light_theme.dart';
import 'package:ridzs_passenger_app/core/theme/ridzs_theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/services/ride_rating_service.dart';
import 'package:ridzs_passenger_app/view/home/widget/ride_rating_form.dart';
import 'package:ridzs_passenger_app/stores/map/map_store.dart';
import 'package:ridzs_passenger_app/models/common/ride_response/ride_response.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Dio dio;
  late RideRatingService ratings;
  late List<RequestOptions> requests;
  late Future<Response<dynamic>> Function(RequestOptions) respond;

  Map<String, dynamic> saved({int stars = 5, String feedback = 'Good trip'}) =>
      {
        'id': 'saved-id',
        'rideId': 'r1',
        'by': 'passenger',
        'rating': stars,
        'feedback': feedback,
        'createdAt': '2026-09-13T00:00:00Z',
      };
  Response<dynamic> reply(RequestOptions request, Map<String, dynamic> data) =>
      Response(
          requestOptions: request,
          statusCode: 200,
          data: {'success': true, 'data': data});

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://example.test/passenger'));
    requests = [];
    respond = (request) async => request.method == 'GET'
        ? reply(request, {'rideId': 'r1', 'hasRating': false})
        : reply(
            request,
            saved(
                stars: request.data['rating'],
                feedback: request.data['feedback']));
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (request, handler) async {
      requests.add(request);
      try {
        final response = await respond(request);
        if ((response.statusCode ?? 500) >= 400) {
          handler.reject(DioException(
              requestOptions: request,
              response: response,
              type: DioExceptionType.badResponse));
        } else {
          handler.resolve(response);
        }
      } catch (_) {
        handler.reject(DioException(
            requestOptions: request, type: DioExceptionType.receiveTimeout));
      }
    }));
    ratings = RideRatingService(role: 'passenger', dio: dio);
  });
  tearDown(() {
    ratings.reset();
    dio.close(force: true);
  });

  test('confirms matching persisted rating over HTTP without a socket',
      () async {
    final result = await ratings.submit('r1', 5, ' Good trip ');
    expect(result!.stars, 5);
    expect(result.feedback, 'Good trip');
    expect(requests.single.data, {'rating': 5, 'feedback': 'Good trip'});
  });

  test('lookup distinguishes absence from failure and does not write',
      () async {
    expect(await ratings.load('r1'), isNull);
    expect(ratings.loadError.value, isNull);
    expect(requests.single.method, 'GET');
    respond = (_) async => throw StateError('offline');
    expect(await ratings.load('r1'), isNull);
    expect(ratings.loadError.value, isNotNull);
  });

  test('restart loads the earlier saved rating and Done does not submit again',
      () async {
    respond = (request) async =>
        reply(request, {'rideId': 'r1', 'hasRating': true, 'rating': saved()});
    expect((await ratings.load('r1'))!.stars, 5);
    expect((await ratings.submit('r1', 5, 'Good trip'))!.id, 'saved-id');
    expect(requests, hasLength(1));
  });

  test('timeout preserves failure and allows an idempotent retry', () async {
    respond = (_) async => throw StateError('offline');
    expect(await ratings.submit('r1', 5, 'Good trip'), isNull);
    expect(ratings.record.value, isNull);
    expect(ratings.error.value, isNotNull);
    respond = (request) async => reply(request, saved());
    expect(await ratings.submit('r1', 5, 'Good trip'), isNotNull);
    expect(requests[0].data, requests[1].data);
  });

  test('changed retry reconciles only an explicit already-saved conflict',
      () async {
    respond = (request) async => request.method == 'POST'
        ? Response(
            requestOptions: request,
            statusCode: 409,
            data: {'success': false, 'code': 'RATING_ALREADY_SAVED'})
        : reply(
            request, {'rideId': 'r1', 'hasRating': true, 'rating': saved()});
    final original = await ratings.submit('r1', 1, 'Changed after timeout');
    expect(original!.stars, 5);
    expect(original.feedback, 'Good trip');
    expect(requests.map((r) => r.method), ['POST', 'GET']);
  });

  test('unrelated conflict cannot be treated as a saved rating', () async {
    respond = (request) async => Response(
        requestOptions: request,
        statusCode: 409,
        data: {'success': false, 'code': 'RIDE_NOT_COMPLETED'});
    expect(await ratings.submit('r1', 5, 'Good trip'), isNull);
    expect(requests, hasLength(1));
  });

  for (final field in [
    'id',
    'rideId',
    'by',
    'rating',
    'feedback',
    'createdAt'
  ]) {
    test('rejects invalid $field confirmation', () async {
      respond = (request) async => reply(request, {
            ...saved(),
            field: field == 'rating'
                ? 2.5
                : field == 'id'
                    ? ''
                    : 'wrong'
          });
      expect(await ratings.submit('r1', 5, 'Good trip'), isNull);
      expect(ratings.record.value, isNull);
    });
  }

  test('overlapping submissions post only once', () async {
    final gate = Completer<Response<dynamic>>();
    respond = (_) => gate.future;
    final first = ratings.submit('r1', 5, 'Good trip');
    while (requests.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    expect(await ratings.submit('r1', 4, 'Changed'), isNull);
    gate.complete(reply(requests.single, saved()));
    expect(await first, isNotNull);
    expect(requests, hasLength(1));
  });

  test('logout prevents late lookup or submit from entering another session',
      () async {
    final gate = Completer<Response<dynamic>>();
    respond = (_) => gate.future;
    final first = ratings.submit('r1', 5, 'Good trip');
    while (requests.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    ratings.reset();
    gate.complete(reply(requests.single, saved()));
    expect(await first, isNull);
    expect(ratings.record.value, isNull);
    expect(ratings.error.value, isNull);
  });

  test(
      'store retains the completion screen on failure then clears after storage',
      () async {
    final notices = <String>[];
    final store = MapStore(ratingService: ratings, rideNotice: notices.add);
    store.currentRide = RideRequest.fromJson({
      'ride': {'id': 'r1', 'status': 'completed'}
    });

    respond = (_) async => throw StateError('offline');
    await store.submitFeedback(rideId: 'r1', rating: 5, feedback: 'Good trip');
    expect(store.currentRide, isNotNull);
    expect(notices, isEmpty);
    respond = (request) async => reply(request, saved());
    await store.submitFeedback(rideId: 'r1', rating: 5, feedback: 'Good trip');
    expect(store.currentRide, isNull);
    expect(notices, ['Rating saved.']);

    store.dispose();
  });

  test('store refuses premature ratings without HTTP requests', () async {
    final store = MapStore(ratingService: ratings, rideNotice: (_) {});
    store.currentRide = RideRequest.fromJson({
      'ride': {'id': 'r1', 'status': 'started'}
    });
    await store.submitFeedback(rideId: 'r1', rating: 5, feedback: 'Good trip');
    expect(requests, isEmpty);
    expect(store.currentRide, isNotNull);
    store.dispose();
  });

  testWidgets(
      'form retains input on failure and shows saved state only on confirmation',
      (tester) async {
    var fail = true;
    respond = (request) async {
      if (request.method == 'GET') {
        return reply(request, {'rideId': 'r1', 'hasRating': false});
      }
      if (fail) throw StateError('offline');
      return reply(request, saved());
    };
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: RideRatingForm(
      rideId: 'r1',
      participant: 'Test participant',
      service: ratings,
      foreground: Colors.black,
      background: Colors.white,
      submit: (stars, feedback) async {
        await ratings.submit('r1', stars, feedback);
      },
    ))));
    await tester.pumpAndSettle();
    tester.widget<RatingBar>(find.byType(RatingBar)).onRatingUpdate(5);
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Good trip');
    await tester.ensureVisible(find.text('Submit rating'));
    await tester.tap(find.text('Submit rating'));
    await tester.pumpAndSettle();
    expect(find.text('Good trip'), findsOneWidget);
    expect(find.textContaining('Rating not confirmed'), findsOneWidget);
    expect(find.text('Done'), findsNothing);
    fail = false;
    await tester.ensureVisible(find.text('Submit rating'));
    await tester.tap(find.text('Submit rating'));
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Your saved rating'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  for (final width in [320.0, 1000.0]) {
    testWidgets('saved rating form fits at width $width with large text',
        (tester) async {
      tester.view.physicalSize = Size(width, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final fonts = FontLoader('Poppins')
        ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'));
      await fonts.load();
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
      respond = (request) async => reply(
          request, {'rideId': 'r1', 'hasRating': true, 'rating': saved()});
      await tester.pumpWidget(MaterialApp(
          theme: RidzsTheme.refine(ThemeData(
              useMaterial3: true,
              colorScheme: flexSchemeLight,
              fontFamily: 'Poppins')),
          home: MediaQuery(
            data: MediaQueryData(
                size: Size(width, 700), textScaler: const TextScaler.linear(2)),
            child: Scaffold(
                body: RepaintBoundary(
                    key: const Key('rating-form'),
                    child: RideRatingForm(
                      rideId: 'r1',
                      participant: 'Alexandria Long Participant Name',
                      service: ratings,
                      foreground: Colors.black,
                      background: Colors.white,
                      submit: (stars, feedback) async {
                        await ratings.submit('r1', stars, feedback);
                      },
                    ))),
          )));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Done'));
      await tester.pumpAndSettle();
      if (width == 320) {
        await expectLater(find.byKey(const Key('rating-form')),
            matchesGoldenFile('goldens/rating_large_text.png'));
      }
      expect(tester.widget<TextField>(find.byType(TextField)).readOnly, true);
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets('rating stays scrollable above the keyboard and safe area',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
      return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: Scaffold(
              appBar: AppBar(),
              body: Column(children: [
                const Spacer(),
                RideRatingForm(
                    rideId: 'r1',
                    participant: 'Test participant',
                    service: ratings,
                    foreground: Colors.black,
                    background: Colors.white,
                    submit: (_, feedback) async {}),
              ])));
    })));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Submit rating'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
