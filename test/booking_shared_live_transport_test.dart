import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/core/configs/app_config.dart';
import 'package:ridzs_passenger_app/core/services/dio_service.dart';
import 'package:ridzs_passenger_app/core/services/socket_service.dart';
import 'acceptance_live_transport_test.dart' show eventually;
import 'booking_live_transport_test.dart' show BookingLivePassenger;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final manifestPath = Platform.environment['RIDZS_SHARED_FIXTURE'];
  if (manifestPath == null) {
    test('requires shared passenger/driver fixture', () {},
        skip: 'Run backend test-ride-event-transport.sh search-shared-native');
    return;
  }
  test('shared native retry and cancellation convergence', () async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = null;
    addTearDown(() => HttpOverrides.global = previous);
    final manifest = jsonDecode(File(manifestPath).readAsStringSync()) as Map;
    expect(Uri.parse(manifest['url'] as String).host, '127.0.0.1');
    final control = Dio(BaseOptions(
        baseUrl: '${manifest['url']}/passenger',
        headers: {'Authorization': 'Bearer ${manifest['key']}'},
        receiveTimeout: const Duration(seconds: 45)));
    addTearDown(() => control.close(force: true));
    Future<Map<String, dynamic>> command(String name, [Object? body]) async =>
        Map<String, dynamic>.from(
            (await control.post('/$name', data: body)).data as Map);
    Future<Map<String, dynamic>> waitFor(String phase) async {
      final deadline = DateTime.now().add(const Duration(seconds: 75));
      while (DateTime.now().isBefore(deadline)) {
        final state = await command('state');
        if (state['phase'] == phase) return state;
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      throw StateError('Driver did not reach $phase');
    }

    final fixture = await command('connect');
    final scenario = fixture['scenario'] as String;
    for (final key in ['api', 'socket']) {
      expect(Uri.parse(fixture[key] as String).host, '127.0.0.1');
    }
    FlutterSecureStorage.setMockInitialValues(
        {'access_token': fixture['token'] as String});
    AppConfig.baseUrl = fixture['api'] as String;
    AppConfig.socketUrl = fixture['socket'] as String;
    final dio = Dio(BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10)));
    addTearDown(() => dio.close(force: true));
    final requests = <RequestOptions>[];
    dio.interceptors.add(AuthInterceptor(dio));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (request, handler) {
      expect(
          request.method == 'GET' ||
              request.method == 'PUT' &&
                  request.path == '/rides/${fixture['rideId']}/status' ||
              request.method == 'POST' &&
                  request.path == '/rides/${fixture['rideId']}/search',
          true);
      requests.add(request);
      handler.next(request);
    }));
    final sockets = SocketService.withTransport();
    addTearDown(sockets.dispose);
    final store = BookingLivePassenger(dio, sockets);
    addTearDown(store.dispose);
    final hints = <dynamic>[];
    await store.initialize();
    await eventually(() =>
        store.isConnected &&
        store.recovery.ready.value &&
        !store.recovery.loading.value);
    sockets.socket.on('ride:sync', hints.add);
    store.recovery.setForeground(true);
    await command('ready');
    if (scenario.startsWith('cancel-')) {
      await waitFor('accept-held');
      await store.recovery.refresh(reconcile: true);
      expect(store.currentRide?.ride?.status?.title,
          scenario == 'cancel-after-accept' ? 'accepted' : 'searching');
      final cancel = store.cancelRide('Changed plans');
      await store.cancelRide('Changed plans');
      await cancel;
      expect(store.currentRide, isNull);
      expect(store.isCancellingRide, false);
      await command('cancelled');
      final deadline = DateTime.now().add(const Duration(seconds: 75));
      var state = await command('state');
      while (!(state['done'] as List).contains('driver') &&
          DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        state = await command('state');
      }
      expect(state['done'], contains('driver'));
      await store.recovery.refresh(reconcile: true);
      await store.retryDriverSearch();
      expect(store.currentRide, isNull);
      expect(requests.where((r) => r.method == 'PUT'), hasLength(1));
      expect(requests.where((r) => r.method == 'POST'), isEmpty);
      final response = await dio.get('/rides/${fixture['rideId']}');
      final ride = response.data['data']['ride'] as Map;
      expect(ride['payment']['status'], 'released');
      await command('done', {
        'status': ride['status'],
        'version': ride['version'],
        'activeRide': store.currentRide != null,
        'pendingOffer': false,
        'ready': store.recovery.ready.value,
      });
      return;
    }
    await waitFor('skipped');
    await store.recovery.refresh(reconcile: true);
    await eventually(() => store.noDriversFound);
    expect(store.currentRide!.ride!.sId, fixture['rideId']);
    expect(store.currentRide!.ride!.dispatch, isNot(contains('cycle')));
    final version = store.currentRide!.ride!.version;
    // Both UI invocations share the real in-flight retry guard.
    final retry = store.retryDriverSearch();
    await store.retryDriverSearch();
    await retry;
    expect(store.searchBusy.value, false);
    expect(store.noDriversFound, false);
    final posts = requests.where((r) => r.method == 'POST');
    expect(posts, hasLength(1));
    expect(posts.single.data, {'version': version});
    await command('restarted');
    await waitFor('accepted');
    await eventually(() => hints.isNotEmpty);
    await store.recovery.refresh(reconcile: true);
    await eventually(
        () => store.currentRide?.ride?.status?.title == 'accepted');
    expect(store.noDriversFound, false);
    await store.retryDriverSearch();
    expect(posts, hasLength(1));
    final ride = store.currentRide!.ride!;
    expect(ride.dispatch, isNot(contains('cycle')));
    await command('done', {
      'rideId': ride.sId,
      'driverId': ride.driverId,
      'passengerId': ride.passengerId,
      'version': ride.version,
      'status': ride.status!.title,
    });
  }, timeout: const Timeout(Duration(minutes: 3)));
}
