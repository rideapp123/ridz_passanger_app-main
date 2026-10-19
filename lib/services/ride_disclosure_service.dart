import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/services/dio_service.dart';
import '../models/ride_disclosure.dart';

class RideDisclosureSessionEnded implements Exception {
  const RideDisclosureSessionEnded();
}

class RideDisclosureUnavailable implements Exception {
  const RideDisclosureUnavailable();
}

class RideDisclosureSnapshot {
  RideDisclosureSnapshot(this.data, this._elapsed, this._current);
  final RideDisclosure data;
  final Stopwatch _elapsed;
  final bool Function() _current;
  Duration get remaining =>
      data.refreshAfter.difference(data.serverTime) - _elapsed.elapsed;
  bool get isFresh => _current() && remaining > Duration.zero;
}

class RideDisclosureService extends ChangeNotifier {
  RideDisclosureService(
      {required this.ownerId,
      required this.rideId,
      required String? Function() ownerReader,
      required bool Function() rideIsCurrent,
      Dio? dio})
      : _ownerReader = ownerReader,
        _rideIsCurrent = rideIsCurrent,
        _dio = dio ?? Api().dio {
    if (!RideDisclosure.validRideId(rideId)) {
      throw const FormatException('Invalid ride');
    }
    _auth = _dio.interceptors.whereType<AuthInterceptor>().single;
    _epoch = _auth.sessionEpoch;
    _backend = _dio.options.baseUrl;
    _auth.sessionChanges.addListener(invalidate);
    _token = _auth.readAccessToken().catchError((Object _) => null);
  }
  final String ownerId, rideId;
  final String? Function() _ownerReader;
  final bool Function() _rideIsCurrent;
  final Dio _dio;
  late final AuthInterceptor _auth;
  late final int _epoch;
  late final String _backend;
  late final Future<String?> _token;
  CancelToken _cancel = CancelToken();
  bool _ended = false;
  bool get isCurrent =>
      !_ended &&
      ownerId.isNotEmpty &&
      _ownerReader() == ownerId &&
      _rideIsCurrent() &&
      _dio.options.baseUrl == _backend &&
      _auth.sessionEpoch == _epoch &&
      _dio.interceptors.whereType<AuthInterceptor>().length == 1 &&
      _dio.interceptors.contains(_auth);

  void invalidate() {
    if (_ended) return;
    _ended = true;
    cancelRequests();
    notifyListeners();
  }

  void cancelRequests() {
    _cancel.cancel('Ride document view ended');
    _cancel = CancelToken();
  }

  Future<String> _check() async {
    try {
      if (!isCurrent) throw const RideDisclosureSessionEnded();
      final token = await _token;
      final current = await _auth.readAccessToken();
      if (!isCurrent || token == null || token != current) {
        throw const RideDisclosureSessionEnded();
      }
      final parts = token.split('.');
      if (parts.length != 3) throw const RideDisclosureSessionEnded();
      final claims = jsonDecode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      if (claims is! Map ||
          claims['id'] != ownerId ||
          claims['role'] != 'PASSENGER') {
        throw const RideDisclosureSessionEnded();
      }
      return token;
    } catch (_) {
      invalidate();
      throw const RideDisclosureSessionEnded();
    }
  }

  Future<RideDisclosureSnapshot> load(String locale) async {
    if (!RideDisclosure.validLocale(locale)) {
      throw const FormatException('Invalid document language');
    }
    final cancel = _cancel;
    final elapsed = Stopwatch()..start();
    final token = await _check();
    if (cancel.isCancelled) throw const RideDisclosureSessionEnded();
    try {
      final response = await _dio.get(
          '/rides/${Uri.encodeComponent(rideId)}/regional-disclosure',
          queryParameters: {'locale': locale},
          cancelToken: cancel,
          options: Options(followRedirects: false, headers: {
            'Cache-Control': 'no-store'
          }, extra: {
            'expectedAuthToken': token,
            'expectedAuthSessionEpoch': _epoch,
            'authSessionIsCurrent': () => isCurrent && !cancel.isCancelled,
          }));
      await _check();
      if (cancel.isCancelled) throw const RideDisclosureSessionEnded();
      final body = response.data;
      if (response.statusCode != 200 ||
          body is! Map ||
          body['success'] != true) {
        throw const FormatException('Invalid ride document response');
      }
      final result = RideDisclosureSnapshot(
          RideDisclosure.parse(body['data'], rideId: rideId, locale: locale),
          elapsed,
          () => isCurrent && !cancel.isCancelled);
      if (!result.isFresh) {
        throw const FormatException('Ride document observation expired');
      }
      return result;
    } catch (error) {
      if (error is DioException &&
          const [401, 403, 404].contains(error.response?.statusCode)) {
        invalidate();
      }
      await _check();
      if (cancel.isCancelled) throw const RideDisclosureSessionEnded();
      if (error is DioException &&
          error.response?.statusCode == 409 &&
          error.response?.data is Map &&
          error.response?.data['code'] == 'RIDE_DISCLOSURE_UNAVAILABLE') {
        throw const RideDisclosureUnavailable();
      }
      rethrow;
    }
  }

  @override
  void dispose() {
    _auth.sessionChanges.removeListener(invalidate);
    _ended = true;
    cancelRequests();
    super.dispose();
  }
}
