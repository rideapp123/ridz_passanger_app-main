import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:ridzs_passenger_app/core/services/dio_service.dart';
import 'package:ridzs_passenger_app/services/ride_disclosure_service.dart';

String rideDocumentToken(String owner, {String role = 'PASSENGER'}) =>
    'header.${base64Url.encode(utf8.encode(jsonEncode({
          'id': owner,
          'role': role
        })))}.signature';

Map<String, dynamic> rideDisclosure({String locale = 'en-CA'}) {
  final data = <String, dynamic>{
    'protocol': 1,
    'scope': 'ride_regional_disclosure',
    'audience': 'passenger_information',
    'rideId': 'ride-a',
    'marketId': 'ON-ottawa',
    'policyVersion': 2,
    'province': 'ON',
    'municipality': 'ottawa',
    'locale': locale,
    'contentVersion': '11111111-1111-4111-8111-111111111111',
    'capturedAt': '2026-10-18T12:00:00Z',
    'effectiveFrom': '2026-10-18T11:59:00Z',
    'validUntil': '2026-10-18T13:00:00.123Z',
    'serverTime': '2026-10-19T12:00:00Z',
    'refreshAfter': '2026-10-19T12:00:30Z',
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
  sealRideDisclosure(data);
  return data;
}

void sealRideDisclosure(Map<String, dynamic> data) {
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
  ]).replaceAllMapped(RegExp(r'[\uD800-\uDFFF]'),
      (m) => '\\u${m[0]!.codeUnitAt(0).toRadixString(16).toUpperCase()}');
  data['contentHash'] = sha256.convert(utf8.encode(canonical)).toString();
}

ResponseBody documentResponse(Object? value, {int status = 200}) =>
    ResponseBody.fromString(
        jsonEncode({'success': true, 'data': value}), status,
        headers: {
          Headers.contentTypeHeader: ['application/json']
        });
ResponseBody missingDocument() => ResponseBody.fromString(
        jsonEncode({
          'success': false,
          'code': 'RIDE_DISCLOSURE_UNAVAILABLE',
          'message': 'PRIVATE details'
        }),
        409,
        headers: {
          Headers.contentTypeHeader: ['application/json']
        });

class DocumentAdapter implements HttpClientAdapter {
  DocumentAdapter(this.respond);
  final Future<ResponseBody> Function(RequestOptions) respond;
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream,
          Future<void>? cancelFuture) =>
      respond(options);
  @override
  void close({bool force = false}) {}
}

class RideDocumentHarness {
  RideDocumentHarness() {
    auth = AuthInterceptor(dio, tokenReader: () async {
      await beforeTokenRead?.call();
      return token;
    });
    dio.interceptors.add(auth);
    dio.httpClientAdapter = DocumentAdapter((request) async {
      requests.add(request);
      return respond(request);
    });
  }
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test/passenger'));
  late final AuthInterceptor auth;
  final owner = Observable<String?>('owner-a');
  final rideCurrent = Observable(true);
  String? token = rideDocumentToken('owner-a');
  Future<void> Function()? beforeTokenRead;
  final requests = <RequestOptions>[];
  Future<ResponseBody> Function(RequestOptions) respond = (r) async =>
      documentResponse(
          rideDisclosure(locale: r.queryParameters['locale'] as String));
  RideDisclosureService create() => RideDisclosureService(
      ownerId: 'owner-a',
      rideId: 'ride-a',
      ownerReader: () => owner.value,
      rideIsCurrent: () => rideCurrent.value,
      dio: dio);
  void close() => dio.close(force: true);
}
