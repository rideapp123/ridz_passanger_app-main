import 'dart:developer';
import '../core/configs/app_config.dart';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';

import '../../core/services/dio_service.dart';
import '../models/contracts/login_contract.dart';
import '../models/contracts/user_details_update_contract.dart';
import '../models/response/user/login_response.dart';
import '../models/response/user/me_response.dart';
import '../models/response/user/register_token_response.dart';
import '../models/response/user/request_code_response.dart';

class AuthService {
  factory AuthService() => _instance ??= AuthService._();

  AuthService._();

  static AuthService? _instance;

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static Map<String, dynamic> _unwrapData(dynamic value) {
    final body = _asMap(value);
    final data = body['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return body;
  }

  static String _backendRootUrl() => AppConfig.apiRootUrl;

  static Map<String, dynamic> _normalizeUserJson(Map<String, dynamic> user) {
    final normalized = Map<String, dynamic>.from(user);
    if (normalized['id'] == null && normalized['_id'] != null) {
      normalized['id'] = normalized['_id'];
    }
    if (normalized['profile_picture'] == null &&
        normalized['profilePicture'] != null) {
      normalized['profile_picture'] = normalized['profilePicture'];
    }
    // Ensure profile_picture is a full URL
    final pic = normalized['profile_picture'];
    if (pic is String && pic.isNotEmpty && !pic.startsWith('http')) {
      // Relative path — prepend the backend base URL (without /passenger)
      normalized['profile_picture'] = '${_backendRootUrl()}$pic';
      debugPrint(
          'Normalized profile_picture: ${normalized['profile_picture']}');
    }
    if (normalized['authType'] is String) {
      normalized['authType'] = (normalized['authType'] as String).toLowerCase();
    }
    return normalized;
  }

  // Login
  static Future<LoginResponse> login(LoginContract data) async {
    final response = await Api()
        .dio
        .post('/auth/verify-otp', data: LoginContract.toJson(data));
    final body = _asMap(response.data);
    final payload = _unwrapData(response.data);

    final user = payload['passenger'] ?? payload['user'];
    if (user is! Map) {
      throw Exception(body['message'] ?? 'Invalid login response');
    }

    return LoginResponse.fromJson({
      'user': _normalizeUserJson(Map<String, dynamic>.from(user)),
      'token': payload['token'] ?? '',
      'isNewUser': payload['isNewUser'] ?? false,
      'message': body['message'],
    });
  }

  static Future<void> logOut() async {
    // JWT is stateless in backend; clearing local token is sufficient.
    return;
  }

  // // Login
  static Future<LoginResponse> loginWithGoogle(String idToken) async {
    var response = await Api().dio.post('/auth/google-login', data: {
      'googleId': idToken,
    });
    final body = _asMap(response.data);
    final payload = _unwrapData(response.data);
    final user = payload['passenger'] ?? payload['user'];
    if (user is! Map) {
      throw Exception(body['message'] ?? 'Invalid Google login response');
    }

    return LoginResponse.fromJson({
      'user': _normalizeUserJson(Map<String, dynamic>.from(user)),
      'token': payload['token'] ?? '',
      'isNewUser': payload['isNewUser'] ?? false,
      'message': body['message'],
    });
  }

  //
  // // Get me
  static Future<MeResponse> getMe() async {
    var response = await Api().dio.get('/auth/me');
    debugPrint('Get me Response -> ${response.statusCode}');
    final body = _asMap(response.data);
    final payload = _unwrapData(response.data);
    final user = payload['passenger'] ?? payload['user'] ?? payload;
    if (user is! Map) {
      throw Exception(body['message'] ?? 'Invalid user response');
    }
    final userMap = Map<String, dynamic>.from(user);
    debugPrint(
        'Profile picture from backend: ${userMap['profile_picture'] ?? userMap['profilePicture']}');
    return MeResponse.fromJson({
      'user': _normalizeUserJson(userMap),
      'message': body['message'],
    });
  }

  static Future<MeResponse> updateProfile(
      UserDetailsUpdateContract contract) async {
    var response = await Api().dio.put('/auth/update-profile',
        data: UserDetailsUpdateContract.toJson(contract));
    final body = _asMap(response.data);
    final payload = _unwrapData(response.data);
    final user = payload['passenger'] ?? payload['user'] ?? payload;
    if (user is! Map) {
      throw Exception(body['message'] ?? 'Invalid profile update response');
    }
    return MeResponse.fromJson({
      'user': _normalizeUserJson(Map<String, dynamic>.from(user)),
      'message': body['message'],
    });
  }

  //
  // // Sends Firebase Cloud Messaging token
  static Future<RegisterTokenResponse> sendFCMToken(String token) async {
    final response = await Api().dio.put(
      '/auth/update-fcm-token',
      data: {'fcmToken': token},
    );
    final body = _asMap(response.data);
    return RegisterTokenResponse.fromJson({
      'success': body['success'] == true,
    });
  }

  // Request
  static Future<RequestCodeResponse> requestCode(String recipient) async {
    var response =
        await Api().dio.post('/auth/send-otp', data: {'recipient': recipient});

    log('Request code Response -> ${response.statusCode}');
    log('Request code Response -> ${response.data}');

    final body = _asMap(response.data);
    final payload = _unwrapData(response.data);
    return RequestCodeResponse.fromJson({
      'success': body['success'] == true,
      'resend': payload['resend'] == true,
      'message': body['message'],
      'error': body['code'],
    });
  }

  static Future<String> uploadImage(String filePath) async {
    try {
      final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';
      debugPrint('Upload image: $filePath (mime: $mimeType)');

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
          contentType: DioMediaType.parse(mimeType),
        ),
      });

      final response = await Api().dio.post(
            '/auth/update-profile-image',
            data: formData,
            options: Options(
              contentType: 'multipart/form-data',
              sendTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

      debugPrint('Upload image Response -> ${response.statusCode}');
      debugPrint('Upload image Response -> ${response.data}');

      final body = _asMap(response.data);
      final payload = _unwrapData(body);
      String? imageUrl;
      if (payload['profilePicture'] is String) {
        imageUrl = payload['profilePicture'] as String;
      } else if (payload['profile_picture'] is String) {
        imageUrl = payload['profile_picture'] as String;
      }
      if (imageUrl != null && imageUrl.isNotEmpty) {
        if (!imageUrl.startsWith('http')) {
          imageUrl = '${_backendRootUrl()}$imageUrl';
        }
        debugPrint('Uploaded profile picture URL: $imageUrl');
        return imageUrl;
      }
      debugPrint('Upload response missing profilePicture key: $payload');
      return '';
    } on DioException catch (e) {
      debugPrint(
          'Error uploading image: ${e.response?.statusCode} ${e.response?.data}');
      throw Exception(
          'Failed to upload image: ${e.response?.statusCode ?? e.message}');
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }
}
