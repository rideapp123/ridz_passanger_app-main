// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverLocation _$DriverLocationFromJson(Map<String, dynamic> json) =>
    DriverLocation(
      driverId: json['driverId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isAvailable: json['isAvailable'] as bool,
      vehicle: json['vehicle'] == null
          ? null
          : VehicleInfo.fromJson(json['vehicle'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DriverLocationToJson(DriverLocation instance) =>
    <String, dynamic>{
      'driverId': instance.driverId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'heading': instance.heading,
      'speed': instance.speed,
      'timestamp': instance.timestamp.toIso8601String(),
      'isAvailable': instance.isAvailable,
      'vehicle': instance.vehicle,
    };

VehicleInfo _$VehicleInfoFromJson(Map<String, dynamic> json) => VehicleInfo(
      plateNumber: json['plateNumber'] as String,
      model: json['model'] as String,
      color: json['color'] as String,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$VehicleInfoToJson(VehicleInfo instance) =>
    <String, dynamic>{
      'plateNumber': instance.plateNumber,
      'model': instance.model,
      'color': instance.color,
      'type': instance.type,
    };

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$DriverLocation on _DriverLocation, Store {
  Computed<LatLng>? _$positionComputed;

  @override
  LatLng get position =>
      (_$positionComputed ??= Computed<LatLng>(() => super.position,
              name: '_DriverLocation.position'))
          .value;
  Computed<String>? _$formattedSpeedComputed;

  @override
  String get formattedSpeed =>
      (_$formattedSpeedComputed ??= Computed<String>(() => super.formattedSpeed,
              name: '_DriverLocation.formattedSpeed'))
          .value;

  late final _$driverIdAtom =
      Atom(name: '_DriverLocation.driverId', context: context);

  @override
  String get driverId {
    _$driverIdAtom.reportRead();
    return super.driverId;
  }

  @override
  set driverId(String value) {
    _$driverIdAtom.reportWrite(value, super.driverId, () {
      super.driverId = value;
    });
  }

  late final _$latitudeAtom =
      Atom(name: '_DriverLocation.latitude', context: context);

  @override
  double get latitude {
    _$latitudeAtom.reportRead();
    return super.latitude;
  }

  @override
  set latitude(double value) {
    _$latitudeAtom.reportWrite(value, super.latitude, () {
      super.latitude = value;
    });
  }

  late final _$longitudeAtom =
      Atom(name: '_DriverLocation.longitude', context: context);

  @override
  double get longitude {
    _$longitudeAtom.reportRead();
    return super.longitude;
  }

  @override
  set longitude(double value) {
    _$longitudeAtom.reportWrite(value, super.longitude, () {
      super.longitude = value;
    });
  }

  late final _$headingAtom =
      Atom(name: '_DriverLocation.heading', context: context);

  @override
  double? get heading {
    _$headingAtom.reportRead();
    return super.heading;
  }

  @override
  set heading(double? value) {
    _$headingAtom.reportWrite(value, super.heading, () {
      super.heading = value;
    });
  }

  late final _$speedAtom =
      Atom(name: '_DriverLocation.speed', context: context);

  @override
  double? get speed {
    _$speedAtom.reportRead();
    return super.speed;
  }

  @override
  set speed(double? value) {
    _$speedAtom.reportWrite(value, super.speed, () {
      super.speed = value;
    });
  }

  late final _$timestampAtom =
      Atom(name: '_DriverLocation.timestamp', context: context);

  @override
  DateTime get timestamp {
    _$timestampAtom.reportRead();
    return super.timestamp;
  }

  @override
  set timestamp(DateTime value) {
    _$timestampAtom.reportWrite(value, super.timestamp, () {
      super.timestamp = value;
    });
  }

  late final _$isAvailableAtom =
      Atom(name: '_DriverLocation.isAvailable', context: context);

  @override
  bool get isAvailable {
    _$isAvailableAtom.reportRead();
    return super.isAvailable;
  }

  @override
  set isAvailable(bool value) {
    _$isAvailableAtom.reportWrite(value, super.isAvailable, () {
      super.isAvailable = value;
    });
  }

  late final _$vehicleAtom =
      Atom(name: '_DriverLocation.vehicle', context: context);

  @override
  VehicleInfo? get vehicle {
    _$vehicleAtom.reportRead();
    return super.vehicle;
  }

  @override
  set vehicle(VehicleInfo? value) {
    _$vehicleAtom.reportWrite(value, super.vehicle, () {
      super.vehicle = value;
    });
  }

  @override
  String toString() {
    return '''
driverId: ${driverId},
latitude: ${latitude},
longitude: ${longitude},
heading: ${heading},
speed: ${speed},
timestamp: ${timestamp},
isAvailable: ${isAvailable},
vehicle: ${vehicle},
position: ${position},
formattedSpeed: ${formattedSpeed}
    ''';
  }
}

mixin _$VehicleInfo on _VehicleInfo, Store {
  Computed<String>? _$displayInfoComputed;

  @override
  String get displayInfo =>
      (_$displayInfoComputed ??= Computed<String>(() => super.displayInfo,
              name: '_VehicleInfo.displayInfo'))
          .value;

  late final _$plateNumberAtom =
      Atom(name: '_VehicleInfo.plateNumber', context: context);

  @override
  String get plateNumber {
    _$plateNumberAtom.reportRead();
    return super.plateNumber;
  }

  @override
  set plateNumber(String value) {
    _$plateNumberAtom.reportWrite(value, super.plateNumber, () {
      super.plateNumber = value;
    });
  }

  late final _$modelAtom = Atom(name: '_VehicleInfo.model', context: context);

  @override
  String get model {
    _$modelAtom.reportRead();
    return super.model;
  }

  @override
  set model(String value) {
    _$modelAtom.reportWrite(value, super.model, () {
      super.model = value;
    });
  }

  late final _$colorAtom = Atom(name: '_VehicleInfo.color', context: context);

  @override
  String get color {
    _$colorAtom.reportRead();
    return super.color;
  }

  @override
  set color(String value) {
    _$colorAtom.reportWrite(value, super.color, () {
      super.color = value;
    });
  }

  late final _$typeAtom = Atom(name: '_VehicleInfo.type', context: context);

  @override
  String? get type {
    _$typeAtom.reportRead();
    return super.type;
  }

  @override
  set type(String? value) {
    _$typeAtom.reportWrite(value, super.type, () {
      super.type = value;
    });
  }

  @override
  String toString() {
    return '''
plateNumber: ${plateNumber},
model: ${model},
color: ${color},
type: ${type},
displayInfo: ${displayInfo}
    ''';
  }
}
