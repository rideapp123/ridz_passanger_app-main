import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/services/ride_chat_service.dart';
import 'package:ridzs_passenger_app/models/chat/chat_message_model.dart';

void main() {
  late Dio dio;
  late RideChatService chat;
  late DateTime now;
  late String token;
  late List<RequestOptions> requests;
  late List<RideMessage> recovered;
  late Future<Response<dynamic>> Function(RequestOptions) respond;

  String key(int n) => '1700000000000${n.toRadixString(16).padLeft(24, '0')}';
  Map<String, dynamic> row(int n, {String ride = 'r1', String text = 'Here'}) =>
      {
        'id': 'm$n',
        'rideId': ride,
        'sender': 'passenger',
        'text': text,
        'timestamp': 1700000000000,
        'orderKey': key(n),
      };
  Response<dynamic> page(List<Map<String, dynamic>> rows,
          {String ride = 'r1', String? cursor}) =>
      raw({'rideId': ride, 'messages': rows, 'nextCursor': cursor});

  setUp(() {
    now = DateTime.utc(2026, 9, 26);
    token = 'session-a';
    requests = [];
    recovered = [];
    dio = Dio(BaseOptions(baseUrl: 'https://example.test/passenger'));
    respond = (_) async => page([]);
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (request, handler) async {
      requests.add(request);
      final response = await respond(request);
      if ((response.statusCode ?? 500) >= 400) {
        handler.reject(DioException(
            requestOptions: request,
            response: response,
            type: DioExceptionType.badResponse));
      } else {
        handler.resolve(Response(
            requestOptions: request, statusCode: 200, data: response.data));
      }
    }));
    chat = RideChatService(
        role: 'passenger',
        dio: dio,
        now: () => now,
        tokenReader: () async => token);
  });

  tearDown(() {
    chat.reset();
    dio.close(force: true);
  });

  void recoveryTest(String name, Future<void> Function(WidgetTester) body) {
    testWidgets(name, (tester) async {
      try {
        await body(tester);
      } finally {
        chat.stopRecovery();
        await tester.pump();
      }
    });
  }

  void start([String ride = 'r1']) => chat.startRecovery(ride, (messages) {
        recovered = RideMessage.mergeHistory(recovered, messages, ride);
      });

  Future<void> advance(WidgetTester tester, int seconds) async {
    now = now.add(Duration(seconds: seconds));
    await tester.pump(Duration(seconds: seconds));
    for (var i = 0; i < 20; i++) {
      await tester.pump();
    }
  }

  recoveryTest(
      'sweeps more than 100 records, refreshes head, and repairs late inserts and changed text',
      (tester) async {
    final rows = List.generate(250, (i) => row((i + 1) * 10));
    respond = (request) async {
      final before = request.queryParameters['before'] as String?;
      final eligible = rows
          .where((r) =>
              before == null || (r['orderKey'] as String).compareTo(before) < 0)
          .toList()
        ..sort((a, b) =>
            (b['orderKey'] as String).compareTo(a['orderKey'] as String));
      final selected = eligible.take(100).toList();
      return page(selected,
          cursor: eligible.length > 100
              ? selected.last['orderKey'] as String
              : null);
    };
    await tester.runAsync(() => chat.history('r1'));
    final manualCursor = chat.nextCursor.value;
    start();
    await advance(tester, 10);
    expect(recovered, hasLength(100));
    await advance(tester, 10);
    expect(recovered, hasLength(200));
    await advance(tester, 10);
    expect(recovered, hasLength(250));
    rows.add(row(5, text: 'Late insert behind previous boundary'));
    rows.add(row(2510, text: 'New head'));
    rows[0] = row(10, text: '');
    await advance(tester, 10);
    expect(recovered.last.id, 'm2510');
    await advance(tester, 10);
    await advance(tester, 10);
    expect(recovered, hasLength(252));
    expect(recovered.first.id, 'm5');
    expect(recovered.firstWhere((r) => r.id == 'm10').message, '');
    expect(chat.nextCursor.value, manualCursor);
    expect(requests.every((r) => r.queryParameters['limit'] == 100), isTrue);
    expect(requests, hasLength(11)); // One manual read, then 1/2/2/1/2/2.
  });

  recoveryTest(
      'does not overlap a slow read and stop cancels and discards its response',
      (tester) async {
    final held = Completer<Response<dynamic>>();
    respond = (_) => held.future;
    start();
    await advance(tester, 10);
    await advance(tester, 60);
    expect(requests, hasLength(1));
    chat.stopRecovery();
    expect(requests.single.cancelToken!.isCancelled, isTrue);
    held.complete(page([row(1)]));
    await tester.pump();
    await advance(tester, 60);
    expect(recovered, isEmpty);
    expect(requests, hasLength(1));
    expect(chat.historyError.value, isNull);
  });

  recoveryTest(
      'reset suppresses late responses and new ride starts with a fresh sweep',
      (tester) async {
    final held = Completer<Response<dynamic>>();
    respond = (_) => held.future;
    start();
    await advance(tester, 10);
    chat.reset();
    token = 'session-b';
    respond = (_) async => page([row(2, ride: 'r2')], ride: 'r2');
    start('r2');
    await advance(tester, 10);
    held.complete(page([row(1)]));
    await tester.pump();
    expect(recovered.map((r) => r.rideId), ['r2']);
    expect(requests.last.queryParameters.containsKey('before'), isFalse);
  });

  recoveryTest('token changed during a read cannot apply its data',
      (tester) async {
    final held = Completer<Response<dynamic>>();
    respond = (_) => held.future;
    start();
    await advance(tester, 10);
    token = 'another-account';
    held.complete(page([row(1)]));
    await tester.pump();
    await advance(tester, 30);
    expect(recovered, isEmpty);
    expect(requests, hasLength(1));
  });

  recoveryTest(
      'manual reads have priority without cancelling their cursor update',
      (tester) async {
    final held = Completer<Response<dynamic>>();
    respond = (_) => held.future;
    final manual = chat.history('r1');
    await tester.pump();
    start();
    await advance(tester, 10);
    expect(requests, hasLength(1));
    held.complete(page([row(2)], cursor: key(2)));
    await advance(tester, 0);
    await manual;
    respond = (_) async => page([row(3)]);
    await advance(tester, 10);
    expect(recovered.single.id, 'm3');
    expect(chat.nextCursor.value, key(2));
  });

  recoveryTest(
      '429 cooldown is shared with manual history and success clears only its own error',
      (tester) async {
    respond = (_) async => failure(429, retry: '30');
    start();
    await advance(tester, 10);
    expect(chat.historyError.value, contains('Retrying'));
    await expectLater(chat.history('r1'), throwsFormatException);
    expect(requests, hasLength(1));
    await advance(tester, 20);
    expect(requests, hasLength(1));
    respond = (_) async => page([row(1)]);
    await advance(tester, 10);
    expect(recovered, hasLength(1));
    expect(chat.historyError.value, isNull);
  });

  recoveryTest('temporary failures back off and preserve a manual error',
      (tester) async {
    respond = (_) async => failure(503);
    start();
    await advance(tester, 10);
    await advance(tester, 10);
    expect(requests, hasLength(2));
    await advance(tester, 19);
    expect(requests, hasLength(2));
    await advance(tester, 1);
    expect(requests, hasLength(3));
    chat.historyError.value = 'Earlier page could not be loaded.';
    respond = (_) async => page([row(1)]);
    await advance(tester, 40);
    expect(recovered, hasLength(1));
    expect(chat.historyError.value, 'Earlier page could not be loaded.');
  });

  recoveryTest('covered route neither reads nor applies an in-flight page',
      (tester) async {
    var visible = false;
    final held = Completer<Response<dynamic>>();
    respond = (_) => held.future;
    chat.startRecovery('r1', (messages) => recovered.addAll(messages),
        canRead: () => visible);
    await advance(tester, 10);
    expect(requests, isEmpty);
    visible = true;
    await advance(tester, 10);
    expect(requests, hasLength(1));
    visible = false;
    held.complete(page([row(1)]));
    await advance(tester, 0);
    expect(recovered, isEmpty);
    respond = (_) async => page([row(2)]);
    visible = true;
    await advance(tester, 10);
    expect(recovered.single.id, 'm2');
  });

  for (final status in [401, 403, 404]) {
    recoveryTest('HTTP $status stops automatic recovery', (tester) async {
      respond = (_) async => failure(status);
      start();
      await advance(tester, 10);
      await advance(tester, 120);
      expect(requests, hasLength(1));
      expect(recovered, isEmpty);
    });
  }

  for (final invalid in [
    'wrong ride',
    'too many',
    'duplicate',
    'unordered',
    'bad key',
    'missing id',
    'wrong record ride',
    'bad cursor',
    'empty cursor page'
  ]) {
    recoveryTest('rejects $invalid recovery page before merging',
        (tester) async {
      respond = (_) async => switch (invalid) {
            'wrong ride' => page([row(1)], ride: 'r2'),
            'too many' => page(List.generate(101, (i) => row(101 - i))),
            'duplicate' => page([row(1), row(1)]),
            'unordered' => page([row(1), row(2)]),
            'bad key' => page([
                {...row(1), 'orderKey': 'invalid'}
              ]),
            'missing id' => page([
                {...row(1), 'id': null}
              ]),
            'wrong record ride' => page([row(1, ride: 'r2')]),
            'bad cursor' => page([row(2)], cursor: key(1)),
            _ => page([], cursor: key(1)),
          };
      start();
      await advance(tester, 10);
      expect(recovered, isEmpty);
      expect(chat.historyError.value, contains('Retrying'));
    });
  }
}

Response<dynamic> raw(Map<String, dynamic> data) => Response(
    requestOptions: RequestOptions(path: '/chat/r1'),
    statusCode: 200,
    data: {'success': true, 'data': data});

Response<dynamic> failure(int status, {String? retry}) => Response(
    requestOptions: RequestOptions(path: '/chat/r1'),
    statusCode: status,
    headers: Headers.fromMap({
      if (retry != null) 'retry-after': [retry]
    }));
