import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';
import 'card.dart';
import '../../../core/enums/user/auth_provider_type.dart';
import '../../../core/helpers/util_helper.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends _User with _$User {
  User({
    super.email,
    super.username,
    String? id,
    super.stripeCustomerId,
    super.mobileNumber,
    super.profilePicture,
    super.referredCount,
    super.referralCode,
    super.authType,
    super.isEmailVerified,
    super.isMobileVerified,
    super.name,
    super.googleId,
    super.card,
    super.createdAt,
    super.updatedAt,
  }) : super(
          id: id ?? '',
        );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  User merge(User other) {
    return User.fromJson(UtilsHelper.mergeObjects(toJson(), other.toJson()));
  }
}

abstract class _User with Store {
  _User({
    this.email,
    this.username,
    this.id = '',
    this.mobileNumber,
    this.profilePicture,
    this.referralCode,
    this.referredCount,
    this.stripeCustomerId,
    this.authType,
    this.isEmailVerified,
    this.isMobileVerified,
    this.name,
    this.googleId,
    this.card,
    this.createdAt,
    this.updatedAt,
  });

  @observable
  String? email;

  @observable
  String? username;

  @observable
  String id;

  @observable
  String? stripeCustomerId;

  @observable
  String? mobileNumber;

  @observable
  @JsonKey(name: 'profile_picture')
  String? profilePicture;

  @observable
  int? referredCount;

  @observable
  String? referralCode;

  @observable
  AuthProviderType? authType;

  @observable
  bool? isEmailVerified;

  @observable
  bool? isMobileVerified;

  @observable
  String? name;

  @observable
  String? googleId;

  @observable
  CardModel? card;

  @observable
  DateTime? createdAt;

  @observable
  DateTime? updatedAt;
}
