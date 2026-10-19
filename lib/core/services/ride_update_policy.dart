// Keep this policy aligned in both apps; backend revisions are authoritative.
bool acceptsRideUpdate({
  required String? expectedId,
  required String? incomingId,
  required String? currentStatus,
  required String? incomingStatus,
  required int? currentVersion,
  required int? incomingVersion,
}) {
  const order = {
    'requested': 0,
    'searching': 1,
    'accepted': 2,
    'arrived': 3,
    'started': 4,
    'completed': 5,
    'cancelled': 5,
  };
  if (expectedId == null ||
      expectedId.isEmpty ||
      incomingId != expectedId ||
      !order.containsKey(incomingStatus)) {
    return false;
  }
  if (currentVersion != null &&
      (incomingVersion == null || incomingVersion <= currentVersion)) {
    return false;
  }
  if (currentStatus == 'cancelled' || currentStatus == 'completed') {
    return incomingStatus == currentStatus &&
        incomingVersion != null &&
        (currentVersion == null || incomingVersion > currentVersion);
  }
  if ((order[incomingStatus] ?? -1) < (order[currentStatus] ?? -1)) {
    return false;
  }
  if (currentStatus == incomingStatus && incomingVersion == null) return false;
  return true;
}
