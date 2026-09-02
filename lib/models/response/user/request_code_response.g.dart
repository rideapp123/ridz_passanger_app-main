// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_code_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestCodeResponse _$RequestCodeResponseFromJson(Map<String, dynamic> json) =>
    RequestCodeResponse(
      success: json['success'] as bool,
      resend: json['resend'] as bool,
      message: json['message'] as String?,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$RequestCodeResponseToJson(
        RequestCodeResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'resend': instance.resend,
      'error': instance.error,
      'message': instance.message,
    };
