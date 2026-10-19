import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/services/regional_disclosure_service.dart';
import 'package:ridzs_passenger_app/services/service_area_service.dart';
import 'package:ridzs_passenger_app/view/home/widget/service_area_notice.dart';
import 'package:ridzs_passenger_app/view/legal/regional_information_screen.dart';
import 'fixtures/regional_disclosure.dart';
import 'fixtures/ride_disclosure.dart' show DocumentAdapter, documentResponse;

class PickupAreas extends ServiceAreaService {
  PickupAreas() : super(dio: Dio());
  @override
  Future<ServiceArea> check(double latitude, double longitude) async =>
      ServiceArea.fromJson({
        'available': true,
        'marketId': latitude == 45 ? 'ON-ottawa' : 'ON-toronto',
        'name': 'Synthetic pickup',
        'termsUrl': 'https://legacy.test/terms',
        'privacyUrl': 'https://legacy.test/privacy'
      });
}

void main() {
  late List<RequestOptions> requests;
  late Future<ResponseBody> Function(RequestOptions) respond;
  setUp(() {
    requests = [];
    respond = (r) async => documentResponse(regionalDisclosure(
        id: r.uri.path.split('/').last,
        locale: r.queryParameters['locale'] as String));
  });
  RegionalDisclosureService service() => RegionalDisclosureService(
      apiRootReader: () => 'https://example.test',
      adapter: DocumentAdapter((r) async {
        requests.add(r);
        return respond(r);
      }));

  test('service-area model retains only valid server market IDs', () {
    for (final market in ['ON-ottawa', 'AB-calgary', 'QC-montreal']) {
      expect(
          ServiceArea.fromJson({'available': true, 'marketId': market})
              .marketId,
          market);
    }
    for (final market in [
      null,
      '',
      'ZZ-city',
      '../private',
      'ON-ottawa:en-CA'
    ]) {
      expect(
          ServiceArea.fromJson({'available': true, 'marketId': market})
              .marketId,
          null);
    }
  });
  testWidgets(
      'pickup terms and privacy open exact current market without discovery or external URLs',
      (tester) async {
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: ServiceAreaNotice(
                latitude: 45,
                longitude: -75,
                service: PickupAreas(),
                documentServiceFactory: service))));
    await tester.pumpAndSettle();
    expect(requests, isEmpty);
    await tester.tap(find.text('Ride terms'));
    await tester.pumpAndSettle();
    expect(find.text('Synthetic terms'), findsOneWidget);
    expect(find.text('Change market'), findsNothing);
    expect(requests.single.uri.path, '/public/regional-disclosures/ON-ottawa');
    expect(requests.single.headers.containsKey('Authorization'), isFalse);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Privacy'));
    await tester.pumpAndSettle();
    expect(find.text('Synthetic privacy'), findsOneWidget);
    expect(requests, hasLength(2));
    expect(requests.every((r) => r.uri.host == 'example.test'), isTrue);
  });
  testWidgets(
      'changed pickup clears open document and cannot select another market inside it',
      (tester) async {
    final latitude = ValueNotifier(45.0);
    addTearDown(latitude.dispose);
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    final areas = PickupAreas();
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: ValueListenableBuilder<double>(
                valueListenable: latitude,
                builder: (_, value, __) => ServiceAreaNotice(
                    latitude: value,
                    longitude: -75,
                    service: areas,
                    documentServiceFactory: service)))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ride terms'));
    await tester.pumpAndSettle();
    latitude.value = 46;
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsNothing);
    expect(find.text('Pickup changed. Close and reopen this page.'),
        findsOneWidget);
    expect(requests, hasLength(1));
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ride terms'));
    await tester.pumpAndSettle();
    expect(requests.last.uri.path, '/public/regional-disclosures/ON-toronto');
  });
  testWidgets('late response for a changed pickup cannot render',
      (tester) async {
    var current = true;
    final revision = ValueNotifier(0);
    addTearDown(revision.dispose);
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    final pending = Completer<ResponseBody>();
    respond = (_) => pending.future;
    await tester.pumpWidget(MaterialApp(
        home: RegionalInformationScreen(
            pickupMarketId: 'ON-ottawa',
            contextChanges: revision,
            contextIsCurrent: () => current,
            serviceFactory: service)));
    for (var i = 0; i < 20 && requests.isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(requests, hasLength(1));
    current = false;
    revision.value++;
    pending.complete(documentResponse(regionalDisclosure()));
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsNothing);
    expect(find.text('Pickup changed. Close and reopen this page.'),
        findsOneWidget);
    expect(requests, hasLength(1));
  });
  testWidgets('invalid pickup ID never opens discovery as a fallback',
      (tester) async {
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpWidget(MaterialApp(
        home: RegionalInformationScreen(
            pickupMarketId: '../other', serviceFactory: service)));
    await tester.pumpAndSettle();
    expect(requests, isEmpty);
    expect(find.byType(SelectableText), findsNothing);
    expect(find.textContaining('Close and reopen'), findsOneWidget);
  });
}
