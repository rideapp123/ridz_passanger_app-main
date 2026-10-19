/// A routing hint, never a ride snapshot or proof that a booking failed.
class RideBookingHint {
  RideBookingHint._(this.notificationId, this.rideId);

  final String notificationId;
  final String rideId;
  static final _uuid = RegExp(r'^[a-f0-9]{8}(-[a-f0-9]{4}){3}-[a-f0-9]{12}$');
  static const _fields = [
    'notificationId',
    'rideId',
    'event',
    'version',
    'type',
    'expiresAt'
  ];

  static RideBookingHint? parse(dynamic value) {
    if (value is! Map || value.length != _fields.length) return null;
    for (final field in _fields) {
      final text = value[field];
      if (text is! String || text.isEmpty || text.length > 128) return null;
    }
    final version = int.tryParse(value['version'] as String);
    final paired = value['event'] == 'ride:status' &&
            value['type'] == 'RIDE_STATUS_UPDATED' ||
        value['event'] == 'ride:noDriverFound' &&
            value['type'] == 'RIDE_NO_DRIVER_FOUND';
    if (!paired ||
        !_uuid.hasMatch(value['notificationId'] as String) ||
        !RegExp(r'^[A-Za-z0-9_-]{1,128}$')
            .hasMatch(value['rideId'] as String) ||
        version == null ||
        version < 1 ||
        version > 9007199254740991 ||
        DateTime.tryParse(value['expiresAt'] as String) == null) {
      return null;
    }
    return RideBookingHint._(value['notificationId'], value['rideId']);
  }
}
