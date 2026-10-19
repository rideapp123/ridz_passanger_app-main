import 'dart:convert';
import 'package:crypto/crypto.dart';

class RideDisclosureSection {
  const RideDisclosureSection(this.kind, this.title, this.body);
  final String kind, title, body;
}

/// An archived passenger document, not acceptance or current market authority.
class RideDisclosure {
  const RideDisclosure._(
      this.rideId,
      this.marketId,
      this.policyVersion,
      this.locale,
      this.contentVersion,
      this.contentHash,
      this.capturedAt,
      this.effectiveFrom,
      this.validUntil,
      this.serverTime,
      this.refreshAfter,
      this.operatorName,
      this.sections);
  final String rideId,
      marketId,
      locale,
      contentVersion,
      contentHash,
      operatorName;
  final int policyVersion;
  final DateTime capturedAt,
      effectiveFrom,
      validUntil,
      serverTime,
      refreshAfter;
  final List<RideDisclosureSection> sections;
  static const kinds = ['terms', 'privacy', 'ride_information', 'support'];

  static bool validRideId(String id) =>
      RegExp(r'^[A-Za-z0-9_-]{1,200}$').hasMatch(id);
  static bool validLocale(String locale) =>
      const ['en-CA', 'fr-CA'].contains(locale);

  static RideDisclosure parse(Object? raw,
      {required String rideId, required String locale}) {
    final data = _fields(raw, const {
      'protocol',
      'scope',
      'rideId',
      'audience',
      'marketId',
      'policyVersion',
      'province',
      'municipality',
      'locale',
      'contentVersion',
      'contentHash',
      'capturedAt',
      'effectiveFrom',
      'validUntil',
      'serverTime',
      'refreshAfter',
      'operatorName',
      'sections'
    });
    final market = data['marketId'];
    final version = data['policyVersion'];
    if (!validRideId(rideId) ||
        !validLocale(locale) ||
        data['protocol'] is! int ||
        data['protocol'] != 1 ||
        data['scope'] != 'ride_regional_disclosure' ||
        data['audience'] != 'passenger_information' ||
        data['rideId'] != rideId ||
        data['locale'] != locale ||
        market is! String ||
        !RegExp(r'^(AB|BC|MB|NB|NL|NS|ON|PE|QC|SK)-[a-z][a-z0-9-]{1,79}$')
            .hasMatch(market) ||
        data['province'] != market.substring(0, 2) ||
        data['municipality'] != market.substring(3) ||
        version is! int ||
        version < 0 ||
        version > 9007199254740990 ||
        data['contentVersion'] is! String ||
        !RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')
            .hasMatch(data['contentVersion'] as String) ||
        data['contentHash'] is! String ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(data['contentHash'] as String) ||
        data['sections'] is! List ||
        (data['sections'] as List).length != 4) {
      throw const FormatException('Invalid ride document');
    }
    final captured = _instant(data['capturedAt']);
    final from = _instant(data['effectiveFrom']);
    final until = _instant(data['validUntil']);
    final now = _instant(data['serverTime']);
    final refresh = _instant(data['refreshAfter']);
    // The publication window must cover capture, not today's historical read.
    if (captured
            .isBefore(DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)) ||
        captured.isAfter(now) ||
        from.isAfter(captured) ||
        !until.isAfter(captured) ||
        !refresh.isAfter(now) ||
        refresh.difference(now) > const Duration(seconds: 30)) {
      throw const FormatException('Invalid ride document dates');
    }
    final operator = _text(data['operatorName'], 200);
    final sections = <RideDisclosureSection>[];
    var length = 0;
    for (var i = 0; i < kinds.length; i++) {
      final section = _fields(
          (data['sections'] as List)[i], const {'kind', 'title', 'body'});
      if (section['kind'] != kinds[i]) {
        throw const FormatException('Invalid section order');
      }
      final title = _text(section['title'], 160);
      final body = _text(section['body'], 50000);
      length += body.length;
      sections.add(RideDisclosureSection(kinds[i], title, body));
    }
    if (length > 100000) throw const FormatException('Oversized ride document');
    final canonical = jsonEncode([
      1,
      market,
      version,
      locale,
      data['contentVersion'],
      from.toIso8601String().replaceFirst('.000Z', 'Z'),
      until.toIso8601String().replaceFirst('.000Z', 'Z'),
      operator,
      sections.map((s) => [s.kind, s.title, s.body]).toList()
    ]).replaceAllMapped(RegExp(r'[\uD800-\uDFFF]'),
        (m) => '\\u${m[0]!.codeUnitAt(0).toRadixString(16).toUpperCase()}');
    final hash = sha256.convert(utf8.encode(canonical)).toString();
    if (hash != data['contentHash']) {
      throw const FormatException('Ride document changed');
    }
    return RideDisclosure._(
        rideId,
        market,
        version,
        locale,
        data['contentVersion'] as String,
        hash,
        captured,
        from,
        until,
        now,
        refresh,
        operator,
        List.unmodifiable(sections));
  }
}

Map _fields(Object? value, Set<String> fields) {
  if (value is! Map ||
      value.length != fields.length ||
      !value.keys.toSet().containsAll(fields)) {
    throw const FormatException('Invalid ride document fields');
  }
  return value;
}

String _text(Object? value, int max) {
  if (value is! String ||
      value.trim().isEmpty ||
      value.length > max ||
      value.runes
          .any((c) => (c < 32 || c >= 127 && c <= 159) && c != 9 && c != 10)) {
    throw const FormatException('Invalid ride document text');
  }
  return value;
}

DateTime _instant(Object? value) {
  if (value is! String ||
      !RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{3})?Z$')
          .hasMatch(value)) {
    throw const FormatException('Invalid ride document time');
  }
  final result = DateTime.tryParse(value);
  if (result == null ||
      result.toIso8601String() !=
          (value.contains('.') ? value : value.replaceFirst('Z', '.000Z'))) {
    throw const FormatException('Invalid ride document time');
  }
  return result;
}
