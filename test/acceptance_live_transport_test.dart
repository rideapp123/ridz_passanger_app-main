import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart' show runInAction;
import 'package:ridzs_passenger_app/core/configs/app_config.dart';
import 'package:ridzs_passenger_app/core/services/dio_service.dart';
import 'package:ridzs_passenger_app/core/services/preferences_service.dart';
import 'package:ridzs_passenger_app/core/services/socket_service.dart';

import 'package:ridzs_passenger_app/stores/map/map_store.dart';

// Maps/GPS/chat resource startup is outside this host-native transport checkpoint.
class LiveStore extends MapStore {
  LiveStore(Dio dio, SocketService sockets)
      : super(
            recoveryDio: dio,
            sessionTokenReader: PreferencesService.getAccessToken,
            rideNotice: (_) {});
  int resumes = 0;
  @override
  Future<void> resumeRideResources() async {
    resumes++;
  }
}

Future<void> eventually(bool Function() condition,
    {Duration timeout = const Duration(seconds: 10)}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition() && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 25));
  }
  expect(condition(), isTrue, reason: 'Live transport did not converge');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final manifestPath = Platform.environment['RIDZS_ACCEPTANCE_FIXTURE'];
  if (manifestPath == null) {
    test('requires disposable backend fixture', () {},
        skip: 'Run backend test-ride-event-transport.sh acceptance-native');
    return;
  }

  group('native store over live acceptance transport', () {
    late Dio control;
    late Dio dio;
    late LiveStore store;
    late SocketService sockets;
    late Map<String, dynamic> fixture;
    final paths = <String>[];
    final responses = <Map<String, dynamic>>[];
    final hints = <dynamic>[];
    Completer<void>? held;
    Completer<void>? release;
    var holdNext = false;
    var connections = 0;

    Future<Map<String, dynamic>> command(String name) async =>
        Map<String, dynamic>.from((await control.post('/$name')).data as Map);

    String? status() => store.currentRide?.ride?.status?.title;

    Future<void> connect() async {
      final connected = Completer<void>();
      await sockets.initialize(
        onConnected: () {
          connections++;
          if (!connected.isCompleted) connected.complete();
        },
        onRideSync: (hint) {
          hints.add(hint);
          store.recovery.handleSyncHint(hint);
        },
        onMessageReceived: (_) {},
      );
      await connected.future.timeout(const Duration(seconds: 10));
    }

    void createStore() {
      sockets = SocketService();
      store = LiveStore(dio, sockets);
      store.recovery.activate();
      store.recovery.setForeground(true);
    }

    setUp(() async {
      // Flutter's widget HTTP override returns 400; this explicit suite uses real IO.
      final oldOverride = HttpOverrides.current;
      HttpOverrides.global = null;
      addTearDown(() => HttpOverrides.global = oldOverride);
      final manifest = jsonDecode(File(manifestPath).readAsStringSync()) as Map;
      final url = Uri.parse(manifest['url'] as String);
      expect(url.host, '127.0.0.1');
      expect(url.scheme, 'http');
      control = Dio(BaseOptions(
        baseUrl: url.toString(),
        headers: {'Authorization': 'Bearer ${manifest['key']}'},
        receiveTimeout: const Duration(seconds: 45),
      ));
      fixture = await command('reset');
      for (final key in ['api', 'socket']) {
        expect(Uri.parse(fixture[key] as String).host, '127.0.0.1');
      }
      FlutterSecureStorage.setMockInitialValues(
          {'access_token': fixture['token'] as String});
      AppConfig.baseUrl = fixture['api'] as String;
      AppConfig.socketUrl = fixture['socket'] as String;
      dio = Dio(BaseOptions(
        baseUrl: fixture['api'] as String,
        receiveTimeout: const Duration(seconds: 10),
        connectTimeout: const Duration(seconds: 10),
      ));
      paths.clear();
      responses.clear();
      hints.clear();
      connections = 0;
      holdNext = false;
      held = null;
      release = null;
      // Real auth interceptor and IO adapter; only a selected response is delayed.
      dio.interceptors.add(AuthInterceptor(dio));
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.method, 'GET',
              reason: 'Recovery must not repeat writes');
          paths.add(options.path);
          handler.next(options);
        },
        onResponse: (response, handler) async {
          responses.add(Map<String, dynamic>.from(response.data as Map));
          if (holdNext && response.requestOptions.path == '/rides/current') {
            holdNext = false;
            held!.complete();
            await release!.future;
          }
          handler.next(response);
        },
      ));
      createStore();
      await store.recovery.refresh();
      expect(store.recovery.ready.value, isTrue);
      await connect();
    });

    tearDown(() async {
      if (release != null && !release!.isCompleted) release!.complete();
      store.dispose();
      sockets.dispose();
      dio.close(force: true);
      control.close(force: true);
    });

    Future<void> accepted() async {
      await command('accept');
      await command('deliver');
      await eventually(
          () => status() == 'accepted' && store.recovery.ready.value);
      expect(hints, isNotEmpty);
      expect((hints.first as Map).keys.toSet(), {'type', 'notificationId'});
      expect(hints.first['type'], 'RIDE_ACCEPTANCE_SYNC');
      expect(hints.first['notificationId'], matches(RegExp(r'^[a-f0-9]{64}$')));
      expect(store.currentRide!.ride!.sId, fixture['rideId']);
      expect(store.currentRide!.contactUri, isNotNull);
    }

    test(
        'real hints converge, duplicate bursts preserve resources, stale hints read started',
        () async {
      await accepted();
      final version = store.currentRide!.ride!.version!;
      final resumes = store.resumes;
      final reads = paths.length;
      for (var i = 0; i < 5; i++) {
        await command('duplicate');
      }
      await eventually(() => hints.length == 6);
      expect(paths.length, reads);
      expect(store.resumes, resumes);
      await Future<void>.delayed(const Duration(milliseconds: 2100));
      await command('duplicate');
      await eventually(
          () => paths.length > reads && store.recovery.ready.value);
      expect(store.resumes, resumes);
      await command('arrived');
      await command('started');
      await Future<void>.delayed(const Duration(milliseconds: 2100));
      await command('duplicate');
      await eventually(() => status() == 'started');
      expect(store.currentRide!.ride!.version, greaterThan(version));
      expect(connections, 1);
    });

    test(
        'subscriber outage recovers by foreground polling; pause and resume work',
        () async {
      await command('pause-relay');
      await command('accept');
      await command('deliver');
      await eventually(() => status() == 'accepted',
          timeout: const Duration(seconds: 20));
      expect(hints, isEmpty);
      expect(connections, 1);
      store.recovery.setForeground(false);
      final reads = paths.length;
      await command('arrived');
      await Future<void>.delayed(const Duration(seconds: 16));
      expect(paths.length, reads);
      expect(status(), 'accepted');
      store.recovery.setForeground(true);
      await eventually(() => status() == 'arrived',
          timeout: const Duration(seconds: 20));
      expect(hints, isEmpty);
      expect(connections, 1);
    }, timeout: const Timeout(Duration(seconds: 90)));

    test('hint invalidates a delayed real HTTP snapshot before restoring',
        () async {
      held = Completer<void>();
      release = Completer<void>();
      holdNext = true;
      final resumes = store.resumes;
      final flight = store.recovery.refresh(reconcile: true);
      await held!.future.timeout(const Duration(seconds: 10));
      await command('accept');
      await command('deliver');
      await eventually(() => hints.isNotEmpty);
      release!.complete();
      await flight;
      expect(status(), 'accepted');
      expect(store.resumes, resumes + 1);
      expect(store.recovery.ready.value, isTrue);
      expect(paths.where((p) => p == '/rides/current').length,
          greaterThanOrEqualTo(3));
    });

    test('session replacement rejects old response and isolates socket rooms',
        () async {
      await accepted();
      held = Completer<void>();
      release = Completer<void>();
      holdNext = true;
      final oldStore = store;
      final flight = oldStore.recovery.refresh(reconcile: true);
      await held!.future.timeout(const Duration(seconds: 10));
      oldStore.dispose();
      sockets.dispose();
      await PreferencesService.setAccessToken(
          fixture['foreignToken'] as String);
      createStore();
      await store.recovery.refresh();
      await connect();
      expect(store.currentRide, isNull);
      final count = hints.length;
      release!.complete();
      await flight;
      await command('duplicate');
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(oldStore.currentRide, isNull);
      expect(oldStore.recovery.active, isFalse);
      expect(store.currentRide, isNull);
      expect(store.recovery.ready.value, isTrue);
      expect(hints.length, count);
    });

    test('late reconnection reads assignment without replaying a hint',
        () async {
      sockets.dispose();
      await command('accept');
      await command('deliver');
      await connect();
      await store.recovery.refresh();
      expect(status(), 'accepted');
      expect(hints, isEmpty);
      expect(store.recovery.ready.value, isTrue);
    });

    for (final terminal in ['completed', 'cancelled']) {
      test('missed $terminal fixture recovers by ID and removes contact',
          () async {
        await accepted();
        if (terminal == 'completed') {
          await command('arrived');
          await command('started');
        }
        await command(terminal);
        await command('duplicate');
        final count = hints.length;
        await store.recovery.refresh(reconcile: true);
        expect(paths, contains('/rides/${fixture['rideId']}'));
        expect(store.recovery.ready.value, isTrue);
        final last = responses.last['data']['ride'] as Map;
        expect(last['status'], terminal);
        expect(last['participant']['contact']['canCall'], isFalse);
        if (terminal == 'cancelled') {
          expect(store.currentRide, isNull);
        } else {
          expect(status(), terminal);
          expect(store.currentRide!.contactUri, isNull);
        }
        await Future<void>.delayed(const Duration(milliseconds: 300));
        expect(hints.length, count);
      });
    }

    test('busy command defers a real hint until foreground reconciliation',
        () async {
      runInAction(() => store.booking.busy.value = true);
      final reads = paths.length;
      await command('accept');
      await command('deliver');
      await eventually(() => hints.isNotEmpty);
      expect(paths.length, reads);
      expect(status(), isNot('accepted'));
      runInAction(() => store.booking.busy.value = false);
      await eventually(() => status() == 'accepted',
          timeout: const Duration(seconds: 20));
      expect(store.recovery.ready.value, isTrue);
    }, timeout: const Timeout(Duration(seconds: 60)));
  });
}
