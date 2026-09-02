import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'driver_location.g.dart';

@JsonSerializable()
class DriverLocation extends _DriverLocation with _$DriverLocation {
  DriverLocation({
    required String driverId,
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
    required DateTime timestamp,
    required bool isAvailable,
    VehicleInfo? vehicle,
  }) : super(driverId, latitude, longitude, heading, speed, timestamp, isAvailable, vehicle);

  factory DriverLocation.fromJson(Map<String, dynamic> json) =>
      _$DriverLocationFromJson(json);
  Map<String, dynamic> toJson() => _$DriverLocationToJson(this);
}

abstract class _DriverLocation with Store {
  _DriverLocation(
      this.driverId,
      this.latitude,
      this.longitude,
      this.heading,
      this.speed,
      this.timestamp,
      this.isAvailable,
      this.vehicle,
      );

  @observable
  String driverId;

  @observable
  double latitude;

  @observable
  double longitude;

  @observable
  double? heading;

  @observable
  double? speed;

  @observable
  DateTime timestamp;

  @observable
  bool isAvailable;

  @observable
  VehicleInfo? vehicle;

  @computed
  LatLng get position => LatLng(latitude, longitude);

  @computed
  String get formattedSpeed => speed != null ? '${speed!.toStringAsFixed(1)} km/h' : 'N/A';
}

@JsonSerializable()
class VehicleInfo extends _VehicleInfo with _$VehicleInfo {
  VehicleInfo({
    required String plateNumber,
    required String model,
    required String color,
    String? type,
  }) : super(plateNumber, model, color, type);

  factory VehicleInfo.fromJson(Map<String, dynamic> json) =>
      _$VehicleInfoFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleInfoToJson(this);
}

abstract class _VehicleInfo with Store {
  _VehicleInfo(
      this.plateNumber,
      this.model,
      this.color,
      this.type,
      );

  @observable
  String plateNumber;

  @observable
  String model;

  @observable
  String color;

  @observable
  String? type;

  @computed
  String get displayInfo => '$color $model ($plateNumber)';
}