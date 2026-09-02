// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      email: json['email'] as String?,
      username: json['username'] as String?,
      id: json['id'] as String?,
      stripeCustomerId: json['stripeCustomerId'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      profilePicture: json['profile_picture'] as String?,
      referredCount: (json['referredCount'] as num?)?.toInt(),
      referralCode: json['referralCode'] as String?,
      authType:
          $enumDecodeNullable(_$AuthProviderTypeEnumMap, json['authType']),
      isEmailVerified: json['isEmailVerified'] as bool?,
      isMobileVerified: json['isMobileVerified'] as bool?,
      name: json['name'] as String?,
      googleId: json['googleId'] as String?,
      card: json['card'] == null
          ? null
          : CardModel.fromJson(json['card'] as Map<String, dynamic>),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'email': instance.email,
      'username': instance.username,
      'id': instance.id,
      'stripeCustomerId': instance.stripeCustomerId,
      'mobileNumber': instance.mobileNumber,
      'profile_picture': instance.profilePicture,
      'referredCount': instance.referredCount,
      'referralCode': instance.referralCode,
      'authType': _$AuthProviderTypeEnumMap[instance.authType],
      'isEmailVerified': instance.isEmailVerified,
      'isMobileVerified': instance.isMobileVerified,
      'name': instance.name,
      'googleId': instance.googleId,
      'card': instance.card,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$AuthProviderTypeEnumMap = {
  AuthProviderType.email: 'email',
  AuthProviderType.google: 'google',
  AuthProviderType.mobile: 'mobile',
};

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$User on _User, Store {
  late final _$emailAtom = Atom(name: '_User.email', context: context);

  @override
  String? get email {
    _$emailAtom.reportRead();
    return super.email;
  }

  @override
  set email(String? value) {
    _$emailAtom.reportWrite(value, super.email, () {
      super.email = value;
    });
  }

  late final _$usernameAtom = Atom(name: '_User.username', context: context);

  @override
  String? get username {
    _$usernameAtom.reportRead();
    return super.username;
  }

  @override
  set username(String? value) {
    _$usernameAtom.reportWrite(value, super.username, () {
      super.username = value;
    });
  }

  late final _$idAtom = Atom(name: '_User.id', context: context);

  @override
  String get id {
    _$idAtom.reportRead();
    return super.id;
  }

  @override
  set id(String value) {
    _$idAtom.reportWrite(value, super.id, () {
      super.id = value;
    });
  }

  late final _$stripeCustomerIdAtom =
      Atom(name: '_User.stripeCustomerId', context: context);

  @override
  String? get stripeCustomerId {
    _$stripeCustomerIdAtom.reportRead();
    return super.stripeCustomerId;
  }

  @override
  set stripeCustomerId(String? value) {
    _$stripeCustomerIdAtom.reportWrite(value, super.stripeCustomerId, () {
      super.stripeCustomerId = value;
    });
  }

  late final _$mobileNumberAtom =
      Atom(name: '_User.mobileNumber', context: context);

  @override
  String? get mobileNumber {
    _$mobileNumberAtom.reportRead();
    return super.mobileNumber;
  }

  @override
  set mobileNumber(String? value) {
    _$mobileNumberAtom.reportWrite(value, super.mobileNumber, () {
      super.mobileNumber = value;
    });
  }

  late final _$profilePictureAtom =
      Atom(name: '_User.profilePicture', context: context);

  @override
  String? get profilePicture {
    _$profilePictureAtom.reportRead();
    return super.profilePicture;
  }

  @override
  set profilePicture(String? value) {
    _$profilePictureAtom.reportWrite(value, super.profilePicture, () {
      super.profilePicture = value;
    });
  }

  late final _$referredCountAtom =
      Atom(name: '_User.referredCount', context: context);

  @override
  int? get referredCount {
    _$referredCountAtom.reportRead();
    return super.referredCount;
  }

  @override
  set referredCount(int? value) {
    _$referredCountAtom.reportWrite(value, super.referredCount, () {
      super.referredCount = value;
    });
  }

  late final _$referralCodeAtom =
      Atom(name: '_User.referralCode', context: context);

  @override
  String? get referralCode {
    _$referralCodeAtom.reportRead();
    return super.referralCode;
  }

  @override
  set referralCode(String? value) {
    _$referralCodeAtom.reportWrite(value, super.referralCode, () {
      super.referralCode = value;
    });
  }

  late final _$authTypeAtom = Atom(name: '_User.authType', context: context);

  @override
  AuthProviderType? get authType {
    _$authTypeAtom.reportRead();
    return super.authType;
  }

  @override
  set authType(AuthProviderType? value) {
    _$authTypeAtom.reportWrite(value, super.authType, () {
      super.authType = value;
    });
  }

  late final _$isEmailVerifiedAtom =
      Atom(name: '_User.isEmailVerified', context: context);

  @override
  bool? get isEmailVerified {
    _$isEmailVerifiedAtom.reportRead();
    return super.isEmailVerified;
  }

  @override
  set isEmailVerified(bool? value) {
    _$isEmailVerifiedAtom.reportWrite(value, super.isEmailVerified, () {
      super.isEmailVerified = value;
    });
  }

  late final _$isMobileVerifiedAtom =
      Atom(name: '_User.isMobileVerified', context: context);

  @override
  bool? get isMobileVerified {
    _$isMobileVerifiedAtom.reportRead();
    return super.isMobileVerified;
  }

  @override
  set isMobileVerified(bool? value) {
    _$isMobileVerifiedAtom.reportWrite(value, super.isMobileVerified, () {
      super.isMobileVerified = value;
    });
  }

  late final _$nameAtom = Atom(name: '_User.name', context: context);

  @override
  String? get name {
    _$nameAtom.reportRead();
    return super.name;
  }

  @override
  set name(String? value) {
    _$nameAtom.reportWrite(value, super.name, () {
      super.name = value;
    });
  }

  late final _$googleIdAtom = Atom(name: '_User.googleId', context: context);

  @override
  String? get googleId {
    _$googleIdAtom.reportRead();
    return super.googleId;
  }

  @override
  set googleId(String? value) {
    _$googleIdAtom.reportWrite(value, super.googleId, () {
      super.googleId = value;
    });
  }

  late final _$cardAtom = Atom(name: '_User.card', context: context);

  @override
  CardModel? get card {
    _$cardAtom.reportRead();
    return super.card;
  }

  @override
  set card(CardModel? value) {
    _$cardAtom.reportWrite(value, super.card, () {
      super.card = value;
    });
  }

  late final _$createdAtAtom = Atom(name: '_User.createdAt', context: context);

  @override
  DateTime? get createdAt {
    _$createdAtAtom.reportRead();
    return super.createdAt;
  }

  @override
  set createdAt(DateTime? value) {
    _$createdAtAtom.reportWrite(value, super.createdAt, () {
      super.createdAt = value;
    });
  }

  late final _$updatedAtAtom = Atom(name: '_User.updatedAt', context: context);

  @override
  DateTime? get updatedAt {
    _$updatedAtAtom.reportRead();
    return super.updatedAt;
  }

  @override
  set updatedAt(DateTime? value) {
    _$updatedAtAtom.reportWrite(value, super.updatedAt, () {
      super.updatedAt = value;
    });
  }

  @override
  String toString() {
    return '''
email: ${email},
username: ${username},
id: ${id},
stripeCustomerId: ${stripeCustomerId},
mobileNumber: ${mobileNumber},
profilePicture: ${profilePicture},
referredCount: ${referredCount},
referralCode: ${referralCode},
authType: ${authType},
isEmailVerified: ${isEmailVerified},
isMobileVerified: ${isMobileVerified},
name: ${name},
googleId: ${googleId},
card: ${card},
createdAt: ${createdAt},
updatedAt: ${updatedAt}
    ''';
  }
}
