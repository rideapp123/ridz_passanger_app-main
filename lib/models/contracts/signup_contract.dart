import 'package:json_annotation/json_annotation.dart';

part 'signup_contract.g.dart';

@JsonSerializable()
class SignUpContract {
  SignUpContract(
      {required this.firstName,
      // required this.last_name,
      required this.email,
      required this.password,
      this.referralCode});

  factory SignUpContract.fromJson(Map<String, dynamic> json) =>
      _$SignUpContractFromJson(json);
  @JsonKey(name: 'first_name')
  final String firstName;
  //final String last_name;
  final String email;
  final String password;
  @JsonKey(name: 'referral_code')
  String? referralCode;

  static Map<String, dynamic> toJson(SignUpContract data) =>
      _$SignUpContractToJson(data);
}
