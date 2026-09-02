import 'package:json_annotation/json_annotation.dart';

part 'send_otp_response.g.dart';

@JsonSerializable()
class SendOtpResponse {
  SendOtpResponse(
      {required this.resend, required this.success, required this.message});
  final bool? success;
  final bool? resend;
  final String? message;

  static SendOtpResponse fromJson(Map<String, dynamic> json) =>
      _$SendOtpResponseFromJson(json);

  static Map<String, dynamic> toJson(SendOtpResponse data) =>
      _$SendOtpResponseToJson(data);
}
