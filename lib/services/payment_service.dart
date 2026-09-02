import 'dart:developer';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:ridzs_passenger_app/core/services/dio_service.dart';
import 'package:ridzs_passenger_app/models/response/payment/get_card_response.dart';

import '../models/payment/transaction_response_model.dart';
import '../models/payment/wallet_response_model.dart';

class PaymentService {
  factory PaymentService() => _instance ??= PaymentService._();

  PaymentService._();

  static PaymentService? _instance;

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

  static Future<Map> initStripe() async {
    final response = await Api().dio.post('/payment/create-setup-intent');
    final body = _asMap(response.data);
    final data = _unwrapData(response.data);

    if (response.statusCode == 200 && body['success'] != false) {
      log('URL = payment/create-setup-intent');
      return data;
    } else {
      throw Exception(body['message'] ?? 'Failed to initialize stripe');
    }
  }

  static Future<Map> addCard(SetupIntent setupIntentResult) async {
    final response = await Api().dio.post('/payment/add-card', data: {
      'setupIntentId': setupIntentResult.paymentMethodId,
    });

    final body = _asMap(response.data);
    final data = _unwrapData(response.data);
    if (response.statusCode == 200 && body['success'] != false) {
      log('URL = /payment/add-card');
      return {
        ...data,
        'message': body['message'],
      };
    } else {
      throw Exception(body['message'] ?? 'Failed to add card');
    }
  }

  static Future<GetCardResponse> getCards() async {
    try {
      final response = await Api().dio.get('/payment/cards');
      final body = _asMap(response.data);
      final data = _unwrapData(response.data);
      if (body['success'] == true) {
        return GetCardResponse.fromJson({
          'success': true,
          'cards': data['cards'] ?? <dynamic>[],
        });
      } else {
        throw Exception(body['message'] ?? 'Failed to load cards');
      }
    } catch (e) {
      throw Exception('Failed to get cards: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> initializePayment(num amount) async {
    try {
      final result = await Api().dio.post(
        '/wallet/initialize-payment',
        data: {"amount": amount},
      );
      final body = _asMap(result.data);
      final data = _unwrapData(result.data);

      log('Initializing payment -> ${result.statusCode}');
      log('Initializing payment -> ${result.data}');

      if (result.statusCode == 200 && body['success'] != false) {
        log('Payment initialized successfully');
        return data;
      } else {
        log('Failed to initialize payment: $body');
        return {};
      }
    } catch (e) {
      log('Error initializing payment: $e');
      return {};
    }
  }

  static Future<Balance?> getWalletBalance() async {
    try {
      final response = await Api().dio.get(
            '/wallet/balance',
          );
      final body = _asMap(response.data);
      final data = _unwrapData(response.data);
      log('Get wallet balance -> ${response.statusCode}');
      log('Get wallet balance -> ${response.data}');
      if (response.statusCode == 200 && body['success'] != false) {
        log('Wallet balance retrieved successfully');
        final balance = _asMap(data['balance']);
        return BalanceResponse.fromJson({
          'success': true,
          'balance': {
            '_id': balance['id'] ?? balance['_id'] ?? '',
            'userId': balance['userId'] ?? '',
            'userType': balance['userType'] ?? 'passenger',
            'balance': balance['balance'] ?? 0,
            'holdBalance': balance['holdBalance'] ?? 0,
            'lastUpdated': balance['lastUpdated'] ??
                DateTime.now().toIso8601String(),
            '__v': balance['version'] ?? balance['__v'] ?? 0,
          }
        }).balance;
      } else {
        log('Failed to retrieve wallet balance: $body');
        return null;
      }
    } catch (e) {
      log('Error retrieving wallet balance: $e');
      return null;
    }
  }

  static Future<List<Transaction>> getUserTransaction(int pageNo) async {
    try {
      final request = await Api().dio.get(
            '/wallet/transactions?page=$pageNo&limit=10',
          );
      final body = _asMap(request.data);
      final data = _unwrapData(request.data);

      log('Get transaction -> ${request.statusCode}');
      log('Get transaction -> ${request.data}');
      if (request.statusCode == 200 && body['success'] != false) {
        log('Get transaction retrieved successfully');
        final pagination = _asMap(data['pagination']);
        final transactions = (data['transactions'] as List? ?? <dynamic>[])
            .map((e) => _asMap(e))
            .toList();

        final response = TransactionResponse.fromJson({
          'success': true,
          'transactions': transactions
              .map((tx) => {
                    ...tx,
                    '_id': tx['id'] ?? tx['_id'] ?? '',
                    '__v': tx['version'] ?? tx['__v'] ?? 0,
                  })
              .toList(),
          'total': pagination['total'] ?? transactions.length,
          'page': pagination['page'] ?? pageNo,
          'pages': pagination['pages'] ?? 1,
        });
        return response.transactions;
      } else {
        log('Failed to retrieve transaction: $body');
        return [];
      }
    } catch (e) {
      log('Error retrieving transaction: $e');
      return [];
    }
  }

  static Future<bool> deleteCard(String cardId) async {
    try {
      final response = await Api().dio.delete('/payment/cards/$cardId');
      final body = _asMap(response.data);
      log('Delete card -> ${response.statusCode}');
      log('Delete card -> ${response.data}');
      if (response.statusCode == 200 && body['success'] != false) {
        log('Card deleted successfully');
        return true;
      } else {
        log('Failed to delete card: $body');
        return false;
      }
    } catch (e) {
      log('Error deleting card: $e');
      return false;
    }
  }
}
