// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_card_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetCardResponse _$GetCardResponseFromJson(Map<String, dynamic> json) =>
    GetCardResponse(
      success: json['success'] as bool?,
      cards: (json['cards'] as List<dynamic>?)
          ?.map((e) => CardDetails.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetCardResponseToJson(GetCardResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'cards': instance.cards,
    };

CardDetails _$CardDetailsFromJson(Map<String, dynamic> json) => CardDetails(
      id: json['id'] as String?,
      brand: json['brand'] as String?,
      last4: json['last4'] as String?,
      expMonth: (json['exp_month'] as num?)?.toInt(),
      expYear: (json['exp_year'] as num?)?.toInt(),
      isDefault: json['isDefault'] as bool?,
    );

Map<String, dynamic> _$CardDetailsToJson(CardDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'brand': instance.brand,
      'last4': instance.last4,
      'exp_month': instance.expMonth,
      'exp_year': instance.expYear,
      'isDefault': instance.isDefault,
    };
