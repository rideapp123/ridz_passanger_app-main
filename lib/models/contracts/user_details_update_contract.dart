import 'package:json_annotation/json_annotation.dart';
import 'package:ridzs_passenger_app/models/common/user/card.dart';

part 'user_details_update_contract.g.dart';

@JsonSerializable()
class UserDetailsUpdateContract {
  UserDetailsUpdateContract({
    this.username,
    this.email,
    this.mobileNumber,
    this.profilePicture,
    this.card,
  });

  factory UserDetailsUpdateContract.fromJson(Map<String, dynamic> json) =>
      _$UserDetailsUpdateContractFromJson(json);
  final String? username;

  final String? email;
  final String? mobileNumber;
  @JsonKey(name: 'profile_picture')
  final String? profilePicture;
  final CardModel? card;

  static Map<String, dynamic> toJson(UserDetailsUpdateContract data) =>
      _$UserDetailsUpdateContractToJson(data);
}
