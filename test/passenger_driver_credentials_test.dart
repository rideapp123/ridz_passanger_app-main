import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart';
import 'package:ridzs_passenger_app/models/common/ride_response/ride_response.dart';
import 'package:ridzs_passenger_app/models/passenger_driver_credentials.dart';
import 'package:ridzs_passenger_app/services/passenger_driver_credentials_service.dart';
import 'fixtures/passenger_driver_credentials.dart';

void main() {
  test('minimal public records accept both kinds and empty availability', () {
    final data = passengerCredentials();
    (data['credentials'] as List).add(
        {'kind': 'operator_certificate', 'expiresAt': '2027-01-01T00:00:00Z'});
    expect(
        PassengerDriverCredentials.parse(data, credentialBinding).credentials,
        hasLength(2));
    expect(
        PassengerDriverCredentials.parse(
                passengerCredentials(available: false), credentialBinding)
            .credentials,
        isEmpty);
  });
  final invalid = <String, Object?>{
    'protocol': 2,
    'rideId': 'other',
    'rideVersion': 4,
    'driverId': 'other',
    'issuer': 'Government',
    'scope': 'government',
    'serverTime': '2026-02-30T00:00:00Z',
    'validUntil': '2026-10-18T00:00:31Z',
    'credentials': {},
    'applicationId': 'private-app',
  };
  for (final entry in invalid.entries) {
    test('rejects unexpected ${entry.key}', () {
      expect(
          () => PassengerDriverCredentials.parse(
              {...passengerCredentials(), entry.key: entry.value},
              credentialBinding),
          throwsFormatException);
    });
  }
  for (final record in [
    {'kind': 'government_licence', 'expiresAt': '2027-01-01T00:00:00Z'},
    {'kind': 'operator_driver_id', 'expiresAt': '2026-10-18T00:00:01Z'},
    {'kind': 'operator_driver_id', 'expiresAt': '2027-01-01T00:00:00'},
    {
      'kind': 'operator_driver_id',
      'expiresAt': '2027-01-01T00:00:00Z',
      'id': 'private-id'
    },
  ]) {
    test('rejects unsafe record $record', () {
      expect(
          () => PassengerDriverCredentials.parse({
                ...passengerCredentials(),
                'credentials': [record]
              }, credentialBinding),
          throwsFormatException);
    });
  }
  test('duplicate kinds, fractional revisions and expired leases fail closed',
      () {
    final data = passengerCredentials();
    data['credentials'] = [data['credentials'][0], data['credentials'][0]];
    expect(() => PassengerDriverCredentials.parse(data, credentialBinding),
        throwsFormatException);
    expect(
        () => PassengerDriverCredentials.parse(
            {...passengerCredentials(), 'rideVersion': 3.0}, credentialBinding),
        throwsFormatException);
    expect(
        () => PassengerDriverCredentials.parse(
            {...passengerCredentials(), 'validUntil': '2026-10-18T00:00:00Z'},
            credentialBinding),
        throwsFormatException);
  });
  for (final status in [
    'accepted',
    'arrived',
    'started',
    'completed',
    'cancelled',
    'searching'
  ]) {
    test('native entry binding for $status', () {
      final request = RideRequest.fromJson({
        'ride': {
          'id': 'ride-a',
          'driverId': 'driver-a',
          'status': status,
          'version': 3
        }
      });
      expect(CredentialRideBinding.fromRide(request) != null,
          ['accepted', 'arrived', 'started'].contains(status));
      expect(credentialBinding.matches(request),
          ['accepted', 'arrived', 'started'].contains(status));
    });
  }

  late PassengerCredentialsHarness harness;
  late PassengerDriverCredentialsService service;
  setUp(() {
    harness = PassengerCredentialsHarness();
    service = harness.create();
  });
  tearDown(() {
    service.dispose();
    harness.close();
  });
  test('GET is no-store, no redirect and pinned to original passenger login',
      () async {
    final snapshot = await service.load();
    expect(snapshot.remaining <= const Duration(seconds: 30), isTrue);
    expect(snapshot.remaining > Duration.zero, isTrue);
    final request = harness.requests.single;
    expect(request.path, '/rides/ride-a/driver-credentials');
    expect(request.method, 'GET');
    expect(request.followRedirects, isFalse);
    expect(request.headers['Cache-Control'], 'no-store');
    expect(request.headers['Authorization'], 'Bearer ${harness.token}');
    expect(request.extra['expectedAuthSessionEpoch'], 0);
    expect(request.queryParameters, isEmpty);
  });
  for (final change in ['owner', 'token', 'ride', 'backend', 'logout']) {
    void mutate() {
      switch (change) {
        case 'owner':
          runInAction(() => harness.owner.value = 'passenger-b');
        case 'token':
          harness.token = credentialToken('passenger-b');
        case 'ride':
          runInAction(() => harness.rideCurrent.value = false);
        case 'backend':
          harness.dio.options.baseUrl = 'https://other.test';
        case 'logout':
          harness.auth.endSession();
      }
    }

    test('$change blocks subsequent requests', () async {
      await service.load();
      mutate();
      await expectLater(
          service.load(), throwsA(isA<PassengerCredentialSessionEnded>()));
      expect(harness.requests, hasLength(1));
    });
    test('$change rejects late responses', () async {
      harness.respond = (_) async {
        mutate();
        return credentialsResponse(passengerCredentials());
      };
      await expectLater(
          service.load(), throwsA(isA<PassengerCredentialSessionEnded>()));
    });
    test('$change during dispatch cannot send old ride to a new session',
        () async {
      await service.load();
      final entered = Completer<void>(), release = Completer<void>();
      var reads = 0;
      harness.beforeTokenRead = () async {
        if (++reads == 2) {
          entered.complete();
          await release.future;
        }
      };
      final rejected = expectLater(
          service.load(), throwsA(isA<PassengerCredentialSessionEnded>()));
      await entered.future;
      mutate();
      release.complete();
      await rejected;
      expect(harness.requests, hasLength(1));
    });
  }
  test('a driver token cannot open passenger credential reads', () async {
    service.dispose();
    harness.token = credentialToken('passenger-a', role: 'DRIVER');
    service = harness.create();
    await expectLater(
        service.load(), throwsA(isA<PassengerCredentialSessionEnded>()));
    expect(harness.requests, isEmpty);
  });
  for (final status in [401, 403, 404, 409]) {
    test('$status clears the ride credential session', () async {
      harness.respond = (_) async => credentialsResponse({}, status: status);
      await expectLater(
          service.load(), throwsA(isA<PassengerCredentialSessionEnded>()));
      expect(service.isCurrent, isFalse);
    });
  }
  test('transient errors can retry without reusing data', () async {
    harness.respond = (_) async => credentialsResponse({}, status: 503);
    await expectLater(service.load(), throwsA(isA<DioException>()));
    harness.respond = (_) async =>
        credentialsResponse(passengerCredentials(available: false));
    expect((await service.load()).data.credentials, isEmpty);
  });
  test('round-trip time is deducted from server observation lease', () async {
    harness.respond = (_) async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return credentialsResponse({
        ...passengerCredentials(available: false),
        'validUntil': '2026-10-18T00:00:00.001Z'
      });
    };
    await expectLater(service.load(), throwsFormatException);
  });
  test('cancelled requests cannot supply records but a new read is allowed',
      () async {
    final entered = Completer<void>(), release = Completer<void>();
    harness.respond = (_) async {
      entered.complete();
      await release.future;
      return credentialsResponse(passengerCredentials());
    };
    final rejected = expectLater(service.load(), throwsA(anything));
    await entered.future;
    service.cancelRequests();
    release.complete();
    await rejected;
    harness.respond = (_) async =>
        credentialsResponse(passengerCredentials(available: false));
    expect((await service.load()).data.credentials, isEmpty);
  });
}
