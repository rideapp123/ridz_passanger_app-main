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
import 'package:ridzs_passenger_app/stores/map/map_store.dart';
import 'package:ridzs_passenger_app/services/ride_service.dart';
import 'acceptance_live_transport_test.dart' show eventually;

// Platform map/GPS resources are substituted; store socket wiring and HTTP are not.
class BookingLivePassenger extends MapStore {
  BookingLivePassenger(Dio dio, SocketService sockets)
      : super(
            rideService: RideService.withClient(dio),
            recoveryDio: dio,
            socketService: sockets,
            sessionTokenReader: PreferencesService.getAccessToken,
            rideNotice: (_) {});
  @override
  Future<void> initializeMap() async {}
  @override
  Future<void> resumeRideResources() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final manifestPath = Platform.environment['RIDZS_BOOKING_FIXTURE'];
  if (manifestPath == null) {
    test('requires disposable booking backend fixture', () {},
        skip: 'Run backend test-ride-event-transport.sh booking-native');
    return;
  }
  group('native passenger booking over live transport', () {
    late Dio control, dio;
    late BookingLivePassenger store;
    late SocketService sockets;
    late Map<String, dynamic> fixture;
    final paths = <String>[], hints = <dynamic>[];
    Completer<void>? held, release;
    bool holdCurrent = false;
    Future<Map<String, dynamic>> command(String name) async =>
        Map<String, dynamic>.from((await control.post('/$name')).data as Map);
    String? status() => store.currentRide?.ride?.status?.title;
    Future<void> createStore() async {
      sockets = SocketService.withTransport();
      store = BookingLivePassenger(dio, sockets);
      await store.initialize();
      await eventually(() =>
          store.isConnected &&
          store.recovery.ready.value &&
          !store.recovery.loading.value);
      sockets.socket.on('ride:booking-sync', hints.add);
    }

    setUp(() async {
      final previous = HttpOverrides.current;
      HttpOverrides.global = null;
      addTearDown(() => HttpOverrides.global = previous);
      final manifest = jsonDecode(File(manifestPath).readAsStringSync()) as Map;
      final url = Uri.parse(manifest['url'] as String);
      expect(url.host, '127.0.0.1');
      expect(url.scheme, 'http');
      control = Dio(BaseOptions(
          baseUrl: url.toString(),
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
      paths.clear();
      hints.clear();
      held = null;
      release = null;
      holdCurrent = false;
      dio.interceptors.add(AuthInterceptor(dio));
      dio.interceptors.add(InterceptorsWrapper(onRequest: (request, handler) {
        expect(request.method, 'GET',
            reason: 'Hints cannot repeat booking commands');
        paths.add(request.path);
        handler.next(request);
      }, onResponse: (response, handler) async {
        if (holdCurrent && response.requestOptions.path == '/rides/current') {
          holdCurrent = false;
          held!.complete();
          await release!.future;
        }
        handler.next(response);
      }));
      await createStore();
      expect(status(), 'searching');
    });
    tearDown(() {
      if (release != null && !release!.isCompleted) release!.complete();
      store.dispose();
      sockets.dispose();
      dio.close(force: true);
      control.close(force: true);
    });
    test(
        'cross-instance booking hints restore searching and bound duplicate bursts',
        () async {
      store.recovery.setForeground(true);
      final activated = await command('activate');
      await command('deliver');
      await eventually(() =>
          store.currentRide?.ride?.version == activated['rideVersion'] &&
          hints.isNotEmpty &&
          store.recovery.ready.value);
      expect((hints.single as Map).keys.toSet(), {
        'notificationId',
        'rideId',
        'event',
        'version',
        'type',
        'expiresAt'
      });
      expect(hints.single['type'], 'RIDE_STATUS_UPDATED');
      expect(store.noDriversFound, false);
      final reads = paths.length;
      for (var i = 0; i < 5; i++) {
        await command('duplicate');
      }
      await eventually(() => hints.length == 6);
      await Future<void>.delayed(const Duration(milliseconds: 2100));
      await command('duplicate');
      await eventually(() => hints.length == 7);
      expect(paths.length, reads);
      expect(status(), 'searching');
    });
    test('exhausted dispatch is displayed only from authenticated ride state',
        () async {
      store.recovery.setForeground(true);
      await command('exhaust');
      expect(store.noDriversFound, false);
      await command('deliver');
      await eventually(() => store.noDriversFound);
      expect(hints.single['type'], 'RIDE_NO_DRIVER_FOUND');
      expect(status(), 'searching');
      expect(store.bookingConfirmationPending, false);
    });
    test('lost pubsub hint converges through foreground polling', () async {
      await command('pause-relay');
      store.recovery.setForeground(true);
      final activated = await command('activate');
      await command('deliver');
      await eventually(
          () => store.currentRide?.ride?.version == activated['rideVersion'],
          timeout: const Duration(seconds: 20));
      expect(hints, isEmpty);
      await command('resume-relay');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(hints, isEmpty);
    }, timeout: const Timeout(Duration(seconds: 60)));
    test('reconnect recovers without replaying a missed booking hint',
        () async {
      sockets.socket.disconnect();
      await eventually(() => !store.isConnected);
      final activated = await command('activate');
      await command('deliver');
      sockets.reconnect();
      await eventually(() =>
          store.isConnected &&
          store.currentRide?.ride?.version == activated['rideVersion'] &&
          store.recovery.ready.value);
      expect(hints, isEmpty);
    });
    test('hint invalidates a delayed real pre-activation HTTP snapshot',
        () async {
      store.recovery.setForeground(true);
      held = Completer<void>();
      release = Completer<void>();
      holdCurrent = true;
      final flight = store.recovery.refresh(reconcile: true);
      await held!.future.timeout(const Duration(seconds: 10));
      final activated = await command('activate');
      await command('deliver');
      await eventually(() => hints.isNotEmpty);
      release!.complete();
      await flight;
      expect(status(), 'searching');
      expect(store.currentRide?.ride?.version, activated['rideVersion']);
      expect(store.recovery.ready.value, true);
    });
    test('account replacement fences held response and original passenger room',
        () async {
      store.recovery.setForeground(true);
      held = Completer<void>();
      release = Completer<void>();
      holdCurrent = true;
      final old = store;
      final flight = old.recovery.refresh(reconcile: true);
      await held!.future.timeout(const Duration(seconds: 10));
      old.dispose();
      await PreferencesService.setAccessToken(
          fixture['foreignToken'] as String);
      await createStore();
      store.recovery.setForeground(true);
      release!.complete();
      await flight;
      await command('activate');
      await command('deliver');
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(hints, isEmpty);
      expect(store.currentRide, isNull);
      expect(old.currentRide, isNull);
      await expectLater(
          dio.get('/rides/${fixture['rideId']}'), throwsA(isA<DioException>()));
    });
    test(
        'command becoming busy during real HTTP preserves state until idle recovery',
        () async {
      store.recovery.setForeground(true);
      final before = store.currentRide?.ride?.version;
      final activated = await command('activate');
      held = Completer<void>();
      release = Completer<void>();
      holdCurrent = true;
      await command('deliver');
      await held!.future.timeout(const Duration(seconds: 10));
      store.isCancellingRide = true;
      release!.complete();
      await eventually(
          () => !store.recovery.loading.value && !store.recovery.reconciling);
      expect(store.currentRide?.ride?.version, before);
      store.isCancellingRide = false;
      await store.recovery.refresh(reconcile: true);
      expect(status(), 'searching');
      expect(store.currentRide?.ride?.version, activated['rideVersion']);
    });
    test(
        'delayed booking frame reads started state and missed terminal resolves by ID',
        () async {
      store.recovery.setForeground(true);
      await command('pause-relay');
      await command('activate');
      await command('deliver');
      await command('fresh-presence');
      await command('accept');
      await command('assert-accepted');
      await command('arrived');
      await command('started');
      await command('resume-relay');
      await command('replay-wire');
      await eventually(() => status() == 'started');
      expect(hints.single['type'], 'RIDE_STATUS_UPDATED');
      await command('cancelled');
      await store.recovery.refresh(reconcile: true);
      expect(paths, contains('/rides/${fixture['rideId']}'));
      expect(store.currentRide, isNull);
      expect(store.recovery.ready.value, true);
    });
  });
}
