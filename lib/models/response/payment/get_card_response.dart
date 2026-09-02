import 'package:json_annotation/json_annotation.dart';

part 'get_card_response.g.dart';

@JsonSerializable()
class GetCardResponse {
  @JsonKey(name: "success")
  final bool? success;
  @JsonKey(name: "cards")
  final List<CardDetails>? cards;

  GetCardResponse({
    this.success,
    this.cards,
  });

  factory GetCardResponse.fromJson(Map<String, dynamic> json) {
    return _$GetCardResponseFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$GetCardResponseToJson(this);
  }
}

@JsonSerializable()
class CardDetails {
  @JsonKey(name: "id")
  final String? id;
  @JsonKey(name: "brand")
  final String? brand;
  @JsonKey(name: "last4")
  final String? last4;
  @JsonKey(name: "exp_month")
  final int? expMonth;
  @JsonKey(name: "exp_year")
  final int? expYear;
  @JsonKey(name: "isDefault")
  final bool? isDefault;

  CardDetails({
    this.id,
    this.brand,
    this.last4,
    this.expMonth,
    this.expYear,
    this.isDefault,
  });

  factory CardDetails.fromJson(Map<String, dynamic> json) {
    return _$CardDetailsFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$CardDetailsToJson(this);
  }
}
