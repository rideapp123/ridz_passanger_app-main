import 'package:json_annotation/json_annotation.dart';

part 'send_otp_contract.g.dart';

@JsonSerializable()
class SendOtpContract {
  SendOtpContract({required this.recipient});
  final String recipient;

  static SendOtpContract fromJson(Map<String, dynamic> json) =>
      _$SendOtpContractFromJson(json);

  static Map<String, dynamic> toJson(SendOtpContract data) =>
      _$SendOtpContractToJson(data);
}
