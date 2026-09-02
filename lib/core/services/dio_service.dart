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
  AuthInterceptor(this.dio);
  final Dio dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    String? accessToken = await PreferencesService.getAccessToken();
    log('calling Api ${AppConfig.baseUrl}${options.path}');
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('API Success');

    log(
      'API Response[${response.requestOptions.uri.path}]: ${response.statusCode}',
      name: response.requestOptions.path,
    );

    log(
      'API Response[${response.requestOptions.uri.path}]: ${response.data}',
      name: response.requestOptions.path,
    );

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(err.toString());

    if (err.response != null) {
      log('API Error Response: ${err.response?.data}');
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
        final message = err.response?.data is Map
            ? err.response?.data['message']
            : null;
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
