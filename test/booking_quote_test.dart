import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/models/ride/booking_quote.dart';
import 'package:ridzs_passenger_app/services/booking_quote_service.dart';

Map<String, dynamic> trip() => {
      'vehicleType': 'standard',
      'pickup': {'latitude': 45.42, 'longitude': -75.69, 'address': 'Ottawa A'},
      'destination': {
        'latitude': 45.43,
        'longitude': -75.70,
        'address': 'Ottawa B'
      },
    };

Map<String, dynamic> fixture({DateTime? created}) {
  final time = created ?? DateTime.utc(2026, 10, 3, 12);
  return {
    'id': 'a' * 64,
    'fingerprint': 'b' * 64,
    'pricingRevision': 'c' * 64,
    'protocol': 1,
    'request': trip(),
    'route': {
      'provider': 'mapbox',
      'profile': 'driving',
      'distanceMeters': 4500.0,
      'durationSeconds': 600.0
    },
    'fare': {'total': 12.35},
    'amountMinor': 1235,
    'currency': 'usd',
    'createdAt': time.toIso8601String(),
    'expiresAt': time.add(const Duration(seconds: 120)).toIso8601String(),
    'serverTime': time.toIso8601String(),
    'bookingSupported': false,
  };
}

void main() {
  final time = DateTime.utc(2026, 10, 3, 12);
  BookingQuote parse(Map<String, dynamic> value) => BookingQuote.fromJson(value,
      now: () => time, elapsed: () => Duration.zero);

  test('parses non-bookable immutable server quote without recalculating price',
      () {
    final quote = parse(fixture());
    expect(quote.amountMinor, 1235);
    expect(quote.currency, 'usd');
    expect(quote.bookingSupported, false);
    expect(quote.remaining, const Duration(seconds: 120));
    expect(quote.matchesRequest(trip()), true);
    expect(() => quote.request['vehicleType'] = 'xl', throwsUnsupportedError);
    expect(
        () => (quote.request['pickup'] as Map).clear(), throwsUnsupportedError);
  });

  for (final entry in <String, dynamic>{
    'protocol': 1.0,
    'id': 'wrong',
    'fingerprint': null,
    'pricingRevision': 'wrong',
    'currency': 'cad',
    'amountMinor': 1235.0,
    'bookingSupported': true,
    'expiresAt': '2026-10-03T12:03:00Z',
    'serverTime': '2026-10-03T11:59:00Z',
    'createdAt': '2026-10-03T12:00:00',
  }.entries) {
    test('rejects invalid ${entry.key}', () {
      final value = fixture()..[entry.key] = entry.value;
      expect(() => parse(value), throwsFormatException);
    });
  }
  test(
      'rejects price mismatch, unsafe routing, invalid points and client fares',
      () {
    var value = fixture();
    (value['fare'] as Map)['total'] = 1.0;
    expect(() => parse(value), throwsFormatException);
    value = fixture();
    (value['route'] as Map)['profile'] = 'cycling';
    expect(() => parse(value), throwsFormatException);
    value = fixture();
    (value['route'] as Map)['distanceMeters'] = double.nan;
    expect(() => parse(value), throwsFormatException);
    value = fixture();
    ((value['request'] as Map)['pickup'] as Map)['latitude'] = 91;
    expect(() => parse(value), throwsFormatException);
    expect(() => BookingQuote.canonicalRequest(trip()..['total'] = 1),
        throwsFormatException);
  });
  test('expiry cannot extend after clock rollback or replay', () {
    var wall = time;
    var elapsed = Duration.zero;
    final quote = BookingQuote.fromJson(fixture(),
        now: () => wall, elapsed: () => elapsed);
    elapsed = const Duration(seconds: 60);
    wall = time.subtract(const Duration(hours: 1));
    expect(quote.remaining, const Duration(seconds: 60));
    quote.retainEarlierDeadline(parse(fixture()));
    expect(quote.remaining, const Duration(seconds: 60));
    elapsed = const Duration(seconds: 121);
    expect(quote.remaining, Duration.zero);
    quote.retainEarlierDeadline(parse(fixture()));
    expect(quote.remaining, Duration.zero);
  });
  test('server expiry, network delay and ahead clock only shorten deadline',
      () {
    expect(
        BookingQuote.fromJson(fixture(),
                now: () => time,
                elapsed: () => Duration.zero,
                requestDuration: const Duration(seconds: 20))
            .remaining,
        const Duration(seconds: 100));
    expect(
        BookingQuote.fromJson(fixture(),
            now: () => time.add(const Duration(minutes: 3))).remaining,
        Duration.zero);
    final value = fixture()
      ..['serverTime'] = time.add(const Duration(minutes: 3)).toIso8601String();
    expect(parse(value).remaining, Duration.zero);
  });
  test('same identity cannot change immutable evidence', () {
    final original = parse(fixture());
    final changed = fixture()..['fingerprint'] = 'd' * 64;
    expect(() => original.retainEarlierDeadline(parse(changed)),
        throwsFormatException);
  });

  group('service', () {
    late Dio dio;
    late Object? session;
    late BookingQuoteService service;
    late List<RequestOptions> requests;
    late Future<Map<String, dynamic>> Function(RequestOptions) respond;
    late Map<String, dynamic> quote;
    setUp(() {
      session = Object();
      requests = [];
      quote = fixture(created: DateTime.now().toUtc());
      dio = Dio(BaseOptions(baseUrl: 'https://example.test/passenger'));
      service = BookingQuoteService(dio: dio, sessionReader: () => session);
      respond = (_) async => jsonDecode(jsonEncode(quote));
      dio.interceptors
          .add(InterceptorsWrapper(onRequest: (options, handler) async {
        requests.add(options);
        handler
            .resolve(Response(requestOptions: options, statusCode: 200, data: {
          'success': true,
          'data': {'quote': await respond(options)}
        }));
      }));
    });
    tearDown(() {
      service.dispose();
      dio.close(force: true);
    });

    test(
        'issue and get never call booking or payment and replay retains object',
        () async {
      final first = await service.issue(trip(), 'key');
      final remaining = first.remaining;
      final replay = await service.get(first.id);
      expect(identical(first, replay), true);
      expect(replay.remaining <= remaining, true);
      expect(requests.map((e) => e.path),
          ['/ride-quotes', '/ride-quotes/${first.id}']);
      expect(requests.first.headers['Idempotency-Key'], 'key');
      expect(requests.first.data, trip());
      expect(first.bookingSupported, false);
    });
    test('wrong trip and read identity fail without a booking fallback',
        () async {
      (quote['request'] as Map)['vehicleType'] = 'xl';
      await expectLater(service.issue(trip(), 'key'), throwsFormatException);
      await expectLater(service.get('d' * 64), throwsFormatException);
      expect(requests.every((r) => r.path.startsWith('/ride-quotes')), true);
    });
    test('same key cannot change quote identity', () async {
      await service.issue(trip(), 'key');
      quote['id'] = 'd' * 64;
      await expectLater(service.issue(trip(), 'key'), throwsFormatException);
    });
    test('logout or account switch fences late responses', () async {
      final waiting = Completer<Map<String, dynamic>>();
      respond = (_) => waiting.future;
      final request = service.issue(trip(), 'key');
      await Future<void>.delayed(Duration.zero);
      session = Object();
      final check = expectLater(request, throwsStateError);
      waiting.complete(quote);
      await check;
    });
    test('signed out and disposed services make no requests', () async {
      session = null;
      await expectLater(service.issue(trip(), 'key'), throwsStateError);
      session = Object();
      service.dispose();
      await expectLater(service.issue(trip(), 'key'), throwsStateError);
      expect(requests, isEmpty);
    });
    test('invalid key and unknown authority fields make no request', () {
      expect(() => service.issue(trip(), ''), throwsArgumentError);
      expect(() => service.issue(trip()..['fare'] = 0, 'key'),
          throwsFormatException);
      expect(requests, isEmpty);
    });
  });
}
