class RideHistoryResponse {
  final bool success;
  final String message;
  final List<Ride> rides;
  final Pagination pagination;

  RideHistoryResponse({
    required this.success,
    required this.message,
    required this.rides,
    required this.pagination,
  });

  factory RideHistoryResponse.fromJson(Map<String, dynamic> json) {
    return RideHistoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      rides: (json['rides'] as List<dynamic>?)
              ?.map((e) => Ride.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: Pagination.fromJson(
          json['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'rides': rides.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class DriverInfo {
  final String id;
  final String name;
  final String photo;
  final String mobileNumber;

  DriverInfo({
    required this.id,
    required this.name,
    required this.photo,
    required this.mobileNumber,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      photo: json['photo'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photo': photo,
      'mobileNumber': mobileNumber,
    };
  }
}

class PassengerInfo {
  final String id;
  final String name;
  final String photo;
  final String mobileNumber;

  PassengerInfo({
    required this.id,
    required this.name,
    required this.photo,
    required this.mobileNumber,
  });

  factory PassengerInfo.fromJson(Map<String, dynamic> json) {
    return PassengerInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      photo: json['photo'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photo': photo,
      'mobileNumber': mobileNumber,
    };
  }
}

class Ride {
  final String id;
  final String passengerId;
  final String vehicleType;
  final Location pickup;
  final Location destination;
  final String status;
  final double distanceInKm;
  final int estimatedTimeInMinutes;
  final int waitingTimeInMinutes;
  final Fare fare;
  final Route route;
  final Timestamps timestamps;
  final Payment payment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;
  final String? driverId;
  final String? driverImage;
  final Cancellation? cancellation;
  final DriverInfo? driverInfo;
  final PassengerInfo? passengerInfo;

  Ride({
    required this.id,
    required this.passengerId,
    required this.vehicleType,
    required this.pickup,
    required this.destination,
    required this.status,
    required this.distanceInKm,
    required this.estimatedTimeInMinutes,
    required this.waitingTimeInMinutes,
    required this.fare,
    required this.route,
    required this.driverImage,
    required this.timestamps,
    required this.payment,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    this.driverId,
    this.cancellation,
    this.driverInfo,
    this.passengerInfo,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['_id'] ?? '',
      passengerId: json['passengerId'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      pickup: Location.fromJson(json['pickup'] as Map<String, dynamic>? ?? {}),
      destination:
          Location.fromJson(json['destination'] as Map<String, dynamic>? ?? {}),
      status: json['status'] ?? '',
      distanceInKm: (json['distanceInKm'] as num?)?.toDouble() ?? 0.0,
      estimatedTimeInMinutes: json['estimatedTimeInMinutes'] ?? 0,
      driverImage: json['driverImage'] ?? '',
      waitingTimeInMinutes: json['waitingTimeInMinutes'] ?? 0,
      fare: Fare.fromJson(json['fare'] as Map<String, dynamic>? ?? {}),
      route: Route.fromJson(json['route'] as Map<String, dynamic>? ?? {}),
      timestamps: Timestamps.fromJson(
          json['timestamps'] as Map<String, dynamic>? ?? {}),
      payment: Payment.fromJson(json['payment'] as Map<String, dynamic>? ?? {}),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      v: json['__v'] ?? 0,
      driverId: json['driverId'],
      cancellation: json['cancellation'] != null
          ? Cancellation.fromJson(json['cancellation'] as Map<String, dynamic>)
          : null,
      driverInfo: json['driverInfo'] != null
          ? DriverInfo.fromJson(json['driverInfo'] as Map<String, dynamic>)
          : null,
      passengerInfo: json['passengerInfo'] != null
          ? PassengerInfo.fromJson(
              json['passengerInfo'] as Map<String, dynamic>)
          : null,
    );
  }

  factory Ride.unknown() {
    return Ride(
      id: 'unknown',
      passengerId: 'unknown',
      vehicleType: 'unknown',
      pickup: Location(
        latitude: 0.0,
        longitude: 0.0,
        address: 'unknown',
        instructions: '',
      ),
      destination: Location(
        latitude: 0.0,
        longitude: 0.0,
        address: 'unknown',
        instructions: '',
      ),
      status: 'unknown',
      distanceInKm: 0.0,
      estimatedTimeInMinutes: 0,
      waitingTimeInMinutes: 0,
      fare: Fare(
        baseFare: 0.0,
        distanceCharge: 0.0,
        timeCharge: 0.0,
        surgeMultiplier: 0.0,
        tollsAndSurcharges: 0.0,
        subtotal: 0.0,
        total: 0.0,
        breakdown: FareBreakdown(
          base: 0.0,
          distance: 0.0,
          time: 0.0,
          waiting: 0.0,
          peakHour: 0.0,
          nightCharge: 0.0,
          surge: 0.0,
          zoneCharge: 0.0,
          serviceCharge: 0.0,
          gst: 0.0,
          tollsAndSurcharges: 0.0,
        ),
      ),
      route: Route(
        encoded: '',
        waypoints: [],
      ),
      driverImage: '',
      timestamps: Timestamps(),
      payment: Payment(
        method: 'unknown',
        status: 'unknown',
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      v: 0,
      driverId: null,
      cancellation: null,
      driverInfo: null,
      passengerInfo: null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      '_id': id,
      'passengerId': passengerId,
      'vehicleType': vehicleType,
      'pickup': pickup.toJson(),
      'destination': destination.toJson(),
      'status': status,
      'distanceInKm': distanceInKm,
      'estimatedTimeInMinutes': estimatedTimeInMinutes,
      'driverImage': driverImage,
      'waitingTimeInMinutes': waitingTimeInMinutes,
      'fare': fare.toJson(),
      'route': route.toJson(),
      'timestamps': timestamps.toJson(),
      'payment': payment.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };

    if (driverId != null) {
      data['driverId'] = driverId;
    }

    if (cancellation != null) {
      data['cancellation'] = cancellation!.toJson();
    }

    if (driverInfo != null) {
      data['driverInfo'] = driverInfo!.toJson();
    }

    if (passengerInfo != null) {
      data['passengerInfo'] = passengerInfo!.toJson();
    }

    return data;
  }
}

class Location {
  final double latitude;
  final double longitude;
  final String address;
  final String instructions;

  Location({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.instructions,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] ?? '',
      instructions: json['instructions'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'instructions': instructions,
    };
  }
}

class Fare {
  final double baseFare;
  final double distanceCharge;
  final double timeCharge;
  final double surgeMultiplier;
  final double tollsAndSurcharges;
  final double subtotal;
  final double total;
  final FareBreakdown breakdown;

  Fare({
    required this.baseFare,
    required this.distanceCharge,
    required this.timeCharge,
    required this.surgeMultiplier,
    required this.tollsAndSurcharges,
    required this.subtotal,
    required this.total,
    required this.breakdown,
  });

  factory Fare.fromJson(Map<String, dynamic> json) {
    return Fare(
      baseFare: (json['baseFare'] as num?)?.toDouble() ?? 0.0,
      distanceCharge: (json['distanceCharge'] as num?)?.toDouble() ?? 0.0,
      timeCharge: (json['timeCharge'] as num?)?.toDouble() ?? 0.0,
      surgeMultiplier: (json['surgeMultiplier'] as num?)?.toDouble() ?? 0.0,
      tollsAndSurcharges:
          (json['tollsAndSurcharges'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      breakdown: FareBreakdown.fromJson(
          json['breakdown'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseFare': baseFare,
      'distanceCharge': distanceCharge,
      'timeCharge': timeCharge,
      'surgeMultiplier': surgeMultiplier,
      'tollsAndSurcharges': tollsAndSurcharges,
      'subtotal': subtotal,
      'total': total,
      'breakdown': breakdown.toJson(),
    };
  }
}

class FareBreakdown {
  final double base;
  final double distance;
  final double time;
  final double waiting;
  final double peakHour;
  final double nightCharge;
  final double surge;
  final double zoneCharge;
  final double serviceCharge;
  final double gst;
  final double tollsAndSurcharges;

  FareBreakdown({
    required this.base,
    required this.distance,
    required this.time,
    required this.waiting,
    required this.peakHour,
    required this.nightCharge,
    required this.surge,
    required this.zoneCharge,
    required this.serviceCharge,
    required this.gst,
    required this.tollsAndSurcharges,
  });

  factory FareBreakdown.fromJson(Map<String, dynamic> json) {
    return FareBreakdown(
      base: (json['base'] as num?)?.toDouble() ?? 0.0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      time: (json['time'] as num?)?.toDouble() ?? 0.0,
      waiting: (json['waiting'] as num?)?.toDouble() ?? 0.0,
      peakHour: (json['peakHour'] as num?)?.toDouble() ?? 0.0,
      nightCharge: (json['nightCharge'] as num?)?.toDouble() ?? 0.0,
      surge: (json['surge'] as num?)?.toDouble() ?? 0.0,
      zoneCharge: (json['zoneCharge'] as num?)?.toDouble() ?? 0.0,
      serviceCharge: (json['serviceCharge'] as num?)?.toDouble() ?? 0.0,
      gst: (json['gst'] as num?)?.toDouble() ?? 0.0,
      tollsAndSurcharges:
          (json['tollsAndSurcharges'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base': base,
      'distance': distance,
      'time': time,
      'waiting': waiting,
      'peakHour': peakHour,
      'nightCharge': nightCharge,
      'surge': surge,
      'zoneCharge': zoneCharge,
      'serviceCharge': serviceCharge,
      'gst': gst,
      'tollsAndSurcharges': tollsAndSurcharges,
    };
  }
}

class Route {
  final String encoded;
  final List<dynamic> waypoints;

  Route({
    required this.encoded,
    required this.waypoints,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      encoded: json['encoded'] ?? '',
      waypoints: json['waypoints'] as List<dynamic>? ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'encoded': encoded,
      'waypoints': waypoints,
    };
  }
}

class Timestamps {
  final DateTime? requested;
  final DateTime? accepted;
  final DateTime? cancelled;

  Timestamps({
    this.requested,
    this.accepted,
    this.cancelled,
  });

  factory Timestamps.fromJson(Map<String, dynamic> json) {
    return Timestamps(
      requested: json['requested'] != null
          ? DateTime.tryParse(json['requested'])
          : null,
      accepted:
          json['accepted'] != null ? DateTime.tryParse(json['accepted']) : null,
      cancelled: json['cancelled'] != null
          ? DateTime.tryParse(json['cancelled'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (requested != null) {
      data['requested'] = requested!.toIso8601String();
    }
    if (accepted != null) {
      data['accepted'] = accepted!.toIso8601String();
    }
    if (cancelled != null) {
      data['cancelled'] = cancelled!.toIso8601String();
    }

    return data;
  }
}

class Payment {
  final String method;
  final String status;
  final double? authorizedAmount;
  final double? reservedAmount;
  final double? capturedAmount;
  final double? releasedAmount;
  final double? driverCreditedAmount;
  final double? adjustmentRemaining;
  final int? adjustmentAttempts;
  final String nextRetryAt;

  Payment({
    required this.method,
    required this.status,
    this.authorizedAmount,
    this.reservedAmount,
    this.capturedAmount,
    this.releasedAmount,
    this.driverCreditedAmount,
    this.adjustmentRemaining,
    this.adjustmentAttempts,
    this.nextRetryAt = '',
  });

  bool get isRetryPending => status.toLowerCase() == 'adjustment_pending';
  bool get needsSupportReview =>
      status.toLowerCase() == 'adjustment_failed_permanent';
  bool get needsRecovery => isRetryPending || needsSupportReview;

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      method: (json['method'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      authorizedAmount: _asNullableDouble(json['authorizedAmount']),
      reservedAmount: _asNullableDouble(json['reservedAmount']),
      capturedAmount: _asNullableDouble(json['capturedAmount']),
      releasedAmount: _asNullableDouble(json['releasedAmount']),
      driverCreditedAmount: _asNullableDouble(json['driverCreditedAmount']),
      adjustmentRemaining: _asNullableDouble(json['adjustmentRemaining']),
      adjustmentAttempts: _asNullableInt(json['adjustmentAttempts']),
      nextRetryAt: (json['nextRetryAt'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'status': status,
      'authorizedAmount': authorizedAmount,
      'reservedAmount': reservedAmount,
      'capturedAmount': capturedAmount,
      'releasedAmount': releasedAmount,
      'driverCreditedAmount': driverCreditedAmount,
      'adjustmentRemaining': adjustmentRemaining,
      'adjustmentAttempts': adjustmentAttempts,
      'nextRetryAt': nextRetryAt,
    };
  }
}

double? _asNullableDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value == null) return null;
  return double.tryParse(value.toString());
}

int? _asNullableInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value == null) return null;
  return int.tryParse(value.toString());
}

class Cancellation {
  final String reason;
  final String? by;

  Cancellation({
    required this.reason,
    this.by,
  });

  factory Cancellation.fromJson(Map<String, dynamic> json) {
    return Cancellation(
      reason: json['reason'] ?? '',
      by: json['by'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'reason': reason,
    };

    if (by != null) {
      data['by'] = by;
    }

    return data;
  }
}

class Pagination {
  final int total;
  final int page;
  final int limit;
  final int pages;

  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      pages: json['pages'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'limit': limit,
      'pages': pages,
    };
  }
}
