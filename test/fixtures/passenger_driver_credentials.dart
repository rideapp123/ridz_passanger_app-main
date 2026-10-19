import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:ridzs_passenger_app/core/services/dio_service.dart';
import 'package:ridzs_passenger_app/models/passenger_driver_credentials.dart';
import 'package:ridzs_passenger_app/services/passenger_driver_credentials_service.dart';
import '../session_request_test.dart' show TestAdapter;

const credentialBinding = CredentialRideBinding('ride-a', 'driver-a', 3);
String credentialToken(String owner, {String role = 'PASSENGER'}) =>
    'header.${base64Url.encode(utf8.encode(jsonEncode({
          'id': owner,
          'role': role
        })))}.signature';

Map<String, dynamic> passengerCredentials({bool available = true}) => {
      'protocol': 1,
      'rideId': 'ride-a',
      'rideVersion': 3,
      'driverId': 'driver-a',
      'issuer': 'Ridzs',
      'scope': 'operator_only',
      'serverTime': '2026-10-18T00:00:00Z',
      'validUntil': '2026-10-18T00:00:30Z',
      'credentials': [
        if (available)
          {'kind': 'operator_driver_id', 'expiresAt': '2027-01-01T00:00:00Z'}
      ],
    };

ResponseBody credentialsResponse(Object? value, {int status = 200}) =>
    ResponseBody.fromString(
        jsonEncode({'success': true, 'data': value}), status,
        headers: {
          Headers.contentTypeHeader: ['application/json']
        });

class PassengerCredentialsHarness {
  PassengerCredentialsHarness() {
    auth = AuthInterceptor(dio, tokenReader: () async {
      await beforeTokenRead?.call();
      return token;
    });
    dio.interceptors.add(auth);
    dio.httpClientAdapter = TestAdapter((request) async {
      requests.add(request);
      return respond(request);
    });
  }
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test/passenger'));
  late final AuthInterceptor auth;
  final owner = Observable<String?>('passenger-a');
  final rideCurrent = Observable(true);
  String? token = credentialToken('passenger-a');
  Future<void> Function()? beforeTokenRead;
  final requests = <RequestOptions>[];
  Future<ResponseBody> Function(RequestOptions) respond =
      (_) async => credentialsResponse(passengerCredentials());
  PassengerDriverCredentialsService create() =>
      PassengerDriverCredentialsService(
          ownerId: 'passenger-a',
          binding: credentialBinding,
          dio: dio,
          ownerReader: () => owner.value,
          rideIsCurrent: () => rideCurrent.value);
  void close() => dio.close(force: true);
}
