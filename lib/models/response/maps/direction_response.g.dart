// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direction_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DirectionResponse _$DirectionResponseFromJson(Map<String, dynamic> json) =>
    DirectionResponse(
      routes: (json['routes'] as List<dynamic>?)
          ?.map((e) => Routes.fromJson(e as Map<String, dynamic>))
          .toList(),
      waypoints: (json['waypoints'] as List<dynamic>?)
          ?.map((e) => Waypoints.fromJson(e as Map<String, dynamic>))
          .toList(),
      code: json['code'] as String?,
      uuid: json['uuid'] as String?,
    );

Map<String, dynamic> _$DirectionResponseToJson(DirectionResponse instance) =>
    <String, dynamic>{
      'routes': instance.routes,
      'waypoints': instance.waypoints,
      'code': instance.code,
      'uuid': instance.uuid,
    };

Routes _$RoutesFromJson(Map<String, dynamic> json) => Routes(
      geometry: json['geometry'] == null
          ? null
          : Geometry.fromJson(json['geometry'] as Map<String, dynamic>),
      legs: (json['legs'] as List<dynamic>?)
          ?.map((e) => Legs.fromJson(e as Map<String, dynamic>))
          .toList(),
      weightName: json['weight_name'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      duration: (json['duration'] as num?)?.toDouble(),
      distance: (json['distance'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$RoutesToJson(Routes instance) => <String, dynamic>{
      'geometry': instance.geometry,
      'legs': instance.legs,
      'weight_name': instance.weightName,
      'weight': instance.weight,
      'duration': instance.duration,
      'distance': instance.distance,
    };

Geometry _$GeometryFromJson(Map<String, dynamic> json) => Geometry(
      coordinates: json['coordinates'] as List<dynamic>?,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$GeometryToJson(Geometry instance) => <String, dynamic>{
      'coordinates': instance.coordinates,
      'type': instance.type,
    };

Legs _$LegsFromJson(Map<String, dynamic> json) => Legs(
      steps: json['steps'] as List<dynamic>?,
      summary: json['summary'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      duration: (json['duration'] as num?)?.toDouble(),
      distance: (json['distance'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$LegsToJson(Legs instance) => <String, dynamic>{
      'steps': instance.steps,
      'summary': instance.summary,
      'weight': instance.weight,
      'duration': instance.duration,
      'distance': instance.distance,
    };

Waypoints _$WaypointsFromJson(Map<String, dynamic> json) => Waypoints(
      distance: (json['distance'] as num?)?.toDouble(),
      name: json['name'] as String?,
      location: (json['location'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$WaypointsToJson(Waypoints instance) => <String, dynamic>{
      'distance': instance.distance,
      'name': instance.name,
      'location': instance.location,
    };
