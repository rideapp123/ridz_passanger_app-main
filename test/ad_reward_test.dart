import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/core/services/dio_service.dart';
import 'package:ridzs_passenger_app/core/theme/light_theme.dart';
import 'package:ridzs_passenger_app/core/theme/ridzs_theme.dart';
import 'package:ridzs_passenger_app/models/ad_reward.dart';
import 'package:ridzs_passenger_app/services/ad_reward_flow.dart';
import 'package:ridzs_passenger_app/services/ad_reward_service.dart';
import 'package:ridzs_passenger_app/services/reward_ad_player.dart';
import 'package:ridzs_passenger_app/view/my_rewards/ad_watch_screen.dart';
import 'session_request_test.dart' show TestAdapter;

const unit = 'ca-app-pub-1234567890123456/1234567890';
final startTime = DateTime.utc(2026, 10, 18);
Map<String, dynamic> reward({String status = 'started', String? request}) => {
      'id': 'session1',
      'passengerId': 'p1',
      'rideId': '',
      'status': status,
      'startRequestId': request,
      'rewardAmount': .25,
      'currency': 'usd',
      'startedAt': startTime.toIso8601String(),
      'rules': {
        'version': 1,
        'rewardMinor': 25,
        'currency': 'usd',
        'allowedUnits': ['1234567890'],
        'providerAmount': '1',
        'providerItem': 'credit',
        'notBefore': startTime.toIso8601String(),
        'watchDeadline':
            startTime.add(const Duration(minutes: 30)).toIso8601String(),
        'confirmationDeadline': startTime
            .add(const Duration(hours: 24, minutes: 30))
            .toIso8601String()
      },
      if (status == 'completed') ...{
        'walletTransactionId': 'wallet1',
        'completedAt':
            startTime.add(const Duration(minutes: 1)).toIso8601String(),
        'adMetadata': {
          'serverVerified': 'true',
          'adNetwork': 'admob',
          'transaction_id': 'event1',
          'ad_unit': '1234567890',
          'reward_amount': '1',
          'reward_item': 'credit',
          'timestamp':
              '${startTime.add(const Duration(seconds: 30)).millisecondsSinceEpoch}'
        },
      },
    };

class FakeRewards extends AdRewardService {
  final keys = <String>[];
  int details = 0, cancels = 0, offers = 0;
  bool loseStart = false, offerFails = false;
  Object? startError;
  Map<String, dynamic> value = reward();
  Completer<AdRewardSession>? detailGate;
  @override
  Future<AdRewardOffer> offer(String token, {String? rideId}) async {
    offers++;
    if (offerFails) throw StateError('Disabled');
    return AdRewardOffer(25, {'1234567890'});
  }

  @override
  Future<AdRewardSession> start(
      String token, String owner, String requestId, String? rideId) async {
    keys.add(requestId);
    value['startRequestId'] = requestId;
    value['rideId'] = rideId ?? '';
    if (startError != null) throw startError!;
    if (loseStart) {
      loseStart = false;
      throw StateError('Lost reply after commit');
    }
    return AdRewardSession.parse(value, owner);
  }

  @override
  Future<AdRewardSession> detail(String token, String owner, String id) async {
    details++;
    if (detailGate != null) return detailGate!.future;
    return AdRewardSession.parse(value, owner, expectedId: id);
  }

  @override
  Future<AdRewardSession> cancel(String token, String owner, String id) async {
    cancels++;
    value['status'] = 'cancelled';
    return AdRewardSession.parse(value, owner, expectedId: id);
  }
}

class FakePlayer implements RewardAdPlayer {
  int shows = 0;
  bool fail = false, disposed = false;
  Completer<void>? gate;
  void Function()? emit;
  @override
  Future<void> show(String unit, String owner, String session,
      Future<bool> Function() beforeShow, void Function() earned) async {
    if (fail) throw StateError('Load failed');
    if (!await beforeShow()) return;
    shows++;
    emit = earned;
    earned();
    if (gate != null) await gate!.future;
  }

  @override
  void dispose() {
    disposed = true;
    if (gate != null && !gate!.isCompleted) gate!.complete();
  }
}

class Harness {
  final service = FakeRewards();
  final memory = <String, Map<String, dynamic>>{};
  final flows = <AdRewardFlow>[];
  String? owner = 'p1', token = 'token-a';
  int wallets = 0;
  bool writeFails = false, walletFails = false;
  DateTime time = startTime.add(const Duration(minutes: 1));
  AdRewardFlow flow({FakePlayer? player, String sdk = unit}) {
    final flow = AdRewardFlow(
        owner: 'p1',
        sdkUnit: sdk,
        ownerReader: () => owner,
        tokenReader: () async => token,
        service: service,
        player: player ?? FakePlayer(),
        now: () => time,
        environment: 'test',
        pollInterval: const Duration(hours: 1),
        refreshWallet: () async {
          wallets++;
          if (walletFails) throw StateError('Offline');
        },
        read: (key) async =>
            memory[key] == null ? null : Map.from(memory[key]!),
        write: (key, value) async {
          if (writeFails) throw StateError('Disk full');
          memory[key] = Map.from(value);
        },
        remove: (key) async {
          memory.remove(key);
        });
    flows.add(flow);
    return flow;
  }

  void dispose() {
    for (final flow in flows) {
      flow.dispose();
    }
    flows.clear();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('contract', () {
    test('only a verified session yields exact USD credit', () {
      final value = AdRewardSession.parse(reward(status: 'completed'), 'p1');
      expect(AdRewardCredit(value).money, 'USD 0.25');
      expect(() => AdRewardCredit(AdRewardSession.parse(reward(), 'p1')),
          throwsFormatException);
      expect(approvedRewardUnit({'1234567890'}, unit), true);
      expect(approvedRewardUnit({unit}, unit), true);
      expect(approvedRewardUnit({'other'}, unit), false);
    });
    for (final entry in <String, dynamic>{
      'passengerId': 'p2',
      'currency': 'cad',
      'rewardAmount': .251,
      'status': 'success',
      'rules': null,
      'walletTransactionId': '',
      'adMetadata': {},
      'completedAt': '2099-01-01T00:00:00Z'
    }.entries) {
      test('rejects unverified ${entry.key}', () {
        final raw = reward(status: 'completed')..[entry.key] = entry.value;
        expect(() => AdRewardSession.parse(raw, 'p1'), throwsFormatException);
      });
    }
    test('rejects wrong session and changed or late provider evidence', () {
      expect(() => AdRewardSession.parse(reward(), 'p1', expectedId: 'other'),
          throwsFormatException);
      for (final field in [
        'serverVerified',
        'ad_unit',
        'reward_amount',
        'reward_item',
        'timestamp'
      ]) {
        final raw = reward(status: 'completed');
        (raw['adMetadata'] as Map)[field] = 'wrong';
        expect(() => AdRewardSession.parse(raw, 'p1'), throwsFormatException,
            reason: field);
      }
    });
  });

  group('HTTP', () {
    late Dio dio;
    late AdRewardService service;
    late Map<String, dynamic> body;
    late List<RequestOptions> calls;
    setUp(() {
      calls = [];
      body = {
        'success': true,
        'data': {'session': reward()}
      };
      dio = Dio(BaseOptions(baseUrl: 'https://example.test/passenger'));
      service = AdRewardService(dio: dio);
      dio.httpClientAdapter = TestAdapter((request) async {
        calls.add(request);
        return ResponseBody.fromString(jsonEncode(body), 200, headers: {
          'content-type': ['application/json']
        });
      });
    });
    tearDown(() => dio.close(force: true));
    test('detail is strict and carries the original account token', () async {
      final result = await service.detail('token-a', 'p1', 'session1');
      expect(result.confirmed, false);
      expect(calls.single.extra['expectedAuthToken'], 'token-a');
      body['success'] = false;
      await expectLater(
          service.detail('token-a', 'p1', 'session1'), throwsFormatException);
      body.remove('success');
      await expectLater(
          service.detail('token-a', 'p1', 'session1'), throwsFormatException);
    });
    test('start must echo its key and ride; cancellation must be terminal',
        () async {
      await expectLater(
          service.start('token-a', 'p1', 'request-1234567890', null),
          throwsFormatException);
      body['data'] = {'session': reward(request: 'request-1234567890')};
      expect(
          (await service.start('token-a', 'p1', 'request-1234567890', null)).id,
          'session1');
      await expectLater(
          service.start('token-a', 'p1', 'request-1234567890', 'ride1'),
          throwsFormatException);
      await expectLater(
          service.cancel('token-a', 'p1', 'session1'), throwsFormatException);
      expect(calls.any((r) => r.path.endsWith('/complete')), false);
    });
    test('account switch cannot dispatch an old request', () async {
      dio.interceptors
          .add(AuthInterceptor(dio, tokenReader: () async => 'token-b'));
      await expectLater(service.detail('token-a', 'p1', 'session1'),
          throwsA(isA<DioException>()));
      expect(calls, isEmpty);
    });
    test('real auth interceptor retains rate status and Retry-After', () async {
      dio.interceptors
          .add(AuthInterceptor(dio, tokenReader: () async => 'token-a'));
      dio.httpClientAdapter = TestAdapter((request) async =>
          ResponseBody.fromString(
              '{"success":false,"code":"AD_REWARD_START_RATE_LIMITED"}', 429,
              headers: {
                'content-type': ['application/json'],
                'retry-after': ['60']
              }));
      await expectLater(
          service.start('token-a', 'p1', 'request-1234567890', null),
          throwsA(isA<DioException>()
              .having((e) => e.response?.statusCode, 'status', 429)
              .having((e) => e.response?.headers.value('Retry-After'), 'retry',
                  '60')));
    });
  });

  group('recovery', () {
    late Harness h;
    setUp(() => h = Harness());
    tearDown(() => h.dispose());
    test('earned callback is not credit; close never cancels a shown ad',
        () async {
      final player = FakePlayer();
      final flow = h.flow(player: player);
      await flow.initialize();
      expect(player.shows, 1);
      expect(flow.phase, RewardPhase.pending);
      expect(flow.credit, isNull);
      expect(h.wallets, 0);
      expect(h.memory.values.single['presented'], true);
      await flow.close();
      expect(h.service.cancels, 0);
      expect(h.memory, isEmpty);
    });
    test('lost start reply survives close and recreation with the same key',
        () async {
      h.service.loseStart = true;
      final first = h.flow();
      await first.initialize();
      expect(first.phase, RewardPhase.pending);
      await first.close();
      expect(h.memory, hasLength(1));
      final next = h.flow();
      await next.initialize();
      expect(h.service.keys, hasLength(2));
      expect(h.service.keys.toSet(), hasLength(1));
      expect(h.memory.values.single['sessionId'], 'session1');
    });
    test('persistence failure cannot start or show an ad', () async {
      h.writeFails = true;
      final player = FakePlayer();
      final flow = h.flow(player: player);
      await flow.initialize();
      expect(h.service.keys, isEmpty);
      expect(player.shows, 0);
      h.writeFails = false;
      await flow.retry();
      expect(h.service.keys, hasLength(1));
      expect(player.shows, 1);
    });
    test('restart after presentation only checks the saved session', () async {
      final first = h.flow();
      await first.initialize();
      final player = FakePlayer();
      final next = h.flow(player: player);
      await next.initialize();
      expect(first.active, false);
      expect(player.shows, 0);
      expect(h.service.keys, hasLength(1));
      h.service.value = reward(status: 'completed');
      await next.refresh();
      expect(next.credit?.minor, 25);
      expect(h.wallets, 1);
    });
    test('history recovery never offers, starts, plays or cancels', () async {
      final player = FakePlayer();
      final flow = h.flow(player: player);
      h.service.offerFails = true;
      await flow.initialize(resumeSessionId: 'session1');
      expect(h.service.offers, 0);
      expect(h.service.keys, isEmpty);
      expect(player.shows, 0);
      await flow.close();
      expect(h.service.cancels, 0);
    });
    test('load failure can retry the same unshown session or cancel it',
        () async {
      final player = FakePlayer()..fail = true;
      final flow = h.flow(player: player);
      await flow.initialize();
      expect(flow.canCancel, true);
      player.fail = false;
      await flow.retry();
      expect(h.service.keys, hasLength(1));
      expect(player.shows, 1);
      await flow.close();
      expect(h.service.cancels, 0);
      final otherPlayer = FakePlayer()..fail = true;
      final other = h.flow(player: otherPlayer);
      await other.initialize();
      await other.close();
      expect(h.service.cancels, 1);
    });
    test('wallet refresh failure retains verified credit without another start',
        () async {
      final flow = h.flow();
      await flow.initialize();
      h.walletFails = true;
      h.service.value = reward(status: 'completed');
      await flow.refresh();
      expect(flow.credit?.money, 'USD 0.25');
      expect(flow.walletRefreshFailed, true);
      expect(h.service.keys, hasLength(1));
    });
    test(
        'late confirmation after account switch cannot refresh wallet or credit',
        () async {
      final flow = h.flow();
      await flow.initialize();
      final gate = h.service.detailGate = Completer<AdRewardSession>();
      final request = flow.refresh();
      await Future<void>.delayed(Duration.zero);
      h.owner = 'p2';
      h.token = 'token-b';
      gate.complete(AdRewardSession.parse(reward(status: 'completed'), 'p1'));
      await request;
      expect(flow.phase, RewardPhase.ended);
      expect(flow.credit, isNull);
      expect(h.wallets, 0);
    });
    test('logout immediately ends a playing ad and ignores its callback',
        () async {
      final player = FakePlayer()..gate = Completer<void>();
      final flow = h.flow(player: player);
      final opening = flow.initialize();
      while (player.shows == 0) {
        await Future<void>.delayed(Duration.zero);
      }
      AdRewardFlow.endAllSessions();
      player.emit!();
      await opening;
      expect(flow.phase, RewardPhase.ended);
      expect(h.wallets, 0);
      expect(player.disposed, true);
    });
    test('unapproved units fail before session creation', () async {
      final flow = h.flow(sdk: 'ca-app-pub-1234567890123456/9999999999');
      await flow.initialize();
      expect(flow.phase, RewardPhase.review);
      expect(h.service.keys, isEmpty);
    });
    test('disabled offer can retry without inventing a reward amount',
        () async {
      h.service.offerFails = true;
      final flow = h.flow();
      await flow.initialize();
      expect(flow.phase, RewardPhase.unavailable);
      expect(flow.session, isNull);
      h.service.offerFails = false;
      await flow.retry();
      expect(h.service.keys, hasLength(1));
    });
    test('rate cooldown retains its key and blocks early retries', () async {
      final request = RequestOptions(path: '/ad-rewards/start');
      h.service.startError = DioException(
          requestOptions: request,
          response: Response(
              requestOptions: request,
              statusCode: 429,
              headers: Headers.fromMap({
                'Retry-After': ['60']
              })));
      final flow = h.flow();
      await flow.initialize();
      await flow.retry();
      expect(flow.canRetry, false);
      expect(h.service.keys, hasLength(1));
      h.time = h.time.add(const Duration(seconds: 60));
      h.service.startError = null;
      await flow.retry();
      expect(h.service.keys.toSet(), hasLength(1));
      expect(h.service.keys, hasLength(2));
    });
    test('expired watch window never presents an ad', () async {
      h.time = startTime.add(const Duration(hours: 1));
      final player = FakePlayer();
      final flow = h.flow(player: player);
      await flow.initialize();
      expect(flow.phase, RewardPhase.expired);
      expect(player.shows, 0);
    });
    test('changed persisted money fails closed without wallet refresh',
        () async {
      final flow = h.flow();
      await flow.initialize();
      h.service.value = reward(status: 'completed')..['rewardAmount'] = .5;
      (h.service.value['rules'] as Map)['rewardMinor'] = 50;
      await flow.refresh();
      expect(flow.phase, RewardPhase.review);
      expect(flow.credit, isNull);
      expect(h.wallets, 0);
    });
  });

  testWidgets('Done returns typed credit only for a server-confirmed reward',
      (tester) async {
    final h = Harness();
    h.service.value = reward(status: 'completed');
    final flow = h.flow();
    h.flows.clear();
    await tester.runAsync(() => flow.initialize());
    Object? result;
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => TextButton(
                onPressed: () async {
                  result = await Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => AdWatchScreen(flow: flow)));
                },
                child: const Text('Open')))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Reward confirmed'), findsOneWidget);
    expect(h.wallets, 1);
    await tester.runAsync(() async {
      await tester.tap(find.widgetWithText(FilledButton, 'Done'));
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pumpAndSettle();
    expect(
        result,
        isA<AdRewardCredit>()
            .having((v) => v.owner, 'owner', 'p1')
            .having((v) => v.minor, 'minor', 25));
    expect(h.service.keys, hasLength(1));
    expect(h.service.cancels, 0);
    await tester.pumpWidget(const SizedBox());
  });

  for (final width in [320.0, 1000.0]) {
    testWidgets(
        'pending reward fits large text at $width and closes without cancel',
        (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final fonts = FontLoader('Poppins')
        ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'));
      await fonts.load();
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
      final h = Harness();
      final flow = h.flow();
      // Screen owns and disposes the injected flow.
      h.flows.clear();
      await tester.runAsync(() => flow.initialize());
      await tester.pumpWidget(MaterialApp(
          theme: RidzsTheme.refine(ThemeData(
              useMaterial3: true,
              colorScheme: flexSchemeLight,
              fontFamily: 'Poppins')),
          home: Builder(
              builder: (context) => TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => MediaQuery(
                          data: MediaQueryData(
                              size: Size(width, 800),
                              textScaler: const TextScaler.linear(2)),
                          child: RepaintBoundary(
                              key: const Key('reward'),
                              child: AdWatchScreen(flow: flow))))),
                  child: const Text('Open')))));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Awaiting confirmation'), findsOneWidget);
      expect(find.text('Reward confirmed'), findsNothing);
      expect(tester.takeException(), isNull);
      if (width == 320) {
        await expectLater(find.byKey(const Key('reward')),
            matchesGoldenFile('goldens/reward_pending_large_text.png'));
      }
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Close'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await tester.tap(find.widgetWithText(FilledButton, 'Close'));
        await Future<void>.delayed(Duration.zero);
      });
      await tester.pumpAndSettle();
      expect(find.text('Open'), findsOneWidget);
      expect(h.service.cancels, 0);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
