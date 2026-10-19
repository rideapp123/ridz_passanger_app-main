import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/core/configs/app_config.dart';
import 'package:ridzs_passenger_app/core/services/ride_booking_hint.dart';
import 'package:ridzs_passenger_app/core/services/ride_recovery.dart';
import 'package:ridzs_passenger_app/core/services/socket_service.dart';
import 'package:ridzs_passenger_app/stores/map/map_store.dart';
import 'fixtures/hint_socket.dart';
import 'ride_recovery_test.dart' show pumpRecovery;

Map<String, dynamic> bookingHint({bool exhausted = false}) => {
      'notificationId': '11111111-1111-1111-1111-111111111111',
      'rideId': 'ride-1',
      'version': '4',
      'type': exhausted ? 'RIDE_NO_DRIVER_FOUND' : 'RIDE_STATUS_UPDATED',
      'event': exhausted ? 'ride:noDriverFound' : 'ride:status',
      'expiresAt': '2026-10-11T00:00:00Z',
    };
Map<String, dynamic> snapshot(String id, String status) => {
      'ride': {
        'id': id,
        'status': status,
        'version': 5,
        'payment': {'status': 'authorized'},
        'dispatch': {'state': 'exhausted'}
      }
    };

class HintPassengerStore extends MapStore {
  HintPassengerStore(Dio dio, SocketService socket)
      : super(
            recoveryDio: dio,
            socketService: socket,
            sessionTokenReader: () async => 'account-a',
            rideNotice: (_) {});
  @override
  Future<void> initializeMap() async {}
  @override
  Future<void> resumeRideResources() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Dio dio;
  late RideRecovery recovery;
  late SocketService service;
  late List<HintSocket> sockets;
  late List<RequestOptions> requests;
  late List<Map<String, dynamic>?> restored;
  late Future<Map<String, dynamic>> Function(RequestOptions) respond;
  late Future<String?> Function() socketToken;
  late Future<String?> Function() recoveryToken;
  late String? token;
  String? currentId;
  bool allowed = true;
  void setup() {
    AppConfig.socketUrl = 'https://example.test';
    AppConfig.baseUrl = 'https://example.test/passenger';
    FlutterSecureStorage.setMockInitialValues({'access_token': 'account-a'});
    token = 'account-a';
    socketToken = () async => token;
    recoveryToken = () async => token;
    currentId = null;
    allowed = true;
    sockets = [];
    requests = [];
    restored = [];
    respond = (_) async => {'hasActiveRide': false};
    dio = Dio(BaseOptions(baseUrl: 'https://example.test/passenger'));
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (request, handler) async {
      requests.add(request);
      try {
        handler.resolve(Response(
            requestOptions: request,
            statusCode: 200,
            data: {'success': true, 'data': await respond(request)}));
      } on DioException catch (error) {
        handler.reject(error);
      }
    }));
    recovery = RideRecovery(
        dio: dio,
        tokenReader: () => recoveryToken(),
        currentRideId: () => currentId,
        canReconcile: () => allowed,
        restore: (value) async {
          restored.add(value);
        },
        readHint: (_) async => null,
        writeHint: (_, __) async {},
        removeHint: (_) async {});
    service = SocketService.withTransport(
        tokenReader: () => socketToken(),
        socketFactory: (_, options) {
          expectSync(options['query']['token'], token);
          expectSync(options['query']['userType'], 'passenger');
          final socket = HintSocket();
          sockets.add(socket);
          return socket;
        });
  }

  setUp(setup);
  tearDown(() {
    recovery.dispose();
    service.dispose();
    dio.close(force: true);
  });

  Future<void> start() async {
    recovery.dispose();
    service.dispose();
    dio.close(force: true);
    setup();
    recovery.activate();
    recovery.setForeground(true);
    await service.initialize(onBookingSync: recovery.handleBookingHint);
  }

  void send([Map<String, dynamic>? hint]) =>
      sockets.last.receive('ride:booking-sync', hint ?? bookingHint());

  for (final exhausted in [false, true]) {
    test(
        'minimal ${exhausted ? 'exhaustion' : 'status'} hint is parsed but expiry is not authority',
        () {
      expect(RideBookingHint.parse(bookingHint(exhausted: exhausted))?.rideId,
          'ride-1');
    });
  }
  for (final field in [
    'notificationId',
    'rideId',
    'version',
    'expiresAt',
    'type',
    'event'
  ]) {
    test('malformed $field is rejected', () {
      for (final invalid in [null, '', 4, 'invalid/\n', 'x' * 129]) {
        expect(
            RideBookingHint.parse({...bookingHint(), field: invalid}), isNull);
      }
    });
  }
  test('wrong pairing, unsafe versions and state-bearing payloads are rejected',
      () {
    for (final bad in [
      null,
      [],
      {},
      {...bookingHint(), 'event': 'ride:noDriverFound'},
      {...bookingHint(), 'version': '0'},
      {...bookingHint(), 'version': '9007199254740992'},
      {
        ...bookingHint(),
        'ride': {'status': 'cancelled'}
      }
    ]) {
      expect(RideBookingHint.parse(bad), isNull);
    }
  });
  testWidgets(
      'registered event restores HTTP state, not hinted exhaustion, with burst deduplication',
      (tester) async {
    await start();
    respond =
        (_) async => {'hasActiveRide': true, ...snapshot('ride-1', 'started')};
    for (var i = 0; i < 100; i++) {
      send(bookingHint(exhausted: true));
    }
    expect(restored, isEmpty);
    await pumpRecovery(tester);
    expect(requests.map((r) => r.path), ['/rides/current']);
    expect(requests.single.extra['expectedAuthToken'], 'account-a');
    expect(restored.single!['ride']['status'], 'started');
    await pumpRecovery(tester, const Duration(seconds: 2));
    send();
    await pumpRecovery(tester);
    expect(requests, hasLength(1));
    recovery.dispose();
  });
  testWidgets(
      'no active ride resolves hinted booking by authenticated identity',
      (tester) async {
    await start();
    respond = (r) async => r.path == '/rides/current'
        ? {'hasActiveRide': false}
        : snapshot('ride-1', 'cancelled');
    send(bookingHint(exhausted: true));
    await pumpRecovery(tester);
    expect(requests.map((r) => r.path), ['/rides/current', '/rides/ride-1']);
    expect(
        requests.every(
            (r) => r.method == 'GET' && r.extra['expectedAuthToken'] == token),
        true);
    expect(restored.single!['ride']['status'], 'cancelled');
    recovery.dispose();
  });
  testWidgets(
      'different current ride takes precedence over delayed booking hint',
      (tester) async {
    await start();
    respond = (_) async =>
        {'hasActiveRide': true, ...snapshot('new-ride', 'accepted')};
    send();
    await pumpRecovery(tester);
    expect(requests, hasLength(1));
    expect(restored.single!['ride']['id'], 'new-ride');
    recovery.dispose();
  });
  testWidgets(
      'existing local ride identity takes precedence for terminal recovery',
      (tester) async {
    await start();
    currentId = 'existing-ride';
    respond = (r) async => r.path == '/rides/current'
        ? {'hasActiveRide': false}
        : snapshot('existing-ride', 'completed');
    send();
    await pumpRecovery(tester);
    expect(requests.last.path, '/rides/existing-ride');
    expect(restored.single!['ride']['id'], 'existing-ride');
    recovery.dispose();
  });
  testWidgets('busy booking command defers and retains terminal lookup hint',
      (tester) async {
    await start();
    allowed = false;
    respond = (r) async => r.path == '/rides/current'
        ? {'hasActiveRide': false}
        : snapshot('ride-1', 'cancelled');
    send();
    await pumpRecovery(tester);
    expect(requests, isEmpty);
    allowed = true;
    await pumpRecovery(tester, const Duration(seconds: 15));
    expect(requests.map((r) => r.path), ['/rides/current', '/rides/ride-1']);
    recovery.dispose();
  });
  testWidgets('command becoming busy during GET defers applying its snapshot',
      (tester) async {
    await start();
    final held = Completer<Map<String, dynamic>>();
    respond = (_) => held.future;
    send();
    await pumpRecovery(tester);
    expect(requests, hasLength(1));
    allowed = false;
    held.complete({'hasActiveRide': true, ...snapshot('ride-1', 'searching')});
    await pumpRecovery(tester);
    expect(restored, isEmpty);
    allowed = true;
    respond = (r) async => r.path == '/rides/current'
        ? {'hasActiveRide': false}
        : snapshot('ride-1', 'cancelled');
    await pumpRecovery(tester, const Duration(seconds: 15));
    expect(requests.last.path, '/rides/ride-1');
    expect(restored.single!['ride']['status'], 'cancelled');
    recovery.dispose();
  });
  testWidgets('logout during hinted HTTP recovery prevents a late restore',
      (tester) async {
    await start();
    final held = Completer<Map<String, dynamic>>();
    respond = (_) => held.future;
    send();
    await pumpRecovery(tester);
    recovery.dispose();
    held.complete({'hasActiveRide': true, ...snapshot('ride-1', 'searching')});
    await pumpRecovery(tester);
    expect(restored, isEmpty);
    token = 'account-b';
    recovery.activate();
    recovery.setForeground(true);
    await service.initialize(onBookingSync: recovery.handleBookingHint);
    respond = (_) async => {'hasActiveRide': false};
    unawaited(recovery.refresh());
    await pumpRecovery(tester);
    expect(requests.map((r) => r.path), ['/rides/current', '/rides/current']);
    expect(restored, [null]);
    recovery.dispose();
  });
  testWidgets('hint invalidates an older in-flight current-ride snapshot',
      (tester) async {
    await start();
    final held = Completer<Map<String, dynamic>>();
    respond = (_) => requests.length == 1
        ? held.future
        : Future.value(
            {'hasActiveRide': true, ...snapshot('ride-1', 'started')});
    unawaited(recovery.refresh());
    await pumpRecovery(tester);
    send();
    await pumpRecovery(tester);
    held.complete({'hasActiveRide': true, ...snapshot('ride-1', 'accepted')});
    await pumpRecovery(tester);
    expect(requests, hasLength(2));
    expect(restored.single!['ride']['status'], 'started');
    recovery.dispose();
  });
  testWidgets(
      'background hints do not issue reads; foreground polling restores',
      (tester) async {
    await start();
    recovery.setForeground(false);
    send();
    await pumpRecovery(tester);
    expect(requests, isEmpty);
    recovery.setForeground(true);
    await pumpRecovery(tester, const Duration(seconds: 15));
    expect(requests.map((r) => r.path), ['/rides/current']);
    recovery.dispose();
  });
  testWidgets('failed GET preserves uncertainty until polling succeeds',
      (tester) async {
    await start();
    respond = (request) async => throw DioException(
        requestOptions: request, type: DioExceptionType.connectionError);
    send();
    await pumpRecovery(tester);
    expect(restored, isEmpty);
    expect(recovery.ready.value, false);
    respond = (_) async =>
        {'hasActiveRide': true, ...snapshot('ride-1', 'searching')};
    await pumpRecovery(tester, const Duration(seconds: 15));
    expect(restored.single!['ride']['status'], 'searching');
    recovery.dispose();
  });
  testWidgets('wrong by-ID response is never restored', (tester) async {
    await start();
    respond = (r) async => r.path == '/rides/current'
        ? {'hasActiveRide': false}
        : snapshot('foreign', 'cancelled');
    send();
    await pumpRecovery(tester);
    expect(restored, isEmpty);
    expect(recovery.ready.value, false);
    recovery.dispose();
  });
  testWidgets(
      'credential switch after socket validation cannot start a new-account read',
      (tester) async {
    await start();
    final held = Completer<String?>();
    recoveryToken = () => held.future;
    send();
    await pumpRecovery(tester);
    token = 'account-b';
    held.complete(token);
    await pumpRecovery(tester);
    expect(requests, isEmpty);
    expect(restored, isEmpty);
    recovery.dispose();
  });
  for (final replace in [false, true]) {
    test(
        'held credential read is fenced after ${replace ? 'replacement' : 'logout'}',
        () async {
      var callbacks = 0;
      await service.initialize(onBookingSync: (_, __) => callbacks++);
      final old = sockets.single.callbacks['ride:booking-sync']!;
      final held = Completer<String?>();
      socketToken = () => held.future;
      old(bookingHint());
      socketToken = () async => token;
      if (replace) {
        await service.initialize(onBookingSync: (_, __) => callbacks++);
      } else {
        service.dispose();
      }
      held.complete(token);
      await Future<void>.delayed(Duration.zero);
      old(bookingHint());
      await Future<void>.delayed(Duration.zero);
      expect(callbacks, 0);
      if (replace) {
        send();
        await Future<void>.delayed(Duration.zero);
        expect(callbacks, 1);
      }
    });
  }
  test('old socket cannot deliver a hint under a different account', () async {
    var callbacks = 0;
    await service.initialize(onBookingSync: (_, __) => callbacks++);
    token = 'account-b';
    send();
    await Future<void>.delayed(Duration.zero);
    expect(callbacks, 0);
  });
  test('valid socket burst bounds pending credential reads to one', () async {
    var callbacks = 0;
    await service.initialize(onBookingSync: (_, __) => callbacks++);
    var reads = 0;
    final held = Completer<String?>();
    socketToken = () {
      reads++;
      return held.future;
    };
    for (var i = 0; i < 100; i++) {
      send();
    }
    expect(reads, 1);
    held.complete(token);
    await Future<void>.delayed(Duration.zero);
    expect(callbacks, 1);
  });
  test(
      'malformed hints never read credentials and storage failure is contained',
      () async {
    var callbacks = 0;
    await service.initialize(onBookingSync: (_, __) => callbacks++);
    var reads = 0;
    socketToken = () async {
      reads++;
      throw StateError('Unavailable');
    };
    send({});
    expect(reads, 0);
    send();
    await Future<void>.delayed(Duration.zero);
    expect(callbacks, 0);
  });
  testWidgets(
      'actual MapStore registration exposes exhausted booking only after HTTP recovery',
      (tester) async {
    final store = HintPassengerStore(dio, service);
    unawaited(store.initialize());
    await pumpRecovery(tester);
    expect(store.error, isNull);
    store.recovery.setForeground(true);
    respond = (_) async =>
        {'hasActiveRide': true, ...snapshot('ride-1', 'searching')};
    send(bookingHint(exhausted: true));
    expect(store.noDriversFound, false);
    await pumpRecovery(tester);
    expect(store.currentRide?.ride?.sId, 'ride-1');
    expect(store.noDriversFound, true);
    expect(store.booking.pending.value, false);
    store.dispose();
  });
}
