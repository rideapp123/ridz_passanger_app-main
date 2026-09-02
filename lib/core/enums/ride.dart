enum CarType {
  standard,
  comfort,
  xl,
  luxury,
  electric;

  String toJson() => name;

  static CarType fromJson(String json) {
    return CarType.values.firstWhere(
      (type) => type.name == json,
      orElse: () => throw ArgumentError('Invalid CarType: $json'),
    );
  }
}

// Rest of the enums remain the same
enum RideStatus {
  requested('requested'),
  searching('searching'),
  accepted('accepted'),
  arrived('arrived'),
  started('started'),
  completed('completed'),
  cancelled('cancelled');

  static RideStatus? fromString(String value) {
    return RideStatus.values.firstWhere(
      (status) => status.title == value,
      orElse: () => cancelled,
    );
  }

  final String title;
  const RideStatus(this.title);
}

enum PaymentMethod { wallet, card }
