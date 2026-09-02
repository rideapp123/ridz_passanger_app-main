class AllPromocodeResponseModel {
  bool? success;
  String? message;
  AllPromocodeData? data;

  AllPromocodeResponseModel({this.success, this.message, this.data});

  AllPromocodeResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data =
        json['data'] != null ? AllPromocodeData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class AllPromocodeData {
  List<Bonuses>? bonuses;
  int? total;

  AllPromocodeData({this.bonuses, this.total});

  AllPromocodeData.fromJson(Map<String, dynamic> json) {
    if (json['bonuses'] != null) {
      bonuses = <Bonuses>[];
      json['bonuses'].forEach((v) {
        bonuses!.add(Bonuses.fromJson(v));
      });
    }
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (bonuses != null) {
      data['bonuses'] = bonuses!.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    return data;
  }
}

class Bonuses {
  String? code;
  String? type;
  int? value;
  String? description;
  int? minRideValue;
  int? maxAmount;
  String? endDate;
  int? remainingUses;

  Bonuses(
      {this.code,
      this.type,
      this.value,
      this.description,
      this.minRideValue,
      this.maxAmount,
      this.endDate,
      this.remainingUses});

  Bonuses.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    type = json['type'];
    value = json['value'];
    description = json['description'];
    minRideValue = json['minRideValue'];
    maxAmount = json['maxAmount'];
    endDate = json['endDate'];
    remainingUses = json['remainingUses'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['type'] = type;
    data['value'] = value;
    data['description'] = description;
    data['minRideValue'] = minRideValue;
    data['maxAmount'] = maxAmount;
    data['endDate'] = endDate;
    data['remainingUses'] = remainingUses;
    return data;
  }
}
