import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/models/ride/get_ride_response.dart';
import 'package:ridzs_passenger_app/models/ride/ride_trace_response.dart';

void main() {
  test('basic smoke test', () {
    expect(1 + 1, 2);
  });

  test('ride trace sample parses backend response shape', () {
    final sample = RideTraceSample.fromJson({
      '_id': 'sample-1',
      'rideId': 'ride-1',
      'passengerId': 'passenger-1',
      'driverId': 'driver-1',
      'latitude': 51.0447,
      'longitude': '-114.0719',
      'heading': 180,
      'speed': '32.5',
      'accuracy': 8,
      'source': 'driver_location_update',
      'recordedAt': '2026-09-02T06:00:00Z',
    });

    expect(sample.id, 'sample-1');
    expect(sample.rideId, 'ride-1');
    expect(sample.hasValidCoordinate, isTrue);
    expect(sample.latitude, 51.0447);
    expect(sample.longitude, -114.0719);
    expect(sample.speed, 32.5);
    expect(sample.recordedAt?.toUtc().toIso8601String(),
        '2026-09-02T06:00:00.000Z');
  });

  test('ride history payment parses recovery fields', () {
    final payment = Payment.fromJson({
      'method': 'card',
      'status': 'adjustment_pending',
      'capturedAmount': '40.50',
      'adjustmentRemaining': 9.25,
      'adjustmentAttempts': '2',
      'nextRetryAt': '2026-09-02T06:10:00Z',
    });

    expect(payment.isRetryPending, isTrue);
    expect(payment.needsRecovery, isTrue);
    expect(payment.capturedAmount, 40.50);
    expect(payment.adjustmentRemaining, 9.25);
    expect(payment.adjustmentAttempts, 2);
  });
}
