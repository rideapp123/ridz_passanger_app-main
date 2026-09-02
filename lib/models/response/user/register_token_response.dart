import 'package:json_annotation/json_annotation.dart';

part 'register_token_response.g.dart';

@JsonSerializable()
class RegisterTokenResponse {
  RegisterTokenResponse({required this.success});
  final bool success;

  static RegisterTokenResponse fromJson(Map<String, dynamic> json) =>
      _$RegisterTokenResponseFromJson(json);

  static Map<String, dynamic> toJson(RegisterTokenResponse data) =>
      _$RegisterTokenResponseToJson(data);
}
