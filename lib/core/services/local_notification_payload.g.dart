// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_notification_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalNotificationPayload _$LocalNotificationPayloadFromJson(
        Map<String, dynamic> json) =>
    LocalNotificationPayload(
      title: json['title'] as String,
      details: json['details'],
    );

Map<String, dynamic> _$LocalNotificationPayloadToJson(
        LocalNotificationPayload instance) =>
    <String, dynamic>{
      'title': instance.title,
      'details': instance.details,
    };
