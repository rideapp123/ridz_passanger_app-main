import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart';
import 'package:ridzs_passenger_app/core/theme/light_theme.dart';
import 'package:ridzs_passenger_app/core/theme/ridzs_theme.dart';
import 'package:ridzs_passenger_app/view/home/widget/passenger_driver_credentials_screen.dart';
import 'fixtures/passenger_driver_credentials.dart';

void main() {
  setUpAll(() async {
    await (FontLoader('Poppins')
          ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf')))
        .load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });
  late PassengerCredentialsHarness harness;
  setUp(() => harness = PassengerCredentialsHarness());
  tearDown(() => harness.close());
  Future<void> mount(WidgetTester tester, {double scale = 1}) async {
    await tester.pumpWidget(MaterialApp(
        theme: RidzsTheme.refine(ThemeData(
            useMaterial3: true,
            colorScheme: flexSchemeLight,
            fontFamily: 'Poppins')),
        home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: PassengerDriverCredentialsScreen(
                binding: credentialBinding, serviceFactory: harness.create))));
    await tester.pumpAndSettle();
  }

  Future<void> close(WidgetTester tester) =>
      tester.pumpWidget(const SizedBox());
  testWidgets(
      'renders minimal credential, clears on failed refresh and retries',
      (tester) async {
    await mount(tester);
    expect(find.text('Ridzs driver ID'), findsOneWidget);
    expect(find.textContaining('government licence'), findsOneWidget);
    harness.respond = (_) async => throw Exception('private review reason');
    await tester.tap(find.byTooltip('Refresh credentials'));
    await tester.pumpAndSettle();
    expect(find.text('Ridzs driver ID'), findsNothing);
    expect(find.textContaining('private review'), findsNothing);
    harness.respond = (_) async =>
        credentialsResponse(passengerCredentials(available: false));
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('No current Ridzs-issued credentials available.'),
        findsOneWidget);
    await close(tester);
  });
  for (final change in ['logout', 'owner', 'ride']) {
    testWidgets('$change immediately clears previously displayed credential',
        (tester) async {
      await mount(tester);
      switch (change) {
        case 'logout':
          harness.auth.endSession();
        case 'owner':
          runInAction(() => harness.owner.value = 'passenger-b');
        case 'ride':
          runInAction(() => harness.rideCurrent.value = false);
      }
      await tester.pumpAndSettle();
      expect(find.text('Ridzs driver ID'), findsNothing);
      expect(find.text('Retry'), findsNothing);
      expect(find.textContaining('Ride or session changed'), findsOneWidget);
      await close(tester);
    });
  }
  testWidgets(
      'background hides observation and resume fetches current authority',
      (tester) async {
    await mount(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(find.text('Ridzs driver ID'), findsNothing);
    harness.respond = (_) async =>
        credentialsResponse(passengerCredentials(available: false));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('No current Ridzs-issued credentials available.'),
        findsOneWidget);
    expect(harness.requests, hasLength(2));
    await close(tester);
  });
  testWidgets('server lease refresh clears record before delayed result',
      (tester) async {
    await mount(tester);
    final reply = Completer<ResponseBody>();
    harness.respond = (_) => reply.future;
    await tester.pump(const Duration(seconds: 30));
    expect(find.text('Ridzs driver ID'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    reply.complete(credentialsResponse(passengerCredentials(available: false)));
    await tester.pumpAndSettle();
    expect(find.text('No current Ridzs-issued credentials available.'),
        findsOneWidget);
    await close(tester);
  });
  testWidgets('disposed view cannot be repopulated by late reply',
      (tester) async {
    await mount(tester);
    final reply = Completer<ResponseBody>();
    harness.respond = (_) => reply.future;
    await tester.tap(find.byTooltip('Refresh credentials'));
    await tester.pump();
    await close(tester);
    reply.complete(credentialsResponse(passengerCredentials()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  for (final width in [320.0, 390.0]) {
    testWidgets('$width 2x text fits and scrolls without private references',
        (tester) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final data = passengerCredentials();
      (data['credentials'] as List).add({
        'kind': 'operator_certificate',
        'expiresAt': '2027-01-01T00:00:00Z'
      });
      harness.respond = (_) async => credentialsResponse(data);
      await mount(tester, scale: 2);
      await expectLater(find.byType(Scaffold),
          matchesGoldenFile('goldens/driver_credentials_${width.toInt()}.png'));
      await tester.scrollUntilVisible(find.text('Ridzs certificate'), 300);
      expect(tester.takeException(), isNull);
      expect(find.text('driver-a'), findsNothing);
      await close(tester);
    });
  }
}
