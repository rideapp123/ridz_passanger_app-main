import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/core/services/wallet_refresh_policy.dart';

void main() {
  test('refreshes for settled and recoverable payment states', () {
    for (final status in [
      'authorized',
      'held',
      'captured',
      'settled',
      'released',
      'adjustment_pending',
      'adjustment_failed_permanent',
    ]) {
      expect(
        shouldRefreshWalletForRide(
            rideStatus: 'started', paymentStatus: status),
        isTrue,
        reason: status,
      );
    }
  });

  test(
      'refreshes when a ride becomes terminal and ignores nonfinancial updates',
      () {
    expect(
        shouldRefreshWalletForRide(
            rideStatus: 'completed', paymentStatus: null),
        isTrue);
    expect(
        shouldRefreshWalletForRide(
            rideStatus: 'cancelled', paymentStatus: null),
        isTrue);
    expect(
        shouldRefreshWalletForRide(
            rideStatus: 'started', paymentStatus: 'unknown'),
        isFalse);
  });
}
