import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/core/configs/app_config.dart';
import 'package:ridzs_passenger_app/core/services/dio_service.dart';
import 'package:ridzs_passenger_app/core/services/navigation_service.dart';
import 'package:ridzs_passenger_app/core/theme/size_config.dart';
import 'package:ridzs_passenger_app/models/payment/transaction_response_model.dart';
import 'package:ridzs_passenger_app/services/payment_service.dart';
import 'package:ridzs_passenger_app/stores/users/user_store.dart';
import 'package:ridzs_passenger_app/view/my_wallet/my_wallet.dart';
import 'package:provider/provider.dart';

class WalletHistoryAdapter implements HttpClientAdapter {
  WalletHistoryAdapter(this.respond);

  final Future<ResponseBody> Function(RequestOptions options) respond;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) =>
      respond(options);

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> transaction(String id) => {
      'id': id,
      'userId': 'passenger-1',
      'userType': 'passenger',
      'type': 'credit',
      'amount': 12.5,
      'balance': 42.5,
      'category': 'ride',
      'description': 'Ride payment',
      'status': 'completed',
      'createdAt': '2026-10-12T12:00:00Z',
      'updatedAt': '2026-10-12T12:00:00Z',
      'metadata': <String, dynamic>{},
    };

ResponseBody history(int page, String id) => ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'data': {
          'transactions': [transaction(id)],
          'pagination': {'total': 20, 'page': page, 'pages': 2},
        },
      }),
      200,
      headers: {
        'content-type': ['application/json'],
      },
    );

ResponseBody emptyHistory() => ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'data': {
          'transactions': <dynamic>[],
          'pagination': {'total': 0, 'page': 1, 'pages': 0},
        },
      }),
      200,
      headers: {
        'content-type': ['application/json'],
      },
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Dio dio;

  setUp(() {
    AppConfig.baseUrl = 'https://wallet-history.test';
    dio = Api().dio;
    dio.options.baseUrl = AppConfig.baseUrl;
    dio.interceptors.clear();
  });

  test('refresh always reloads transaction history from page one', () async {
    final requestedPages = <int>[];
    dio.httpClientAdapter = WalletHistoryAdapter((options) async {
      final page = int.parse(options.uri.queryParameters['page']!);
      requestedPages.add(page);
      return history(page, 'fresh');
    });

    final store = UserStore();
    store.transactionPageNo = 4;
    store.transactionList = [Transaction.fromJson(transaction('stale'))];

    await store.refreshTransactionList();

    expect(requestedPages, isNotEmpty);
    expect(requestedPages, [1]);
    expect(store.transactionPageNo, 2);
    expect(store.transactionList.map((item) => item.id), ['fresh']);
    expect(store.transactionError.value, isNull);
  });

  test('refresh requested during an in-flight load runs afterward', () async {
    final requestStarted = Completer<void>();
    final releaseFirstRequest = Completer<void>();
    final requestedPages = <int>[];
    dio.httpClientAdapter = WalletHistoryAdapter((options) async {
      final page = int.parse(options.uri.queryParameters['page']!);
      requestedPages.add(page);
      if (requestedPages.length == 1) {
        requestStarted.complete();
        await releaseFirstRequest.future;
        return history(page, 'stale');
      }
      return history(page, 'fresh');
    });

    final store = UserStore();
    final initialLoad = store.getTransactionList();
    await requestStarted.future.timeout(const Duration(seconds: 5));
    await store.refreshTransactionList();
    releaseFirstRequest.complete();
    await initialLoad;

    expect(requestedPages, [1, 1]);
    expect(store.transactionList.map((item) => item.id), ['fresh']);
    expect(store.transactionPageNo, 2);
  });

  test('failed refresh retains history and exposes retryable error state',
      () async {
    final store = UserStore();
    store.transactionList = [
      Transaction.fromJson({...transaction('existing'), '_id': 'existing'}),
    ];
    dio.httpClientAdapter = WalletHistoryAdapter((options) async {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.receiveTimeout,
      );
    });

    await store.refreshTransactionList();

    expect(store.transactionList.map((item) => item.id), ['existing']);
    expect(store.transactionError.value, 'Transaction history unavailable');
    expect(store.isTransactionLoading, isFalse);

    dio.httpClientAdapter =
        WalletHistoryAdapter((options) async => history(1, 'new'));
    await store.refreshTransactionList();
    expect(store.transactionList.map((item) => item.id), ['new']);
    expect(store.transactionError.value, isNull);
  });

  test('invalid transaction response is not interpreted as empty history',
      () async {
    dio.httpClientAdapter = WalletHistoryAdapter((_) async =>
        ResponseBody.fromString(
            jsonEncode({'success': true, 'data': {}}), 200));

    await expectLater(
      PaymentService.getUserTransaction(1),
      throwsFormatException,
    );
  });

  testWidgets('wallet history error has a working retry action',
      (tester) async {
    var failHistory = true;
    dio.httpClientAdapter = WalletHistoryAdapter((options) async {
      if (options.uri.path.endsWith('/wallet/balance')) {
        return ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'data': {
              'balance': {
                'id': 'wallet-1',
                'userId': 'passenger-1',
                'userType': 'passenger',
                'balance': 42.5,
                'holdBalance': 0,
                'lastUpdated': '2026-10-12T12:00:00Z',
                'version': 1,
              },
            },
          }),
          200,
          headers: {
            'content-type': ['application/json'],
          },
        );
      }
      if (failHistory) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.receiveTimeout,
        );
      }
      return emptyHistory();
    });
    final store = UserStore();

    await tester.pumpWidget(
      Provider<UserStore>.value(
        value: store,
        child: MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          builder: (context, child) {
            SizeConfig().init(context);
            return child!;
          },
          home: const MyWallet(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Transaction history unavailable'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    failHistory = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('No transactions found'), findsOneWidget);
    expect(find.text('Transaction history unavailable'), findsNothing);
  });
}
