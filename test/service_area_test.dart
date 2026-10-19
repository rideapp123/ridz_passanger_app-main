import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/services/service_area_service.dart';
import 'package:ridzs_passenger_app/view/home/widget/service_area_notice.dart';

class FakeAreaService extends ServiceAreaService {
  FakeAreaService() : super(dio: Dio());
  final calls = <Completer<ServiceArea>>[];
  @override
  Future<ServiceArea> check(double latitude, double longitude) {
    final call = Completer<ServiceArea>();
    calls.add(call);
    return call.future;
  }
}

void main() {
  test('URLs must be HTTPS and unavailable remains unavailable', () {
    final area = ServiceArea.fromJson(
        {'available': false, 'termsUrl': 'javascript:alert(1)'});
    expect(area.available, false);
    expect(area.termsUrl, null);
  });
  test('passenger service uses backend coordinates and validates envelope',
      () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/passenger'));
    addTearDown(dio.close);
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      expect(options.uri.path, '/passenger/service-area');
      expect(options.queryParameters, {'latitude': 45.4, 'longitude': -75.7});
      handler.resolve(Response(requestOptions: options, data: {
        'success': true,
        'data': {'available': false, 'reason': 'Closed'}
      }));
    }));
    expect((await ServiceAreaService(dio: dio).check(45.4, -75.7)).available,
        false);
  });
  testWidgets('late results cannot overwrite a changed pickup', (tester) async {
    final service = FakeAreaService();
    Widget host(double lat) => MaterialApp(
        home: Scaffold(
            body: ServiceAreaNotice(
                latitude: lat, longitude: -75.7, service: service)));
    await tester.pumpWidget(host(45.4));
    await tester.pumpWidget(host(0));
    service.calls[1].complete(ServiceArea.fromJson(
        {'available': false, 'reason': 'Pickup unavailable'}));
    await tester.pumpAndSettle();
    service.calls[0].complete(
        ServiceArea.fromJson({'available': true, 'name': 'Old pickup'}));
    await tester.pumpAndSettle();
    expect(find.text('Pickup unavailable'), findsOneWidget);
    expect(find.text('Old pickup'), findsNothing);
  });
  testWidgets('failed request offers retry and hides technical details',
      (tester) async {
    final service = FakeAreaService();
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: ServiceAreaNotice(
                latitude: 45.4, longitude: -75.7, service: service))));
    service.calls.first.completeError(Exception('private error'));
    await tester.pumpAndSettle();
    expect(find.textContaining('private error'), findsNothing);
    await tester.tap(find.byTooltip('Retry service-area check'));
    await tester.pump();
    service.calls.last
        .complete(ServiceArea.fromJson({'available': true, 'name': 'Ottawa'}));
    await tester.pumpAndSettle();
    expect(find.text('Ottawa'), findsOneWidget);
  });
}
