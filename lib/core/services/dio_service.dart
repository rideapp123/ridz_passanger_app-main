import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../configs/app_config.dart';
import 'preferences_service.dart';

class Api {
  factory Api() => _singleton;

  Api._internal();
  final dio = createDio();

  static final _singleton = Api._internal();

  void endSession() {
    for (final interceptor in dio.interceptors.whereType<AuthInterceptor>()) {
      interceptor.endSession();
    }
  }

  static Dio createDio() {
    var dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      receiveTimeout: const Duration(seconds: 10),
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ));

    dio.interceptors.addAll({
      AuthInterceptor(dio),
    });

    return dio;
  }
}

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this.dio, {Future<String?> Function()? tokenReader})
      : _tokenReader = tokenReader ?? PreferencesService.getAccessToken;
  final Dio dio;
  final Future<String?> Function() _tokenReader;
  int _epoch = 0;
  CancelToken _cancel = CancelToken();
  final ValueNotifier<int> _sessionChanges = ValueNotifier(0);
  int get sessionEpoch => _epoch;
  Listenable get sessionChanges => _sessionChanges;
  Future<String?> readAccessToken() => _tokenReader();

  void endSession() {
    _epoch++;
    _cancel.cancel('Session ended');
    _cancel = CancelToken();
    _sessionChanges.value = _epoch;
  }

  bool _stale(RequestOptions options) =>
      options.extra['authSessionEpoch'] != _epoch;
  DioException _cancelled(RequestOptions options) => DioException(
      requestOptions: options,
      type: DioExceptionType.cancel,
      message: 'Session ended');

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.extra['authSessionEpoch'] = _epoch;
    options.cancelToken ??= _cancel;
    String? accessToken;
    try {
      accessToken = await _tokenReader();
    } catch (error) {
      return handler
          .reject(DioException(requestOptions: options, error: error));
    }
    if (_stale(options)) return handler.reject(_cancelled(options));
    if (options.extra.containsKey('expectedAuthSessionEpoch') &&
        options.extra['expectedAuthSessionEpoch'] != _epoch) {
      return handler.reject(_cancelled(options));
    }
    final isCurrent = options.extra['authSessionIsCurrent'];
    if (isCurrent is bool Function() && !isCurrent()) {
      return handler.reject(_cancelled(options));
    }
    if (options.extra.containsKey('expectedAuthToken') &&
        options.extra['expectedAuthToken'] != accessToken) {
      return handler.reject(_cancelled(options));
    }
    log('API request: ${options.method}');
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_stale(response.requestOptions)) {
      return handler.reject(_cancelled(response.requestOptions));
    }
    debugPrint('API Success');

    log('API response: ${response.statusCode}');

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.requestOptions.path.startsWith('/privacy-request')) {
      return handler.next(err);
    }
    if (_stale(err.requestOptions)) {
      return handler.next(_cancelled(err.requestOptions));
    }
    if (err.requestOptions.path.startsWith('/rides') ||
        err.requestOptions.path.startsWith('/ride-quotes') ||
        err.requestOptions.path.startsWith('/ad-rewards') ||
        err.requestOptions.path.startsWith('/chat/')) {
      return handler.next(err);
    }
    if (err.requestOptions.path == '/service-area') {
      return handler.next(err);
    }
    debugPrint('API error: ${err.type.name}');

    if (err.response != null) {
      log('API error status: ${err.response?.statusCode}');
    }
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw CustomException(err.requestOptions,
            'No internet connection detected, please try again.');
      case DioExceptionType.cancel:
        break;
      case DioExceptionType.unknown:
        throw CustomException(err.requestOptions,
            'An unexpected error occurred, please try again.');
      case DioExceptionType.connectionError:
        throw CustomException(err.requestOptions,
            'Network is unreachable, please try again later.');
      default:
        final message =
            err.response?.data is Map ? err.response?.data['message'] : null;
        switch (err.response?.statusCode) {
          case 400:
          case 401:
          case 404:
          case 406:
          case 409:
          case 422:
          case 500:
            throw CustomException(
                err.requestOptions, message ?? 'Something went wrong');
          default:
            throw CustomException(
                err.requestOptions, message ?? 'Something went wrong');
        }
    }
    return handler.next(err);
  }
}

class CustomException extends DioException {
  CustomException(RequestOptions r, String message)
      : super(requestOptions: r, message: message);

  @override
  String toString() {
    return message ?? 'An unknown error occurred;';
  }
}
