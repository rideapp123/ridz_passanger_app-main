import 'package:json_annotation/json_annotation.dart';

import '../../common/user/user.dart';

part 'me_response.g.dart';

@JsonSerializable()
class MeResponse {
  MeResponse({required this.user, required this.message});
  final User user;
  final String? message;

  static MeResponse fromJson(Map<String, dynamic> json) =>
      _$MeResponseFromJson(json);

  static Map<String, dynamic> toJson(MeResponse data) =>
      _$MeResponseToJson(data);
}
