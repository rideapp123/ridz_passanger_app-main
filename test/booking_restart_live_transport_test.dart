import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/core/configs/app_config.dart';
import 'package:ridzs_passenger_app/core/services/dio_service.dart';
import 'package:ridzs_passenger_app/core/services/preferences_service.dart';
import 'package:ridzs_passenger_app/core/services/socket_service.dart';
import 'acceptance_live_transport_test.dart' show eventually;
import 'booking_live_transport_test.dart' show BookingLivePassenger;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final manifestPath = Platform.environment['RIDZS_RESTART_FIXTURE'];
  if (manifestPath == null) {
    test('requires disposable restart backend fixture', () {},
        skip: 'Run backend test-ride-event-transport.sh search-restart-native');
    return;
  }
  group('passenger restart over authenticated transport', () {
    late Dio control, dio;
    late BookingLivePassenger store;
    late SocketService sockets;
    late Map<String, dynamic> fixture;
    final requests = <RequestOptions>[];
    Completer<void>? held, release;
    bool loseReply = false, holdReply = false, failReads = false;
    Future<Map<String, dynamic>> command(String name) async =>
        Map<String, dynamic>.from((await control.post('/$name')).data as Map);
    Future<void> createStore() async {
      sockets = SocketService.withTransport();
      store = BookingLivePassenger(dio, sockets);
      await store.initialize();
      await eventually(() =>
          store.isConnected &&
          store.recovery.ready.value &&
          !store.recovery.loading.value);
    }

    int posts() => requests.where((r) => r.method == 'POST').length;

    setUp(() async {
      final previous = HttpOverrides.current;
      HttpOverrides.global = null;
      addTearDown(() => HttpOverrides.global = previous);
      final manifest = jsonDecode(File(manifestPath).readAsStringSync()) as Map;
      expect(Uri.parse(manifest['url'] as String).host, '127.0.0.1');
      control = Dio(BaseOptions(
          baseUrl: manifest['url'] as String,
          headers: {'Authorization': 'Bearer ${manifest['key']}'},
          receiveTimeout: const Duration(seconds: 45)));
      fixture = await command('reset');
      for (final key in ['api', 'socket']) {
        expect(Uri.parse(fixture[key] as String).host, '127.0.0.1');
      }
      FlutterSecureStorage.setMockInitialValues(
          {'access_token': fixture['token'] as String});
      AppConfig.baseUrl = fixture['api'] as String;
      AppConfig.socketUrl = fixture['socket'] as String;
      dio = Dio(BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10)));
      requests.clear();
      held = null;
      release = null;
      loseReply = false;
      holdReply = false;
      failReads = false;
      dio.interceptors.add(AuthInterceptor(dio));
      dio.interceptors.add(InterceptorsWrapper(onRequest: (request, handler) {
        expect(
            request.method == 'GET' ||
                request.method == 'POST' &&
                    request.path == '/rides/${fixture['rideId']}/search',
            true);
        requests.add(request);
        if (failReads && request.method == 'GET') {
          handler.reject(DioException(
              requestOptions: request, type: DioExceptionType.connectionError));
        } else {
          handler.next(request);
        }
      }, onResponse: (response, handler) async {
        if (response.requestOptions.method == 'POST') {
          if (holdReply) {
            holdReply = false;
            held!.complete();
            await release!.future;
          }
          if (loseReply) {
            loseReply = false;
            // Client-observed loss after the real authenticated HTTP command committed.
            handler.reject(DioException(
                requestOptions: response.requestOptions,
                type: DioExceptionType.connectionError,
                error: 'Synthetic restart reply loss'));
            return;
          }
        }
        handler.next(response);
      }));
      await createStore();
      expect(store.noDriversFound, true);
    });
    tearDown(() {
      if (release != null && !release!.isCompleted) release!.complete();
      store.dispose();
      sockets.dispose();
      dio.close(force: true);
      control.close(force: true);
    });
    Future<void> verify() async {
      expect(posts(), 1);
      expect(store.searchBusy.value, false);
      await command('assert');
    }

    test(
        'explicit restart progresses through worker activation and real driver acceptance',
        () async {
      await command('deliver-old');
      await store.retryDriverSearch();
      expect(store.noDriversFound, false);
      final active = await command('activate');
      await command('deliver');
      await store.recovery.refresh(reconcile: true);
      expect(store.currentRide?.ride?.version, active['rideVersion']);
      await command('accept');
      await command('replay-old');
      await store.recovery.refresh(reconcile: true);
      expect(store.currentRide?.ride?.status?.title, 'accepted');
      await verify();
    });
    test('lost successful reply recovers by GET without repeating POST',
        () async {
      loseReply = true;
      await store.retryDriverSearch();
      await eventually(
          () => !store.noDriversFound && store.recovery.ready.value);
      await store.retryDriverSearch();
      await verify();
    });
    test('held restart reply cannot undo a newer authenticated acceptance',
        () async {
      held = Completer<void>();
      release = Completer<void>();
      holdReply = true;
      final flight = store.retryDriverSearch();
      await held!.future.timeout(const Duration(seconds: 10));
      await store.retryDriverSearch(); // Busy guard: never a second command.
      await command('activate');
      await command('accept');
      await store.recovery.refresh(reconcile: true);
      expect(store.currentRide?.ride?.status?.title, 'accepted');
      release!.complete();
      await flight;
      expect(store.currentRide?.ride?.status?.title, 'accepted');
      await verify();
    });
    test('account replacement fences a held restart response', () async {
      held = Completer<void>();
      release = Completer<void>();
      holdReply = true;
      final old = store;
      final flight = old.retryDriverSearch();
      await held!.future.timeout(const Duration(seconds: 10));
      old.dispose();
      sockets.dispose();
      await PreferencesService.setAccessToken(
          fixture['foreignToken'] as String);
      await createStore();
      release!.complete();
      await flight;
      expect(old.currentRide, isNull);
      expect(store.currentRide, isNull);
      await expectLater(
          dio.get('/rides/${fixture['rideId']}'),
          throwsA(isA<DioException>()
              .having((e) => e.response?.statusCode, 'status', 404)));
      await verify();
    });
    test(
        'unknown outcome survives store recreation with no automatic command replay',
        () async {
      loseReply = true;
      failReads = true;
      await store.retryDriverSearch();
      expect(store.recovery.ready.value, false);
      expect(posts(), 1);
      store.dispose();
      sockets.dispose();
      failReads = false;
      await createStore();
      expect(store.noDriversFound, false);
      await store.retryDriverSearch();
      await verify();
    });
  });
}
