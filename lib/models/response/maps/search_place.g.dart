// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_place.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchPlace _$SearchPlaceFromJson(Map<String, dynamic> json) => SearchPlace(
      type: json['type'] as String?,
      features: (json['features'] as List<dynamic>?)
          ?.map((e) => Features.fromJson(e as Map<String, dynamic>))
          .toList(),
      attribution: json['attribution'] as String?,
      responseId: json['response_id'] as String?,
    );

Map<String, dynamic> _$SearchPlaceToJson(SearchPlace instance) =>
    <String, dynamic>{
      'type': instance.type,
      'features': instance.features,
      'attribution': instance.attribution,
      'response_id': instance.responseId,
    };

Features _$FeaturesFromJson(Map<String, dynamic> json) => Features(
      type: json['type'] as String?,
      geometry: json['geometry'] == null
          ? null
          : Geometry.fromJson(json['geometry'] as Map<String, dynamic>),
      properties: json['properties'] == null
          ? null
          : Properties.fromJson(json['properties'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FeaturesToJson(Features instance) => <String, dynamic>{
      'type': instance.type,
      'geometry': instance.geometry,
      'properties': instance.properties,
    };

Geometry _$GeometryFromJson(Map<String, dynamic> json) => Geometry(
      coordinates: (json['coordinates'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      type: json['type'] as String?,
    );

Map<String, dynamic> _$GeometryToJson(Geometry instance) => <String, dynamic>{
      'coordinates': instance.coordinates,
      'type': instance.type,
    };

Properties _$PropertiesFromJson(Map<String, dynamic> json) => Properties(
      name: json['name'] as String?,
      mapboxId: json['mapbox_id'] as String?,
      featureType: json['feature_type'] as String?,
      address: json['address'] as String?,
      fullAddress: json['full_address'] as String?,
      placeFormatted: json['place_formatted'] as String?,
      context: json['context'] == null
          ? null
          : Context.fromJson(json['context'] as Map<String, dynamic>),
      coordinates: json['coordinates'] == null
          ? null
          : Coordinates.fromJson(json['coordinates'] as Map<String, dynamic>),
      language: json['language'] as String?,
      maki: json['maki'] as String?,
      poiCategory: (json['poi_category'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      poiCategoryIds: (json['poi_category_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      externalIds: json['external_ids'] == null
          ? null
          : ExternalIds.fromJson(json['external_ids'] as Map<String, dynamic>),
      metadata: json['metadata'] == null
          ? null
          : Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PropertiesToJson(Properties instance) =>
    <String, dynamic>{
      'name': instance.name,
      'mapbox_id': instance.mapboxId,
      'feature_type': instance.featureType,
      'address': instance.address,
      'full_address': instance.fullAddress,
      'place_formatted': instance.placeFormatted,
      'context': instance.context,
      'coordinates': instance.coordinates,
      'language': instance.language,
      'maki': instance.maki,
      'poi_category': instance.poiCategory,
      'poi_category_ids': instance.poiCategoryIds,
      'external_ids': instance.externalIds,
      'metadata': instance.metadata,
    };

Context _$ContextFromJson(Map<String, dynamic> json) => Context(
      country: json['country'] == null
          ? null
          : Country.fromJson(json['country'] as Map<String, dynamic>),
      postcode: json['postcode'] == null
          ? null
          : Postcode.fromJson(json['postcode'] as Map<String, dynamic>),
      place: json['place'] == null
          ? null
          : Place.fromJson(json['place'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ContextToJson(Context instance) => <String, dynamic>{
      'country': instance.country,
      'postcode': instance.postcode,
      'place': instance.place,
    };

Country _$CountryFromJson(Map<String, dynamic> json) => Country(
      name: json['name'] as String?,
      countryCode: json['country_code'] as String?,
      countryCodeAlpha3: json['country_code_alpha_3'] as String?,
    );

Map<String, dynamic> _$CountryToJson(Country instance) => <String, dynamic>{
      'name': instance.name,
      'country_code': instance.countryCode,
      'country_code_alpha_3': instance.countryCodeAlpha3,
    };

Postcode _$PostcodeFromJson(Map<String, dynamic> json) => Postcode(
      id: json['id'] as String?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$PostcodeToJson(Postcode instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

Place _$PlaceFromJson(Map<String, dynamic> json) => Place(
      id: json['id'] as String?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$PlaceToJson(Place instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

Coordinates _$CoordinatesFromJson(Map<String, dynamic> json) => Coordinates(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      routablePoints: (json['routable_points'] as List<dynamic>?)
          ?.map((e) => RoutablePoints.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CoordinatesToJson(Coordinates instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'routable_points': instance.routablePoints,
    };

RoutablePoints _$RoutablePointsFromJson(Map<String, dynamic> json) =>
    RoutablePoints(
      name: json['name'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$RoutablePointsToJson(RoutablePoints instance) =>
    <String, dynamic>{
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

ExternalIds _$ExternalIdsFromJson(Map<String, dynamic> json) => ExternalIds(
      foursquare: json['foursquare'] as String?,
    );

Map<String, dynamic> _$ExternalIdsToJson(ExternalIds instance) =>
    <String, dynamic>{
      'foursquare': instance.foursquare,
    };

Metadata _$MetadataFromJson(Map<String, dynamic> json) => Metadata(
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$MetadataToJson(Metadata instance) => <String, dynamic>{
      'phone': instance.phone,
    };
