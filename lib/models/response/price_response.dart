import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';

import '../../core/enums/ride.dart';
part 'price_response.g.dart';
@JsonSerializable()
class PriceResponse {
  PriceResponse({required this.pricing});

  final List<Price> pricing;

  factory PriceResponse.fromJson(Map<String, dynamic> json) =>
      _$PriceResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PriceResponseToJson(this);
}

@JsonSerializable()
class Price extends _Price with _$Price {
  Price({
    required super.taxes,
    required super.vehicleType,
    required super.basePrice,
    required super.minimumFare,
    required super.perKilometer,
    required super.perMinute,
    required super.waitingChargePerMinute,
    required super.cancellationFee,
    required super.peakHourMultiplier,
    required super.nightChargeMultiplier,
    required super.isActive,
    required super.lastUpdatedBy,
    required super.surgeMultipliers,
    required super.specialZones,
    required super.createdAt,
    required super.updatedAt,
    required super.id,
  });

  factory Price.fromJson(Map<String, dynamic> json) => _$PriceFromJson(json);

  Map<String, dynamic> toJson() => _$PriceToJson(this);
}

abstract class _Price with Store {
  _Price({
    required this.taxes,
    required this.vehicleType,
    required this.basePrice,
    required this.minimumFare,
    required this.perKilometer,
    required this.perMinute,
    required this.waitingChargePerMinute,
    required this.cancellationFee,
    required this.peakHourMultiplier,
    required this.nightChargeMultiplier,
    required this.isActive,
    required this.lastUpdatedBy,
    required this.surgeMultipliers,
    required this.specialZones,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
  });

  @observable
  @JsonKey(name: 'taxes')
  TaxesModel taxes;

  @observable
  CarType vehicleType;

  @observable
  double basePrice;

  @observable
  double minimumFare;

  @observable
  double perKilometer;

  @observable
  double perMinute;

  @observable
  double waitingChargePerMinute;

  @observable
  double cancellationFee;

  @observable
  double peakHourMultiplier;

  @observable
  double nightChargeMultiplier;

  @observable
  bool isActive;

  @observable
  String lastUpdatedBy;

  @observable
  List<double> surgeMultipliers;

  @observable
  List<String> specialZones;

  @observable
  DateTime createdAt;

  @observable
  DateTime updatedAt;

  @observable
  @JsonKey(name: '_id')
  String id;
}

@JsonSerializable()
class TaxesModel {
  TaxesModel({
    required this.serviceCharge,
    required this.gst,
  });

  final double serviceCharge;
  final double gst;

  factory TaxesModel.fromJson(Map<String, dynamic> json) =>
      _$TaxesModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaxesModelToJson(this);
}