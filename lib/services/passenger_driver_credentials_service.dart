import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/services/dio_service.dart';
import '../models/passenger_driver_credentials.dart';

class PassengerCredentialSessionEnded implements Exception {
  const PassengerCredentialSessionEnded();
}

class PassengerCredentialSnapshot {
  PassengerCredentialSnapshot(this.data, this._elapsed);
  final PassengerDriverCredentials data;
  final Stopwatch _elapsed;
  Duration get remaining =>
      data.validUntil.difference(data.serverTime) - _elapsed.elapsed;
}

class PassengerDriverCredentialsService extends ChangeNotifier {
  PassengerDriverCredentialsService(
      {required this.ownerId,
      required this.binding,
      required String? Function() ownerReader,
      required bool Function() rideIsCurrent,
      Dio? dio})
      : _ownerReader = ownerReader,
        _rideIsCurrent = rideIsCurrent,
        _dio = dio ?? Api().dio {
    _auth = _dio.interceptors.whereType<AuthInterceptor>().single;
    _epoch = _auth.sessionEpoch;
    _backend = _dio.options.baseUrl;
    _auth.sessionChanges.addListener(invalidate);
    _token = _auth.readAccessToken().catchError((Object _) => null);
  }
  final String ownerId;
  final CredentialRideBinding binding;
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
      _dio.interceptors.whereType<AuthInterceptor>().length == 1 &&
      _dio.interceptors.contains(_auth) &&
      _auth.sessionEpoch == _epoch;

  void invalidate() {
    if (_ended) return;
    _ended = true;
    cancelRequests();
    notifyListeners();
  }

  void cancelRequests() {
    _cancel.cancel('Credential view ended');
    _cancel = CancelToken();
  }

  Future<String> _check() async {
    try {
      if (!isCurrent) throw const PassengerCredentialSessionEnded();
      final token = await _token;
      final current = await _auth.readAccessToken();
      if (!isCurrent || token == null || token != current) {
        throw const PassengerCredentialSessionEnded();
      }
      final parts = token.split('.');
      if (parts.length != 3) throw const PassengerCredentialSessionEnded();
      final claims = jsonDecode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      if (claims is! Map ||
          claims['id'] != ownerId ||
          claims['role'] != 'PASSENGER') {
        throw const PassengerCredentialSessionEnded();
      }
      return token;
    } catch (_) {
      invalidate();
      throw const PassengerCredentialSessionEnded();
    }
  }

  Future<PassengerCredentialSnapshot> load() async {
    if (!CredentialRideBinding.validId(binding.rideId) ||
        !CredentialRideBinding.validId(binding.driverId) ||
        binding.version < 0) {
      throw const FormatException('Invalid assigned ride');
    }
    final cancel = _cancel;
    final elapsed = Stopwatch()..start();
    final token = await _check();
    if (cancel.isCancelled) throw const PassengerCredentialSessionEnded();
    try {
      final response = await _dio.get(
          '/rides/${Uri.encodeComponent(binding.rideId)}/driver-credentials',
          cancelToken: cancel,
          options: Options(followRedirects: false, headers: {
            'Cache-Control': 'no-store'
          }, extra: {
            'expectedAuthToken': token,
            'expectedAuthSessionEpoch': _epoch,
            'authSessionIsCurrent': () => isCurrent && !cancel.isCancelled,
          }));
      await _check();
      if (cancel.isCancelled) throw const PassengerCredentialSessionEnded();
      final body = response.data;
      if (response.statusCode != 200 ||
          body is! Map ||
          body['success'] != true) {
        throw const FormatException('Invalid credential response');
      }
      final result = PassengerCredentialSnapshot(
          PassengerDriverCredentials.parse(body['data'], binding), elapsed);
      if (result.remaining <= Duration.zero) {
        throw const FormatException('Credential observation expired');
      }
      return result;
    } catch (error) {
      if (error is DioException &&
          const [401, 403, 404, 409].contains(error.response?.statusCode)) {
        invalidate();
      }
      await _check();
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
