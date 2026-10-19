double? rideNumber(dynamic value) {
  final number = value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '');
  return number != null && number.isFinite ? number : null;
}

int? rideInteger(dynamic value) {
  if (value is int) return value;
  if (value is String && int.tryParse(value) != null) return int.parse(value);
  final number = rideNumber(value);
  return number != null && number == number.truncateToDouble()
      ? number.toInt()
      : null;
}

String rideText(dynamic value) => value is String ? value.trim() : '';

class RideParticipant {
  final String id, role, displayName, photoUrl, phoneNumber;
  final bool canCall;
  RideParticipant.fromJson(Map json)
      : id = rideText(json['id']),
        role = rideText(json['role']),
        displayName = rideText(json['displayName']),
        photoUrl = rideText(json['photoUrl']).startsWith('https://')
            ? rideText(json['photoUrl'])
            : '',
        phoneNumber = json['contact'] is Map
            ? rideText(json['contact']['phoneNumber'])
            : '',
        canCall = json['contact'] is Map && json['contact']['canCall'] == true;

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'contact': {'canCall': canCall, 'phoneNumber': phoneNumber}
      };
}

class RideVehicle {
  final String id, make, model, color, licensePlate;
  RideVehicle.fromJson(Map json)
      : id = rideText(json['id']),
        make = rideText(json['make']),
        model = rideText(json['model']),
        color = rideText(json['color']),
        licensePlate = rideText(json['licensePlate']);
  String get description =>
      [color, make, model].where((part) => part.isNotEmpty).join(' ');
  Map<String, dynamic> toJson() => {
        'id': id,
        'make': make,
        'model': model,
        'color': color,
        'licensePlate': licensePlate
      };
}

Uri? rideContactUri(String? status, String? phone, bool allowed) {
  if (!allowed || !const ['accepted', 'arrived', 'started'].contains(status)) {
    return null;
  }
  final number = phone?.trim() ?? '';
  if (!RegExp(r'^\+[1-9][0-9]{7,14}$').hasMatch(number)) return null;
  return Uri(scheme: 'tel', path: number);
}

Map<String, dynamic>? rideHistoryIdentity(
    Map<String, dynamic> json, String role) {
  if (json.containsKey('participant')) {
    final value = json['participant'];
    if (value is! Map || value['role'] != role) return null;
    final participant = RideParticipant.fromJson(value);
    return {
      'id': participant.id,
      'name': participant.displayName,
      'photo': participant.photoUrl,
      'mobileNumber': ''
    };
  }
  final legacy = json['${role}Info'];
  return legacy is Map ? Map<String, dynamic>.from(legacy) : null;
}
