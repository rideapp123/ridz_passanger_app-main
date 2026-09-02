// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_details_update_contract.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDetailsUpdateContract _$UserDetailsUpdateContractFromJson(
        Map<String, dynamic> json) =>
    UserDetailsUpdateContract(
      username: json['username'] as String?,
      email: json['email'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      profilePicture: json['profile_picture'] as String?,
      card: json['card'] == null
          ? null
          : CardModel.fromJson(json['card'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserDetailsUpdateContractToJson(
        UserDetailsUpdateContract instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'mobileNumber': instance.mobileNumber,
      'profile_picture': instance.profilePicture,
      'card': instance.card,
    };
