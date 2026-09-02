import 'dart:convert';
import 'dart:developer';

import 'package:ridzs_passenger_app/core/services/dio_service.dart';
import 'package:ridzs_passenger_app/models/promocode/all_promocode_response_model.dart';

class PromoCodeService {
  static final PromoCodeService _instance = PromoCodeService._();
  factory PromoCodeService() => _instance;
  PromoCodeService._();

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  Future<List<Bonuses>> getAllPromocode() async {
    try {
      final request = await Api().dio.get('/bonus/available');
      final body = _asMap(request.data);
      final data = _asMap(body['data']);

      log('Get all promocode Statuscode: ${request.statusCode}');
      log('Get all promocode Response: ${jsonEncode(request.data)}');

      if (request.statusCode == 200 && body['success'] != false) {
        final response = AllPromocodeResponseModel.fromJson({
          'success': body['success'],
          'message': body['message'],
          'data': {
            'bonuses': data['bonuses'] ?? <dynamic>[],
            'total': data['total'] ?? 0,
          }
        });
        return response.data?.bonuses ?? <Bonuses>[];
      } else {
        throw Exception('Failed to get promocode: ${body['message']}');
      }
    } catch (e, st) {
      log('Error getting promocode: $e', name: 'PromoCodeService');
      log('Stack trace: $st', name: 'PromoCodeService');
      rethrow;
    }
  }
}
