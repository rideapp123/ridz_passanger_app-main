import 'package:json_annotation/json_annotation.dart';

part 'direction_response.g.dart';

@JsonSerializable()
class DirectionResponse {
  @JsonKey(name: "routes")
  final List<Routes>? routes;
  @JsonKey(name: "waypoints")
  final List<Waypoints>? waypoints;
  @JsonKey(name: "code")
  final String? code;
  @JsonKey(name: "uuid")
  final String? uuid;

  DirectionResponse({
    this.routes,
    this.waypoints,
    this.code,
    this.uuid,
  });

  factory DirectionResponse.fromJson(Map<String, dynamic> json) {
    return _$DirectionResponseFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$DirectionResponseToJson(this);
  }
}

@JsonSerializable()
class Routes {
  @JsonKey(name: "geometry")
  final Geometry? geometry;
  @JsonKey(name: "legs")
  final List<Legs>? legs;
  @JsonKey(name: "weight_name")
  final String? weightName;
  @JsonKey(name: "weight")
  final double? weight;
  @JsonKey(name: "duration")
  final double? duration;
  @JsonKey(name: "distance")
  final double? distance;

  Routes({
    this.geometry,
    this.legs,
    this.weightName,
    this.weight,
    this.duration,
    this.distance,
  });

  factory Routes.fromJson(Map<String, dynamic> json) {
    return _$RoutesFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$RoutesToJson(this);
  }
}

@JsonSerializable()
class Geometry {
  @JsonKey(name: "coordinates")
  final List<dynamic>? coordinates;
  @JsonKey(name: "type")
  final String? type;

  Geometry({
    this.coordinates,
    this.type,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return _$GeometryFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$GeometryToJson(this);
  }
}

@JsonSerializable()
class Legs {
  @JsonKey(name: "steps")
  final List<dynamic>? steps;
  @JsonKey(name: "summary")
  final String? summary;
  @JsonKey(name: "weight")
  final double? weight;
  @JsonKey(name: "duration")
  final double? duration;
  @JsonKey(name: "distance")
  final double? distance;

  Legs({
    this.steps,
    this.summary,
    this.weight,
    this.duration,
    this.distance,
  });

  factory Legs.fromJson(Map<String, dynamic> json) {
    return _$LegsFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$LegsToJson(this);
  }
}

@JsonSerializable()
class Waypoints {
  @JsonKey(name: "distance")
  final double? distance;
  @JsonKey(name: "name")
  final String? name;
  @JsonKey(name: "location")
  final List<double>? location;

  Waypoints({
    this.distance,
    this.name,
    this.location,
  });

  factory Waypoints.fromJson(Map<String, dynamic> json) {
    return _$WaypointsFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$WaypointsToJson(this);
  }
}
