import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Passenger information only. Neither discovery nor a read grants ride authority.
class DisclosureMarket {
  const DisclosureMarket._(this.marketId, this.policyVersion, this.province,
      this.municipality, this.marketName);
  final String marketId, province, municipality, marketName;
  final int policyVersion;

  static DisclosureMarket parse(Object? value) {
    final data = _fields(value, const {
      'marketId',
      'policyVersion',
      'province',
      'municipality',
      'marketName'
    });
    return _from(data);
  }

  static DisclosureMarket _from(Map data) {
    final market = data['marketId'];
    final version = data['policyVersion'];
    if (!validId(market) ||
        data['province'] != (market as String).substring(0, 2) ||
        data['municipality'] != market.substring(3) ||
        version is! int ||
        version < 0 ||
        version > 9007199254740991) {
      throw const FormatException('Invalid regional market');
    }
    return DisclosureMarket._(market, version, data['province'] as String,
        data['municipality'] as String, _text(data['marketName'], 120));
  }

  static bool validId(Object? value) =>
      value is String &&
      RegExp(r'^(AB|BC|MB|NB|NL|NS|ON|PE|QC|SK)-[a-z][a-z0-9-]{1,79}$')
          .hasMatch(value);
  static bool validLocale(Object? value) =>
      const ['en-CA', 'fr-CA'].contains(value);
  static bool validCursor(Object? value) {
    if (value is! String) return false;
    final parts = value.split(':');
    return parts.length == 2 && validId(parts[0]) && validLocale(parts[1]);
  }
}

class DisclosureMarketPage {
  const DisclosureMarketPage._(this.locale, this.serverTime, this.refreshAfter,
      this.items, this.nextAfter);
  final String locale;
  final DateTime serverTime, refreshAfter;
  final List<DisclosureMarket> items;
  final String? nextAfter;

  static DisclosureMarketPage parse(Object? value,
      {required String locale, String? after}) {
    final data = _fields(value, const {
      'protocol',
      'scope',
      'locale',
      'serverTime',
      'refreshAfter',
      'items'
    }, optional: const {
      'nextAfter'
    });
    if (!DisclosureMarket.validLocale(locale) ||
        after != null && !DisclosureMarket.validCursor(after) ||
        data['protocol'] is! int ||
        data['protocol'] != 1 ||
        data['scope'] != 'regional_disclosure_markets' ||
        data['locale'] != locale ||
        data['items'] is! List ||
        (data['items'] as List).length > 20) {
      throw const FormatException('Invalid regional market page');
    }
    final now = _instant(data['serverTime']);
    final refresh = _instant(data['refreshAfter']);
    _deadline(now, refresh);
    final next = data['nextAfter'];
    if (next != null &&
        (!DisclosureMarket.validCursor(next) ||
            after != null && (next as String).compareTo(after) <= 0)) {
      throw const FormatException('Invalid regional market cursor');
    }
    final items = <DisclosureMarket>[];
    String? previous = after;
    for (final raw in data['items'] as List) {
      final market = DisclosureMarket.parse(raw);
      final key = '${market.marketId}:$locale';
      if (previous != null && key.compareTo(previous) <= 0 ||
          next != null && key.compareTo(next as String) > 0) {
        throw const FormatException('Unordered regional market page');
      }
      previous = key;
      items.add(market);
    }
    return DisclosureMarketPage._(
        locale, now, refresh, List.unmodifiable(items), next as String?);
  }
}

class DisclosureSection {
  const DisclosureSection._(this.kind, this.title, this.body);
  final String kind, title, body;
}

class RegionalDisclosure {
  const RegionalDisclosure._(
      this.market,
      this.locale,
      this.contentVersion,
      this.contentHash,
      this.effectiveFrom,
      this.validUntil,
      this.serverTime,
      this.refreshAfter,
      this.operatorName,
      this.sections);
  final DisclosureMarket market;
  final String locale, contentVersion, contentHash, operatorName;
  final DateTime effectiveFrom, validUntil, serverTime, refreshAfter;
  final List<DisclosureSection> sections;
  static const sectionKinds = [
    'terms',
    'privacy',
    'ride_information',
    'support'
  ];

  static RegionalDisclosure parse(Object? value,
      {required String marketId,
      required String locale,
      int? expectedPolicyVersion}) {
    final data = _fields(value, const {
      'protocol',
      'scope',
      'marketId',
      'policyVersion',
      'province',
      'municipality',
      'marketName',
      'locale',
      'contentVersion',
      'contentHash',
      'effectiveFrom',
      'validUntil',
      'serverTime',
      'refreshAfter',
      'operatorName',
      'sections'
    });
    if (!DisclosureMarket.validId(marketId) ||
        !DisclosureMarket.validLocale(locale) ||
        data['protocol'] is! int ||
        data['protocol'] != 1 ||
        data['scope'] != 'regional_disclosure' ||
        data['marketId'] != marketId ||
        data['locale'] != locale ||
        expectedPolicyVersion != null &&
            data['policyVersion'] != expectedPolicyVersion ||
        data['contentVersion'] is! String ||
        !RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')
            .hasMatch(data['contentVersion'] as String) ||
        data['contentHash'] is! String ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(data['contentHash'] as String) ||
        data['sections'] is! List ||
        (data['sections'] as List).length != 4) {
      throw const FormatException('Invalid regional disclosure');
    }
    final market = DisclosureMarket._from(data);
    final from = _instant(data['effectiveFrom']);
    final until = _instant(data['validUntil']);
    final now = _instant(data['serverTime']);
    final refresh = _instant(data['refreshAfter']);
    _deadline(now, refresh);
    if (from.isAfter(now) || !until.isAfter(now) || refresh.isAfter(until)) {
      throw const FormatException('Unavailable regional disclosure');
    }
    final operator = _text(data['operatorName'], 200);
    final sections = <DisclosureSection>[];
    var length = 0;
    for (var i = 0; i < sectionKinds.length; i++) {
      final section = _fields(
          (data['sections'] as List)[i], const {'kind', 'title', 'body'});
      if (section['kind'] != sectionKinds[i]) {
        throw const FormatException('Invalid regional section order');
      }
      final title = _text(section['title'], 160);
      final body = _text(section['body'], 50000);
      length += body.length;
      sections.add(DisclosureSection._(sectionKinds[i], title, body));
    }
    if (length > 100000) {
      throw const FormatException('Oversized regional disclosure');
    }
    final canonical = [
      1,
      marketId,
      market.policyVersion,
      locale,
      data['contentVersion'],
      _javaInstant(from),
      _javaInstant(until),
      operator,
      sections.map((s) => [s.kind, s.title, s.body]).toList()
    ];
    // Jackson's UTF-8 generator escapes supplementary UTF-16 code units.
    final encoded = jsonEncode(canonical).replaceAllMapped(
        RegExp(r'[\uD800-\uDFFF]'),
        (m) => '\\u${m[0]!.codeUnitAt(0).toRadixString(16).toUpperCase()}');
    final hash = sha256.convert(utf8.encode(encoded)).toString();
    if (hash != data['contentHash']) {
      throw const FormatException('Regional disclosure changed');
    }
    return RegionalDisclosure._(
        market,
        locale,
        data['contentVersion'] as String,
        hash,
        from,
        until,
        now,
        refresh,
        operator,
        List.unmodifiable(sections));
  }
}

Map _fields(Object? value, Set<String> required,
    {Set<String> optional = const {}}) {
  if (value is! Map ||
      !value.keys.toSet().containsAll(required) ||
      value.keys.any((k) => !required.contains(k) && !optional.contains(k))) {
    throw const FormatException('Invalid regional information fields');
  }
  return value;
}

String _text(Object? value, int max) {
  if (value is! String ||
      value.trim().isEmpty ||
      value.length > max ||
      value.runes
          .any((c) => (c < 32 || c >= 127 && c <= 159) && c != 9 && c != 10)) {
    throw const FormatException('Invalid regional information text');
  }
  return value;
}

DateTime _instant(Object? value) {
  if (value is! String ||
      !RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{3})?Z$')
          .hasMatch(value)) {
    throw const FormatException('Invalid regional information time');
  }
  final time = DateTime.tryParse(value);
  if (time == null ||
      time.toIso8601String() !=
          (value.contains('.') ? value : value.replaceFirst('Z', '.000Z'))) {
    throw const FormatException('Invalid regional information time');
  }
  return time;
}

String _javaInstant(DateTime time) =>
    time.toIso8601String().replaceFirst('.000Z', 'Z');

void _deadline(DateTime now, DateTime refresh) {
  if (!refresh.isAfter(now) ||
      refresh.difference(now) > const Duration(seconds: 30)) {
    throw const FormatException('Invalid regional information deadline');
  }
}
