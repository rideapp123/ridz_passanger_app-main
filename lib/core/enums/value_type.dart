import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum RewardType {
  @JsonValue('offer')
  offer,
  @JsonValue('discount')
  discount,
  @JsonValue('service')
  service,
  @JsonValue('unknown')
  unknown,
}

enum ValueType {
  @JsonValue('percent')
  percentage,
  @JsonValue('absolute')
  absolute,
  @JsonValue('unknown')
  unknown,
}
