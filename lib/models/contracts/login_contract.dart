import 'package:json_annotation/json_annotation.dart';

part 'login_contract.g.dart';

@JsonSerializable()
class LoginContract {
  LoginContract({required this.recipient, required this.otp});
  final String recipient;
  final String otp;

  static LoginContract fromJson(Map<String, dynamic> json) =>
      _$LoginContractFromJson(json);

  static Map<String, dynamic> toJson(LoginContract data) =>
      _$LoginContractToJson(data);
}
