import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/services/regional_disclosure_service.dart';
import 'fixtures/regional_disclosure.dart';
import 'session_request_test.dart' show TestAdapter;

ResponseBody response(Object? data, {int status = 200}) =>
    ResponseBody.fromString(jsonEncode(data), status, headers: {
      Headers.contentTypeHeader: ['application/json']
    });

void main() {
  late RegionalDisclosureService service;
  late String root;
  late List<RequestOptions> requests;
  late Future<ResponseBody> Function(RequestOptions) respond;
  setUp(() {
    root = 'https://example.test/api';
    requests = [];
    respond =
        (_) async => response({'success': true, 'data': regionalDisclosure()});
    service = RegionalDisclosureService(
        apiRootReader: () => root,
        adapter: TestAdapter((request) async {
          requests.add(request);
          return respond(request);
        }));
  });
  tearDown(() => service.dispose());
  Future<DisclosureObservation> load() => service.load(
      marketId: 'ON-ottawa', locale: 'en-CA', expectedPolicyVersion: 2);
  test(
      'anonymous no-store GET stays on configured root and does not follow redirects',
      () async {
    final result = await load();
    expect(result.isFresh, isTrue);
    expect(result.remaining, lessThan(const Duration(seconds: 30)));
    final r = requests.single;
    expect(r.uri.toString(),
        'https://example.test/api/public/regional-disclosures/ON-ottawa?locale=en-CA');
    expect(r.method, 'GET');
    expect(r.followRedirects, isFalse);
    expect(r.headers['Cache-Control'], 'no-store');
    expect(r.headers.keys.map((k) => k.toLowerCase()),
        isNot(contains('authorization')));
    expect(
        r.headers.keys.map((k) => k.toLowerCase()), isNot(contains('cookie')));
    expect(r.data, isNull);
  });
  test('market discovery forwards exact locale and cursor', () async {
    respond = (_) async => response(
        {'success': true, 'data': regionalMarketPage(locale: 'fr-CA')});
    final result =
        await service.markets(locale: 'fr-CA', after: 'AB-calgary:en-CA');
    expect(result.data.items.single.marketId, 'ON-ottawa');
    expect(requests.single.uri.path, '/api/public/regional-disclosure-markets');
    expect(requests.single.queryParameters,
        {'locale': 'fr-CA', 'after': 'AB-calgary:en-CA'});
  });
  test('bad input is blocked before network and never guesses locale',
      () async {
    await expectLater(service.load(marketId: '../audit', locale: 'en-CA'),
        throwsFormatException);
    await expectLater(service.load(marketId: 'ON-ottawa', locale: 'en'),
        throwsFormatException);
    await expectLater(
        service.load(
            marketId: 'ON-ottawa', locale: 'en-CA', expectedPolicyVersion: -1),
        throwsFormatException);
    await expectLater(service.markets(locale: 'fr'), throwsFormatException);
    await expectLater(service.markets(locale: 'en-CA', after: 'private'),
        throwsFormatException);
    expect(requests, isEmpty);
  });
  test('explicit unavailable has no fallback or automatic retry', () async {
    respond = (_) async => response(
        {'success': false, 'code': 'DISCLOSURE_UNAVAILABLE'},
        status: 409);
    await expectLater(load(), throwsA(isA<DisclosureUnavailable>()));
    expect(requests, hasLength(1));
  });
  for (final status in [301, 400, 401, 404, 409, 500, 503]) {
    test('HTTP $status is not fabricated content or translation', () async {
      respond = (_) async =>
          response({'success': false, 'code': 'OTHER'}, status: status);
      await expectLater(load(), throwsA(isA<DioException>()));
      expect(requests, hasLength(1));
    });
  }
  for (final raw in [
    null,
    [],
    {'success': false, 'data': regionalDisclosure()},
    {'success': true, 'data': null}
  ]) {
    test('invalid envelope $raw', () async {
      respond = (_) async => response(raw);
      await expectLater(load(), throwsFormatException);
    });
  }
  test('revised policy is rejected even with a valid new content digest',
      () async {
    final data = regionalDisclosure()..['policyVersion'] = 3;
    sealDisclosure(data);
    respond = (_) async => response({'success': true, 'data': data});
    await expectLater(load(), throwsFormatException);
  });
  test('elapsed network time consumes freshness independently of device date',
      () async {
    final data = regionalDisclosure()
      ..['refreshAfter'] = '2026-10-18T12:00:00.001Z';
    respond = (_) async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return response({'success': true, 'data': data});
    };
    await expectLater(load(), throwsA(isA<DisclosureReadEnded>()));
  });
  for (final change in ['cancel', 'dispose', 'backend']) {
    void mutate() {
      switch (change) {
        case 'cancel':
          service.cancelRequests();
        case 'dispose':
          service.dispose();
        case 'backend':
          root = 'https://other.test';
      }
    }

    test('$change invalidates observed content', () async {
      final result = await load();
      mutate();
      expect(result.isFresh, isFalse);
    });
    test('$change rejects a late response', () async {
      respond = (_) async {
        mutate();
        return response({'success': true, 'data': regionalDisclosure()});
      };
      await expectLater(load(), throwsA(isA<DisclosureReadEnded>()));
    });
  }
  test(
      'cancellation allows a new independent read without reviving old content',
      () async {
    final old = await load();
    service.cancelRequests();
    final fresh = await load();
    expect(old.isFresh, isFalse);
    expect(fresh.isFresh, isTrue);
  });
  test('disposed or reconfigured client cannot dispatch', () async {
    root = 'https://other.test';
    await expectLater(load(), throwsA(isA<DisclosureReadEnded>()));
    service.dispose();
    await expectLater(load(), throwsA(isA<DisclosureReadEnded>()));
    expect(requests, isEmpty);
  });
  test('returning to an old backend cannot revive an invalidated observation',
      () async {
    final old = await load();
    final originalRoot = root;
    root = 'https://other.test';
    expect(old.isFresh, isFalse);
    root = originalRoot;
    expect(old.isFresh, isFalse);
    await expectLater(load(), throwsA(isA<DisclosureReadEnded>()));
    expect(requests, hasLength(1));
  });
  test('market page cancellation rejects late data and does not auto-page',
      () async {
    respond = (_) async {
      service.cancelRequests();
      return response({'success': true, 'data': regionalMarketPage()});
    };
    await expectLater(
        service.markets(locale: 'en-CA'), throwsA(isA<DisclosureReadEnded>()));
    expect(requests, hasLength(1));
  });
  test('a filtered empty market page is returned without scanning more pages',
      () async {
    final page = regionalMarketPage()
      ..['items'] = []
      ..['nextAfter'] = 'ON-ottawa:fr-CA';
    respond = (_) async => response({'success': true, 'data': page});
    final result = await service.markets(locale: 'en-CA');
    expect(result.data.items, isEmpty);
    expect(result.data.nextAfter, 'ON-ottawa:fr-CA');
    expect(requests, hasLength(1));
  });
  test('unsafe transport roots are rejected at construction', () {
    for (final url in [
      'file:///tmp/a',
      'https://user:secret@example.test',
      'https://example.test?token=x',
      'https://example.test#x'
    ]) {
      expect(() => RegionalDisclosureService(apiRootReader: () => url),
          throwsFormatException);
    }
  });
}
