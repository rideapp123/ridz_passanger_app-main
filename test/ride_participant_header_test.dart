import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/models/ride_participant.dart';
import 'package:ridzs_passenger_app/models/common/ride_response/ride_response.dart';
import 'package:ridzs_passenger_app/view/home/widget/ride_participant_header.dart';

void main() {
  for (final status in ['accepted', 'arrived', 'started']) {
    testWidgets('$status header links to native credential view',
        (tester) async {
      final request = RideRequest.fromJson({
        'ride': {
          'id': 'ride-a',
          'driverId': 'driver-a',
          'version': 3,
          'status': status
        }
      });
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: RideParticipantHeader(
                  name: 'Driver', rideRequest: request))));
      await tester.tap(find.text('Credentials'));
      await tester.pumpAndSettle();
      expect(find.text('Credentials'), findsOneWidget);
      expect(find.text('Return to your ride to check driver credentials.'),
          findsOneWidget);
    });
  }
  testWidgets('long driver and vehicle identity fit compact large-text screen',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(2)),
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: RideParticipantHeader(
            name: 'A very long driver display name',
            rideRequest: RideRequest.fromJson({
              'ride': {
                'id': 'ride-a',
                'driverId': 'driver-a',
                'status': 'accepted',
                'version': 3
              }
            }),
            vehicle: RideVehicle.fromJson({
              'make': 'Example manufacturer',
              'model': 'Long model name',
              'color': 'White',
              'licensePlate': 'TEST 123'
            }),
          )),
    ))));
    expect(tester.takeException(), isNull);
    expect(find.text('TEST 123'), findsOneWidget);
    expect(find.text('4.8'), findsNothing);
  });

  testWidgets('missing vehicle has an honest unavailable state',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: RideParticipantHeader(name: 'Driver'))));
    expect(find.text('Vehicle details unavailable'), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });
}
