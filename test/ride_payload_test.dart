import 'package:ridzs_passenger_app/stores/map/map_store.dart';
import 'package:ridzs_passenger_app/models/ride/get_ride_response.dart'
    as history;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/models/common/ride_response/ride_response.dart';
import 'package:ridzs_passenger_app/view/home/widget/ride_contact_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final fixtures =
      jsonDecode(File('test/fixtures/ride_payloads.json').readAsStringSync())
          as Map;
  Map<String, dynamic> data(String name) =>
      jsonDecode(jsonEncode(fixtures[name]));
  for (final name in ["passengerAccepted", "passengerCompleted"]) {
    test('backend fixture $name parses and retains its scoped participant', () {
      final payload = data(name);
      final request = RideRequest.fromJson(payload);
      final expected = payload['ride']['participant'] as Map;
      expect(request.ride!.sId, 'ride-contract');
      expect(request.ride!.version, 7);
      expect(request.driverName, expected['displayName']);
      expect(request.driverPhoto, expected['photoUrl']);
      expect(request.contactUri != null, expected['contact']['canCall']);
      expect(request.ride!.fare!.total, 14.5);
      expect(request.ride!.pickup!.latitude, 45.0);
      final restored = RideRequest.fromJson(request.toJson());
      expect(restored.participant!.toJson(), expected);
      expect(restored.vehicle!.toJson(), request.vehicle!.toJson());
      expect(restored.contactUri, request.contactUri);
    });
  }

  test('fixture copies match the canonical backend when checked out together',
      () {
    final canonical = File(
        '../ridzs-backend/src/test/resources/contracts/ride_payloads.json');
    if (canonical.existsSync()) {
      expect(jsonDecode(canonical.readAsStringSync()), fixtures);
    }
  });

  for (final invalid in ['role', 'id']) {
    test('wrong participant $invalid is rejected', () {
      final payload = data('passengerAccepted');
      payload['ride']['participant'][invalid] = 'unrelated';
      expect(() => RideRequest.fromJson(payload), throwsFormatException);
    });
  }

  test('legacy aliases and phone survive serialization', () {
    final payload = data('passengerAccepted');
    (payload['ride'] as Map).remove('participant');
    payload.remove('driverName');
    payload.remove('driverMobileNumber');
    payload['driverName'] = 'Legacy Name';
    payload['driverNumber'] = '+16135550105';
    final parsed = RideRequest.fromJson(payload);
    final restored = RideRequest.fromJson(parsed.toJson());
    expect(restored.driverName, 'Legacy Name');
    expect(restored.driverNumber, '+16135550105');
  });

  test('explicit contact removal cannot revive a cached phone or photo', () {
    final previous = RideRequest.fromJson(data('passengerAccepted'));
    final payload = data('passengerAccepted');
    payload['ride']['participant'] = null;
    payload['ride']['vehicle'] = {};
    final current = RideRequest.fromJson(payload)..mergeDisplayFrom(previous);
    expect(current.driverName, '');
    expect(current.driverNumber, '');
    expect(current.driverPhoto, '');
    expect(current.vehicle!.licensePlate, '');
    expect(current.contactUri, isNull);
    expect(RideRequest.fromJson(current.toJson()).contactUri, isNull);
  });

  test('metadata-free update keeps same-participant display data', () {
    final previous = RideRequest.fromJson(data('passengerAccepted'));
    final payload = data('passengerAccepted');
    final ride = Map<String, dynamic>.from(payload['ride'])
      ..remove('participant')
      ..remove('vehicle');
    final current = RideRequest.fromJson({'ride': ride})
      ..mergeDisplayFrom(previous);
    expect(current.driverName, previous.driverName);
    expect(current.contactUri, previous.contactUri);
    expect(current.vehicle!.licensePlate, previous.vehicle!.licensePlate);
  });

  test('a different participant never inherits prior contact details', () {
    final previous = RideRequest.fromJson(data('passengerAccepted'));
    final ride = Map<String, dynamic>.from(data('passengerAccepted')['ride'])
      ..remove('participant')
      ..remove('vehicle')
      ..['driverId'] = 'new-participant';
    final current = RideRequest.fromJson({'ride': ride})
      ..mergeDisplayFrom(previous);
    expect(current.contactUri, isNull);
    expect(current.vehicle, isNull);
  });

  test('terminal snapshot cannot enable calling even with a stale phone', () {
    final payload = data('passengerCompleted');
    payload['ride']['participant']
        ['contact'] = {'canCall': true, 'phoneNumber': '+16135550100'};
    expect(RideRequest.fromJson(payload).contactUri, isNull);
  });

  test('malformed phone cannot become a dialable URI', () {
    final payload = data('passengerAccepted');
    payload['ride']['participant']['contact']['phoneNumber'] =
        '+16135550100?body=secret';
    expect(RideRequest.fromJson(payload).contactUri, isNull);
  });

  test('numeric strings, empty route and payment nulls are safe', () {
    final payload = data('passengerAccepted');
    payload['estimatedDistance'] = '4.5';
    payload['estimatedDuration'] = 10.5;
    payload['ride']['pickup']['latitude'] = '45.0';
    payload['ride']['fare']['total'] = '14.5';
    payload['ride']['payment']['capturedAmount'] = null;
    payload['ride']['route'] = {};
    final parsed = RideRequest.fromJson(payload);
    expect(parsed.estimatedDistance, 4.5);
    expect(parsed.estimatedDuration, 11);
    expect(parsed.ride!.pickup!.latitude, 45.0);
    expect(parsed.ride!.fare!.total, 14.5);
    expect(parsed.ride!.payment!.capturedAmount, isNull);
    expect(parsed.ride!.route!.waypoints, isEmpty);
  });

  test('all lifecycle timestamps survive serialization', () {
    final payload = data('passengerAccepted');
    for (final key in [
      'accepted',
      'arrived',
      'started',
      'completed',
      'cancelled'
    ]) {
      payload['ride']['timestamps'][key] = '2026-09-12T01:00:00Z';
    }
    final parsed = RideRequest.fromJson(payload);
    expect(parsed.ride!.timestamps!.toJson(), payload['ride']['timestamps']);
  });

  testWidgets('unavailable contact is a disabled named control',
      (tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: RideContactButton(uri: null))));
    final button = tester.widget<IconButton>(find.byType(IconButton));
    expect(button.onPressed, isNull);
    expect(button.tooltip, 'Phone unavailable');
  });

  testWidgets('failed dialer launch reports a generic error', (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: RideContactButton(
                uri: Uri(scheme: 'tel', path: '+16135550100'),
                launcher: (_) async => false))));
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();
    expect(find.text('Unable to open phone app'), findsOneWidget);
  });

  testWidgets('authorized contact launches exactly the supplied URI',
      (tester) async {
    Uri? launched;
    final uri = RideRequest.fromJson(data('passengerAccepted')).contactUri!;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: RideContactButton(
                uri: uri,
                launcher: (value) async {
                  launched = value;
                  return true;
                }))));
    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(launched, uri);
  });
  test(
      'history reads canonical participant and numeric duration without contact',
      () {
    final payload = data('passengerAccepted');
    payload['ride']['estimatedTimeInMinutes'] = 10.0;
    final parsed =
        history.Ride.fromJson(Map<String, dynamic>.from(payload['ride']));
    expect(
        parsed.driverInfo!.name, payload['ride']['participant']['displayName']);
    expect(parsed.driverInfo!.mobileNumber, '');
    expect(parsed.estimatedTimeInMinutes, 10);
  });

  test(
      'real store applies explicit contact revocation and rejects stale restoration',
      () {
    final store = MapStore(rideNotice: (_) {});
    addTearDown(store.dispose);
    final previous = RideRequest.fromJson(data('passengerAccepted'));
    store.currentRide = previous;
    final payload = data('passengerAccepted');
    payload['ride']['version'] = 8;
    payload['ride']['participant']
        ['contact'] = {'canCall': false, 'phoneNumber': ''};
    expect(store.applyRideUpdate(RideRequest.fromJson(payload)), true);
    expect(store.currentRide!.contactUri, isNull);
    expect(store.applyRideUpdate(previous), false);
    expect(store.currentRide!.contactUri, isNull);
  });

  test(
      'authoritative recovery refreshes contact without a lifecycle revision change',
      () {
    final store = MapStore(rideNotice: (_) {});
    addTearDown(store.dispose);
    final payload = data('passengerAccepted');
    store.currentRide = RideRequest.fromJson(payload);
    payload['ride']['participant']
        ['contact'] = {'canCall': false, 'phoneNumber': ''};
    final refreshed = RideRequest.fromJson(payload);
    expect(store.applyRideUpdate(refreshed), false);
    expect(store.applyRideUpdate(refreshed, fromRecovery: true), true);
    expect(store.currentRide!.contactUri, isNull);
    expect(store.currentRide!.ride!.version, 7);
  });
}
