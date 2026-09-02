import 'package:json_annotation/json_annotation.dart';

enum PaymentStatusType {
  @JsonValue('new')
  newest,
  failed,
  success,
  transferred,
}
