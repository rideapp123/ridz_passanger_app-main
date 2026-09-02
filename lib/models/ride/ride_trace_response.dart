import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideTraceSample {
  final String id;
  final String rideId;
  final String passengerId;
  final String driverId;
  final double latitude;
  final double longitude;
  final double? heading;
  final double? speed;
  final double? accuracy;
  final String source;
  final DateTime? recordedAt;

  const RideTraceSample({
    required this.id,
    required this.rideId,
    required this.passengerId,
    required this.driverId,
    required this.latitude,
    required this.longitude,
    this.heading,
    this.speed,
    this.accuracy,
    required this.source,
    this.recordedAt,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  bool get hasValidCoordinate =>
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180 &&
      !(latitude == 0 && longitude == 0);

  factory RideTraceSample.fromJson(Map<String, dynamic> json) {
    return RideTraceSample(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      rideId: (json['rideId'] ?? '').toString(),
      passengerId: (json['passengerId'] ?? '').toString(),
      driverId: (json['driverId'] ?? '').toString(),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      heading: _asNullableDouble(json['heading']),
      speed: _asNullableDouble(json['speed']),
      accuracy: _asNullableDouble(json['accuracy']),
      source: (json['source'] ?? '').toString(),
      recordedAt: DateTime.tryParse((json['recordedAt'] ?? '').toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rideId': rideId,
      'passengerId': passengerId,
      'driverId': driverId,
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'speed': speed,
      'accuracy': accuracy,
      'source': source,
      'recordedAt': recordedAt?.toIso8601String(),
    };
  }
}

double _asDouble(dynamic value) => _asNullableDouble(value) ?? 0;

double? _asNullableDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value == null) return null;
  return double.tryParse(value.toString());
}
