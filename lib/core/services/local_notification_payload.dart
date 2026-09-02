import 'package:json_annotation/json_annotation.dart';

part 'local_notification_payload.g.dart';

@JsonSerializable()
class LocalNotificationPayload {
  LocalNotificationPayload({required this.title, required this.details});

  factory LocalNotificationPayload.fromJson(Map<String, dynamic> json) =>
      _$LocalNotificationPayloadFromJson(json);

  final String title;
  final dynamic details;

  Map<String, dynamic> toJson() => _$LocalNotificationPayloadToJson(this);
}
