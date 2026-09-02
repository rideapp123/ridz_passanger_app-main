import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:ridzs_passenger_app/models/promocode/all_promocode_response_model.dart';
import 'package:ridzs_passenger_app/models/ride/get_ride_response.dart';
import 'package:ridzs_passenger_app/models/ride/ride_trace_response.dart';

import '../core/enums/ride.dart';
import '../core/services/dio_service.dart';
import '../models/common/ride_response/ride_response.dart';
import '../models/response/price_response.dart';

class RideService {
  static final RideService _instance = RideService._();
  factory RideService() => _instance;
  RideService._();

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  Map<String, dynamic> _unwrapData(dynamic value) {
    final body = _asMap(value);
    final data = body['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return body;
  }

  Future<RideRequest> createRideRequest({
    required CarType vehicleType,
    required LocationDetails pickup,
    required LocationDetails destination,
    required PaymentMethod paymentMethod,
    double? distanceInKm,
    int? estimatedTimeInMinutes,
    String? promoCode,
  }) async {
    try {
      final request = {
        'vehicleType': vehicleType.toString().split('.').last,
        'pickup': {
          'latitude': pickup.latitude,
          'longitude': pickup.longitude,
          'address': pickup.address,
          if (pickup.instructions != null) 'instructions': pickup.instructions,
        },
        'destination': {
          'latitude': destination.latitude,
          'longitude': destination.longitude,
          'address': destination.address,
          if (destination.instructions != null)
            'instructions': destination.instructions,
        },
        'paymentMethod': paymentMethod.name,
        if (distanceInKm != null) 'distanceInKm': distanceInKm,
        if (estimatedTimeInMinutes != null)
          'timeInMinutes': estimatedTimeInMinutes,
        if (promoCode != null) 'promoCode': promoCode,
      };

      final response = await Api().dio.post(
            '/rides',
            data: request,
          );

      log('Ride request Statuscode: ${response.statusCode}');
      log('Ride request Response: ${response.data}');

      final body = _asMap(response.data);
      final data = _unwrapData(response.data);
      if (body['success'] == false) {
        throw Exception('Failed to create ride request: ${body['message']}');
      }
      return RideRequest.fromJson({
        ...data,
        'ride': data['ride'] ?? data,
      });
    } catch (e, st) {
      log('Error creating ride request: $e', name: 'RideService');
      log('Stack trace: $st', name: 'RideService');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAdRewardOffer({String? rideId}) async {
    final response = await Api().dio.get(
      '/ad-rewards/offer',
      queryParameters: {
        if (rideId != null && rideId.isNotEmpty) 'rideId': rideId,
      },
    );
    final body = _asMap(response.data);
    final data = _unwrapData(response.data);
    if (body['success'] == false) {
      throw Exception('Failed to get ad reward offer: ${body['message']}');
    }
    return data;
  }

  Future<Map<String, dynamic>> startAdReward({String? rideId}) async {
    final response = await Api().dio.post(
      '/ad-rewards/start',
      data: {
        if (rideId != null && rideId.isNotEmpty) 'rideId': rideId,
        'placement': rideId == null || rideId.isEmpty
            ? 'wallet_rewards'
            : 'post_ride_request',
      },
    );
    final body = _asMap(response.data);
    final data = _unwrapData(response.data);
    if (body['success'] == false) {
      throw Exception('Failed to start ad reward: ${body['message']}');
    }
    return _asMap(data['session']);
  }

  Future<Map<String, dynamic>> completeAdReward(
    String sessionId, {
    Map<String, dynamic>? metadata,
  }) async {
    final response = await Api().dio.post(
      '/ad-rewards/$sessionId/complete',
      data: {
        'adNetwork': 'admob',
        if (metadata != null) ...metadata,
      },
    );
    final body = _asMap(response.data);
    final data = _unwrapData(response.data);
    if (body['success'] == false) {
      throw Exception('Failed to complete ad reward: ${body['message']}');
    }
    return data;
  }

  Future<Map<String, dynamic>> getAdRewardSession(String sessionId) async {
    final response = await Api().dio.get('/ad-rewards/$sessionId');
    final body = _asMap(response.data);
    final data = _unwrapData(response.data);
    if (body['success'] == false) {
      throw Exception('Failed to get ad reward: ${body['message']}');
    }
    return _asMap(data['session']);
  }

  Future<void> cancelAdReward(String sessionId,
      {String reason = 'dismissed'}) async {
    final response = await Api().dio.post(
      '/ad-rewards/$sessionId/cancel',
      data: {'reason': reason},
    );
    final body = _asMap(response.data);
    if (body['success'] == false) {
      throw Exception('Failed to cancel ad reward: ${body['message']}');
    }
  }

  Future<List<Map<String, dynamic>>> getAdRewardHistory({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await Api().dio.get(
      '/ad-rewards',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    final body = _asMap(response.data);
    final data = _unwrapData(response.data);
    if (body['success'] == false) {
      throw Exception('Failed to get ad reward history: ${body['message']}');
    }
    return (data['sessions'] as List? ?? <dynamic>[]).map(_asMap).toList();
  }

  Future<RideResponse> updateRideStatus(
    String rideId,
    RideStatus status, {
    String? reason,
    String? details,
  }) async {
    try {
      final response = await Api().dio.put(
        '/rides/$rideId/status',
        data: {
          'status': status.toString().split('.').last,
          if (reason != null) 'reason': reason,
          if (details != null) 'details': details,
        },
      );

      final body = _asMap(response.data);
      final data = _unwrapData(response.data);
      if (body['success'] == false) {
        throw Exception('Failed to update ride status: ${body['message']}');
      }
      final ride = data['ride'];
      if (ride is! Map) {
        throw Exception('Invalid ride status response');
      }
      return RideResponse.fromJson(Map<String, dynamic>.from(ride));
    } catch (e) {
      log('Error updating ride status: $e', name: 'RideService');
      rethrow;
    }
  }

  Future<PriceResponse> getPrices() async {
    try {
      final response = await Api().dio.get('/pricing');
      final body = _asMap(response.data);
      final data = _unwrapData(response.data);
      if (body['success'] == false) {
        throw Exception('Failed to get prices: ${body['message']}');
      }
      return PriceResponse.fromJson({
        'pricing': data['pricing'] ?? <dynamic>[],
      });
    } catch (e) {
      log('Error getting prices: $e', name: 'RideService');
      rethrow;
    }
  }

  Future<Bonuses?> addPromoCode(String code, num baseAmount) async {
    try {
      final requestBody = {
        'code': code,
        'baseAmount': baseAmount,
      };

      log('Adding promo code: $requestBody');

      final request = await Api().dio.post(
            '/bonus/validate',
            data: requestBody,
          );

      log('Promo code Statuscode: ${request.statusCode}');
      log('Promo code Response: ${jsonEncode(request.data)}');

      final body = _asMap(request.data);
      final data = _unwrapData(request.data);
      if (body['success'] == false) {
        throw Exception('Failed to add promo code: ${body['message']}');
      }
      if (request.statusCode == 200) {
        final response = Bonuses.fromJson(data);
        return response;
      } else {
        throw Exception('Failed to add promo code: ${body['message']}');
      }
    } catch (e) {
      log('Error adding promo code: $e', name: 'RideService');
      rethrow;
    }
  }

  Future<RideHistoryResponse> getRides() async {
    try {
      final response = await Api().dio.get('/rides');

      log('Get rides Statuscode: ${response.statusCode}');
      log('Get rides Response: ${jsonEncode(response.data)}');

      final body = _asMap(response.data);
      final data = _unwrapData(response.data);
      if (response.statusCode != 200 || body['success'] == false) {
        throw Exception('Failed to get rides: ${body['message']}');
      }
      return RideHistoryResponse.fromJson({
        'success': body['success'] ?? true,
        'message': body['message'] ?? '',
        'rides': data['rides'] ?? <dynamic>[],
        'pagination': data['pagination'] ?? <String, dynamic>{},
      });
    } catch (e, st) {
      log('Error getting rides: $e', name: 'RideService');
      log('Stack trace: $st', name: 'RideService');
      rethrow;
    }
  }

  Future<List<RideTraceSample>> getRideTrace(
    String rideId, {
    int limit = 500,
  }) async {
    try {
      final response = await Api().dio.get(
        '/rides/$rideId/trace',
        queryParameters: {'limit': limit},
      );

      final body = _asMap(response.data);
      final data = _unwrapData(response.data);
      if (response.statusCode != 200 || body['success'] == false) {
        throw Exception('Failed to get ride trace: ${body['message']}');
      }

      return (data['samples'] as List? ?? <dynamic>[])
          .whereType<Map>()
          .map((sample) =>
              RideTraceSample.fromJson(Map<String, dynamic>.from(sample)))
          .toList();
    } catch (e, st) {
      log('Error getting ride trace: $e', name: 'RideService');
      log('Stack trace: $st', name: 'RideService');
      rethrow;
    }
  }

  Future<Ride> retryRidePayment(String rideId) async {
    try {
      final response = await Api().dio.post(
            '/rides/$rideId/payment/retry',
            options: Options(
              headers: {
                'Idempotency-Key':
                    'passenger-payment-retry-$rideId-${DateTime.now().millisecondsSinceEpoch}',
              },
            ),
          );

      final body = _asMap(response.data);
      final data = _unwrapData(response.data);
      if (response.statusCode != 200 || body['success'] == false) {
        throw Exception('Failed to retry ride payment: ${body['message']}');
      }
      final ride = data['ride'];
      if (ride is! Map) {
        throw Exception('Invalid ride payment retry response');
      }
      return Ride.fromJson(Map<String, dynamic>.from(ride));
    } catch (e, st) {
      log('Error retrying ride payment: $e', name: 'RideService');
      log('Stack trace: $st', name: 'RideService');
      rethrow;
    }
  }

  Future<RideRequest> getCurrentRides() async {
    try {
      final response = await Api().dio.get('/rides/current');

      log('Get Current rides Statuscode: ${response.statusCode}');
      log('Get Current rides Response: ${jsonEncode(response.data)}');

      final body = _asMap(response.data);
      final data = _unwrapData(response.data);
      if (response.statusCode != 200 || body['success'] == false) {
        throw Exception('Failed to get rides: ${body['message']}');
      }

      if (data['hasActiveRide'] == false || data['ride'] == null) {
        throw Exception('No current ride found');
      }

      return RideRequest.fromJson(data);
    } catch (e, st) {
      log('Error getting current rides: $e', name: 'RideService');
      log('Stack trace: $st', name: 'RideService');
      rethrow;
    }
  }
}
