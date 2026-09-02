import 'dart:developer';

import 'package:dio/dio.dart';

import 'package:ridzs_passenger_app/models/response/maps/direction_response.dart';
import 'package:ridzs_passenger_app/models/response/maps/search_place.dart';

class MapService {
  factory MapService() => _instance ??= MapService._();

  MapService._();
  static MapService? _instance;

static const String _mapboxToken =
      String.fromEnvironment('MAPBOX_PUBLIC_TOKEN');

  final Dio _dio = Dio();

  Future<SearchPlace> searchPlace(String searchText) async {
    final response = await _dio.get(
        'https://api.mapbox.com/search/searchbox/v1/forward?q=$searchText&access_token=$_mapboxToken');

    if (response.statusCode == 200) {
      return SearchPlace.fromJson(response.data);
    } else {
      throw Exception('Failed to search places');
    }
  }

  Future<DirectionResponse> directionAPI(
      String lat1, String long1, String lat2, String long2) async {
    final url =
        'https://api.mapbox.com/directions/v5/mapbox/cycling/$long1,$lat1;$long2,$lat2?geometries=geojson&access_token=$_mapboxToken';
    final response = await _dio.get(url);

    if (response.statusCode == 200) {
      log('Direction API URL: $url');
      return DirectionResponse.fromJson(response.data);
    } else {
      throw Exception('Failed to load directions');
    }
  }
}
