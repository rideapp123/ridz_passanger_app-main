// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_contract.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginContract _$LoginContractFromJson(Map<String, dynamic> json) =>
    LoginContract(
      recipient: json['recipient'] as String,
      otp: json['otp'] as String,
    );

Map<String, dynamic> _$LoginContractToJson(LoginContract instance) =>
    <String, dynamic>{
      'recipient': instance.recipient,
      'otp': instance.otp,
    };
