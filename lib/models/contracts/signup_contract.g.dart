// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_contract.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignUpContract _$SignUpContractFromJson(Map<String, dynamic> json) =>
    SignUpContract(
      firstName: json['first_name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      referralCode: json['referral_code'] as String?,
    );

Map<String, dynamic> _$SignUpContractToJson(SignUpContract instance) =>
    <String, dynamic>{
      'first_name': instance.firstName,
      'email': instance.email,
      'password': instance.password,
      'referral_code': instance.referralCode,
    };
