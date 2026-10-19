import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:ridzs_passenger_app/core/services/navigation_service.dart';
import 'package:ridzs_passenger_app/core/theme/size_config.dart';
import 'package:ridzs_passenger_app/core/theme/light_theme.dart';
import 'package:ridzs_passenger_app/core/theme/ridzs_theme.dart';
import 'package:ridzs_passenger_app/view/home/widget/ride_chat_bottom_sheet.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/services/ride_chat_service.dart';
import 'package:ridzs_passenger_app/models/chat/chat_message_model.dart';
import 'package:ridzs_passenger_app/view/home/widget/ride_chat_composer.dart';
import 'package:ridzs_passenger_app/stores/map/map_store.dart';
import 'package:ridzs_passenger_app/models/common/ride_response/ride_response.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Dio dio;
  late RideChatService chat;
  late Map<String, Map<String, dynamic>> pending;
  late List<RequestOptions> requests;
  late Future<Map<String, dynamic>> Function(RequestOptions) respond;
  String token = 'account-a';

  RideChatService service() => RideChatService(
        role: 'passenger',
        dio: dio,
        tokenReader: () async => token,
        readPending: (key) async => pending[key],
        writePending: (key, value) async {
          pending[key] = {...value};
        },
        removePending: (key) async {
          pending.remove(key);
        },
      );

  Map<String, dynamic> saved(RequestOptions request) => {
        'id': 'saved-id',
        'rideId': 'r1',
        'sender': 'passenger',
        'clientMessageId': request.data['clientMessageId'],
        'text': request.data['message'],
        'timestamp': 1700000000000,
        'orderKey': '1700000000000000000000000000000000001',
      };

  setUp(() {
    token = 'account-a';
    pending = {};
    requests = [];
    dio = Dio(BaseOptions(baseUrl: 'https://example.test/passenger'));
    respond = (request) async => saved(request);
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (request, handler) async {
      requests.add(request);
      try {
        final body = await respond(request);
        handler
            .resolve(Response(requestOptions: request, statusCode: 200, data: {
          'success': true,
          'data': body,
        }));
      } catch (_) {
        handler.reject(DioException(
            requestOptions: request, type: DioExceptionType.receiveTimeout));
      }
    }));
    chat = service();
  });
  tearDown(() {
    chat.reset();
    dio.close(force: true);
  });

  test(
      'saves the immutable command before sending and validates durable confirmation',
      () async {
    respond = (request) async {
      expect(pending.values.single, request.data);
      return saved(request);
    };
    final message = await chat.send('r1', ' Here ');
    expect(message!.message, 'Here');
    expect(message.id, 'saved-id');
    expect(pending, isEmpty);
    expect(requests.single.method, 'POST');
  });

  test('timeout retry after process restart uses the same command', () async {
    respond = (_) async => throw StateError('lost response');
    expect(await chat.send('r1', 'Here'), isNull);
    final command = Map<String, dynamic>.from(requests.single.data);
    final restarted = service();
    expect(await restarted.pendingDraft('r1'), 'Here');
    respond = (request) async => saved(request);
    expect(await restarted.send('r1', 'Here'), isNotNull);
    expect(requests.last.data, command);
    expect(pending, isEmpty);
    restarted.reset();
  });

  test('unconfirmed text cannot be overwritten by a different retry', () async {
    respond = (_) async => throw StateError('lost response');
    await chat.send('r1', 'Original');
    expect(await chat.send('r1', 'Changed'), isNull);
    expect(requests, hasLength(1));
    expect(await chat.pendingDraft('r1'), 'Original');
  });

  for (final field in ['id', 'rideId', 'sender', 'clientMessageId', 'text']) {
    test('rejects wrong $field acknowledgement and retains draft', () async {
      respond = (request) async =>
          {...saved(request), field: field == 'id' ? '' : 'wrong'};
      expect(await chat.send('r1', 'Here'), isNull);
      expect(pending, hasLength(1));
      expect(chat.sendError.value, isNotNull);
    });
  }

  test('double tap cannot post twice while confirmation is pending', () async {
    final held = Completer<Map<String, dynamic>>();
    respond = (_) => held.future;
    final first = chat.send('r1', 'Here');
    while (requests.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    expect(await chat.send('r1', 'Here'), isNull);
    expect(requests, hasLength(1));
    held.complete(saved(requests.single));
    expect(await first, isNotNull);
  });

  test('account switch cannot restore or replay previous account draft',
      () async {
    respond = (_) async => throw StateError('offline');
    await chat.send('r1', 'Private');
    chat.reset();
    token = 'account-b';
    expect(await chat.pendingDraft('r1'), isNull);
    respond = (request) async => saved(request);
    expect(await chat.send('r1', 'New account'), isNotNull);
    expect(pending.values.single['message'], 'Private');
    expect(requests.first.data['clientMessageId'],
        isNot(requests.last.data['clientMessageId']));
  });

  test('session end suppresses a late send acknowledgement', () async {
    final held = Completer<Map<String, dynamic>>();
    respond = (_) => held.future;
    final result = chat.send('r1', 'Here');
    while (requests.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    chat.reset();
    held.complete(saved(requests.single));
    expect(await result, isNull);
    expect(chat.sending.value, false);
    expect(chat.sendError.value, isNull);
  });

  test('history cursor retrieves older pages and rejects cross-ride records',
      () async {
    respond = (_) async => {
          'rideId': 'r1',
          'messages': [],
          'nextCursor': '1700000000000000000000000000000000001',
        };
    await chat.history('r1');
    respond = (_) async => {'rideId': 'r1', 'messages': [], 'nextCursor': null};
    await chat.history('r1', older: true);
    expect(requests.last.queryParameters['before'],
        '1700000000000000000000000000000000001');
    respond = (_) async => {'rideId': 'r2', 'messages': []};
    await expectLater(chat.history('r1'), throwsFormatException);
  });

  test('stable IDs deduplicate live/history without collapsing identical text',
      () {
    RideMessage message(String id, String order) => RideMessage.fromJson({
          'id': id,
          'rideId': 'r1',
          'sender': 'driver',
          'text': 'Here',
          'timestamp': 1700000000000,
          'orderKey': order,
        });
    final first = message('a', '1'), second = message('b', '2');
    final merged = RideMessage.mergeHistory([second, first], [first], 'r1');
    expect(merged.map((m) => m.id), ['a', 'b']);
    expect(RideMessage.mergeHistory(merged, [], 'r2'), isEmpty);
    final cleared = RideMessage.fromJson({...first.toJson(), 'message': ''});
    final corrected =
        RideMessage.fromJson({...second.toJson(), 'message': 'Corrected'});
    final refreshed =
        RideMessage.mergeHistory(merged, [cleared, corrected], 'r1');
    expect(refreshed.map((m) => m.message), ['', 'Corrected']);
  });

  test(
      'malformed message types fail parsing instead of coercing private objects',
      () {
    expect(
        () => RideMessage.fromJson({
              'rideId': 'r1',
              'sender': 'driver',
              'text': {'private': true},
            }),
        throwsFormatException);
  });

  testWidgets(
      'typing ignores self, unrelated rides and string booleans, then expires',
      (tester) async {
    final store = MapStore(chatService: chat, rideNotice: (_) {});
    store.currentRide = RideRequest.fromJson({
      'ride': {'id': 'r1', 'status': 'accepted'}
    });
    store.receiveTyping({'rideId': 'r1', 'by': 'driver', 'typing': true});
    expect(store.isTyping, true);
    store.receiveTyping({'rideId': 'r1', 'by': 'passenger', 'typing': false});
    expect(store.isTyping, true,
        reason: 'Self echo cannot clear counterparty typing');
    store.receiveTyping({'rideId': 'r2', 'by': 'driver', 'typing': false});
    expect(store.isTyping, true);
    await tester.pump(const Duration(seconds: 5));
    expect(store.isTyping, false);
    store.receiveTyping({'rideId': 'r1', 'by': 'driver', 'typing': 'true'});
    expect(store.isTyping, false);
    store.dispose();
  });

  test('store requires confirmation and merges socket echo by ID', () async {
    final store = MapStore(chatService: chat, rideNotice: (_) {});
    store.currentRide = RideRequest.fromJson({
      'ride': {'id': 'r1', 'status': 'accepted'}
    });
    expect(await store.sendMessage(rideId: 'r1', message: 'Here'), true);
    store.receiveChatMessage(store.chatMessages.single);
    expect(store.chatMessages, hasLength(1));
    respond = (_) async => throw StateError('offline');
    expect(await store.sendMessage(rideId: 'r1', message: 'Again'), false);
    expect(store.chatMessages, hasLength(1));
    store.dispose();
  });

  testWidgets(
      'composer preserves failed draft and clears only confirmed send at large text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var confirmed = false;
    await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(2)),
      child: Scaffold(
          body: RideChatComposer(
        rideId: 'r1',
        chat: chat,
        foreground: Colors.black,
        typing: (_) {},
        send: (_) async => confirmed,
      )),
    )));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Meet at the entrance');
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();
    expect(find.text('Meet at the entrance'), findsOneWidget);
    confirmed = true;
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();
    expect(find.text('Meet at the entrance'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  for (final width in [320.0, 1000.0]) {
    testWidgets('complete chat screen fits at width $width with large text',
        (tester) async {
      tester.view.physicalSize = Size(width, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final fonts = FontLoader('Poppins')
        ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'));
      await fonts.load();
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
      respond =
          (_) async => {'rideId': 'r1', 'messages': [], 'nextCursor': null};
      final store = MapStore(chatService: chat, rideNotice: (_) {});
      final ride = RideRequest.fromJson({
        'ride': {'id': 'r1', 'status': 'accepted'},
        'driverName': 'Alexandria Long Participant Name',
        'passengerName': 'Alexandria Long Participant Name',
      });
      store.currentRide = ride;
      await tester.pumpWidget(Provider<MapStore>.value(
          value: store,
          child: MaterialApp(
            navigatorKey: NavigationService.navigatorKey,
            theme: RidzsTheme.refine(ThemeData(
                useMaterial3: true,
                colorScheme: flexSchemeLight,
                fontFamily: 'Poppins')),
            home: Builder(builder: (context) {
              SizeConfig().init(context);
              return MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(2)),
                  child: Scaffold(
                      body: RepaintBoundary(
                          key: const Key('chat-screen'),
                          child: RideChatBottomSheet(rideRequest: ride))));
            }),
          )));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Refresh chat'), findsOneWidget);
      expect(find.byTooltip('Ride safety'), findsOneWidget);
      if (width == 1000) {
        respond = (_) async => {
              'rideId': 'r1',
              'nextCursor': null,
              'messages': [
                {
                  'id': 'recovered',
                  'rideId': 'r1',
                  'sender': 'driver',
                  'text': 'Recovered without a socket event',
                  'timestamp': 1700000000000,
                  'orderKey': '1700000000000000000000000000000000001',
                }
              ],
            };
        final initialReads = requests.length;
        await tester.pump(const Duration(seconds: 10));
        await tester.pumpAndSettle();
        expect(requests.length, greaterThan(initialReads));
        expect(store.chatMessages.single.id, 'recovered');
        expect(find.text('Recovered without a socket event'), findsOneWidget);
        tester.binding
            .handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pump();
        final pausedReads = requests.length;
        await tester.pump(const Duration(seconds: 30));
        expect(requests.length, pausedReads);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
        tester.binding
            .handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        tester.binding
            .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await tester.pump();
        await tester.pump(const Duration(seconds: 10));
        await tester.pumpAndSettle();
        expect(requests.length, greaterThan(pausedReads));
        unawaited(NavigationService.navigatorKey.currentState!.push(
            MaterialPageRoute<void>(
                builder: (_) => const Scaffold(body: Text('Other screen')))));
        await tester.pumpAndSettle();
        final hiddenReads = requests.length;
        await tester.pump(const Duration(seconds: 30));
        expect(requests.length, hiddenReads);
        NavigationService.navigatorKey.currentState!.pop();
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 10));
        await tester.pumpAndSettle();
        expect(requests.length, greaterThan(hiddenReads));
      }
      await tester.enterText(
          find.byType(TextField), 'Meet at the main entrance');
      await tester.pump();
      expect(tester.takeException(), isNull);
      if (width == 320) {
        await expectLater(find.byKey(const Key('chat-screen')),
            matchesGoldenFile('goldens/chat_large_text.png'));
        final recoveredText =
            List.filled(12, 'Recovered message text').join(' ');
        respond = (_) async => {
              'rideId': 'r1',
              'nextCursor': null,
              'messages': [
                {
                  'id': 'mobile-recovered',
                  'rideId': 'r1',
                  'sender': 'driver',
                  'text': recoveredText,
                  'timestamp': 1700000000000,
                  'orderKey': '1700000000000000000000000000000000001',
                }
              ],
            };
        await tester.pump(const Duration(seconds: 10));
        await tester.pumpAndSettle();
        expect(store.chatMessages.single.id, 'mobile-recovered');
        expect(find.text(recoveredText), findsOneWidget);
        expect(tester.takeException(), isNull);
        final rect = tester.getRect(find.text(recoveredText));
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(width));
      }
      await tester.pumpWidget(const SizedBox());
      final disposedReads = requests.length;
      await tester.pump(const Duration(seconds: 30));
      expect(requests.length, disposedReads);
      store.dispose();
    });
  }
}
