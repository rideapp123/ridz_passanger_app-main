import 'package:json_annotation/json_annotation.dart';

part 'request_code_response.g.dart';

@JsonSerializable()
class RequestCodeResponse {
  RequestCodeResponse(
      {required this.success,
      required this.resend,
      required this.message,
      required this.error});
  final bool success;
  final bool resend;
  final String? error;
  final String? message;

  static RequestCodeResponse fromJson(Map<String, dynamic> json) =>
      _$RequestCodeResponseFromJson(json);

  static Map<String, dynamic> toJson(RequestCodeResponse data) =>
      _$RequestCodeResponseToJson(data);
}
