import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart';
import 'package:ridzs_passenger_app/models/ride_disclosure.dart';
import 'package:ridzs_passenger_app/services/ride_disclosure_service.dart';
import 'fixtures/ride_disclosure.dart';

void main() {
  RideDisclosure parse(Object? data, {String locale = 'en-CA'}) =>
      RideDisclosure.parse(data, rideId: 'ride-a', locale: locale);
  test(
      'archive may be expired now and uses the exact shared Java Unicode digest',
      () {
    final result = parse(rideDisclosure());
    expect(result.contentHash,
        '60c084fedd431c53104e659311d4de061719ca6bfa7b0e5a6c194aa7f0c2ea51');
    expect(result.validUntil.isBefore(result.serverTime), isTrue);
    expect(result.capturedAt.isBefore(result.validUntil), isTrue);
    expect(result.sections, hasLength(4));
    expect(() => result.sections.clear(), throwsUnsupportedError);
  });
  for (final province in [
    'ON',
    'AB',
    'BC',
    'SK',
    'MB',
    'QC',
    'NB',
    'NS',
    'PE',
    'NL'
  ]) {
    test('historical context supports $province without current approval', () {
      final data = rideDisclosure();
      data['marketId'] = '$province-synthetic';
      data['province'] = province;
      data['municipality'] = 'synthetic';
      sealRideDisclosure(data);
      expect(parse(data).marketId, '$province-synthetic');
    });
  }
  final invalid = <String, Object?>{
    'protocol': 1.0,
    'scope': 'regional_disclosure',
    'audience': 'driver_agreement',
    'rideId': 'ride-b',
    'marketId': 'ZZ-ottawa',
    'policyVersion': 2.0,
    'province': 'AB',
    'municipality': 'toronto',
    'locale': 'fr-CA',
    'contentVersion': 'not-a-version',
    'contentHash': 'a' * 64,
    'capturedAt': '2026-10-20T12:00:00Z',
    'effectiveFrom': '2026-10-18T12:00:00.001Z',
    'validUntil': '2026-10-18T12:00:00Z',
    'serverTime': '2026-02-30T12:00:00Z',
    'refreshAfter': '2026-10-19T12:00:31Z',
    'operatorName': '',
    'sections': [],
    'reviewedBy': 'private',
    'acceptedAt': 'not-consent'
  };
  for (final entry in invalid.entries) {
    test('rejects malformed or mismatched ${entry.key}', () {
      expect(() => parse({...rideDisclosure(), entry.key: entry.value}),
          throwsFormatException);
    });
  }
  for (final field in rideDisclosure().keys) {
    test('requires exact field $field', () {
      final data = rideDisclosure()..remove(field);
      expect(() => parse(data), throwsFormatException);
    });
  }
  for (final fault in [
    'wrong-order',
    'duplicate',
    'unknown-field',
    'oversized',
    'control',
    'changed',
    'aggregate'
  ]) {
    test('rejects section fault $fault', () {
      final data = rideDisclosure();
      final sections = data['sections'] as List;
      switch (fault) {
        case 'wrong-order':
          sections[0]['kind'] = 'support';
        case 'duplicate':
          sections[1] = sections[0];
        case 'unknown-field':
          sections[0]['reviewer'] = 'private';
        case 'oversized':
          sections[0]['body'] = 'x' * 50001;
        case 'control':
          sections[0]['body'] = 'bad\u0000text';
        case 'changed':
          sections[0]['body'] = 'Unreviewed';
        case 'aggregate':
          for (final section in sections) {
            section['body'] = 'x' * 30000;
          }
      }
      expect(() => parse(data), throwsFormatException);
    });
  }
  test('missing French never becomes English', () {
    expect(
        () => parse(rideDisclosure(), locale: 'fr-CA'), throwsFormatException);
    expect(parse(rideDisclosure(locale: 'fr-CA'), locale: 'fr-CA').locale,
        'fr-CA');
  });
  test('capture window and freshness remain strict even with a correct digest',
      () {
    for (final change in [
      {'validUntil': '2026-10-18T12:00:00Z'},
      {'effectiveFrom': '2026-10-18T12:00:00.001Z'},
      {'refreshAfter': '2026-10-19T12:00:00Z'},
      {'policyVersion': 9007199254740991},
      {'capturedAt': '1969-01-01T00:00:00Z'},
    ]) {
      final data = {...rideDisclosure(), ...change};
      sealRideDisclosure(data);
      expect(() => parse(data), throwsFormatException);
    }
  });

  late RideDocumentHarness h;
  late RideDisclosureService service;
  setUp(() {
    h = RideDocumentHarness();
    service = h.create();
  });
  tearDown(() {
    service.dispose();
    h.close();
  });
  test(
      'GET pins original actor, ride, language, backend and no-store transport',
      () async {
    final snapshot = await service.load('en-CA');
    expect(snapshot.isFresh, isTrue);
    final request = h.requests.single;
    expect(request.uri.path, '/passenger/rides/ride-a/regional-disclosure');
    expect(request.method, 'GET');
    expect(request.queryParameters, {'locale': 'en-CA'});
    expect(request.headers['Authorization'], 'Bearer ${h.token}');
    expect(request.headers['Cache-Control'], 'no-store');
    expect(request.followRedirects, isFalse);
    expect(request.extra['expectedAuthSessionEpoch'], 0);
    service.cancelRequests();
    expect(snapshot.isFresh, isFalse);
  });
  for (final mutation in [
    'owner',
    'ride',
    'token',
    'backend',
    'logout',
    'interceptor',
    'invalidate'
  ]) {
    void mutate() {
      switch (mutation) {
        case 'owner':
          runInAction(() => h.owner.value = 'owner-b');
        case 'ride':
          runInAction(() => h.rideCurrent.value = false);
        case 'token':
          h.token = rideDocumentToken('owner-a');
          h.token = '${h.token}changed';
        case 'backend':
          h.dio.options.baseUrl = 'https://other.test';
        case 'logout':
          h.auth.endSession();
        case 'interceptor':
          h.dio.interceptors.clear();
        case 'invalidate':
          service.invalidate();
      }
    }

    test('$mutation before request prevents transport', () async {
      // Resolve the original token before changing it.
      await Future<void>.delayed(Duration.zero);
      mutate();
      await expectLater(
          service.load('en-CA'), throwsA(isA<RideDisclosureSessionEnded>()));
      expect(h.requests, isEmpty);
    });
    test('$mutation discards a delayed reply', () async {
      final pending = Completer<ResponseBody>();
      h.respond = (_) => pending.future;
      final future = service.load('en-CA');
      final assertion =
          expectLater(future, throwsA(isA<RideDisclosureSessionEnded>()));
      for (var i = 0; i < 50 && h.requests.isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
      expect(h.requests, hasLength(1));
      mutate();
      pending.complete(documentResponse(rideDisclosure()));
      await assertion;
    });
  }
  for (final status in [401, 403, 404]) {
    test('HTTP $status ends participant session without fallback', () async {
      h.respond = (_) async => documentResponse(null, status: status);
      await expectLater(
          service.load('en-CA'), throwsA(isA<RideDisclosureSessionEnded>()));
      expect(service.isCurrent, isFalse);
      expect(h.requests, hasLength(1));
    });
  }
  test('missing translation permits another exact locale read, not fallback',
      () async {
    h.respond = (_) async => missingDocument();
    await expectLater(
        service.load('fr-CA'), throwsA(isA<RideDisclosureUnavailable>()));
    expect(service.isCurrent, isTrue);
    expect(h.requests, hasLength(1));
    h.respond = (_) async => documentResponse(rideDisclosure());
    expect((await service.load('en-CA')).data.locale, 'en-CA');
  });
  test('invalid locale never reaches transport', () async {
    await expectLater(service.load('fr'), throwsFormatException);
    expect(h.requests, isEmpty);
  });
  test('wrong JWT role cannot access participant documents', () async {
    h.token = rideDocumentToken('owner-a', role: 'ADMIN');
    await expectLater(
        service.load('en-CA'), throwsA(isA<RideDisclosureSessionEnded>()));
    expect(h.requests, isEmpty);
  });
  test('storage outage is not an empty successful read or automatic retry',
      () async {
    h.respond = (_) async => documentResponse(null, status: 503);
    await expectLater(service.load('en-CA'), throwsA(isA<DioException>()));
    expect(h.requests, hasLength(1));
    expect(service.isCurrent, isTrue);
  });
  test('elapsed request time consumes observation freshness', () async {
    h.respond = (_) async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
      return documentResponse(
          {...rideDisclosure(), 'refreshAfter': '2026-10-19T12:00:00.001Z'});
    };
    await expectLater(service.load('en-CA'), throwsFormatException);
  });
}
