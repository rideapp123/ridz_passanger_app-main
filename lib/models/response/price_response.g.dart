// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PriceResponse _$PriceResponseFromJson(Map<String, dynamic> json) =>
    PriceResponse(
      pricing: (json['pricing'] as List<dynamic>)
          .map((e) => Price.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PriceResponseToJson(PriceResponse instance) =>
    <String, dynamic>{
      'pricing': instance.pricing,
    };

Price _$PriceFromJson(Map<String, dynamic> json) => Price(
      taxes: TaxesModel.fromJson(json['taxes'] as Map<String, dynamic>),
      vehicleType: $enumDecode(_$CarTypeEnumMap, json['vehicleType']),
      basePrice: (json['basePrice'] as num).toDouble(),
      minimumFare: (json['minimumFare'] as num).toDouble(),
      perKilometer: (json['perKilometer'] as num).toDouble(),
      perMinute: (json['perMinute'] as num).toDouble(),
      waitingChargePerMinute:
          (json['waitingChargePerMinute'] as num).toDouble(),
      cancellationFee: (json['cancellationFee'] as num).toDouble(),
      peakHourMultiplier: (json['peakHourMultiplier'] as num).toDouble(),
      nightChargeMultiplier: (json['nightChargeMultiplier'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      lastUpdatedBy: json['lastUpdatedBy'] as String,
      surgeMultipliers: (json['surgeMultipliers'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      specialZones: (json['specialZones'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      id: json['_id'] as String,
    );

Map<String, dynamic> _$PriceToJson(Price instance) => <String, dynamic>{
      'taxes': instance.taxes,
      'vehicleType': instance.vehicleType,
      'basePrice': instance.basePrice,
      'minimumFare': instance.minimumFare,
      'perKilometer': instance.perKilometer,
      'perMinute': instance.perMinute,
      'waitingChargePerMinute': instance.waitingChargePerMinute,
      'cancellationFee': instance.cancellationFee,
      'peakHourMultiplier': instance.peakHourMultiplier,
      'nightChargeMultiplier': instance.nightChargeMultiplier,
      'isActive': instance.isActive,
      'lastUpdatedBy': instance.lastUpdatedBy,
      'surgeMultipliers': instance.surgeMultipliers,
      'specialZones': instance.specialZones,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      '_id': instance.id,
    };

const _$CarTypeEnumMap = {
  CarType.standard: 'standard',
  CarType.comfort: 'comfort',
  CarType.xl: 'xl',
  CarType.luxury: 'luxury',
  CarType.electric: 'electric',
};

TaxesModel _$TaxesModelFromJson(Map<String, dynamic> json) => TaxesModel(
      serviceCharge: (json['serviceCharge'] as num).toDouble(),
      gst: (json['gst'] as num).toDouble(),
    );

Map<String, dynamic> _$TaxesModelToJson(TaxesModel instance) =>
    <String, dynamic>{
      'serviceCharge': instance.serviceCharge,
      'gst': instance.gst,
    };

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$Price on _Price, Store {
  late final _$taxesAtom = Atom(name: '_Price.taxes', context: context);

  @override
  TaxesModel get taxes {
    _$taxesAtom.reportRead();
    return super.taxes;
  }

  @override
  set taxes(TaxesModel value) {
    _$taxesAtom.reportWrite(value, super.taxes, () {
      super.taxes = value;
    });
  }

  late final _$vehicleTypeAtom =
      Atom(name: '_Price.vehicleType', context: context);

  @override
  CarType get vehicleType {
    _$vehicleTypeAtom.reportRead();
    return super.vehicleType;
  }

  @override
  set vehicleType(CarType value) {
    _$vehicleTypeAtom.reportWrite(value, super.vehicleType, () {
      super.vehicleType = value;
    });
  }

  late final _$basePriceAtom = Atom(name: '_Price.basePrice', context: context);

  @override
  double get basePrice {
    _$basePriceAtom.reportRead();
    return super.basePrice;
  }

  @override
  set basePrice(double value) {
    _$basePriceAtom.reportWrite(value, super.basePrice, () {
      super.basePrice = value;
    });
  }

  late final _$minimumFareAtom =
      Atom(name: '_Price.minimumFare', context: context);

  @override
  double get minimumFare {
    _$minimumFareAtom.reportRead();
    return super.minimumFare;
  }

  @override
  set minimumFare(double value) {
    _$minimumFareAtom.reportWrite(value, super.minimumFare, () {
      super.minimumFare = value;
    });
  }

  late final _$perKilometerAtom =
      Atom(name: '_Price.perKilometer', context: context);

  @override
  double get perKilometer {
    _$perKilometerAtom.reportRead();
    return super.perKilometer;
  }

  @override
  set perKilometer(double value) {
    _$perKilometerAtom.reportWrite(value, super.perKilometer, () {
      super.perKilometer = value;
    });
  }

  late final _$perMinuteAtom = Atom(name: '_Price.perMinute', context: context);

  @override
  double get perMinute {
    _$perMinuteAtom.reportRead();
    return super.perMinute;
  }

  @override
  set perMinute(double value) {
    _$perMinuteAtom.reportWrite(value, super.perMinute, () {
      super.perMinute = value;
    });
  }

  late final _$waitingChargePerMinuteAtom =
      Atom(name: '_Price.waitingChargePerMinute', context: context);

  @override
  double get waitingChargePerMinute {
    _$waitingChargePerMinuteAtom.reportRead();
    return super.waitingChargePerMinute;
  }

  @override
  set waitingChargePerMinute(double value) {
    _$waitingChargePerMinuteAtom
        .reportWrite(value, super.waitingChargePerMinute, () {
      super.waitingChargePerMinute = value;
    });
  }

  late final _$cancellationFeeAtom =
      Atom(name: '_Price.cancellationFee', context: context);

  @override
  double get cancellationFee {
    _$cancellationFeeAtom.reportRead();
    return super.cancellationFee;
  }

  @override
  set cancellationFee(double value) {
    _$cancellationFeeAtom.reportWrite(value, super.cancellationFee, () {
      super.cancellationFee = value;
    });
  }

  late final _$peakHourMultiplierAtom =
      Atom(name: '_Price.peakHourMultiplier', context: context);

  @override
  double get peakHourMultiplier {
    _$peakHourMultiplierAtom.reportRead();
    return super.peakHourMultiplier;
  }

  @override
  set peakHourMultiplier(double value) {
    _$peakHourMultiplierAtom.reportWrite(value, super.peakHourMultiplier, () {
      super.peakHourMultiplier = value;
    });
  }

  late final _$nightChargeMultiplierAtom =
      Atom(name: '_Price.nightChargeMultiplier', context: context);

  @override
  double get nightChargeMultiplier {
    _$nightChargeMultiplierAtom.reportRead();
    return super.nightChargeMultiplier;
  }

  @override
  set nightChargeMultiplier(double value) {
    _$nightChargeMultiplierAtom.reportWrite(value, super.nightChargeMultiplier,
        () {
      super.nightChargeMultiplier = value;
    });
  }

  late final _$isActiveAtom = Atom(name: '_Price.isActive', context: context);

  @override
  bool get isActive {
    _$isActiveAtom.reportRead();
    return super.isActive;
  }

  @override
  set isActive(bool value) {
    _$isActiveAtom.reportWrite(value, super.isActive, () {
      super.isActive = value;
    });
  }

  late final _$lastUpdatedByAtom =
      Atom(name: '_Price.lastUpdatedBy', context: context);

  @override
  String get lastUpdatedBy {
    _$lastUpdatedByAtom.reportRead();
    return super.lastUpdatedBy;
  }

  @override
  set lastUpdatedBy(String value) {
    _$lastUpdatedByAtom.reportWrite(value, super.lastUpdatedBy, () {
      super.lastUpdatedBy = value;
    });
  }

  late final _$surgeMultipliersAtom =
      Atom(name: '_Price.surgeMultipliers', context: context);

  @override
  List<double> get surgeMultipliers {
    _$surgeMultipliersAtom.reportRead();
    return super.surgeMultipliers;
  }

  @override
  set surgeMultipliers(List<double> value) {
    _$surgeMultipliersAtom.reportWrite(value, super.surgeMultipliers, () {
      super.surgeMultipliers = value;
    });
  }

  late final _$specialZonesAtom =
      Atom(name: '_Price.specialZones', context: context);

  @override
  List<String> get specialZones {
    _$specialZonesAtom.reportRead();
    return super.specialZones;
  }

  @override
  set specialZones(List<String> value) {
    _$specialZonesAtom.reportWrite(value, super.specialZones, () {
      super.specialZones = value;
    });
  }

  late final _$createdAtAtom = Atom(name: '_Price.createdAt', context: context);

  @override
  DateTime get createdAt {
    _$createdAtAtom.reportRead();
    return super.createdAt;
  }

  @override
  set createdAt(DateTime value) {
    _$createdAtAtom.reportWrite(value, super.createdAt, () {
      super.createdAt = value;
    });
  }

  late final _$updatedAtAtom = Atom(name: '_Price.updatedAt', context: context);

  @override
  DateTime get updatedAt {
    _$updatedAtAtom.reportRead();
    return super.updatedAt;
  }

  @override
  set updatedAt(DateTime value) {
    _$updatedAtAtom.reportWrite(value, super.updatedAt, () {
      super.updatedAt = value;
    });
  }

  late final _$idAtom = Atom(name: '_Price.id', context: context);

  @override
  String get id {
    _$idAtom.reportRead();
    return super.id;
  }

  @override
  set id(String value) {
    _$idAtom.reportWrite(value, super.id, () {
      super.id = value;
    });
  }

  @override
  String toString() {
    return '''
taxes: ${taxes},
vehicleType: ${vehicleType},
basePrice: ${basePrice},
minimumFare: ${minimumFare},
perKilometer: ${perKilometer},
perMinute: ${perMinute},
waitingChargePerMinute: ${waitingChargePerMinute},
cancellationFee: ${cancellationFee},
peakHourMultiplier: ${peakHourMultiplier},
nightChargeMultiplier: ${nightChargeMultiplier},
isActive: ${isActive},
lastUpdatedBy: ${lastUpdatedBy},
surgeMultipliers: ${surgeMultipliers},
specialZones: ${specialZones},
createdAt: ${createdAt},
updatedAt: ${updatedAt},
id: ${id}
    ''';
  }
}
