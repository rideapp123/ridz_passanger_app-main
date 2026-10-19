import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/core/enums/ride.dart';
import 'package:ridzs_passenger_app/models/common/ride_response/ride_response.dart';
import 'package:ridzs_passenger_app/services/ride_service.dart';
import 'package:ridzs_passenger_app/stores/map/map_store.dart';

RideRequest snapshot(String status, int version, {String id = 'r1'}) =>
    RideRequest.fromJson({
      'ride': {
        'id': id,
        'status': status,
        'version': version,
        'cancellation': {'by': 'driver', 'reason': 'Vehicle issue'}
      }
    });

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MapStore store;
  late List<String> notices;
  setUp(() {
    notices = [];
    store = MapStore(rideNotice: notices.add);
  });
  tearDown(() => store.dispose());
  for (final status in [
    'requested',
    'searching',
    'accepted',
    'arrived',
    'started'
  ]) {
    test('cancellation clears $status state and permits a different booking',
        () {
      store.currentRide = snapshot(status, 1);
      store.isRideAccepted = true;
      store.isCreatingRide = true;
      store.isTyping = true;
      store.isNavigating = true;
      expect(store.applyRideUpdate(snapshot('cancelled', 2)), true);
      expect(store.currentRide, isNull);
      expect(store.isRideAccepted, false);
      expect(store.isCreatingRide, false);
      expect(store.isNavigating, false);
      expect(store.isTyping, false);
      expect(store.markers, isEmpty);
      expect(store.polylines, isEmpty);
      expect(store.applyRideUpdate(snapshot('cancelled', 2)), false);
      expect(store.applyRideUpdate(snapshot('accepted', 1), allowNewRide: true),
          false);
      expect(notices, hasLength(1));
      expect(
          store.applyRideUpdate(snapshot('requested', 0, id: 'next'),
              allowNewRide: true),
          true);
      expect(store.isCreatingRide, true);
      expect(store.isRideAccepted, false);
    });
  }
  test('older, duplicate, backward, unknown and unrelated updates are ignored',
      () {
    store.currentRide = snapshot('arrived', 4);
    for (final update in [
      snapshot('accepted', 3),
      snapshot('accepted', 5),
      snapshot('arrived', 4),
      snapshot('invalid', 5),
      snapshot('cancelled', 5, id: 'other')
    ]) {
      expect(store.applyRideUpdate(update), false);
    }
    expect(store.currentRide!.ride!.status, RideStatus.arrived);
    expect(notices, isEmpty);
  });
  test('completed rides remain terminal and preserve participant metadata', () {
    store.currentRide = snapshot('started', 3)..driverName = 'Driver';
    expect(store.applyRideUpdate(snapshot('completed', 4)), true);
    expect(store.currentRide!.driverName, 'Driver');
    expect(store.applyRideUpdate(snapshot('cancelled', 5)), false);
    expect(store.applyRideUpdate(snapshot('started', 5)), false);
    expect(notices, hasLength(1));
  });
  test('REST cancellation and duplicate socket cancellation share one outcome',
      () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/passenger'));
    addTearDown(dio.close);
    store = MapStore(
        rideService: RideService.withClient(dio), rideNotice: notices.add)
      ..currentRide = snapshot('accepted', 1)
      ..isRideAccepted = true;
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      expect(options.data['reason'], 'Plans changed');
      handler.resolve(Response(requestOptions: options, statusCode: 200, data: {
        'success': true,
        'data': {
          'ride': {'id': 'r1', 'status': 'cancelled', 'version': 2}
        }
      }));
    }));
    await store.cancelRide('Plans changed');
    expect(store.currentRide, isNull);
    expect(store.applyRideUpdate(snapshot('cancelled', 2)), false);
    expect(notices, hasLength(1));
  });
  test(
      'cancellation key survives lost reply and client replacement without automatic resend',
      () async {
    final dio = Dio();
    addTearDown(dio.close);
    final keys = <String>[];
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      keys.add(options.headers['Idempotency-Key'] as String);
      if (keys.length == 1) {
        handler.reject(DioException(
            requestOptions: options, type: DioExceptionType.receiveTimeout));
      } else {
        handler
            .resolve(Response(requestOptions: options, statusCode: 200, data: {
          'success': true,
          'data': {
            'ride': {'id': 'r1', 'status': 'cancelled', 'version': 2}
          }
        }));
      }
    }));
    await expectLater(
        RideService.withClient(dio).updateRideStatus('r1', RideStatus.cancelled,
            reason: 'Plans changed'),
        throwsA(isA<DioException>()));
    expect(keys, hasLength(1));
    await RideService.withClient(dio)
        .updateRideStatus('r1', RideStatus.cancelled, reason: 'Plans changed');
    expect(keys, hasLength(2));
    expect(keys[0], keys[1]);
    expect(
        keys[0], matches(RegExp(r'^passenger-ride-status-v1-[a-f0-9]{64}$')));
  });
  test(
      'cancellation keys distinguish ride and metadata without exposing the reason',
      () async {
    final dio = Dio();
    addTearDown(dio.close);
    final keys = <String>[];
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      keys.add(options.headers['Idempotency-Key'] as String);
      handler.resolve(Response(requestOptions: options, statusCode: 200, data: {
        'success': true,
        'data': {
          'ride': {
            'id': options.path.split('/')[2],
            'status': 'cancelled',
            'version': 2
          }
        }
      }));
    }));
    final service = RideService.withClient(dio);
    await service.updateRideStatus('r1', RideStatus.cancelled);
    await service.updateRideStatus('r2', RideStatus.cancelled);
    await service.updateRideStatus('r1', RideStatus.cancelled,
        reason: 'Plans changed');
    await service.updateRideStatus('r1', RideStatus.cancelled,
        reason: 'Plans changed', details: 'details');
    expect(keys.toSet(), hasLength(4));
    expect(keys.every((key) => !key.contains('Plans changed')), true);
  });
  test('failed cancellation preserves the ride and retry controls', () async {
    final dio = Dio();
    addTearDown(dio.close);
    store = MapStore(
        rideService: RideService.withClient(dio), rideNotice: notices.add)
      ..currentRide = snapshot('accepted', 1)
      ..isRideAccepted = true;
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      handler.resolve(Response(requestOptions: options, statusCode: 200, data: {
        'success': true,
        'data': {
          'ride': {'id': 'wrong', 'status': 'cancelled'}
        }
      }));
    }));
    await store.cancelRide('Plans changed');
    expect(store.currentRide!.ride!.status, RideStatus.accepted);
    expect(store.isRideAccepted, true);
    expect(store.isCancellingRide, false);
    expect(notices, isEmpty);
  });
  test('late cancellation response cannot clear a newer ride', () async {
    final dio = Dio();
    addTearDown(dio.close);
    final requested = Completer<void>();
    final release = Completer<void>();
    store = MapStore(
        rideService: RideService.withClient(dio), rideNotice: notices.add)
      ..currentRide = snapshot('accepted', 1);
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      requested.complete();
      await release.future;
      handler.resolve(Response(requestOptions: options, statusCode: 200, data: {
        'success': true,
        'data': {
          'ride': {'id': 'r1', 'status': 'cancelled', 'version': 2}
        }
      }));
    }));
    final cancelling = store.cancelRide('Plans changed');
    await requested.future;
    store.applyRideUpdate(snapshot('cancelled', 2));
    store.applyRideUpdate(snapshot('requested', 0, id: 'next'),
        allowNewRide: true);
    release.complete();
    await cancelling;
    expect(store.currentRide!.ride!.sId, 'next');
    expect(notices, hasLength(1));
  });
}
