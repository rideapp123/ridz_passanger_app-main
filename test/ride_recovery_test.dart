import 'dart:async';
import 'dart:convert';
import 'package:ridzs_passenger_app/models/common/ride_response/ride_response.dart'
    show RideRequest;
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/core/services/ride_recovery.dart';
import 'package:ridzs_passenger_app/widgets/ride_recovery_gate.dart';
import 'package:ridzs_passenger_app/stores/map/map_store.dart';

Map<String, dynamic> ride(String status, {String id = 'r1', int version = 1}) =>
    {
      'ride': {'id': id, 'status': status, 'version': version}
    };
Map<String, dynamic> active(String status) =>
    {'hasActiveRide': true, ...ride(status)};
const empty = {'hasActiveRide': false};
String hintKey(String token) =>
    'ride_recovery_${sha256.convert(utf8.encode(token))}';

Future<void> pumpRecovery(WidgetTester tester,
    [Duration elapsed = Duration.zero]) async {
  await tester.pump(elapsed);
  // Dio dispatches interceptor stages on zero-duration timers.
  for (var i = 0; i < 30; i++) {
    await tester.pump();
  }
}

class RestoredStore extends MapStore {
  RestoredStore(Dio dio)
      : super(
            recoveryDio: dio,
            sessionTokenReader: () async => 'account-a',
            rideNotice: (_) {});
  int resumes = 0;
  @override
  Future<void> resumeRideResources() async {
    resumes++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Dio dio;
  late RideRecovery recovery;
  late Map<String, Map<String, dynamic>> hints;
  late List<Map<String, dynamic>?> restored;
  late List<String> paths;
  late Future<Map<String, dynamic>> Function(RequestOptions) respond;
  String? currentId;
  var token = 'account-a';
  var canReconcile = true;

  void setupRecovery() {
    FlutterSecureStorage.setMockInitialValues({});
    dio = Dio(BaseOptions(baseUrl: 'https://example.test/role'));
    hints = {};
    restored = [];
    paths = [];
    currentId = null;
    token = 'account-a';
    canReconcile = true;
    respond = (_) async => empty;
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      paths.add(options.path);
      expectSync(options.method, 'GET',
          reason: 'Recovery never repeats a write');
      try {
        final payload = await respond(options);
        handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {'success': true, 'data': payload}));
      } on DioException catch (error) {
        handler.reject(error);
      }
    }));
    recovery = RideRecovery(
        dio: dio,
        currentRideId: () => currentId,
        canReconcile: () => canReconcile,
        tokenReader: () async => token,
        restore: (snapshot) async {
          restored.add(snapshot);
        },
        readHint: (key) async => hints[key],
        writeHint: (key, value) async {
          hints[key] = value;
        },
        removeHint: (key) async {
          hints.remove(key);
        })
      ..activate();
  }

  void resetRecovery() {
    recovery.dispose();
    dio.close(force: true);
    setupRecovery();
  }

  setUp(setupRecovery);

  Map<String, dynamic> syncHint() => {
        'type': 'RIDE_ACCEPTANCE_SYNC',
        'notificationId': 'a' * 64,
      };

  testWidgets(
      'socket hint reads current HTTP state and bounds duplicate bursts',
      (tester) async {
    resetRecovery();
    recovery.setForeground(true);
    respond = (_) async => active('started');
    for (var i = 0; i < 100; i++) {
      recovery.handleSyncHint(syncHint());
    }
    await pumpRecovery(tester);
    expect(paths, ['/rides/current']);
    expect(restored.single!['ride']['status'], 'started');
    await pumpRecovery(tester, const Duration(seconds: 2));
    recovery.handleSyncHint(syncHint());
    await pumpRecovery(tester);
    expect(paths.length, 2);
    recovery.dispose();
  });

  testWidgets(
      'invalid or background hints cannot change state or issue requests',
      (tester) async {
    resetRecovery();
    recovery.handleSyncHint(syncHint());
    recovery.setForeground(true);
    for (final bad in [
      null,
      [],
      {},
      {
        ...syncHint(),
        'ride': {'status': 'accepted'}
      },
      {...syncHint(), 'notificationId': 'r1'},
      {...syncHint(), 'notificationId': 12},
      {...syncHint(), 'type': 'RIDE_ACCEPTED'},
    ]) {
      recovery.handleSyncHint(bad);
    }
    await pumpRecovery(tester);
    expect(paths, isEmpty);
    recovery.dispose();
    recovery.handleSyncHint(syncHint());
    await pumpRecovery(tester, const Duration(seconds: 30));
    expect(paths, isEmpty);
  });

  testWidgets('hint arriving during a read invalidates its older snapshot',
      (tester) async {
    resetRecovery();
    recovery.setForeground(true);
    final pending = Completer<Map<String, dynamic>>();
    respond = (_) =>
        paths.length == 1 ? pending.future : Future.value(active('started'));
    unawaited(recovery.refresh());
    await pumpRecovery(tester);
    recovery.handleSyncHint(syncHint());
    pending.complete(active('accepted'));
    await pumpRecovery(tester);
    expect(paths.length, 2);
    expect(restored.single!['ride']['status'], 'started');
    recovery.dispose();
  });

  testWidgets('busy commands defer hint refresh to foreground reconciliation',
      (tester) async {
    resetRecovery();
    recovery.setForeground(true);
    canReconcile = false;
    recovery.handleSyncHint(syncHint());
    await pumpRecovery(tester);
    expect(paths, isEmpty);
    canReconcile = true;
    await pumpRecovery(tester, const Duration(seconds: 15));
    expect(paths, ['/rides/current']);
    recovery.dispose();
  });

  testWidgets(
      'logout cancels hinted read and resets the cooldown for a new session',
      (tester) async {
    resetRecovery();
    recovery.setForeground(true);
    final pending = Completer<Map<String, dynamic>>();
    respond = (_) => pending.future;
    recovery.handleSyncHint(syncHint());
    await pumpRecovery(tester);
    recovery.dispose();
    pending.complete(active('accepted'));
    await pumpRecovery(tester);
    expect(restored, isEmpty);
    token = 'account-b';
    recovery.activate();
    recovery.setForeground(true);
    respond = (_) async => empty;
    recovery.handleSyncHint(syncHint());
    await pumpRecovery(tester);
    expect(restored, [null]);
    recovery.dispose();
  });
  tearDown(() {
    recovery.dispose();
    dio.close(force: true);
  });

  for (final status in [
    'requested',
    'searching',
    'accepted',
    'arrived',
    'started'
  ]) {
    test('recovers authoritative $status on cold start', () async {
      respond = (_) async => active(status);
      await recovery.refresh();
      expect(restored.single!['ride']['status'], status);
      expect(restored.single!['ride']['_id'], 'r1');
      expect(recovery.ready.value, true);
      expect(recovery.loading.value, false);
    });
  }

  test('explicit empty response clears stale UI', () async {
    await recovery.refresh();
    expect(restored, [null]);
    expect(recovery.ready.value, true);
  });

  testWidgets('foreground polling recovers a missed event without reconnecting',
      (tester) async {
    resetRecovery();
    unawaited(recovery.refresh());
    await pumpRecovery(tester);
    recovery.setForeground(true);
    respond = (_) async => active('accepted');
    await pumpRecovery(tester, const Duration(seconds: 14));
    expect(paths, hasLength(1));
    await pumpRecovery(tester, const Duration(seconds: 1));
    expect(restored.last!['ride']['status'], 'accepted');
    expect(recovery.ready.value, true);
    expect(recovery.loading.value, false);
    recovery.setForeground(false);
  });

  testWidgets('foreground lifecycle pauses, resumes and disposes the timer',
      (tester) async {
    resetRecovery();
    recovery.dispose();
    recovery.setForeground(true);
    await pumpRecovery(tester, const Duration(seconds: 30));
    expect(paths, isEmpty);
    recovery.activate();
    await pumpRecovery(tester, const Duration(seconds: 15));
    expect(paths, hasLength(1));
    recovery.setForeground(false);
    await pumpRecovery(tester, const Duration(minutes: 1));
    expect(paths, hasLength(1));
    recovery.setForeground(true);
    recovery.setForeground(true);
    await pumpRecovery(tester, const Duration(seconds: 15));
    expect(paths, hasLength(2));
    recovery.dispose();
    await pumpRecovery(tester, const Duration(minutes: 1));
    expect(paths, hasLength(2));
  });

  testWidgets('slow periodic read stays single-flight without blocking the UI',
      (tester) async {
    resetRecovery();
    unawaited(recovery.refresh());
    await pumpRecovery(tester);
    final release = Completer<Map<String, dynamic>>();
    respond = (_) => release.future;
    recovery.setForeground(true);
    await pumpRecovery(tester, const Duration(seconds: 15));
    expect(recovery.reconciling, true);
    expect(recovery.ready.value, true);
    expect(recovery.loading.value, false);
    await pumpRecovery(tester, const Duration(minutes: 2));
    expect(paths, hasLength(2));
    release.complete(active('accepted'));
    await pumpRecovery(tester);
    respond = (_) async => active('started');
    await pumpRecovery(tester, const Duration(seconds: 14));
    expect(paths, hasLength(2));
    await pumpRecovery(tester, const Duration(seconds: 1));
    expect(restored.last!['ride']['status'], 'started');
    expect(paths, hasLength(3));
    recovery.setForeground(false);
  });

  testWidgets('failed poll preserves state, blocks actions and retries',
      (tester) async {
    resetRecovery();
    respond = (_) async => active('accepted');
    unawaited(recovery.refresh());
    await pumpRecovery(tester);
    respond = (request) async => throw DioException(
        requestOptions: request, type: DioExceptionType.receiveTimeout);
    recovery.setForeground(true);
    await pumpRecovery(tester, const Duration(seconds: 15));
    expect(restored.single!['ride']['status'], 'accepted');
    expect(recovery.ready.value, false);
    expect(recovery.error.value, isNotNull);
    respond = (_) async => active('started');
    await pumpRecovery(tester, const Duration(seconds: 15));
    expect(restored.last!['ride']['status'], 'started');
    expect(recovery.ready.value, true);
    expect(recovery.error.value, isNull);
    recovery.setForeground(false);
  });

  testWidgets('explicit recovery during a poll blocks until a fresh follow-up',
      (tester) async {
    resetRecovery();
    unawaited(recovery.refresh());
    await pumpRecovery(tester);
    final release = Completer<Map<String, dynamic>>();
    respond = (_) => release.future;
    recovery.setForeground(true);
    await pumpRecovery(tester, const Duration(seconds: 15));
    final explicit = recovery.requireRefresh();
    expect(recovery.ready.value, false);
    expect(recovery.loading.value, true);
    expect(recovery.reconciling, false);
    respond = (_) async => active('started');
    release.complete(active('accepted'));
    await pumpRecovery(tester);
    await explicit;
    expect(restored.last!['ride']['status'], 'started');
    expect(paths, hasLength(3));
    recovery.setForeground(false);
  });

  testWidgets('disposed poll cannot restore or schedule work in a new session',
      (tester) async {
    resetRecovery();
    unawaited(recovery.refresh());
    await pumpRecovery(tester);
    final release = Completer<Map<String, dynamic>>();
    respond = (_) => release.future;
    recovery.setForeground(true);
    await pumpRecovery(tester, const Duration(seconds: 15));
    recovery.dispose();
    token = 'account-b';
    recovery.activate();
    release.complete(active('accepted'));
    await pumpRecovery(tester, const Duration(minutes: 1));
    expect(restored, [null]);
    expect(paths, hasLength(2));
    expect(recovery.ready.value, false);
  });

  for (final terminal in ['completed', 'cancelled']) {
    testWidgets('store converges from missed assignment through $terminal',
        (tester) async {
      resetRecovery();
      final store = RestoredStore(dio);
      addTearDown(store.dispose);
      store.recovery.activate();
      unawaited(store.recovery.refresh());
      await pumpRecovery(tester);
      store.recovery.setForeground(true);
      for (final entry in ['accepted', 'arrived', 'started'].asMap().entries) {
        respond = (_) async => {
              'hasActiveRide': true,
              ...ride(entry.value, version: entry.key + 2),
            };
        await pumpRecovery(tester, const Duration(seconds: 15));
        expect(store.currentRide?.ride?.status?.name, entry.value);
        expect(store.currentRide?.ride?.version, entry.key + 2);
        expect(
            store.applyRideUpdate(
                RideRequest.fromJson(ride('accepted', version: 2))),
            false);
      }
      respond = (request) async => request.path.endsWith('/current')
          ? empty
          : ride(terminal, version: 5);
      await pumpRecovery(tester, const Duration(seconds: 15));
      expect(store.currentRide?.ride?.status?.name,
          terminal == 'cancelled' ? null : 'completed');
      expect(store.recovery.ready.value, true);
      expect(
          store.applyRideUpdate(
              RideRequest.fromJson(ride('accepted', version: 2))),
          false);
      // A duplicate terminal read cannot repeat the transition.
      await pumpRecovery(tester, const Duration(seconds: 15));
      expect(store.currentRide?.ride?.status?.name,
          terminal == 'cancelled' ? null : 'completed');
      store.recovery.setForeground(false);
    });
  }

  testWidgets('poll defers during a command and resumes when it completes',
      (tester) async {
    resetRecovery();
    unawaited(recovery.refresh());
    await pumpRecovery(tester);
    canReconcile = false;
    recovery.setForeground(true);
    await pumpRecovery(tester, const Duration(seconds: 15));
    expect(paths, hasLength(1));
    expect(recovery.ready.value, true);
    canReconcile = true;
    respond = (_) async => active('accepted');
    await pumpRecovery(tester, const Duration(seconds: 15));
    expect(paths, hasLength(2));
    expect(restored.last!['ride']['status'], 'accepted');
    recovery.setForeground(false);
  });

  testWidgets('pause during an HTTP flight prevents any subsequent poll',
      (tester) async {
    resetRecovery();
    unawaited(recovery.refresh());
    await pumpRecovery(tester);
    final release = Completer<Map<String, dynamic>>();
    respond = (_) => release.future;
    recovery.setForeground(true);
    await pumpRecovery(tester, const Duration(seconds: 15));
    recovery.setForeground(false);
    release.complete(active('accepted'));
    await pumpRecovery(tester);
    await pumpRecovery(tester, const Duration(minutes: 1));
    expect(paths, hasLength(2));
    expect(restored.last!['ride']['status'], 'accepted');
  });

  test(
      'routine same-phase refresh does not restart route/chat/location resources',
      () async {
    final store = RestoredStore(dio);
    addTearDown(store.dispose);
    respond = (_) async => active('accepted');
    store.recovery.activate();
    await store.recovery.refresh();
    final resumes = store.resumes;
    await store.recovery.refresh(reconcile: true);
    expect(store.resumes, resumes);
    respond =
        (_) async => {'hasActiveRide': true, ...ride('accepted', version: 2)};
    await store.recovery.refresh(reconcile: true);
    expect(store.resumes, resumes);
    expect(store.currentRide?.ride?.version, 2);
    await store.recovery.refresh();
    expect(store.resumes, resumes + 1,
        reason: 'Explicit resume restores resources');
  });

  for (final status in ['completed', 'cancelled']) {
    test('missed $status recovered using private session hint', () async {
      hints[hintKey(token)] = {'rideId': 'r1'};
      respond = (request) async =>
          request.path.endsWith('/current') ? empty : ride(status);
      await recovery.refresh();
      expect(paths, ['/rides/current', '/rides/r1']);
      expect(restored.single!['ride']['status'], status);
      expect(recovery.ready.value, true);
    });
  }

  test('timeout preserves state and exposes retry until confirmation',
      () async {
    respond = (request) async => throw DioException(
        requestOptions: request, type: DioExceptionType.receiveTimeout);
    await recovery.refresh();
    expect(restored, isEmpty);
    expect(recovery.ready.value, false);
    expect(recovery.error.value, isNotNull);
    respond = (_) async => active('started');
    await recovery.refresh();
    expect(recovery.ready.value, true);
    expect(recovery.error.value, isNull);
  });

  for (final malformed in [
    <String, dynamic>{},
    {'hasActiveRide': 'false'},
    {
      'hasActiveRide': true,
      'ride': {'id': 'r1', 'status': 'unknown'}
    },
    {
      'hasActiveRide': true,
      'ride': {'id': 'r1', '_id': 'r2', 'status': 'started'}
    },
  ]) {
    test('malformed response fails closed: $malformed', () async {
      respond = (_) async => malformed;
      await recovery.refresh();
      expect(restored, isEmpty);
      expect(recovery.ready.value, false);
    });
  }

  for (final code in [404, 403, 500]) {
    test('by-id $code is distinguished from no active ride', () async {
      currentId = 'r1';
      respond = (request) async {
        if (request.path.endsWith('/current')) return empty;
        throw DioException(
            requestOptions: request,
            type: DioExceptionType.badResponse,
            response: Response(requestOptions: request, statusCode: code));
      };
      await recovery.refresh();
      expect(recovery.ready.value, code == 404);
      expect(restored, code == 404 ? [null] : isEmpty);
    });
  }

  test('wrong ride by ID cannot replace remembered ride', () async {
    currentId = 'r1';
    respond = (request) async =>
        request.path.endsWith('/current') ? empty : ride('completed', id: 'r2');
    await recovery.refresh();
    expect(restored, isEmpty);
    expect(recovery.ready.value, false);
  });

  test('live event invalidates old read and triggers a fresh read', () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    var calls = 0;
    respond = (_) async {
      if (++calls == 1) {
        entered.complete();
        await release.future;
        return active('accepted');
      }
      return active('started');
    };
    final flight = recovery.refresh();
    await entered.future;
    recovery.changed();
    release.complete();
    await flight;
    expect(restored.single!['ride']['status'], 'started');
    expect(calls, 2);
  });

  test('many concurrent refreshes share one flight with one follow-up',
      () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    var calls = 0;
    respond = (_) async {
      if (++calls == 1) {
        entered.complete();
        await release.future;
      }
      return active('started');
    };
    final first = recovery.refresh();
    await entered.future;
    final others = List.generate(8, (_) => recovery.refresh());
    release.complete();
    await Future.wait([first, ...others]);
    expect(calls, 2);
    expect(recovery.ready.value, true);
  });

  test('logout rejects an old response and a new session can recover',
      () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    var calls = 0;
    respond = (_) async {
      if (++calls == 1) {
        entered.complete();
        await release.future;
        return active('started');
      }
      return empty;
    };
    final old = recovery.refresh();
    await entered.future;
    recovery.dispose();
    token = 'account-b';
    recovery.activate();
    await recovery.refresh();
    release.complete();
    await old;
    expect(restored, [null]);
    expect(recovery.ready.value, true);
  });

  test('another account never reads old account terminal hint', () async {
    hints[hintKey('account-a')] = {'rideId': 'private-ride'};
    token = 'account-b';
    await recovery.refresh();
    expect(paths, ['/rides/current']);
    expect(restored, [null]);
  });

  test('account switch during recovery rejects the previous account snapshot',
      () async {
    respond = (request) async {
      expect(request.extra['expectedAuthToken'], 'account-a');
      token = 'account-b';
      return active('accepted');
    };
    await recovery.refresh();
    expect(restored, isEmpty);
    expect(recovery.ready.value, false);
    expect(recovery.error.value, isNotNull);
  });

  test('terminal lookup carries the captured session token', () async {
    currentId = 'r1';
    respond = (request) async {
      expect(request.extra['expectedAuthToken'], 'account-a');
      return request.path.endsWith('/current') ? empty : ride('completed');
    };
    await recovery.refresh();
    expect(paths, ['/rides/current', '/rides/r1']);
    expect(recovery.ready.value, true);
  });

  test('forget removes the captured hint even when immediately disposed',
      () async {
    respond = (_) async => active('started');
    await recovery.refresh();
    final clear = recovery.forget();
    recovery.dispose();
    await clear;
    expect(hints, isEmpty);
  });

  test('refresh blocks actions until its response is confirmed', () async {
    await recovery.refresh();
    expect(recovery.ready.value, true);
    final flight = recovery.refresh();
    expect(recovery.ready.value, false);
    await flight;
    expect(recovery.ready.value, true);
  });

  for (final status in ['accepted', 'arrived', 'started']) {
    test('real store restores $status and clears state on session disposal',
        () async {
      final store = RestoredStore(dio);
      addTearDown(store.dispose);
      respond = (_) async => active(status);
      store.recovery.activate();
      await store.recovery.refresh();
      expect(store.currentRide!.ride!.status!.title, status);
      expect(store.isRideAccepted, true);
      expect(store.resumes, 1);
      store.dispose();
      expect(store.currentRide, isNull);
      expect(store.isRideAccepted, false);
      expect(store.recovery.ready.value, false);
    });
  }

  for (final terminal in ['completed', 'cancelled']) {
    test('real store recovers missed $terminal with payment state', () async {
      final store = RestoredStore(dio);
      addTearDown(store.dispose);
      respond = (_) async => active('started');
      store.recovery.activate();
      await store.recovery.refresh();
      respond = (request) async => request.path.endsWith('/current')
          ? empty
          : {
              'ride': {
                ...ride(terminal, version: 2)['ride'] as Map,
                'payment': {'status': 'adjustment_pending', 'method': 'card'}
              }
            };
      await store.recovery.refresh();
      expect(store.recovery.ready.value, true);
      if (terminal == 'cancelled') {
        expect(store.currentRide, isNull);
        expect(store.isRideAccepted, false);
      } else {
        expect(store.currentRide!.ride!.status!.title, terminal);
        expect(store.currentRide!.ride!.payment!.status, 'adjustment_pending');
      }
    });
  }

  test('recovery chat reload accepts backend envelope and numeric timestamps',
      () async {
    final store = RestoredStore(dio);
    addTearDown(store.dispose);
    respond = (_) async => active('started');
    store.recovery.activate();
    await store.recovery.refresh();
    respond = (_) async => {
          'messages': [
            {
              'rideId': 'r1',
              'message': 'At pickup',
              'by': 'passenger',
              'timestamp': 1700000000000
            }
          ]
        };
    await store.loadChatMessage(rideId: 'r1');
    expect(store.chatMessages, hasLength(1));
    expect(store.chatMessages.single.sender, 'passenger');
    expect(
        DateTime.parse(store.chatMessages.single.timestamp)
            .millisecondsSinceEpoch,
        1700000000000);
    await store.loadChatMessage(rideId: 'r1');
    expect(store.chatMessages, hasLength(1),
        reason: 'History reload is deduplicated');
    respond = (_) async => {'messages': []};
    await store.loadChatMessage(rideId: 'r1');
    expect(store.chatMessages, hasLength(1),
        reason: 'Empty history cannot erase live messages');
  });

  test('real store retains active ride when recovery fails', () async {
    final store = RestoredStore(dio);
    addTearDown(store.dispose);
    respond = (_) async => active('started');
    store.recovery.activate();
    await store.recovery.refresh();
    respond = (request) async => throw DioException(requestOptions: request);
    await store.recovery.refresh();
    expect(store.currentRide!.ride!.status!.title, 'started');
    expect(store.recovery.ready.value, false);
  });

  for (final size in [const Size(320, 640), const Size(1000, 800)]) {
    testWidgets('recovery gate blocks actions and supports retry at $size',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var presses = 0;
      var logouts = 0;
      await tester.pumpWidget(MaterialApp(
          home: MediaQuery(
              data: MediaQueryData(
                  size: size, textScaler: const TextScaler.linear(2)),
              child: Scaffold(
                  body: RideRecoveryGate(
                      recovery: recovery,
                      onLogout: () {
                        logouts++;
                      },
                      child: SizedBox.expand(
                          child: Center(
                              child: ElevatedButton(
                                  onPressed: () {
                                    presses++;
                                  },
                                  child: const Text('Book')))))))));
      await tester.tap(find.text('Book'), warnIfMissed: false);
      expect(presses, 0);
      respond = (_) async => {};
      await tester.runAsync(recovery.refresh);
      await tester.pumpAndSettle();
      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Sign out'));
      expect(logouts, 1);
      respond = (_) async => empty;
      await tester.runAsync(() async {
        await tester.tap(find.text('Retry'));
        await recovery.refresh();
      });
      await tester.pumpAndSettle();
      expect(find.text('Retry'), findsNothing);
      await tester.tap(find.text('Book'));
      expect(presses, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
