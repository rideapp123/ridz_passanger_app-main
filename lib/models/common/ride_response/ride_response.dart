import '../../ride_participant.dart';
import 'package:ridzs_passenger_app/core/enums/ride.dart';

double _asDouble(dynamic value, [double fallback = 0]) =>
    rideNumber(value) ?? fallback;

double? _asNullableDouble(dynamic value) => rideNumber(value);

int? _asNullableInt(dynamic value) => rideInteger(value);

int _asInt(dynamic value, [int fallback = 0]) =>
    rideNumber(value)?.round() ?? fallback;

class RideRequest {
  RideResponse? ride;
  int? timeout;
  double? estimatedDistance;
  int? estimatedDuration;
  String? driverName;
  String? driverPhoto;
  String? driverNumber;
  RideParticipant? participant;
  RideVehicle? vehicle;

  Uri? get contactUri => rideContactUri(
      ride?.status?.title, driverNumber, participant?.canCall ?? true);
  String get participantLabel =>
      (driverName?.trim().isNotEmpty ?? false) ? driverName!.trim() : 'Driver';

  void mergeDisplayFrom(RideRequest? previous) {
    if (previous == null ||
        previous.ride?.sId != ride?.sId ||
        rideText(previous.ride?.driverId) != rideText(ride?.driverId)) {
      return;
    }
    if (participant == null) {
      participant = previous.participant;
      driverName =
          (driverName?.isNotEmpty ?? false) ? driverName : previous.driverName;
      driverPhoto = (driverPhoto?.isNotEmpty ?? false)
          ? driverPhoto
          : previous.driverPhoto;
      driverNumber = (driverNumber?.isNotEmpty ?? false)
          ? driverNumber
          : previous.driverNumber;
    }
    vehicle ??= previous.vehicle;
  }

  RideRequest({
    this.ride,
    this.timeout,
    this.estimatedDistance,
    this.estimatedDuration,
    this.driverName,
    this.driverNumber,
    this.driverPhoto,
  });

  RideRequest.fromJson(Map<String, dynamic> json) {
    final rideMap = json['ride'];
    ride = rideMap is Map<String, dynamic>
        ? RideResponse.fromJson(rideMap)
        : (rideMap is Map
            ? RideResponse.fromJson(Map<String, dynamic>.from(rideMap))
            : null);
    timeout = _asInt(json['timeout']);
    estimatedDistance = _asDouble(json['estimatedDistance']);
    estimatedDuration = _asInt(json['estimatedDuration']);
    driverName = (json['driverName'] ?? '').toString();
    driverNumber =
        (json['driverMobileNumber'] ?? json['driverNumber'] ?? '').toString();
    driverPhoto = (json['driverPhoto'] ?? '').toString();
    final snapshot = json['ride'];
    if (snapshot is Map && snapshot.containsKey('participant')) {
      final value = snapshot['participant'];
      participant =
          RideParticipant.fromJson(value is Map ? value : {'role': 'driver'});
      if (value is Map &&
          (participant!.role != 'driver' ||
              (participant!.id.isNotEmpty &&
                  participant!.id != ride?.driverId))) {
        throw const FormatException('Participant does not match ride');
      }
      driverName = participant!.displayName;
      driverPhoto = participant!.photoUrl;
      driverNumber = participant!.canCall ? participant!.phoneNumber : '';
    }
    if (snapshot is Map && snapshot.containsKey('vehicle')) {
      final value = snapshot['vehicle'];
      vehicle = RideVehicle.fromJson(value is Map ? value : {});
    }
  }

  factory RideRequest.unknown() {
    return RideRequest(
      ride: RideResponse.unknown(),
      timeout: 300,
      estimatedDistance: 0.0,
      estimatedDuration: 0,
      driverName: 'Unknown Driver',
      driverNumber: 'N/A',
      driverPhoto: '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (ride != null) {
      data['ride'] = ride!.toJson();
    }
    data['timeout'] = timeout;
    data['estimatedDistance'] = estimatedDistance;
    data['estimatedDuration'] = estimatedDuration;
    data['driverName'] = driverName;
    data['driverMobileNumber'] = driverNumber;
    data['driverPhoto'] = driverPhoto;
    if (data['ride'] is Map) {
      if (participant != null) {
        data['ride']['participant'] = participant!.toJson();
      }
      if (vehicle != null) data['ride']['vehicle'] = vehicle!.toJson();
    }
    return data;
  }
}

class RideResponse {
  String? passengerId;
  String? driverId;
  String? vehicleType;
  LocationDetails? pickup;
  LocationDetails? destination;
  RideStatus? status;
  double? distanceInKm;
  int? estimatedTimeInMinutes;
  int? waitingTimeInMinutes;
  Fare? fare;
  Route? route;
  Timestamps? timestamps;
  Payment? payment;
  String? sId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  int? version;
  Map<String, dynamic>? cancellation;
  Map<String, dynamic>? dispatch;
  String? passengerName;
  String? passengerPhoto;

  RideResponse({
    this.passengerId,
    this.vehicleType,
    this.pickup,
    this.destination,
    this.status,
    this.distanceInKm,
    this.driverId,
    this.estimatedTimeInMinutes,
    this.waitingTimeInMinutes,
    this.fare,
    this.route,
    this.timestamps,
    this.payment,
    this.sId,
    this.createdAt,
    this.passengerName,
    this.passengerPhoto,
    this.updatedAt,
    this.iV,
    this.version,
    this.cancellation,
  });

  RideResponse.fromJson(Map<String, dynamic> json) {
    passengerId = (json['passengerId'] ?? '').toString();
    vehicleType = (json['vehicleType'] ?? '').toString();
    pickup = json['pickup'] != null
        ? LocationDetails.fromJson(
            Map<String, dynamic>.from(json['pickup'] as Map))
        : null;
    destination = json['destination'] != null
        ? LocationDetails.fromJson(
            Map<String, dynamic>.from(json['destination'] as Map))
        : null;
    status = RideStatus.fromString((json['status'] ?? '').toString());
    version = _asNullableInt(json['version']);
    dispatch = json['dispatch'] is Map
        ? Map<String, dynamic>.from(json['dispatch'])
        : null;
    cancellation = json['cancellation'] is Map
        ? Map<String, dynamic>.from(json['cancellation'])
        : null;
    distanceInKm = _asDouble(json['distanceInKm']);
    estimatedTimeInMinutes = _asInt(json['estimatedTimeInMinutes']);
    waitingTimeInMinutes = _asInt(json['waitingTimeInMinutes']);
    fare = json['fare'] != null
        ? Fare.fromJson(Map<String, dynamic>.from(json['fare'] as Map))
        : null;
    route = json['route'] != null
        ? Route.fromJson(Map<String, dynamic>.from(json['route'] as Map))
        : null;
    timestamps = json['timestamps'] != null
        ? Timestamps.fromJson(
            Map<String, dynamic>.from(json['timestamps'] as Map))
        : null;
    payment = json['payment'] != null
        ? Payment.fromJson(Map<String, dynamic>.from(json['payment'] as Map))
        : null;
    sId = (json['_id'] ?? json['id'] ?? '').toString();
    createdAt = (json['createdAt'] ?? '').toString();
    passengerName = (json['passengerName'] ?? '').toString();
    passengerPhoto = (json['passengerPhoto'] ?? '').toString();
    driverId = (json['driverId'] ?? '').toString();

    updatedAt = (json['updatedAt'] ?? '').toString();
    iV = _asInt(json['__v']);
  }

  factory RideResponse.unknown() {
    return RideResponse(
      passengerId: 'unknown_passenger',
      driverId: 'unknown_driver',
      vehicleType: 'Unknown',
      pickup: LocationDetails(
        latitude: 0.0,
        longitude: 0.0,
        address: 'Unknown Location',
        instructions: 'No instructions',
      ),
      destination: LocationDetails(
        latitude: 0.0,
        longitude: 0.0,
        address: 'Unknown Destination',
        instructions: 'No instructions',
      ),
      status: RideStatus.fromString('completed'),
      distanceInKm: 0.0,
      estimatedTimeInMinutes: 0,
      waitingTimeInMinutes: 0,
      fare: Fare(
        baseFare: 0.0,
        distanceCharge: 0.0,
        timeCharge: 0.0,
        surgeMultiplier: 1.0,
        tollsAndSurcharges: 0.0,
        subtotal: 0.0,
        total: 0.0,
        breakdown: Breakdown(
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
        waypoints: [],
        encoded: '',
      ),
      timestamps: Timestamps(requested: DateTime.now().toIso8601String()),
      payment: Payment(method: 'unknown', status: 'unknown'),
      sId: 'unknown_id',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      iV: 0,
      passengerName: 'Unknown Passenger',
      passengerPhoto: '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['passengerId'] = passengerId;
    data['version'] = version;
    data['cancellation'] = cancellation;
    data['dispatch'] = dispatch;
    data['vehicleType'] = vehicleType;
    if (pickup != null) {
      data['pickup'] = pickup!.toJson();
    }
    if (destination != null) {
      data['destination'] = destination!.toJson();
    }
    data['status'] = status?.title ?? 'cancelled';
    data['distanceInKm'] = distanceInKm;
    data['estimatedTimeInMinutes'] = estimatedTimeInMinutes;
    data['waitingTimeInMinutes'] = waitingTimeInMinutes;
    data['passengerName'] = passengerName;
    data['passengerPhoto'] = passengerPhoto;

    if (fare != null) {
      data['fare'] = fare!.toJson();
    }
    if (route != null) {
      data['route'] = route!.toJson();
    }
    if (timestamps != null) {
      data['timestamps'] = timestamps!.toJson();
    }
    if (payment != null) {
      data['payment'] = payment!.toJson();
    }
    data['_id'] = sId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['driverId'] = driverId ?? '';
    data['__v'] = iV;
    return data;
  }
}

class LocationDetails {
  double? latitude;
  double? longitude;
  String? address;
  String? instructions;

  LocationDetails({
    this.latitude,
    this.longitude,
    this.address,
    this.instructions,
  });

  LocationDetails.fromJson(Map<String, dynamic> json) {
    latitude = _asDouble(json['latitude']);
    longitude = _asDouble(json['longitude']);
    address = (json['address'] ?? '').toString();
    instructions = (json['instructions'] ?? '').toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['address'] = address;
    data['instructions'] = instructions;
    return data;
  }
}

class Fare {
  num? baseFare;
  num? distanceCharge;
  num? timeCharge;
  num? surgeMultiplier;
  num? tollsAndSurcharges;
  num? subtotal;
  num? total;
  Breakdown? breakdown;

  Fare(
      {this.baseFare,
      this.distanceCharge,
      this.timeCharge,
      this.surgeMultiplier,
      this.tollsAndSurcharges,
      this.subtotal,
      this.total,
      this.breakdown});

  Fare.fromJson(Map<String, dynamic> json) {
    baseFare = _asDouble(json['baseFare']);
    distanceCharge = _asDouble(json['distanceCharge']);
    timeCharge = _asDouble(json['timeCharge']);
    surgeMultiplier = _asDouble(json['surgeMultiplier']);
    tollsAndSurcharges = _asDouble(json['tollsAndSurcharges']);
    subtotal = _asDouble(json['subtotal']);
    total = _asDouble(json['total']);
    breakdown = json['breakdown'] != null
        ? Breakdown.fromJson(
            Map<String, dynamic>.from(json['breakdown'] as Map))
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['baseFare'] = baseFare;
    data['distanceCharge'] = distanceCharge;
    data['timeCharge'] = timeCharge;
    data['surgeMultiplier'] = surgeMultiplier;
    data['tollsAndSurcharges'] = tollsAndSurcharges;
    data['subtotal'] = subtotal;
    data['total'] = total;
    if (breakdown != null) {
      data['breakdown'] = breakdown!.toJson();
    }
    return data;
  }
}

class Breakdown {
  num? base;
  num? distance;
  num? time;
  num? waiting;
  num? peakHour;
  num? nightCharge;
  num? surge;
  num? zoneCharge;
  num? serviceCharge;
  num? gst;
  num? tollsAndSurcharges;

  Breakdown(
      {this.base,
      this.distance,
      this.time,
      this.waiting,
      this.peakHour,
      this.nightCharge,
      this.surge,
      this.zoneCharge,
      this.serviceCharge,
      this.gst,
      this.tollsAndSurcharges});

  Breakdown.fromJson(Map<String, dynamic> json) {
    base = _asDouble(json['base']);
    distance = _asDouble(json['distance']);
    time = _asDouble(json['time']);
    waiting = _asDouble(json['waiting']);
    peakHour = _asDouble(json['peakHour']);
    nightCharge = _asDouble(json['nightCharge']);
    surge = _asDouble(json['surge']);
    zoneCharge = _asDouble(json['zoneCharge']);
    serviceCharge = _asDouble(json['serviceCharge']);
    gst = _asDouble(json['gst']);
    tollsAndSurcharges = _asDouble(json['tollsAndSurcharges']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['base'] = base;
    data['distance'] = distance;
    data['time'] = time;
    data['waiting'] = waiting;
    data['peakHour'] = peakHour;
    data['nightCharge'] = nightCharge;
    data['surge'] = surge;
    data['zoneCharge'] = zoneCharge;
    data['serviceCharge'] = serviceCharge;
    data['gst'] = gst;
    data['tollsAndSurcharges'] = tollsAndSurcharges;
    return data;
  }
}

class Route {
  List<double>? waypoints;
  String? encoded;

  Route({
    this.waypoints,
    this.encoded,
  });

  Route.fromJson(Map<String, dynamic> json) {
    final rawWaypoints = (json['waypoints'] as List?) ?? <dynamic>[];
    waypoints = rawWaypoints.map(rideNumber).whereType<double>().toList();
    encoded = (json['encoded'] ?? '').toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['waypoints'] = waypoints;
    data['encoded'] = encoded;
    return data;
  }
}

class Timestamps {
  String? accepted, arrived, started, completed, cancelled;
  String? requested;

  Timestamps(
      {this.requested,
      this.accepted,
      this.arrived,
      this.started,
      this.completed,
      this.cancelled});

  Timestamps.fromJson(Map<String, dynamic> json) {
    requested = (json['requested'] ?? '').toString();
    accepted = json['accepted'] is String ? json['accepted'] : null;
    arrived = json['arrived'] is String ? json['arrived'] : null;
    started = json['started'] is String ? json['started'] : null;
    completed = json['completed'] is String ? json['completed'] : null;
    cancelled = json['cancelled'] is String ? json['cancelled'] : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['requested'] = requested;
    data['accepted'] = accepted;
    data['arrived'] = arrived;
    data['started'] = started;
    data['completed'] = completed;
    data['cancelled'] = cancelled;
    return data;
  }
}

class Payment {
  String? method;
  String? status;
  double? authorizedAmount;
  double? reservedAmount;
  double? capturedAmount;
  double? releasedAmount;
  double? driverCreditedAmount;
  double? adjustmentRemaining;
  int? adjustmentAttempts;
  String? nextRetryAt;

  Payment({
    this.method,
    this.status,
    this.authorizedAmount,
    this.reservedAmount,
    this.capturedAmount,
    this.releasedAmount,
    this.driverCreditedAmount,
    this.adjustmentRemaining,
    this.adjustmentAttempts,
    this.nextRetryAt,
  });

  Payment.fromJson(Map<String, dynamic> json) {
    method = (json['method'] ?? '').toString();
    status = (json['status'] ?? '').toString();
    authorizedAmount = _asNullableDouble(json['authorizedAmount']);
    reservedAmount = _asNullableDouble(json['reservedAmount']);
    capturedAmount = _asNullableDouble(json['capturedAmount']);
    releasedAmount = _asNullableDouble(json['releasedAmount']);
    driverCreditedAmount = _asNullableDouble(json['driverCreditedAmount']);
    adjustmentRemaining = _asNullableDouble(json['adjustmentRemaining']);
    adjustmentAttempts = _asNullableInt(json['adjustmentAttempts']);
    nextRetryAt = (json['nextRetryAt'] ?? '').toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['method'] = method;
    data['status'] = status;
    data['authorizedAmount'] = authorizedAmount;
    data['reservedAmount'] = reservedAmount;
    data['capturedAmount'] = capturedAmount;
    data['releasedAmount'] = releasedAmount;
    data['driverCreditedAmount'] = driverCreditedAmount;
    data['adjustmentRemaining'] = adjustmentRemaining;
    data['adjustmentAttempts'] = adjustmentAttempts;
    data['nextRetryAt'] = nextRetryAt;
    return data;
  }
}
