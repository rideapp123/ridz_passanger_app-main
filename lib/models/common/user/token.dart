import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';

part 'token.g.dart';

@JsonSerializable()
class Token extends _Token with _$Token {
  Token(super.type, super.token);

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);

  Map<String, dynamic> toJson() => _$TokenToJson(this);
}

abstract class _Token with Store {
  _Token(this.type, this.token);
  @observable
  String type;

  @observable
  String token;
}
