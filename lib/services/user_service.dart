import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ridzs_passenger_app/core/services/dio_service.dart';
import 'package:ridzs_passenger_app/core/services/toast_service.dart';

class UserService {
  static final UserService _instance = UserService._();
  factory UserService() => _instance;
  UserService._();

  Future<void> updateFCMToken() async {
    final messaging = FirebaseMessaging.instance;
    final token = await messaging.getToken();

    final request = await Api().dio.put(
      '/auth/update-fcm-token',
      data: {
        'fcmToken': token,
      },
    );

    log('FCM Token update Statuscode: ${request.statusCode}');
    log('FCM Token update Response: ${jsonEncode(request.data)}');

    if (request.statusCode != 200) {
      throw Exception('Failed to update FCM token: ${request.data}');
    }
  }

  Future<void> addWalletAmount(String paymentId, num amount) async {
    try {
      final request = await Api().dio.post(
        '/wallet/add',
        data: {
          'paymentMethodId': paymentId,
          'amount': amount,
        },
      );

      log('Add Wallet Amount Statuscode: ${request.statusCode}');
      log('Add Wallet Amount Response: ${jsonEncode(request.data)}');

      if (request.statusCode != 200) {
        throw Exception('Failed to add wallet amount: ${request.data}');
      }
    } on DioException catch (e) {
      ToastService.show(
          e.response?.data['message'] ?? 'Failed to add wallet amount');
      log('DioException in addWalletAmount: ${e.message}');
      throw Exception('Failed to add wallet amount: ${e.message}');
    } catch (e) {
      log('Unknown error in addWalletAmount: $e');
      throw Exception('Failed to add wallet amount: $e');
    }
  }
}
