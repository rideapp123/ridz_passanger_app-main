import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/models/common/ride_response/ride_response.dart';
import 'package:ridzs_passenger_app/services/booking_attempt.dart';
import 'package:ridzs_passenger_app/services/ride_service.dart';
import 'package:ridzs_passenger_app/stores/map/map_store.dart';
import 'package:ridzs_passenger_app/view/home/widget/booking_status_panel.dart';

RideRequest snapshot(String status, int version,
        {String? dispatch, String payment = 'authorized'}) =>
    RideRequest.fromJson({
      'ride': {
        'id': 'r1',
        'status': status,
        'version': version,
        'payment': {'method': 'wallet', 'status': payment},
        if (dispatch != null) 'dispatch': {'state': dispatch}
      }
    });

class BookingStore extends MapStore {
  BookingStore(Dio dio,
      {void Function(String)? notice, Future<String?> Function()? tokenReader})
      : super(
            rideService: RideService.withClient(dio),
            recoveryDio: dio,
            sessionTokenReader: tokenReader ?? () async => 'account-a',
            rideNotice: notice ?? (_) {});
  @override
  Future<void> resumeRideResources() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Dio dio;
  late RideService service;
  late Map<String, Map<String, dynamic>> storage;
  late List<RequestOptions> requests;
  late Future<Map<String, dynamic>> Function(RequestOptions) respond;
  const payload = {
    'vehicleType': 'economy',
    'paymentMethod': 'card',
    'cardId': 'card-1'
  };
  BookingAttempt attempt({String token = 'account-a'}) => BookingAttempt(
      service: service,
      tokenReader: () async => token,
      read: (key) async => storage[key],
      write: (key, value) async {
        storage[key] = jsonDecode(jsonEncode(value));
      },
      remove: (key) async {
        storage.remove(key);
      });

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    storage = {};
    requests = [];
    dio = Dio(BaseOptions(baseUrl: 'https://example.test/passenger'));
    service = RideService.withClient(dio);
    respond = (_) async => snapshot('searching', 2).toJson();
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      requests.add(options);
      try {
        final data = await respond(options);
        handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {'success': true, 'data': data}));
      } on DioException catch (error) {
        handler.reject(error);
      }
    }));
  });
  tearDown(() => dio.close(force: true));

  test(
      'request and key are durably saved before POST, without a preliminary charge',
      () async {
    final booking = attempt();
    respond = (request) async {
      expect(storage, hasLength(1));
      expect(storage.values.single['key'], request.headers['Idempotency-Key']);
      expect(request.data, payload);
      return snapshot('requested', 1).toJson();
    };
    await booking.submit(payload);
    expect(requests.map((e) => e.path), ['/rides']);
    expect(booking.pending.value, false);
    expect(storage, isEmpty);
  });

  test('timeout and restart replay identical key and payload', () async {
    var booking = attempt();
    respond = (request) async => throw DioException(
        requestOptions: request, type: DioExceptionType.receiveTimeout);
    await expectLater(booking.submit(payload), throwsA(isA<DioException>()));
    final first = requests.single;
    expect(booking.pending.value, true);
    booking.dispose();
    booking = attempt();
    await booking.restore();
    expect(booking.pending.value, true);
    respond = (_) async => snapshot('accepted', 3).toJson();
    await booking.submit({'vehicleType': 'different'});
    expect(requests.last.headers['Idempotency-Key'],
        first.headers['Idempotency-Key']);
    expect(requests.last.data, payload);
    expect(storage, isEmpty);
  });

  test('failed secure write sends no booking', () async {
    final booking = BookingAttempt(
        service: service,
        tokenReader: () async => 'a',
        read: (_) async => null,
        write: (_, __) async => throw StateError('storage unavailable'));
    await expectLater(booking.submit(payload), throwsStateError);
    expect(requests, isEmpty);
  });

  test('backend unconfirmed booking survives restart with its original intent',
      () async {
    var booking = attempt();
    respond = (request) async => throw DioException(
        requestOptions: request,
        response: Response(
            requestOptions: request,
            statusCode: 409,
            data: {'code': 'BOOKING_UNCONFIRMED'}));
    await expectLater(booking.submit(payload), throwsA(isA<DioException>()));
    final firstKey = requests.single.headers['Idempotency-Key'];
    expect(booking.pending.value, true);
    expect(storage, hasLength(1));
    booking.dispose();
    booking = attempt();
    await booking.restore();
    await expectLater(booking.submit({'paymentMethod': 'wallet'}),
        throwsA(isA<DioException>()));
    expect(requests.last.headers['Idempotency-Key'], firstKey);
    expect(requests.last.data, payload);
    expect(booking.pending.value, true);
    expect(storage, hasLength(1));
    respond = (_) async => snapshot('searching', 2).toJson();
    await booking.submit();
    expect(requests.last.headers['Idempotency-Key'], firstKey);
    expect(storage, isEmpty);
  });

  test('submit waits for in-flight restore and reuses the saved request',
      () async {
    final entered = Completer<void>();
    final release = Completer<Map<String, dynamic>?>();
    var reads = 0;
    final booking = BookingAttempt(
        service: service,
        tokenReader: () async => 'account-a',
        read: (_) {
          reads++;
          entered.complete();
          return release.future;
        },
        write: (_, __) async {},
        remove: (_) async {});
    final restoring = booking.restore();
    await entered.future;
    final submitting = booking.submit({'vehicleType': 'changed'});
    expect(requests, isEmpty);
    release.complete({'key': 'original-key', 'payload': payload});
    await restoring;
    await submitting;
    expect(reads, 1);
    expect(requests.single.headers['Idempotency-Key'], 'original-key');
    expect(requests.single.data, payload);
  });

  test('malformed acknowledgement retains pending attempt', () async {
    final booking = attempt();
    respond = (_) async => {
          'ride': {'id': 'r1', 'status': 'unknown'}
        };
    await expectLater(booking.submit(payload), throwsFormatException);
    expect(booking.pending.value, true);
    expect(storage, hasLength(1));
  });

  test('only explicit backend rejection permits a fresh booking', () async {
    final booking = attempt();
    respond = (request) async => throw DioException(
        requestOptions: request,
        response: Response(
            requestOptions: request,
            statusCode: 400,
            data: {'code': 'BOOKING_REJECTED'}));
    await expectLater(booking.submit(payload), throwsA(isA<DioException>()));
    expect(booking.pending.value, false);
    expect(storage, isEmpty);
    final oldKey = requests.single.headers['Idempotency-Key'];
    respond = (_) async => snapshot('requested', 1).toJson();
    await booking.submit(payload);
    expect(requests.last.headers['Idempotency-Key'], isNot(oldKey));
  });

  test('lost rejection response keeps original intent until verified retry',
      () async {
    var booking = attempt();
    respond = (request) async => throw DioException(
        requestOptions: request, type: DioExceptionType.receiveTimeout);
    await expectLater(booking.submit(payload), throwsA(isA<DioException>()));
    final originalKey = requests.single.headers['Idempotency-Key'];
    booking.dispose();
    booking = attempt();
    await booking.restore();
    expect(booking.pending.value, true);
    const corrected = {
      'vehicleType': 'economy',
      'paymentMethod': 'card',
      'cardId': 'pm_corrected'
    };
    respond = (request) async => throw DioException(
        requestOptions: request,
        response: Response(
            requestOptions: request,
            statusCode: 422,
            data: {'code': 'BOOKING_REJECTED'}));
    await expectLater(booking.submit(corrected), throwsA(isA<DioException>()));
    expect(requests.last.headers['Idempotency-Key'], originalKey);
    expect(requests.last.data, payload);
    expect(booking.pending.value, false);
    expect(booking.error.value,
        'Booking was not placed. Review your trip and payment method.');
    expect(storage, isEmpty);
    respond = (_) async => snapshot('requested', 1).toJson();
    await booking.submit(corrected);
    expect(requests.last.headers['Idempotency-Key'], isNot(originalKey));
    expect(requests.last.data, corrected);
    booking.dispose();
  });

  test(
      'restored rejected ride closes display but does not discard retry intent',
      () async {
    final notices = <String>[];
    final store = BookingStore(dio, notice: notices.add);
    addTearDown(store.dispose);
    respond = (request) async => throw DioException(requestOptions: request);
    expect(await store.submitBooking(payload), false);
    final originalKey = requests.single.headers['Idempotency-Key'];
    store.applyRideUpdate(snapshot('cancelled', 2, payment: 'rejected'),
        allowNewRide: true, fromRecovery: true);
    expect(store.currentRide, isNull);
    expect(store.booking.pending.value, true);
    expect(notices, ['Booking was not placed. Review your payment method.']);
    respond = (request) async => throw DioException(
        requestOptions: request,
        response: Response(
            requestOptions: request,
            statusCode: 422,
            data: {'code': 'BOOKING_REJECTED'}));
    await store.retryBookingConfirmation();
    expect(requests.last.headers['Idempotency-Key'], originalKey);
    expect(store.booking.pending.value, false);
  });

  test('another session does not inherit a pending booking', () async {
    final first = attempt();
    respond = (request) async => throw DioException(requestOptions: request);
    await expectLater(first.submit(payload), throwsA(isA<DioException>()));
    final next = attempt(token: 'account-b');
    await next.restore();
    expect(next.pending.value, false);
  });

  test(
      'duplicate taps produce one booking and a late response cannot undo acceptance',
      () async {
    final store = BookingStore(dio);
    addTearDown(store.dispose);
    final entered = Completer<void>(), release = Completer<void>();
    respond = (_) async {
      entered.complete();
      await release.future;
      return snapshot('requested', 1).toJson();
    };
    final first = store.submitBooking(payload);
    await entered.future;
    expect(await store.submitBooking(payload), false);
    store.applyRideUpdate(snapshot('accepted', 3), allowNewRide: true);
    release.complete();
    expect(await first, true);
    expect(store.currentRide!.ride!.status!.title, 'accepted');
    expect(store.isCreatingRide, false);
    expect(requests, hasLength(1));
  });

  test('cancel arriving before the booking response cannot resurrect searching',
      () async {
    final store = BookingStore(dio);
    addTearDown(store.dispose);
    final entered = Completer<void>(), release = Completer<void>();
    respond = (_) async {
      entered.complete();
      await release.future;
      return snapshot('requested', 1).toJson();
    };
    final first = store.submitBooking(payload);
    await entered.future;
    store.applyRideUpdate(snapshot('cancelled', 3), allowNewRide: true);
    release.complete();
    expect(await first, false);
    expect(store.currentRide, isNull);
    expect(store.isCreatingRide, false);
  });

  test(
      'recovery restores pending booking when current ride is explicitly empty',
      () async {
    final first = BookingStore(dio);
    respond = (request) async => throw DioException(requestOptions: request);
    expect(await first.submitBooking(payload), false);
    first.dispose();
    final restarted = BookingStore(dio);
    addTearDown(restarted.dispose);
    respond = (_) async => {'hasActiveRide': false};
    restarted.recovery.activate();
    await restarted.recovery.refresh();
    expect(restarted.recovery.ready.value, true);
    expect(restarted.booking.pending.value, true);
    expect(restarted.currentRide, isNull);
  });

  for (final status in ['requested', 'searching']) {
    test('$status with unresolved payment cannot cancel or restart search',
        () async {
      final store = BookingStore(dio);
      addTearDown(store.dispose);
      store.applyRideUpdate(
          snapshot(status, 1, payment: 'pending', dispatch: 'exhausted'),
          allowNewRide: true);
      expect(store.bookingConfirmationPending, true);
      expect(store.noDriversFound, false);
      await store.cancelRide('Changed plans');
      await store.retryDriverSearch();
      expect(await store.submitBooking(payload), false);
      expect(requests, isEmpty);
      store.applyRideUpdate(snapshot(status, 2));
      expect(store.bookingConfirmationPending, false);
    });

    test('$status shows searching, exhausted search stays cancellable', () {
      final store = BookingStore(dio);
      addTearDown(store.dispose);
      store.applyRideUpdate(snapshot(status, 1), allowNewRide: true);
      expect(store.isCreatingRide, true);
      expect(store.isRideAccepted, false);
      store.applyRideUpdate(snapshot('searching', 2, dispatch: 'exhausted'));
      expect(store.noDriversFound, true);
      store.applyRideUpdate(snapshot('accepted', 3));
      expect(store.noDriversFound, false);
      expect(store.isCreatingRide, false);
    });
  }

  test(
      'restored unresolved ride retries the saved key instead of a new booking',
      () async {
    final store = BookingStore(dio);
    addTearDown(store.dispose);
    respond = (request) async => throw DioException(requestOptions: request);
    expect(await store.submitBooking(payload), false);
    final originalKey = requests.single.headers['Idempotency-Key'];
    store.applyRideUpdate(snapshot('requested', 1, payment: 'pending'),
        allowNewRide: true, fromRecovery: true);
    await store.retryBookingConfirmation();
    expect(store.bookingConfirmationPending, true);
    expect(store.booking.pending.value, true);
    expect(requests.last.headers['Idempotency-Key'], originalKey);
    expect(requests.last.data, payload);
    respond = (_) async => snapshot('searching', 2).toJson();
    await store.retryBookingConfirmation();
    expect(store.bookingConfirmationPending, false);
    expect(store.booking.pending.value, false);
    expect(requests.last.headers['Idempotency-Key'], originalKey);
  });

  test('unresolved ride without saved intent only refreshes server state',
      () async {
    final store = BookingStore(dio);
    addTearDown(store.dispose);
    store.applyRideUpdate(snapshot('requested', 1, payment: 'pending'),
        allowNewRide: true, fromRecovery: true);
    respond = (request) async {
      expect(request.method, 'GET');
      expect(request.path, '/rides/current');
      return {
        'hasActiveRide': true,
        ...snapshot('requested', 1, payment: 'pending').toJson()
      };
    };
    store.recovery.activate();
    await store.retryBookingConfirmation();
    expect(requests, hasLength(1));
    expect(store.bookingConfirmationPending, true);
    expect(store.booking.pending.value, false);
  });

  test('search again uses the existing ride and revision, never a new booking',
      () async {
    final store = BookingStore(dio);
    addTearDown(store.dispose);
    store.applyRideUpdate(snapshot('searching', 5, dispatch: 'exhausted'),
        allowNewRide: true);
    respond = (request) async {
      expect(request.path, '/rides/r1/search');
      expect(request.data, {'version': 5});
      expect(request.extra['expectedAuthToken'], 'account-a');
      return snapshot('searching', 7, dispatch: 'searching').toJson();
    };
    await store.retryDriverSearch();
    expect(store.currentRide!.ride!.sId, 'r1');
    expect(store.noDriversFound, false);
    expect(requests, hasLength(1));
  });

  for (final code in [
    'BOOKING_SEARCH_RECOVERY_REQUIRED',
    'RIDE_CONFLICT',
    'SEARCH_RETRY_NOT_CONFIRMED'
  ]) {
    test(
        'search conflict $code keeps the ride and shows the correct recovery message',
        () async {
      final store = BookingStore(dio);
      addTearDown(store.dispose);
      store.applyRideUpdate(snapshot('searching', 5, dispatch: 'exhausted'),
          allowNewRide: true);
      respond = (request) async => throw DioException(
          requestOptions: request,
          response: Response(
              requestOptions: request,
              statusCode: 409,
              data: {'success': false, 'code': code}));
      await store.retryDriverSearch();
      expect(store.currentRide?.ride?.sId, 'r1');
      expect(store.currentRide?.ride?.version, 5);
      expect(store.noDriversFound, true);
      expect(store.searchBusy.value, false);
      expect(requests.map((request) => request.path), ['/rides/r1/search']);
      expect(
          store.error,
          code == 'BOOKING_SEARCH_RECOVERY_REQUIRED'
              ? 'This search cannot be restarted automatically. Refresh the ride or contact support.'
              : 'Search could not be refreshed. Please retry.');
    });
  }

  test('unchanged authoritative retry response keeps no-drivers visible',
      () async {
    final store = BookingStore(dio);
    addTearDown(store.dispose);
    store.applyRideUpdate(snapshot('searching', 5, dispatch: 'exhausted'),
        allowNewRide: true);
    respond =
        (_) async => snapshot('searching', 5, dispatch: 'exhausted').toJson();
    await store.retryDriverSearch();
    expect(store.noDriversFound, true);
    expect(store.searchBusy.value, false);
    expect(requests, hasLength(1));
  });

  for (final change in ['logout', 'ride', 'revision']) {
    test('search does not POST after $change during token read', () async {
      final token = Completer<String?>();
      final store = BookingStore(dio, tokenReader: () => token.future);
      addTearDown(store.dispose);
      store.applyRideUpdate(snapshot('searching', 5, dispatch: 'exhausted'),
          allowNewRide: true);
      final pending = store.retryDriverSearch();
      if (change == 'logout') {
        store.dispose();
      } else if (change == 'ride') {
        store.currentRide = null;
        store.applyRideUpdate(
            RideRequest.fromJson({
              'ride': {'id': 'r2', 'status': 'searching', 'version': 1}
            }),
            allowNewRide: true);
      } else {
        store.applyRideUpdate(snapshot('searching', 6, dispatch: 'searching'));
      }
      token.complete('account-a');
      await pending;
      expect(requests, isEmpty);
      expect(store.searchBusy.value, false);
      expect(store.error, isNull);
    });
  }

  for (final fails in [false, true]) {
    for (final logout in [false, true]) {
      test(
          'late search result (error=$fails, logout=$logout) cannot alter another ride/session',
          () async {
        final store = BookingStore(dio);
        addTearDown(store.dispose);
        store.applyRideUpdate(snapshot('searching', 5, dispatch: 'exhausted'),
            allowNewRide: true);
        final entered = Completer<void>();
        final release = Completer<void>();
        respond = (request) async {
          entered.complete();
          await release.future;
          if (fails) throw DioException(requestOptions: request);
          return snapshot('searching', 7, dispatch: 'searching').toJson();
        };
        final pending = store.retryDriverSearch();
        await entered.future;
        await store.retryDriverSearch();
        expect(requests, hasLength(1));
        if (logout) store.dispose();
        store.currentRide = null;
        store.applyRideUpdate(
            RideRequest.fromJson({
              'ride': {
                'id': 'r2',
                'status': 'searching',
                'version': 1,
                'dispatch': {'state': 'exhausted'},
                'payment': {'status': 'authorized'}
              }
            }),
            allowNewRide: true);
        release.complete();
        await pending;
        expect(store.currentRide?.ride?.sId, 'r2');
        expect(store.currentRide?.ride?.version, 1);
        expect(store.noDriversFound, true);
        expect(store.error, isNull);
        expect(store.searchBusy.value, false);
      });
    }
  }

  test('search without a signed-in token sends no request', () async {
    final store = BookingStore(dio, tokenReader: () async => null);
    addTearDown(store.dispose);
    store.applyRideUpdate(snapshot('searching', 5, dispatch: 'exhausted'),
        allowNewRide: true);
    await store.retryDriverSearch();
    expect(requests, isEmpty);
    expect(store.noDriversFound, true);
    expect(store.searchBusy.value, false);
    expect(store.error, isNotNull);
  });

  for (final state in BookingView.values) {
    testWidgets('$state has usable controls on compact large-text screen',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var retries = 0, cancellations = 0;
      final cancellable =
          state == BookingView.searching || state == BookingView.exhausted;
      await tester.pumpWidget(MaterialApp(
          home: MediaQuery(
              data: const MediaQueryData(
                  size: Size(320, 640), textScaler: TextScaler.linear(2)),
              child: Scaffold(
                  body: Align(
                      alignment: Alignment.bottomCenter,
                      child: BookingStatusPanel(
                        state: state,
                        onRetry: () {
                          retries++;
                        },
                        onCancel: cancellable
                            ? () {
                                cancellations++;
                              }
                            : null,
                      ))))));
      await tester.pump();
      if (state == BookingView.exhausted || state == BookingView.unconfirmed) {
        await tester.tap(find.byType(FilledButton));
        expect(retries, 1);
      }
      if (cancellable) {
        await tester.tap(find.text('Cancel request'));
        expect(cancellations, 1);
      } else {
        expect(find.text('Cancel request'), findsNothing);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
