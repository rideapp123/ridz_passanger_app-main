import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/core/services/dio_service.dart';
import 'package:ridzs_passenger_app/models/passenger_driver_credentials.dart';
import 'package:ridzs_passenger_app/services/passenger_driver_credentials_service.dart';
import 'package:ridzs_passenger_app/view/home/widget/passenger_driver_credentials_screen.dart';

Future<void> until(WidgetTester tester, bool Function() ready) async {
  for (var i = 0; i < 300; i++) {
    await tester.pump(const Duration(milliseconds: 20));
    if (ready()) return;
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 25)));
  }
  expect(ready(), isTrue, reason: 'Live credential UI did not converge');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final path = Platform.environment['RIDZS_CREDENTIAL_FIXTURE'];
  if (path == null) {
    test('requires disposable credential backend', () {},
        skip: 'Run backend test-adjustment-earnings.sh credentials-native');
    return;
  }
  testWidgets(
      'safe issued view, lost read, revoke, supersede and completed ride',
      (tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = null;
    addTearDown(() => HttpOverrides.global = previous);
    final manifest = jsonDecode(File(path).readAsStringSync()) as Map;
    final url = Uri.parse(manifest['url'] as String);
    expect(url.host, '127.0.0.1');
    expect(url.scheme, 'http');
    final control = Dio(BaseOptions(
        baseUrl: url.toString(),
        headers: {'Authorization': 'Bearer ${manifest['key']}'},
        receiveTimeout: const Duration(seconds: 45)));
    addTearDown(() => control.close(force: true));
    Future<Map> command(String name) async =>
        (await control.post('/$name')).data as Map;
    final config = (await tester.runAsync(() => command('config')))!;
    final api = Uri.parse(config['api'] as String);
    expect(api.host, '127.0.0.1');
    expect(api.scheme, 'http');
    final dio = Dio(BaseOptions(
        baseUrl: api.toString(),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10)));
    addTearDown(() => dio.close(force: true));
    dio.interceptors.add(AuthInterceptor(dio,
        tokenReader: () async => config['token'] as String));
    var loseRead = false;
    var reads = 0;
    dio.interceptors.add(InterceptorsWrapper(onResponse: (response, handler) {
      reads++;
      expect(response.headers.value('cache-control'), 'no-store');
      final data = response.data['data'] as Map;
      expect(data.keys.toSet(), {
        'protocol',
        'rideId',
        'rideVersion',
        'driverId',
        'issuer',
        'scope',
        'serverTime',
        'validUntil',
        'credentials'
      });
      for (final credential in data['credentials'] as List) {
        expect((credential as Map).keys.toSet(), {'kind', 'expiresAt'});
      }
      if (loseRead) {
        loseRead = false;
        handler.reject(DioException(
            requestOptions: response.requestOptions,
            type: DioExceptionType.connectionError,
            message: 'Synthetic lost read response'));
      } else {
        handler.next(response);
      }
    }));
    final binding = CredentialRideBinding(
        config['rideId'] as String, 'driver', config['rideVersion'] as int);
    await tester.runAsync(() => tester.pumpWidget(MaterialApp(
        home: PassengerDriverCredentialsScreen(
            binding: binding,
            serviceFactory: () => PassengerDriverCredentialsService(
                ownerId: 'passenger',
                binding: binding,
                ownerReader: () => 'passenger',
                rideIsCurrent: () => true,
                dio: dio)))));
    const empty = 'No current Ridzs-issued credentials available.';
    await until(tester, () => find.text(empty).evaluate().isNotEmpty);
    Future<void> refresh() async {
      await tester
          .runAsync(() => tester.tap(find.byTooltip('Refresh credentials')));
      await tester.pump();
    }

    await tester.runAsync(() => command('issue'));
    await refresh();
    await until(
        tester,
        () =>
            find.text('Ridzs driver ID').evaluate().isNotEmpty &&
            find.text('Ridzs certificate').evaluate().isNotEmpty);
    loseRead = true;
    await refresh();
    await until(tester, () => find.text('Retry').evaluate().isNotEmpty);
    expect(find.text('Ridzs driver ID'), findsNothing);
    expect(find.text('Ridzs certificate'), findsNothing);
    await tester.runAsync(() => tester.tap(find.text('Retry')));
    await until(
        tester, () => find.text('Ridzs driver ID').evaluate().isNotEmpty);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(find.text('Ridzs driver ID'), findsNothing);
    await tester.runAsync(() => command('revoke'));
    await tester.runAsync(() async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    });
    await until(
        tester, () => find.text('Ridzs certificate').evaluate().isNotEmpty);
    expect(find.text('Ridzs driver ID'), findsNothing);
    await tester.runAsync(() => command('supersede'));
    await refresh();
    await until(tester, () => find.text(empty).evaluate().isNotEmpty);
    expect(find.text('Ridzs certificate'), findsNothing);
    await tester.runAsync(() => command('verify'));
    await refresh();
    await until(
        tester,
        () => find
            .text('Ride or session changed. Return to your ride.')
            .evaluate()
            .isNotEmpty);
    expect(find.text(empty), findsNothing);
    expect(find.text('Retry'), findsNothing);
    expect(reads, greaterThanOrEqualTo(6));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
