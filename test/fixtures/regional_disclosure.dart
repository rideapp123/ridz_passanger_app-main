import 'dart:convert';
import 'package:crypto/crypto.dart';

Map<String, dynamic> regionalMarket({String id = 'ON-ottawa'}) => {
      'marketId': id,
      'policyVersion': 2,
      'province': id.substring(0, 2),
      'municipality': id.substring(3),
      'marketName': 'Synthetic market'
    };

Map<String, dynamic> regionalMarketPage({String locale = 'en-CA'}) => {
      'protocol': 1,
      'scope': 'regional_disclosure_markets',
      'locale': locale,
      'serverTime': '2026-10-18T12:00:00Z',
      'refreshAfter': '2026-10-18T12:00:30Z',
      'items': [regionalMarket()]
    };

Map<String, dynamic> regionalDisclosure(
    {String id = 'ON-ottawa', String locale = 'en-CA'}) {
  final data = <String, dynamic>{
    'protocol': 1,
    'scope': 'regional_disclosure',
    ...regionalMarket(id: id),
    'locale': locale,
    'contentVersion': '11111111-1111-4111-8111-111111111111',
    'effectiveFrom': '2026-10-18T11:59:00Z',
    'validUntil': '2026-10-18T13:00:00.123Z',
    'serverTime': '2026-10-18T12:00:00Z',
    'refreshAfter': '2026-10-18T12:00:30Z',
    'operatorName': 'Synthetic operator',
    'sections': [
      for (final kind in ['terms', 'privacy', 'ride_information', 'support'])
        {
          'kind': kind,
          'title': 'Synthetic $kind',
          'body':
              'Test only: "quoted" / \u00e9 \uD83D\uDE80\n\tNo legal assurance.'
        }
    ]
  };
  sealDisclosure(data);
  return data;
}

void sealDisclosure(Map<String, dynamic> data) {
  final canonical = jsonEncode([
    1,
    data['marketId'],
    data['policyVersion'],
    data['locale'],
    data['contentVersion'],
    (data['effectiveFrom'] as String).replaceFirst('.000Z', 'Z'),
    (data['validUntil'] as String).replaceFirst('.000Z', 'Z'),
    data['operatorName'],
    (data['sections'] as List)
        .map((s) => [s['kind'], s['title'], s['body']])
        .toList()
  ]);
  final escaped = canonical.replaceAllMapped(RegExp(r'[\uD800-\uDFFF]'),
      (m) => '\\u${m[0]!.codeUnitAt(0).toRadixString(16).toUpperCase()}');
  data['contentHash'] = sha256.convert(utf8.encode(escaped)).toString();
}
