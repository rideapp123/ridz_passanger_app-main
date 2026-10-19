import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/services/ride_chat_service.dart';
import 'package:ridzs_passenger_app/core/services/dio_service.dart';
import 'package:ridzs_passenger_app/view/home/widget/ride_chat_composer.dart';
import 'package:ridzs_passenger_app/stores/map/map_store.dart';
import 'package:ridzs_passenger_app/models/common/ride_response/ride_response.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);
  final Future<ResponseBody> Function(RequestOptions) respond;
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream,
          Future<void>? cancelFuture) =>
      respond(options);
  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;
  late RideChatService chat;
  late DateTime now;
  late List<RequestOptions> requests;
  late Map<String, Map<String, dynamic>> drafts;
  late Future<ResponseBody> Function(RequestOptions) respond;
  ResponseBody limited({String? retry = '3'}) => ResponseBody.fromString(
          jsonEncode({'success': false, 'code': 'CHAT_SEND_RATE_LIMITED'}), 429,
          headers: {
            'content-type': ['application/json'],
            if (retry != null) 'retry-after': [retry]
          });
  ResponseBody saved(RequestOptions request) => ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'data': {
              'id': 'saved',
              'rideId': 'r1',
              'sender': 'passenger',
              'clientMessageId': request.data['clientMessageId'],
              'text': request.data['message'],
              'timestamp': 1700000000000,
              'orderKey': '1700000000000000000000000000000000001',
            }
          }),
          200,
          headers: {
            'content-type': ['application/json']
          });

  setUp(() {
    now = DateTime.utc(2026, 9, 13);
    requests = [];
    drafts = {};
    dio = Dio(BaseOptions(baseUrl: 'https://example.test/passenger'));
    dio.interceptors
        .add(AuthInterceptor(dio, tokenReader: () async => 'test-token'));
    respond = (_) async => limited();
    dio.httpClientAdapter = _Adapter((request) async {
      requests.add(request);
      return respond(request);
    });
    chat = RideChatService(
        role: 'passenger',
        dio: dio,
        now: () => now,
        tokenReader: () async => 'test-token',
        readPending: (key) async => drafts[key],
        writePending: (key, value) async {
          drafts[key] = {...value};
        },
        removePending: (key) async {
          drafts.remove(key);
        });
  });
  tearDown(() {
    chat.reset();
    dio.close(force: true);
  });

  test('store retains visible messages and pagination on history 429',
      () async {
    final store = MapStore(chatService: chat, rideNotice: (_) {});
    addTearDown(store.dispose);
    store.currentRide = RideRequest.fromJson({
      'ride': {'id': 'r1', 'status': 'accepted'}
    });
    respond = (request) async => saved(request);
    expect(await store.sendMessage(rideId: 'r1', message: 'Here'), isTrue);
    const cursor = '1700000000000000000000000000000000001';
    respond = (_) async => ResponseBody.fromString(
            jsonEncode({
              'success': true,
              'data': {'rideId': 'r1', 'messages': [], 'nextCursor': cursor}
            }),
            200,
            headers: {
              'content-type': ['application/json']
            });
    await store.loadChatMessage(rideId: 'r1');
    respond = (_) async => limited();
    await store.loadChatMessage(rideId: 'r1', older: true);
    expect(store.chatMessages.single.message, 'Here');
    expect(chat.nextCursor.value, cursor);
    expect(chat.historyError.value, 'Chat history is busy. Try again in 3s.');
    expect(store.isLoadingChatMessage, isFalse);
    final count = requests.length;
    await store.loadChatMessage(rideId: 'r1', older: true);
    expect(requests, hasLength(count));
    expect(store.chatMessages.single.message, 'Here');
  });

  testWidgets('history error fits large text and retries the earlier page',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 750);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    chat.historyError.value = 'Chat history is busy. Try again in 60s.';
    chat.nextCursor.value = '1700000000000000000000000000000000001';
    var refreshed = 0, older = 0;
    await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
            data: const MediaQueryData(
                size: Size(320, 750), textScaler: TextScaler.linear(2)),
            child: Scaffold(
                body: RideChatHistoryStatus(
                    chat: chat,
                    loading: false,
                    reload: () {
                      refreshed++;
                    },
                    older: () {
                      older++;
                    },
                    foreground: Colors.black)))));
    expect(
        find.text('Chat history is busy. Try again in 60s.'), findsOneWidget);
    await tester.tap(find.byTooltip('Retry earlier messages'));
    expect(older, 1);
    expect(refreshed, 0);
    await tester.tap(find.byTooltip('Refresh chat'));
    expect(refreshed, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test(
      'real auth interceptor retains 429; cooldown preserves the original draft',
      () async {
    expect(await chat.send('r1', 'Here'), isNull);
    expect(chat.retryAfterSeconds.value, 3);
    expect(drafts.values.single['message'], 'Here');
    expect(await chat.send('r1', 'Here'), isNull);
    expect(await chat.send('r2', 'Different ride'), isNull);
    expect(requests, hasLength(1));
  });

  test('typing is coalesced but stop, heartbeat and a new ride are allowed',
      () {
    expect(chat.shouldSendTyping('r1', false), isFalse);
    expect(chat.shouldSendTyping('r1', true), isTrue);
    expect(chat.shouldSendTyping('r1', true), isFalse);
    now = now.add(const Duration(seconds: 2));
    expect(chat.shouldSendTyping('r1', true), isTrue);
    expect(chat.shouldSendTyping('r2', false), isFalse);
    expect(chat.shouldSendTyping('r1', false), isTrue);
    expect(chat.shouldSendTyping('r1', false), isFalse);
    expect(chat.shouldSendTyping('r1', true), isTrue);
    expect(chat.shouldSendTyping('r2', true), isTrue);
    chat.reset();
    expect(chat.shouldSendTyping('r2', true), isTrue);
  });

  test('history cooldown preserves cursor and does not block sending or typing',
      () async {
    const cursor = '1700000000000000000000000000000000001';
    respond = (_) async => ResponseBody.fromString(
            jsonEncode({
              'success': true,
              'data': {'rideId': 'r1', 'messages': [], 'nextCursor': cursor}
            }),
            200,
            headers: {
              'content-type': ['application/json']
            });
    await chat.history('r1');
    respond = (_) async => limited();
    await expectLater(
        chat.history('r1', older: true),
        throwsA(isA<FormatException>()
            .having((e) => e.message, 'message', contains('3s'))));
    expect(chat.nextCursor.value, cursor);
    await expectLater(chat.history('r1', older: true), throwsFormatException);
    expect(requests, hasLength(2));
    expect(chat.retryAfterSeconds.value, 0);
    expect(chat.shouldSendTyping('r1', true), isTrue);
    respond = (request) async => saved(request);
    expect(await chat.send('r1', 'Here'), isNotNull);
    now = now.add(const Duration(seconds: 4));
    respond = (_) async => ResponseBody.fromString(
            jsonEncode({
              'success': true,
              'data': {'rideId': 'r1', 'messages': [], 'nextCursor': null}
            }),
            200,
            headers: {
              'content-type': ['application/json']
            });
    await chat.history('r1', older: true);
    expect(requests.last.queryParameters['before'], cursor);
    expect(chat.nextCursor.value, isNull);
  });

  test('send cooldown does not block reading history', () async {
    await chat.send('r1', 'Here');
    respond = (_) async => ResponseBody.fromString(
            jsonEncode({
              'success': true,
              'data': {'rideId': 'r1', 'messages': []}
            }),
            200,
            headers: {
              'content-type': ['application/json']
            });
    expect(await chat.history('r1'), isEmpty);
    expect(chat.retryAfterSeconds.value, 3);
    expect(drafts, hasLength(1));
  });

  for (final retry in [null, 'bad', '-1', '999999']) {
    test('history retry header $retry is bounded', () async {
      respond = (_) async => limited(retry: retry);
      await expectLater(chat.history('r1'), throwsFormatException);
      await expectLater(chat.history('r2'), throwsFormatException);
      expect(requests, hasLength(1));
      now = now.add(const Duration(seconds: 61));
      await expectLater(chat.history('r1'), throwsFormatException);
      expect(requests, hasLength(2));
    });
  }

  test('history 503 remains retryable without send cooldown', () async {
    respond = (_) async => ResponseBody.fromString('{}', 503, headers: {
          'content-type': ['application/json']
        });
    await expectLater(
        chat.history('r1'),
        throwsA(isA<FormatException>().having(
            (e) => e.message, 'message', contains('temporarily unavailable'))));
    expect(chat.retryAfterSeconds.value, 0);
    await expectLater(chat.history('r1'), throwsFormatException);
    expect(requests, hasLength(2));
  });

  test('logout ignores late history throttling and clears existing cooldown',
      () async {
    final entered = Completer<void>(), release = Completer<ResponseBody>();
    respond = (_) {
      entered.complete();
      return release.future;
    };
    final reading = chat.history('r1');
    final rejected = expectLater(reading, throwsA(isA<DioException>()));
    await entered.future;
    chat.reset();
    release.complete(limited());
    await rejected;
    respond = (_) async => limited();
    await expectLater(chat.history('r1'), throwsFormatException);
    expect(requests, hasLength(2));
    chat.reset();
    await expectLater(chat.history('r1'), throwsFormatException);
    expect(requests, hasLength(3));
  });

  test(
      'after cooldown retry uses identical command and clears only confirmed draft',
      () async {
    await chat.send('r1', 'Here');
    final original = Map<String, dynamic>.from(requests.single.data);
    now = now.add(const Duration(seconds: 4));
    respond = (request) async => saved(request);
    expect(await chat.send('r1', 'Here'), isNotNull);
    expect(requests.last.data, original);
    expect(chat.retryAfterSeconds.value, 0);
    expect(drafts, isEmpty);
  });

  for (final entry in <String?, int>{
    'nonsense': 60,
    '-10': 1,
    '99999999': 60,
    null: 60
  }.entries) {
    test('retry header ${entry.key} is bounded to ${entry.value}', () async {
      respond = (_) async => limited(retry: entry.key);
      expect(await chat.send('r1', 'Here'), isNull);
      expect(chat.retryAfterSeconds.value, entry.value);
      expect(drafts, hasLength(1));
    });
  }

  test('multiple retry headers fall back without throwing or losing draft',
      () async {
    respond = (_) async => ResponseBody.fromString('{}', 429, headers: {
          'content-type': ['application/json'],
          'retry-after': ['3', '4']
        });
    expect(await chat.send('r1', 'Here'), isNull);
    expect(chat.retryAfterSeconds.value, 60);
    expect(drafts, hasLength(1));
  });

  test('503 retains draft and explains chat service is unavailable', () async {
    respond = (_) async => ResponseBody.fromString(
            jsonEncode(
                {'success': false, 'code': 'CHAT_RATE_LIMIT_UNAVAILABLE'}),
            503,
            headers: {
              'content-type': ['application/json']
            });
    expect(await chat.send('r1', 'Here'), isNull);
    expect(chat.sendError.value, contains('Chat temporarily unavailable'));
    expect(chat.retryAfterSeconds.value, 0);
    expect(drafts, hasLength(1));
  });

  test('logout cancels countdown and ignores late rate-limit response',
      () async {
    final entered = Completer<void>(), release = Completer<ResponseBody>();
    respond = (_) {
      entered.complete();
      return release.future;
    };
    final sending = chat.send('r1', 'Here');
    await entered.future;
    chat.reset();
    release.complete(limited());
    expect(await sending, isNull);
    expect(chat.retryAfterSeconds.value, 0);
    expect(chat.sendError.value, isNull);
  });

  testWidgets('compact large-text composer counts down without losing input',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 750);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
            data: const MediaQueryData(
                size: Size(320, 750), textScaler: TextScaler.linear(2)),
            child: Scaffold(
                body: Align(
                    alignment: Alignment.bottomCenter,
                    child: RideChatComposer(
                        rideId: 'r1',
                        chat: chat,
                        foreground: Colors.black,
                        typing: (_) {},
                        send: (text) async =>
                            await chat.send('r1', text) != null))))));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Here');
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();
    expect(find.text('Try again in 3s. Your draft is saved.'), findsOneWidget);
    expect(
        tester
            .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.send))
            .onPressed,
        isNull);
    expect(find.text('Here'), findsOneWidget);
    now = now.add(const Duration(seconds: 4));
    await tester.pump(const Duration(seconds: 4));
    expect(chat.retryAfterSeconds.value, 0);
    expect(
        tester
            .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.send))
            .onPressed,
        isNotNull);
    respond = (request) async => saved(request);
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();
    expect(find.text('Here'), findsNothing);
    expect(drafts, isEmpty);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
