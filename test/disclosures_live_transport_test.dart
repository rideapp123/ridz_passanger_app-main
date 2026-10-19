import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/core/services/dio_service.dart';
import 'package:ridzs_passenger_app/services/ride_disclosure_service.dart';
import 'package:ridzs_passenger_app/view/legal/ride_documents_screen.dart';
import 'package:ridzs_passenger_app/services/regional_disclosure_service.dart';

Future<void> until(WidgetTester tester, bool Function() ready) async {
  for (var i = 0; i < 300; i++) {
    await tester.pump(const Duration(milliseconds: 20));
    if (ready()) return;
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 25)));
  }
  expect(ready(), isTrue, reason: 'Live disclosure UI did not converge');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final path = Platform.environment['RIDZS_DISCLOSURE_FIXTURE'];
  if (path == null) {
    test('requires disposable disclosure backend', () {},
        skip: 'Run backend test-adjustment-earnings.sh disclosures-native');
    return;
  }
  testWidgets(
      'live publication, booking, historical read, changes and recovery',
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
    final public = RegionalDisclosureService(
        apiRootReader: () => config['root'] as String);
    addTearDown(public.dispose);
    Future<void> current(String name) async {
      final result = (await tester.runAsync(() =>
          public.load(marketId: config['market'] as String, locale: 'en-CA')))!;
      expect(result.data.operatorName, 'Synthetic $name');
      expect(result.isFresh, isTrue);
    }

    Future<void> unavailable() async {
      await tester.runAsync(() async {
        await expectLater(
            public.load(marketId: config['market'] as String, locale: 'en-CA'),
            throwsA(isA<DisclosureUnavailable>()));
      });
    }

    await unavailable();
    final published = (await tester.runAsync(() => command('publish')))!;
    await current('original');
    await tester.runAsync(() async {
      final page = await public.markets(locale: 'en-CA');
      expect(page.isFresh, isTrue);
      await expectLater(
          public.load(marketId: config['market'] as String, locale: 'fr-CA'),
          throwsA(isA<DisclosureUnavailable>()));
    });
    final booked = (await tester.runAsync(() => command('book')))!;
    final rideId = booked['rideId'] as String;
    expect(booked['hash'], published['hash']);
    var loseRead = false;
    var reads = 0;
    dio.interceptors.add(InterceptorsWrapper(onResponse: (response, handler) {
      reads++;
      expect(response.headers.value('cache-control'), 'no-store');
      expect(response.requestOptions.uri.path,
          '/passenger/rides/$rideId/regional-disclosure');
      expect(response.data['data']['contentHash'], published['hash']);
      expect(response.data['data']['contentVersion'], published['version']);
      expect(response.data['data']['audience'], 'passenger_information');
      expect((response.data['data'] as Map).length, 18);
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
    RideDisclosureService create() => RideDisclosureService(
        ownerId: config['owner'] as String,
        rideId: rideId,
        ownerReader: () => config['owner'] as String,
        rideIsCurrent: () => true,
        dio: dio);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body:
                RideDocumentsButton(rideId: rideId, serviceFactory: create))));
    expect(reads, 0);
    await tester.runAsync(() async {
      await tester.tap(find.text('Ride documents'));
      await tester.pump();
    });
    await until(
        tester, () => find.text('Synthetic original').evaluate().isNotEmpty);
    expect(find.text('Historical passenger information'), findsOneWidget);
    Future<void> refresh() async {
      await tester
          .runAsync(() => tester.tap(find.byTooltip('Refresh ride documents')));
      await tester.pump();
    }

    Future<void> original() => until(
        tester, () => find.text('Synthetic original').evaluate().isNotEmpty);
    Future<void> language(String label) async {
      await tester.tap(find.byKey(const ValueKey('Document language')));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.runAsync(() => tester.tap(find.text(label).last));
      await tester.pump();
    }

    await language('French (Canada)');
    await until(
        tester,
        () => find
            .textContaining('unavailable for this ride in French')
            .evaluate()
            .isNotEmpty);
    expect(find.text('Synthetic original'), findsNothing);
    expect(find.byType(SelectableText), findsNothing);
    await language('English (Canada)');
    await original();
    loseRead = true;
    await refresh();
    await until(
        tester,
        () => find
            .text('Could not load ride documents. Please retry.')
            .evaluate()
            .isNotEmpty);
    expect(find.byType(SelectableText), findsNothing);
    await tester.runAsync(() => tester.tap(find.text('Retry')));
    await original();
    await tester.runAsync(() => command('replace'));
    await current('replacement');
    await refresh();
    await original();
    expect(find.text('Synthetic replacement'), findsNothing);
    await tester.runAsync(() => command('policy'));
    await unavailable();
    await refresh();
    await original();
    await tester.runAsync(() => command('withdraw'));
    await unavailable();
    await refresh();
    await original();
    await tester.runAsync(() => command('recover'));
    await current('recovered');
    await refresh();
    await original();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(find.byType(SelectableText), findsNothing);
    await tester.runAsync(() => command('complete'));
    await tester.runAsync(() async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    });
    await original();
    await tester.runAsync(() => command('deny'));
    await refresh();
    await until(
        tester,
        () => find
            .text('Ride or session changed. Close and reopen this page.')
            .evaluate()
            .isNotEmpty);
    expect(find.byType(SelectableText), findsNothing);
    expect(find.text('Retry'), findsNothing);
    await tester.runAsync(() => command('verify'));
    expect(reads, greaterThanOrEqualTo(9));
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
