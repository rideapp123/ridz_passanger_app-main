import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
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
  RideService._() : _dio = null;
  RideService.withClient(Dio dio) : _dio = dio;
  final Dio? _dio;

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
    required String idempotencyKey,
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

      return createBooking(request, idempotencyKey);
    } catch (e, st) {
      log('Error creating ride request: $e', name: 'RideService');
      log('Stack trace: $st', name: 'RideService');
      rethrow;
    }
  }

  Future<RideRequest> createBooking(
      Map<String, dynamic> payload, String key) async {
    if (key.isEmpty) throw ArgumentError('A booking key is required');
    final response = await (_dio ?? Api().dio).post('/rides',
        data: payload, options: Options(headers: {'Idempotency-Key': key}));
    if (payload.containsKey('quoteId')) {
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      final ride = data is Map ? data['ride'] : null;
      final fare = ride is Map ? ride['fare'] : null;
      final minor = payload['quoteAmountMinor'];
      if (fare is! Map ||
          minor is! int ||
          fare['quoteId'] != payload['quoteId'] ||
          fare['quoteFingerprint'] != payload['quoteFingerprint'] ||
          fare['currency'] != 'usd' ||
          fare['total'] is! num ||
          !(fare['total'] as num).isFinite ||
          ((fare['total'] as num).toDouble() - minor / 100).abs() > 0.0000001) {
        throw const FormatException('Quoted booking was not confirmed');
      }
    }
    return _confirmedRide(response);
  }

  Future<RideRequest> retrySearch(String rideId, int version,
      {required String expectedAuthToken}) async {
    final response = await (_dio ?? Api().dio).post(
        '/rides/${Uri.encodeComponent(rideId)}/search',
        data: {'version': version},
        options: Options(extra: {'expectedAuthToken': expectedAuthToken}));
    final ride = _confirmedRide(response);
    if (ride.ride?.sId != rideId) throw const FormatException('Wrong ride');
    return ride;
  }

  RideRequest _confirmedRide(Response<dynamic> response) {
    final body = response.data;
    final data = body is Map ? body['data'] : null;
    final ride = data is Map ? data['ride'] : null;
    if (response.statusCode != 200 ||
        body is! Map ||
        body['success'] != true ||
        data is! Map ||
        ride is! Map ||
        (ride['id'] ?? ride['_id']) is! String ||
        ((ride['id'] ?? ride['_id']) as String).isEmpty ||
        (ride['_id'] != null &&
            ride['id'] != null &&
            ride['_id'] != ride['id']) ||
        RideStatus.fromString((ride['status'] ?? '').toString()) == null) {
      throw const FormatException('Booking was not confirmed');
    }
    return RideRequest.fromJson(Map<String, dynamic>.from(data));
  }


  Future<RideResponse> updateRideStatus(
    String rideId,
    RideStatus status, {
    String? reason,
    String? details,
  }) async {
    try {
      final response = await (_dio ?? Api().dio).put(
        '/rides/$rideId/status',
        // The same command must retain its key after an uncertain reply or app restart.
        options: Options(headers: {
          'Idempotency-Key':
              'passenger-ride-status-v1-${sha256.convert(utf8.encode(jsonEncode([
                rideId,
                status.title,
                reason,
                details
              ])))}',
        }),
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
      if (response.statusCode != 200 ||
          body['success'] != true ||
          ride is! Map ||
          (ride['id'] ?? ride['_id']) != rideId ||
          ride['status'] != status.title) {
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
