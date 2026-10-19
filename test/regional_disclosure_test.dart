import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/models/regional_disclosure.dart';
import 'fixtures/regional_disclosure.dart';

RegionalDisclosure parse(Object? raw) => RegionalDisclosure.parse(raw,
    marketId: 'ON-ottawa', locale: 'en-CA', expectedPolicyVersion: 2);

void main() {
  test('exact reviewed bundle verifies ordered canonical hash and milliseconds',
      () {
    final data = parse(regionalDisclosure());
    expect(data.market.marketId, 'ON-ottawa');
    expect(data.sections.map((s) => s.kind), RegionalDisclosure.sectionKinds);
    expect(data.validUntil.millisecond, 123);
    expect(data.contentHash,
        '60c084fedd431c53104e659311d4de061719ca6bfa7b0e5a6c194aa7f0c2ea51');
    expect(data.sections.first.body, contains('\u00e9 \uD83D\uDE80'));
    expect(() => data.sections.clear(), throwsUnsupportedError);
  });
  for (final province in [
    'AB',
    'BC',
    'MB',
    'NB',
    'NL',
    'NS',
    'ON',
    'PE',
    'QC',
    'SK'
  ]) {
    test('server context and exact French document for $province', () {
      final id = '$province-synthetic';
      final result = RegionalDisclosure.parse(
          regionalDisclosure(id: id, locale: 'fr-CA'),
          marketId: id,
          locale: 'fr-CA');
      expect(result.market.province, province);
      expect(result.locale, 'fr-CA');
    });
  }
  final invalid = <String, Object?>{
    'protocol': 1.0,
    'scope': 'driver_agreement',
    'marketId': 'AB-calgary',
    'policyVersion': 3,
    'province': 'AB',
    'municipality': 'toronto',
    'marketName': '',
    'locale': 'fr-CA',
    'contentVersion': 'invalid',
    'contentHash': 'a' * 64,
    'effectiveFrom': '2026-10-18T12:00:01Z',
    'validUntil': '2026-10-18T12:00:00Z',
    'serverTime': '2026-02-30T12:00:00Z',
    'refreshAfter': '2026-10-18T12:00:31Z',
    'operatorName': 'Changed unreviewed',
    'sections': [],
    'reviewedBy': 'private',
  };
  for (final entry in invalid.entries) {
    test('rejects invalid or changed ${entry.key}', () {
      expect(() => parse({...regionalDisclosure(), entry.key: entry.value}),
          throwsFormatException);
    });
  }
  test('every required disclosure field is mandatory', () {
    for (final field in regionalDisclosure().keys) {
      final data = regionalDisclosure()..remove(field);
      expect(() => parse(data), throwsFormatException, reason: field);
    }
  });
  for (final instant in [
    '2026-10-18T12:00:00',
    '2026-10-18T12:00:00+00:00',
    '2026-10-18T12:00:00.123456Z',
    '2026-10-18T25:00:00Z',
    '2026-13-18T12:00:00Z'
  ]) {
    test('rejects non-contract instant $instant', () {
      expect(() => parse({...regionalDisclosure(), 'serverTime': instant}),
          throwsFormatException);
    });
  }
  test('zero lifetime, expiry before refresh and section order fail closed',
      () {
    expect(
        () => parse(
            {...regionalDisclosure(), 'refreshAfter': '2026-10-18T12:00:00Z'}),
        throwsFormatException);
    final early = regionalDisclosure()..['validUntil'] = '2026-10-18T12:00:20Z';
    sealDisclosure(early);
    expect(() => parse(early), throwsFormatException);
    final order = regionalDisclosure();
    order['sections'] = (order['sections'] as List).reversed.toList();
    sealDisclosure(order);
    expect(() => parse(order), throwsFormatException);
  });
  for (final body in [
    '',
    ' ',
    'bad\u0000control',
    'bad\u0085control',
    'a' * 50001
  ]) {
    test('invalid section text length ${body.length}', () {
      final data = regionalDisclosure();
      data['sections'][0]['body'] = body;
      sealDisclosure(data);
      expect(() => parse(data), throwsFormatException);
    });
  }
  test('aggregate body bound and extra section fields are enforced', () {
    final data = regionalDisclosure();
    for (final section in data['sections']) {
      section['body'] = 'a' * 25001;
    }
    sealDisclosure(data);
    expect(() => parse(data), throwsFormatException);
    final extra = regionalDisclosure();
    extra['sections'][0]['html'] = '<script>';
    expect(() => parse(extra), throwsFormatException);
  });
  test('unsafe or fractional revisions cannot be accepted', () {
    for (final revision in [-1, 2.0, 9007199254740992]) {
      final data = regionalDisclosure()..['policyVersion'] = revision;
      sealDisclosure(data);
      expect(
          () => RegionalDisclosure.parse(data,
              marketId: 'ON-ottawa', locale: 'en-CA'),
          throwsFormatException);
    }
  });
  test('HTML-looking reviewed text remains plain model text', () {
    final data = regionalDisclosure();
    data['sections'][0]['body'] = '<script>alert(1)</script>';
    sealDisclosure(data);
    expect(parse(data).sections.first.body, '<script>alert(1)</script>');
  });
  test('empty filtered pages keep server cursor without guessed markets', () {
    final raw = regionalMarketPage()
      ..['items'] = []
      ..['nextAfter'] = 'ON-ottawa:fr-CA';
    final page = DisclosureMarketPage.parse(raw, locale: 'en-CA');
    expect(page.items, isEmpty);
    expect(page.nextAfter, 'ON-ottawa:fr-CA');
    expect(() => page.items.clear(), throwsUnsupportedError);
  });
  test('terminal page supports omitted and null optional cursor', () {
    for (final raw in [
      regionalMarketPage(),
      {...regionalMarketPage(), 'nextAfter': null}
    ]) {
      expect(
          DisclosureMarketPage.parse(raw, locale: 'en-CA').nextAfter, isNull);
    }
  });
  final badPages = <String, Object?>{
    'protocol': 1.0,
    'scope': 'market_eligibility',
    'locale': 'fr-CA',
    'serverTime': '2026-02-30T00:00:00Z',
    'refreshAfter': '2026-10-18T12:00:31Z',
    'items': List.generate(21, (_) => regionalMarket()),
    'nextAfter': '../audit',
    'secret': 'private',
  };
  for (final entry in badPages.entries) {
    test('rejects malformed market page ${entry.key}', () {
      expect(
          () => DisclosureMarketPage.parse(
              {...regionalMarketPage(), entry.key: entry.value},
              locale: 'en-CA'),
          throwsFormatException);
    });
  }
  test('duplicate, unordered, past-cursor or out-of-range markets are rejected',
      () {
    for (final items in [
      [regionalMarket(), regionalMarket()],
      [regionalMarket(), regionalMarket(id: 'AB-calgary')],
      [
        {...regionalMarket(), 'operatorLicenceReference': 'private'}
      ],
    ]) {
      expect(
          () => DisclosureMarketPage.parse(
              {...regionalMarketPage(), 'items': items},
              locale: 'en-CA'),
          throwsFormatException);
    }
    expect(
        () => DisclosureMarketPage.parse(regionalMarketPage(),
            locale: 'en-CA', after: 'ON-ottawa:en-CA'),
        throwsFormatException);
    expect(
        () => DisclosureMarketPage.parse(
            {...regionalMarketPage(), 'nextAfter': 'AB-calgary:en-CA'},
            locale: 'en-CA'),
        throwsFormatException);
    expect(
        () => DisclosureMarketPage.parse({
              ...regionalMarketPage(),
              'items': [],
              'nextAfter': 'AB-calgary:en-CA'
            }, locale: 'en-CA', after: 'ON-ottawa:en-CA'),
        throwsFormatException);
  });
}
