import 'package:json_annotation/json_annotation.dart';

part 'search_place.g.dart';

@JsonSerializable()
class SearchPlace {
  @JsonKey(name: "type")
  final String? type;
  @JsonKey(name: "features")
  final List<Features>? features;
  @JsonKey(name: "attribution")
  final String? attribution;
  @JsonKey(name: "response_id")
  final String? responseId;

  SearchPlace({
    this.type,
    this.features,
    this.attribution,
    this.responseId,
  });

  factory SearchPlace.fromJson(Map<String, dynamic> json) {
    return _$SearchPlaceFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$SearchPlaceToJson(this);
  }
}

@JsonSerializable()
class Features {
  @JsonKey(name: "type")
  final String? type;
  @JsonKey(name: "geometry")
  final Geometry? geometry;
  @JsonKey(name: "properties")
  final Properties? properties;

  Features({
    this.type,
    this.geometry,
    this.properties,
  });

  factory Features.fromJson(Map<String, dynamic> json) {
    return _$FeaturesFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$FeaturesToJson(this);
  }
}

@JsonSerializable()
class Geometry {
  @JsonKey(name: "coordinates")
  final List<double>? coordinates;
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
class Properties {
  @JsonKey(name: "name")
  final String? name;
  @JsonKey(name: "mapbox_id")
  final String? mapboxId;
  @JsonKey(name: "feature_type")
  final String? featureType;
  @JsonKey(name: "address")
  final String? address;
  @JsonKey(name: "full_address")
  final String? fullAddress;
  @JsonKey(name: "place_formatted")
  final String? placeFormatted;
  @JsonKey(name: "context")
  final Context? context;
  @JsonKey(name: "coordinates")
  final Coordinates? coordinates;
  @JsonKey(name: "language")
  final String? language;
  @JsonKey(name: "maki")
  final String? maki;
  @JsonKey(name: "poi_category")
  final List<String>? poiCategory;
  @JsonKey(name: "poi_category_ids")
  final List<String>? poiCategoryIds;
  @JsonKey(name: "external_ids")
  final ExternalIds? externalIds;
  @JsonKey(name: "metadata")
  final Metadata? metadata;

  Properties({
    this.name,
    this.mapboxId,
    this.featureType,
    this.address,
    this.fullAddress,
    this.placeFormatted,
    this.context,
    this.coordinates,
    this.language,
    this.maki,
    this.poiCategory,
    this.poiCategoryIds,
    this.externalIds,
    this.metadata,
  });

  factory Properties.fromJson(Map<String, dynamic> json) {
    return _$PropertiesFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$PropertiesToJson(this);
  }
}

@JsonSerializable()
class Context {
  @JsonKey(name: "country")
  final Country? country;
  @JsonKey(name: "postcode")
  final Postcode? postcode;
  @JsonKey(name: "place")
  final Place? place;

  Context({
    this.country,
    this.postcode,
    this.place,
  });

  factory Context.fromJson(Map<String, dynamic> json) {
    return _$ContextFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$ContextToJson(this);
  }
}

@JsonSerializable()
class Country {
  @JsonKey(name: "name")
  final String? name;
  @JsonKey(name: "country_code")
  final String? countryCode;
  @JsonKey(name: "country_code_alpha_3")
  final String? countryCodeAlpha3;

  Country({
    this.name,
    this.countryCode,
    this.countryCodeAlpha3,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return _$CountryFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$CountryToJson(this);
  }
}

@JsonSerializable()
class Postcode {
  @JsonKey(name: "id")
  final String? id;
  @JsonKey(name: "name")
  final String? name;

  Postcode({
    this.id,
    this.name,
  });

  factory Postcode.fromJson(Map<String, dynamic> json) {
    return _$PostcodeFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$PostcodeToJson(this);
  }
}

@JsonSerializable()
class Place {
  @JsonKey(name: "id")
  final String? id;
  @JsonKey(name: "name")
  final String? name;

  Place({
    this.id,
    this.name,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return _$PlaceFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$PlaceToJson(this);
  }
}

@JsonSerializable()
class Coordinates {
  @JsonKey(name: "latitude")
  final double? latitude;
  @JsonKey(name: "longitude")
  final double? longitude;
  @JsonKey(name: "routable_points")
  final List<RoutablePoints>? routablePoints;

  Coordinates({
    this.latitude,
    this.longitude,
    this.routablePoints,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return _$CoordinatesFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$CoordinatesToJson(this);
  }
}

@JsonSerializable()
class RoutablePoints {
  @JsonKey(name: "name")
  final String? name;
  @JsonKey(name: "latitude")
  final double? latitude;
  @JsonKey(name: "longitude")
  final double? longitude;

  RoutablePoints({
    this.name,
    this.latitude,
    this.longitude,
  });

  factory RoutablePoints.fromJson(Map<String, dynamic> json) {
    return _$RoutablePointsFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$RoutablePointsToJson(this);
  }
}

@JsonSerializable()
class ExternalIds {
  @JsonKey(name: "foursquare")
  final String? foursquare;

  ExternalIds({
    this.foursquare,
  });

  factory ExternalIds.fromJson(Map<String, dynamic> json) {
    return _$ExternalIdsFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$ExternalIdsToJson(this);
  }
}

@JsonSerializable()
class Metadata {
  @JsonKey(name: "phone")
  final String? phone;

  Metadata({
    this.phone,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return _$MetadataFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$MetadataToJson(this);
  }
}
