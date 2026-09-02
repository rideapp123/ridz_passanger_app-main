import 'package:json_annotation/json_annotation.dart';

import '../../common/user/user.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  LoginResponse(
      {required this.user, required this.token,required this.isNewUser, required this.message});
  final User user;
  final String token;
  final bool isNewUser;
  final String? message;

  static LoginResponse fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  static Map<String, dynamic> toJson(LoginResponse data) =>
      _$LoginResponseToJson(data);
}
