import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';

part 'card.g.dart';

@JsonSerializable()
class CardModel extends _CardModel with _$CardModel {
  CardModel({
    super.holderName,
    super.cardNumber,
    super.expiryDate,
    super.cvv,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) => _$CardModelFromJson(json);

  Map<String, dynamic> toJson() => _$CardModelToJson(this);
}

abstract class _CardModel with Store {
  _CardModel({
    this.holderName,
    this.cardNumber,
    this.expiryDate,
    this.cvv,
  });

  @observable
  String? cardId;

  @observable
  String? brandName;

  @observable
  @JsonKey(name: 'holder_name')
  String? holderName;

  @observable
  @JsonKey(name: 'card_number')
  String? cardNumber;

  @observable
  @JsonKey(name: 'expiry_date')
  String? expiryDate;

  @observable
  String? cvv;
}
