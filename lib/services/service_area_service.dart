import 'package:dio/dio.dart';
import 'package:ridzs_passenger_app/core/services/dio_service.dart';
import '../models/regional_disclosure.dart';

class ServiceArea {
  final bool available;
  final String name, reason;
  final String? marketId;
  final Uri? termsUrl, privacyUrl;
  ServiceArea.fromJson(Map<dynamic, dynamic> json)
      : available = json['available'] == true,
        marketId = DisclosureMarket.validId(json['marketId'])
            ? json['marketId'] as String
            : null,
        name = json['name'] as String? ?? '',
        reason = json['reason'] as String? ??
            'Ridzs is not available at this pickup.',
        termsUrl = _https(json['termsUrl']),
        privacyUrl = _https(json['privacyUrl']);

  static Uri? _https(dynamic value) {
    final uri = value is String ? Uri.tryParse(value) : null;
    return uri?.scheme == 'https' &&
            uri!.host.isNotEmpty &&
            uri.userInfo.isEmpty
        ? uri
        : null;
  }
}

class ServiceAreaService {
  final Dio _dio;
  ServiceAreaService({Dio? dio}) : _dio = dio ?? Api().dio;

  Future<ServiceArea> check(double latitude, double longitude) async {
    final response = await _dio.get('/service-area', queryParameters: {
      'latitude': latitude,
      'longitude': longitude,
    });
    final body = response.data;
    if (body is! Map ||
        body['success'] != true ||
        body['data'] is! Map ||
        (body['data'] as Map)['available'] is! bool) {
      throw const FormatException('Invalid service area response');
    }
    return ServiceArea.fromJson(body['data'] as Map);
  }
}
