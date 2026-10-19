bool shouldRefreshWalletForRide({
  required String? rideStatus,
  required String? paymentStatus,
}) {
  const paymentStates = {
    'authorized',
    'held',
    'captured',
    'settled',
    'released',
    'adjustment_pending',
    'adjustment_failed_permanent',
  };
  return rideStatus?.toLowerCase() == 'completed' ||
      rideStatus?.toLowerCase() == 'cancelled' ||
      rideStatus?.toLowerCase() == 'canceled' ||
      paymentStates.contains(paymentStatus?.toLowerCase());
}
