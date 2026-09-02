// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardModel _$CardModelFromJson(Map<String, dynamic> json) => CardModel(
      holderName: json['holder_name'] as String?,
      cardNumber: json['card_number'] as String?,
      expiryDate: json['expiry_date'] as String?,
      cvv: json['cvv'] as String?,
    )
      ..cardId = json['cardId'] as String?
      ..brandName = json['brandName'] as String?;

Map<String, dynamic> _$CardModelToJson(CardModel instance) => <String, dynamic>{
      'cardId': instance.cardId,
      'brandName': instance.brandName,
      'holder_name': instance.holderName,
      'card_number': instance.cardNumber,
      'expiry_date': instance.expiryDate,
      'cvv': instance.cvv,
    };

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CardModel on _CardModel, Store {
  late final _$cardIdAtom = Atom(name: '_CardModel.cardId', context: context);

  @override
  String? get cardId {
    _$cardIdAtom.reportRead();
    return super.cardId;
  }

  @override
  set cardId(String? value) {
    _$cardIdAtom.reportWrite(value, super.cardId, () {
      super.cardId = value;
    });
  }

  late final _$brandNameAtom =
      Atom(name: '_CardModel.brandName', context: context);

  @override
  String? get brandName {
    _$brandNameAtom.reportRead();
    return super.brandName;
  }

  @override
  set brandName(String? value) {
    _$brandNameAtom.reportWrite(value, super.brandName, () {
      super.brandName = value;
    });
  }

  late final _$holderNameAtom =
      Atom(name: '_CardModel.holderName', context: context);

  @override
  String? get holderName {
    _$holderNameAtom.reportRead();
    return super.holderName;
  }

  @override
  set holderName(String? value) {
    _$holderNameAtom.reportWrite(value, super.holderName, () {
      super.holderName = value;
    });
  }

  late final _$cardNumberAtom =
      Atom(name: '_CardModel.cardNumber', context: context);

  @override
  String? get cardNumber {
    _$cardNumberAtom.reportRead();
    return super.cardNumber;
  }

  @override
  set cardNumber(String? value) {
    _$cardNumberAtom.reportWrite(value, super.cardNumber, () {
      super.cardNumber = value;
    });
  }

  late final _$expiryDateAtom =
      Atom(name: '_CardModel.expiryDate', context: context);

  @override
  String? get expiryDate {
    _$expiryDateAtom.reportRead();
    return super.expiryDate;
  }

  @override
  set expiryDate(String? value) {
    _$expiryDateAtom.reportWrite(value, super.expiryDate, () {
      super.expiryDate = value;
    });
  }

  late final _$cvvAtom = Atom(name: '_CardModel.cvv', context: context);

  @override
  String? get cvv {
    _$cvvAtom.reportRead();
    return super.cvv;
  }

  @override
  set cvv(String? value) {
    _$cvvAtom.reportWrite(value, super.cvv, () {
      super.cvv = value;
    });
  }

  @override
  String toString() {
    return '''
cardId: ${cardId},
brandName: ${brandName},
holderName: ${holderName},
cardNumber: ${cardNumber},
expiryDate: ${expiryDate},
cvv: ${cvv}
    ''';
  }
}
