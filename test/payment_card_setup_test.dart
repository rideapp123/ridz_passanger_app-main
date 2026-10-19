import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/core/configs/app_config.dart';
import 'package:ridzs_passenger_app/core/services/dio_service.dart';
import 'package:ridzs_passenger_app/services/payment_service.dart';

class CardAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream,
      Future<void>? cancelFuture) async {
    requests.add(options);
    return ResponseBody.fromString(
      '{"success":true,"data":{"card":{"id":"pm_owned"}}}',
      200,
      headers: {
        'content-type': ['application/json']
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late CardAdapter adapter;
  setUp(() {
    AppConfig.baseUrl = 'https://example.test';
    adapter = CardAdapter();
    Api().dio.interceptors.clear();
    Api().dio.httpClientAdapter = adapter;
  });
  SetupIntent setup({String id = 'seti_owned', String status = 'Succeeded'}) =>
      SetupIntent(
        id: id,
        status: status,
        livemode: false,
        clientSecret: 'seti_owned_secret_synthetic',
        paymentMethodId: 'pm_owned',
        usage: 'OffSession',
        paymentMethodTypes: [],
      );

  test('registration sends SetupIntent ID, never payment method or secret',
      () async {
    final result = await PaymentService.addCard(setup());
    expect(result['card']['id'], 'pm_owned');
    expect(adapter.requests.single.data, {'setupIntentId': 'seti_owned'});
    expect(adapter.requests.single.path, '/payment/add-card');
  });

  for (final status in ['RequiresAction', 'Processing', 'Canceled']) {
    test('incomplete $status setup cannot be registered', () async {
      await expectLater(
          PaymentService.addCard(setup(status: status)), throwsStateError);
      expect(adapter.requests, isEmpty);
    });
  }

  test('payment method ID is rejected as a setup ID', () async {
    await expectLater(
        PaymentService.addCard(setup(id: 'pm_owned')), throwsStateError);
    expect(adapter.requests, isEmpty);
  });
}
