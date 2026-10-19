import 'package:dio/dio.dart';
import '../core/services/dio_service.dart';
import '../models/ad_reward.dart';

class AdRewardService {
  AdRewardService({Dio? dio}) : _provided = dio;
  final Dio? _provided;
  Dio get _dio => _provided ?? Api().dio;
  Options _options(String token) =>
      Options(extra: {'expectedAuthToken': token});
  Map<String, dynamic> _data(Response response) {
    final body = response.data;
    if (response.statusCode != 200 ||
        body is! Map ||
        body['success'] != true ||
        body['data'] is! Map) {
      throw const FormatException('Reward response was not confirmed');
    }
    return Map<String, dynamic>.from(body['data']);
  }

  Future<AdRewardOffer> offer(String token, {String? rideId}) async =>
      AdRewardOffer.parse(_data(await _dio.get('/ad-rewards/offer',
          queryParameters: {if (rideId != null) 'rideId': rideId},
          options: _options(token))));

  Future<AdRewardSession> start(
      String token, String owner, String requestId, String? rideId) async {
    final data = _data(
        await _dio.post('/ad-rewards/start', options: _options(token), data: {
      'requestId': requestId,
      if (rideId != null) 'rideId': rideId,
      'placement': rideId == null || rideId.isEmpty
          ? 'wallet_rewards'
          : 'post_ride_request',
    }));
    final session = AdRewardSession.parse(data['session'], owner);
    if (session.requestId != requestId || session.rideId != (rideId ?? '')) {
      throw const FormatException('Wrong reward start response');
    }
    return session;
  }

  Future<AdRewardSession> detail(String token, String owner, String id) async =>
      AdRewardSession.parse(
          _data(await _dio.get('/ad-rewards/${Uri.encodeComponent(id)}',
              options: _options(token)))['session'],
          owner,
          expectedId: id);

  Future<AdRewardSession> cancel(String token, String owner, String id) async {
    final session = AdRewardSession.parse(
        _data(await _dio.post('/ad-rewards/${Uri.encodeComponent(id)}/cancel',
            data: {'reason': 'closed_before_ad'},
            options: _options(token)))['session'],
        owner,
        expectedId: id);
    if (session.status != 'cancelled') {
      throw const FormatException('Cancellation was not confirmed');
    }
    return session;
  }

  Future<List<Map<String, dynamic>>> history(String token,
      {int page = 1}) async {
    final data = _data(await _dio.get('/ad-rewards',
        queryParameters: {'page': page, 'limit': 20},
        options: _options(token)));
    if (data['sessions'] is! List ||
        (data['sessions'] as List).any((v) => v is! Map)) {
      throw const FormatException('Invalid reward history');
    }
    return (data['sessions'] as List)
        .map((v) => Map<String, dynamic>.from(v))
        .toList();
  }
}
