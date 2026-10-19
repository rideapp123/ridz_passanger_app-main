import 'common/ride_response/ride_response.dart';

class CredentialRideBinding {
  const CredentialRideBinding(this.rideId, this.driverId, this.version);
  final String rideId, driverId;
  final int version;

  static CredentialRideBinding? fromRide(RideRequest? request) {
    final ride = request?.ride;
    if (ride == null ||
        !const ['accepted', 'arrived', 'started']
            .contains(ride.status?.title) ||
        ride.sId == null ||
        !validId(ride.sId!) ||
        ride.driverId == null ||
        !validId(ride.driverId!) ||
        ride.version == null ||
        ride.version! < 0) {
      return null;
    }
    return CredentialRideBinding(ride.sId!, ride.driverId!, ride.version!);
  }

  bool matches(RideRequest? request) {
    final current = fromRide(request);
    return current != null &&
        current.rideId == rideId &&
        current.driverId == driverId &&
        current.version == version;
  }

  static bool validId(String id) =>
      RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(id);
}

class PassengerDriverCredential {
  const PassengerDriverCredential(this.kind, this.expiresAt);
  final String kind;
  final DateTime expiresAt;
  String get label =>
      kind == 'operator_driver_id' ? 'Ridzs driver ID' : 'Ridzs certificate';
}

/// No private credential/application identifiers, evidence or reviewer fields.
class PassengerDriverCredentials {
  PassengerDriverCredentials._(
      this.serverTime, this.validUntil, this.credentials);
  final DateTime serverTime, validUntil;
  final List<PassengerDriverCredential> credentials;

  factory PassengerDriverCredentials.parse(
      Object? value, CredentialRideBinding binding) {
    if (value is! Map ||
        value.length != 9 ||
        !value.keys.toSet().containsAll(const {
          'protocol',
          'rideId',
          'rideVersion',
          'driverId',
          'issuer',
          'scope',
          'serverTime',
          'validUntil',
          'credentials'
        }) ||
        value['protocol'] is! int ||
        value['protocol'] != 1 ||
        value['rideVersion'] is! int ||
        value['rideVersion'] != binding.version ||
        value['rideId'] != binding.rideId ||
        value['driverId'] != binding.driverId ||
        value['issuer'] != 'Ridzs' ||
        value['scope'] != 'operator_only' ||
        value['credentials'] is! List ||
        (value['credentials'] as List).length > 2) {
      throw const FormatException('Invalid passenger credential response');
    }
    final now = _instant(value['serverTime']);
    final until = _instant(value['validUntil']);
    if (!until.isAfter(now) ||
        until.difference(now) > const Duration(seconds: 30)) {
      throw const FormatException('Invalid credential observation deadline');
    }
    final records = <PassengerDriverCredential>[];
    final kinds = <String>{};
    for (final item in value['credentials']) {
      if (item is! Map ||
          item.length != 2 ||
          !item.containsKey('expiresAt') ||
          !const {'operator_driver_id', 'operator_certificate'}
              .contains(item['kind']) ||
          !kinds.add(item['kind'] as String)) {
        throw const FormatException('Invalid passenger credential');
      }
      final expiry = _instant(item['expiresAt']);
      if (expiry.isBefore(until)) {
        throw const FormatException('Expired observation');
      }
      records.add(PassengerDriverCredential(item['kind'] as String, expiry));
    }
    return PassengerDriverCredentials._(now, until, List.unmodifiable(records));
  }

  static DateTime _instant(Object? value) {
    if (value is! String) throw const FormatException('Invalid instant');
    final match = RegExp(
            r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(?:\.\d{1,9})?Z$')
        .firstMatch(value);
    final time = DateTime.tryParse(value);
    if (match == null ||
        time == null ||
        time.year != int.parse(match[1]!) ||
        time.month != int.parse(match[2]!) ||
        time.day != int.parse(match[3]!) ||
        time.hour != int.parse(match[4]!) ||
        time.minute != int.parse(match[5]!) ||
        time.second != int.parse(match[6]!)) {
      throw const FormatException('Invalid instant');
    }
    return time;
  }
}
