import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/core/configs/app_config.dart';
import 'package:ridzs_passenger_app/core/services/dio_service.dart';
import 'package:ridzs_passenger_app/services/ride_service.dart';

class TestAdapter implements HttpClientAdapter {
  TestAdapter(this.respond);
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
  setUp(() {
    AppConfig.baseUrl = 'https://example.test';
    dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  });
  tearDown(() => dio.close(force: true));

  test('search retry cannot be sent with a replacement account token',
      () async {
    dio.interceptors
        .add(AuthInterceptor(dio, tokenReader: () async => 'account-b'));
    var calls = 0;
    dio.httpClientAdapter = TestAdapter((_) async {
      calls++;
      return ResponseBody.fromString('{}', 200);
    });
    await expectLater(
        RideService.withClient(dio)
            .retrySearch('ride-a', 5, expectedAuthToken: 'account-a'),
        throwsA(isA<DioException>()
            .having((error) => error.type, 'type', DioExceptionType.cancel)));
    expect(calls, 0);
  });

  test('logout during token read never sends request using the next account',
      () async {
    final entered = Completer<void>();
    final release = Completer<String?>();
    var calls = 0;
    final auth = AuthInterceptor(dio, tokenReader: () {
      entered.complete();
      return release.future;
    });
    dio.interceptors.add(auth);
    dio.httpClientAdapter = TestAdapter((_) async {
      calls++;
      return ResponseBody.fromString('{}', 200);
    });
    final request = dio.get('/rides/current');
    final rejected = expectLater(
        request,
        throwsA(isA<DioException>()
            .having((error) => error.type, 'type', DioExceptionType.cancel)));
    await entered.future;
    auth.endSession();
    release.complete('next-account');
    await rejected;
    expect(calls, 0);
  });

  for (final callerToken in [false, true]) {
    test('logout rejects late response including caller token=$callerToken',
        () async {
      final entered = Completer<void>();
      final release = Completer<void>();
      var token = 'old-account';
      final auth = AuthInterceptor(dio, tokenReader: () async => token);
      dio.interceptors.add(auth);
      var calls = 0;
      dio.httpClientAdapter = TestAdapter((options) async {
        if (++calls == 1) {
          expect(options.headers['Authorization'], 'Bearer old-account');
          entered.complete();
          await release.future;
        } else {
          expect(options.headers['Authorization'], 'Bearer new-account');
        }
        return ResponseBody.fromString('{}', 200, headers: {
          'content-type': ['application/json']
        });
      });
      final request = dio.get('/rides/current',
          cancelToken: callerToken ? CancelToken() : null);
      final rejected = expectLater(
          request,
          throwsA(isA<DioException>()
              .having((error) => error.type, 'type', DioExceptionType.cancel)));
      await entered.future;
      auth.endSession();
      token = 'new-account';
      release.complete();
      await rejected;
      final fresh = await dio.get('/rides/current');
      expect(fresh.statusCode, 200);
    });
  }
}
