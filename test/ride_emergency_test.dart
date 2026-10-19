import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/services/ride_emergency_service.dart';
import 'package:ridzs_passenger_app/core/services/dio_service.dart';
import 'package:ridzs_passenger_app/core/theme/ridzs_theme.dart';
import 'package:ridzs_passenger_app/core/theme/light_theme.dart';
import 'package:ridzs_passenger_app/view/safety/ride_safety_screen.dart';
import 'package:ridzs_passenger_app/stores/map/map_store.dart';

class SafetyAdapter implements HttpClientAdapter {
  SafetyAdapter(this.respond);
  final Future<ResponseBody> Function(RequestOptions) respond;
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream,
          Future<void>? cancelFuture) =>
      respond(options);
  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Dio dio;
  late RideEmergencyService service;
  late String? token;
  late List<RequestOptions> requests;
  late Future<ResponseBody> Function(RequestOptions) respond;
  Map<String, dynamic> saved(
          {String status = 'open', int version = 0, bool safe = false}) =>
      {
        'id': 'a' * 64,
        'rideId': 'r1',
        'by': 'passenger',
        'reason': 'Private report',
        'status': status,
        'version': version,
        'reporterSafe': safe,
        'createdAt': '2026-09-13T12:00:00Z',
        'updatedAt': '2026-09-13T12:00:00Z',
      };
  ResponseBody reply(Map<String, dynamic> data, {int status = 200}) =>
      ResponseBody.fromString(
          jsonEncode({'success': status == 200, 'data': data}), status,
          headers: {
            'content-type': ['application/json']
          });
  ResponseBody conflict(String code) =>
      ResponseBody.fromString(jsonEncode({'success': false, 'code': code}), 409,
          headers: {
            'content-type': ['application/json']
          });

  setUp(() {
    token = 'account-one';
    requests = [];
    dio = Dio(BaseOptions(baseUrl: 'https://example.test/passenger'));
    dio.interceptors.add(AuthInterceptor(dio, tokenReader: () async => token));
    respond = (request) async => request.method == 'GET'
        ? reply({'rideId': 'r1', 'hasIncident': false})
        : reply(saved());
    dio.httpClientAdapter = SafetyAdapter((request) async {
      requests.add(request);
      return respond(request);
    });
    service = RideEmergencyService(
        role: 'passenger', dio: dio, tokenReader: () async => token);
  });
  tearDown(() {
    service.endSession();
    dio.close(force: true);
  });

  test('explicit absence is distinct from a failed lookup', () async {
    expect(await service.load('r1'), true);
    expect(service.record.value, isNull);
    respond = (_) async => reply({}, status: 503);
    expect(await service.load('r1'), false);
    expect(service.ready.value, false);
    expect(service.error.value, isNotNull);
    expect(await service.report('r1', 'Private report'), false);
    expect(requests, hasLength(2));
  });

  test('confirmed report uses role HTTP without location or sockets', () async {
    await service.load('r1');
    expect(await service.report('r1', ' Private report '), true);
    expect(requests.last.path, '/chat/r1/emergency');
    expect(requests.last.data, {'reason': 'Private report'});
    expect(service.record.value!.status, 'open');
    expect(service.notice.value, contains('have not been contacted'));
  });

  test('restart recovers a saved report without another POST', () async {
    respond = (_) async =>
        reply({'rideId': 'r1', 'hasIncident': true, 'incident': saved()});
    expect(await service.load('r1'), true);
    expect(service.record.value!.reason, 'Private report');
    expect(requests.single.method, 'GET');
  });

  test('lost report response stays unconfirmed and identical retry recovers',
      () async {
    await service.load('r1');
    respond = (r) async => throw DioException(
        requestOptions: r, type: DioExceptionType.receiveTimeout);
    expect(await service.report('r1', 'Private report'), false);
    expect(service.record.value, isNull);
    expect(service.notice.value, isNull);
    respond = (_) async => reply(saved());
    expect(await service.report('r1', 'Private report'), true);
    expect(requests[1].data, requests[2].data);
  });

  test('production interceptor preserves conflict code and requires refresh',
      () async {
    await service.load('r1');
    respond = (_) async => conflict('EMERGENCY_ALREADY_SAVED');
    expect(await service.report('r1', 'Changed report'), false);
    expect(service.ready.value, false);
    expect(service.error.value, contains('Report changed'));
    respond = (_) async =>
        reply({'rideId': 'r1', 'hasIncident': true, 'incident': saved()});
    expect(await service.load('r1'), true);
    expect(service.record.value!.reason, 'Private report');
  });

  test('safe sends version and cannot resolve the operator report', () async {
    respond = (_) async =>
        reply({'rideId': 'r1', 'hasIncident': true, 'incident': saved()});
    await service.load('r1');
    respond = (_) async => reply(saved(version: 1, safe: true));
    expect(await service.change('r1', 'safe'), true);
    expect(requests.last.path, '/chat/r1/emergency/safe');
    expect(requests.last.data, {'version': 0});
    expect(service.record.value!.status, 'open');
    expect(await service.change('r1', 'resolve'), false);
    expect(requests, hasLength(2));
  });

  test('closed report can request further review', () async {
    respond = (_) async => reply({
          'rideId': 'r1',
          'hasIncident': true,
          'incident': saved(status: 'resolved', version: 2)
        });
    await service.load('r1');
    respond = (_) async => reply(saved(version: 3));
    expect(await service.change('r1', 'reopen'), true);
    expect(requests.last.data, {'version': 2});
    expect(service.record.value!.status, 'open');
  });

  for (final field in [
    'id',
    'rideId',
    'by',
    'status',
    'version',
    'reporterSafe',
    'updatedAt'
  ]) {
    test('rejects malformed confirmation $field', () async {
      await service.load('r1');
      final malformed = saved();
      malformed[field] = field == 'version' ? -1 : 'invalid';
      respond = (_) async => reply(malformed);
      expect(await service.report('r1', 'Private report'), false);
      expect(service.record.value, isNull);
      expect(service.notice.value, isNull);
    });
  }

  test('stale action confirmation is rejected', () async {
    respond = (_) async =>
        reply({'rideId': 'r1', 'hasIncident': true, 'incident': saved()});
    await service.load('r1');
    respond = (_) async => reply(saved());
    expect(await service.change('r1', 'safe'), false);
    expect(service.record.value!.reporterSafe, false);
  });

  test('duplicate tap cannot submit twice', () async {
    await service.load('r1');
    final started = Completer<void>(), release = Completer<ResponseBody>();
    respond = (_) {
      started.complete();
      return release.future;
    };
    final first = service.report('r1', 'Private report');
    await started.future;
    expect(await service.report('r1', 'Private report'), false);
    release.complete(reply(saved()));
    expect(await first, true);
    expect(requests.where((r) => r.method == 'POST'), hasLength(1));
  });

  test('account switch before write closes session without sending', () async {
    await service.load('r1');
    token = 'account-two';
    expect(await service.report('r1', 'Private report'), false);
    expect(service.ended.value, true);
    expect(requests, hasLength(1));
  });

  test('logout discards an in-flight confirmation', () async {
    await service.load('r1');
    final started = Completer<void>(), release = Completer<ResponseBody>();
    respond = (_) {
      started.complete();
      return release.future;
    };
    final request = service.report('r1', 'Private report');
    await started.future;
    service.endSession();
    release.complete(reply(saved()));
    expect(await request, false);
    expect(service.record.value, isNull);
    expect(service.notice.value, isNull);
  });

  test('store logout closes open safety screens without reusing their sessions',
      () async {
    final store =
        MapStore(recoveryDio: dio, sessionTokenReader: () async => token);
    final session = store.createSafetySession();
    expect(await session.load('r1'), true);
    store.dispose();
    expect(session.ended.value, true);
    final next = store.createSafetySession();
    expect(next.ended.value, false);
    next.endSession();
  });

  testWidgets('failed form retains input then shows confirmed saved status',
      (tester) async {
    await tester.pumpWidget(
        MaterialApp(home: RideSafetyScreen(rideId: 'r1', service: service)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Private report');
    respond = (_) async => reply({}, status: 503);
    await tester.scrollUntilVisible(find.text('Submit safety report'), 150,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Submit safety report'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Update not confirmed.'), findsOneWidget);
    expect(find.text('Private report'), findsOneWidget);
    respond = (_) async => reply(saved());
    await tester.scrollUntilVisible(find.text('Submit safety report'), 150,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Submit safety report'));
    await tester.pumpAndSettle();
    expect(find.text('Saved - awaiting operator review'), findsOneWidget);
    expect(find.text('Emergency alert sent'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('large text and keyboard fit compact and desktop screens',
      (tester) async {
    final font = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetViewInsets();
      tester.view.resetPadding();
    });
    for (final width in [320.0, 1000.0]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 800);
      final scoped = RideEmergencyService(
          role: 'passenger', dio: dio, tokenReader: () async => token);
      await tester.pumpWidget(MaterialApp(
          theme: RidzsTheme.refine(
              ThemeData(colorScheme: flexSchemeLight, fontFamily: 'Poppins')),
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: child!),
          home: RepaintBoundary(
              key: const ValueKey('safety-golden'),
              child: RideSafetyScreen(
                  key: ValueKey(width), rideId: 'r1', service: scoped))));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      if (width == 320) {
        await expectLater(find.byKey(const ValueKey('safety-golden')),
            matchesGoldenFile('goldens/safety_large_text.png'));
      }
      await tester.scrollUntilVisible(find.byType(TextField), 150,
          scrollable: find.byType(Scrollable).first);
      await tester.enterText(find.byType(TextField), 'Private report');
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      tester.view.padding = const FakeViewPadding(top: 24);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Submit safety report'), 150,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      tester.view.resetViewInsets();
      tester.view.resetPadding();
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
