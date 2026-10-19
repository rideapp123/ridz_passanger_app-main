import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart' as mobx;
import 'package:ridzs_passenger_app/core/theme/light_theme.dart';
import 'package:ridzs_passenger_app/core/theme/ridzs_theme.dart';
import 'package:ridzs_passenger_app/view/legal/ride_documents_screen.dart';
import 'fixtures/ride_disclosure.dart';

void main() {
  setUpAll(() async {
    await (FontLoader('Poppins')
          ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf')))
        .load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });
  late RideDocumentHarness h;
  setUp(() => h = RideDocumentHarness());
  tearDown(() => h.close());
  ThemeData theme() => RidzsTheme.refine(ThemeData(
      useMaterial3: true, colorScheme: flexSchemeLight, fontFamily: 'Poppins'));
  Future<void> mount(WidgetTester tester,
      {bool button = false, double scale = 1}) async {
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpWidget(MaterialApp(
        theme: theme(),
        home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: button
                ? Scaffold(
                    body: RideDocumentsButton(
                        rideId: 'ride-a', serviceFactory: h.create))
                : RideDocumentsScreen(
                    rideId: 'ride-a', serviceFactory: h.create))));
    await tester.pumpAndSettle();
  }

  Future<void> choose(WidgetTester tester, String key, String label) async {
    await tester.tap(find.byKey(ValueKey(key)));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text(label).last);
    await tester.pump();
  }

  Future<void> dispatched(WidgetTester tester, int count) async {
    for (var i = 0; i < 20 && h.requests.length < count; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(h.requests, hasLength(count));
  }

  testWidgets('real button opens historical documents and can return',
      (tester) async {
    await mount(tester, button: true);
    expect(h.requests, isEmpty);
    await tester.tap(find.text('Ride documents'));
    await tester.pumpAndSettle();
    expect(find.text('Historical passenger information'), findsOneWidget);
    expect(find.text('Synthetic ride_information'), findsOneWidget);
    expect(h.requests.single.uri.path,
        '/passenger/rides/ride-a/regional-disclosure');
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Historical passenger information'), findsNothing);
    expect(find.text('Ride documents'), findsOneWidget);
  });
  testWidgets(
      'past publication expiry remains readable and is not labelled acceptance',
      (tester) async {
    await mount(tester);
    expect(find.byType(SelectableText), findsOneWidget);
    await tester.scrollUntilVisible(
        find.textContaining('Original validity:'), 300,
        scrollable: find.byType(Scrollable).first);
    expect(
        find.textContaining('Original validity: 2026-10-18'), findsOneWidget);
    expect(find.textContaining('not proof of acceptance'), findsOneWidget);
    expect(h.requests, hasLength(1));
  });
  testWidgets('all four sections are local views of the same immutable read',
      (tester) async {
    await mount(tester);
    for (final entry in {
      'Terms': 'terms',
      'Privacy': 'privacy',
      'Support': 'support'
    }.entries) {
      await choose(tester, 'Document', entry.key);
      await tester.pumpAndSettle();
      expect(find.text('Synthetic ${entry.value}'), findsOneWidget);
    }
    expect(h.requests, hasLength(1));
  });
  testWidgets('missing French clears English and never issues a fallback GET',
      (tester) async {
    await mount(tester);
    h.respond = (_) async => missingDocument();
    await choose(tester, 'Document language', 'French (Canada)');
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsNothing);
    expect(find.textContaining('unavailable for this ride in French'),
        findsOneWidget);
    expect(find.textContaining('PRIVATE'), findsNothing);
    expect(h.requests, hasLength(2));
    expect(h.requests.last.queryParameters['locale'], 'fr-CA');
    h.respond = (_) async => documentResponse(rideDisclosure(locale: 'fr-CA'));
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsOneWidget);
  });
  testWidgets(
      'late language response cannot replace the newly selected language',
      (tester) async {
    await mount(tester);
    final pending = Completer<ResponseBody>();
    h.respond = (_) => pending.future;
    await choose(tester, 'Document language', 'French (Canada)');
    await dispatched(tester, 2);
    expect(find.byType(SelectableText), findsNothing);
    h.respond = (_) async => documentResponse(rideDisclosure());
    await choose(tester, 'Document language', 'English (Canada)');
    await tester.pumpAndSettle();
    pending.complete(documentResponse(rideDisclosure(locale: 'fr-CA')));
    await tester.pumpAndSettle();
    expect(h.requests, hasLength(3));
    expect(find.text('English (Canada)'), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final change in ['owner', 'ride', 'logout', 'backend']) {
    testWidgets('$change clears visible content and requires reopening',
        (tester) async {
      await mount(tester);
      switch (change) {
        case 'owner':
          mobx.runInAction(() => h.owner.value = 'other');
        case 'ride':
          mobx.runInAction(() => h.rideCurrent.value = false);
        case 'logout':
          h.auth.endSession();
        case 'backend':
          h.dio.options.baseUrl = 'https://other.test';
      }
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.byType(SelectableText), findsNothing);
      expect(find.textContaining('Close and reopen'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
      expect(h.requests, hasLength(1));
    });
  }
  testWidgets('expiry clears content and waits for manual refresh',
      (tester) async {
    await mount(tester);
    await tester.pump(const Duration(seconds: 31));
    expect(find.byType(SelectableText), findsNothing);
    expect(find.textContaining('Document check expired'), findsOneWidget);
    expect(h.requests, hasLength(1));
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(h.requests, hasLength(2));
    expect(find.byType(SelectableText), findsOneWidget);
  });
  testWidgets('pause hides content, cancels late reply and resume reads again',
      (tester) async {
    await mount(tester);
    final pending = Completer<ResponseBody>();
    h.respond = (_) => pending.future;
    await tester.tap(find.byTooltip('Refresh ride documents'));
    await dispatched(tester, 2);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(find.byType(SelectableText), findsNothing);
    pending.complete(documentResponse(rideDisclosure()));
    await tester.pump();
    expect(find.byType(SelectableText), findsNothing);
    h.respond = (_) async => documentResponse(rideDisclosure());
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(h.requests, hasLength(3));
    expect(find.byType(SelectableText), findsOneWidget);
  });
  testWidgets('disposal discards a pending transport reply', (tester) async {
    await mount(tester);
    final pending = Completer<ResponseBody>();
    h.respond = (_) => pending.future;
    await tester.tap(find.byTooltip('Refresh ride documents'));
    await dispatched(tester, 2);
    await tester.pumpWidget(const SizedBox.shrink());
    pending.complete(documentResponse(rideDisclosure()));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
  for (final fault in ['outage', 'corrupt', 'wrong-ride', 'missing']) {
    testWidgets(
        '$fault removes stale content and exposes no private error details',
        (tester) async {
      await mount(tester);
      h.respond = (_) async => switch (fault) {
            'outage' => documentResponse({'secret': 'PRIVATE'}, status: 503),
            'corrupt' =>
              documentResponse({...rideDisclosure(), 'contentHash': 'a' * 64}),
            'wrong-ride' =>
              documentResponse({...rideDisclosure(), 'rideId': 'other'}),
            _ => missingDocument()
          };
      await tester.tap(find.byTooltip('Refresh ride documents'));
      await tester.pumpAndSettle();
      expect(find.byType(SelectableText), findsNothing);
      expect(find.textContaining('PRIVATE'), findsNothing);
      expect(find.text('Retry'), findsOneWidget);
    });
  }
  testWidgets('changed ride widget cannot reuse an earlier session',
      (tester) async {
    await mount(tester);
    await tester.pumpWidget(MaterialApp(
        theme: theme(),
        home: RideDocumentsScreen(rideId: 'other', serviceFactory: h.create)));
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsNothing);
    expect(find.textContaining('Close and reopen'), findsOneWidget);
  });
  for (final width in [320, 390, 1000]) {
    testWidgets('historical documents golden $width at 2x text',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width.toDouble(), 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      h.respond = (r) async {
        final data =
            rideDisclosure(locale: r.queryParameters['locale'] as String);
        for (final section in data['sections'] as List) {
          section['body'] =
              'Synthetic historical content for tests only. Not approved legal text.';
        }
        sealRideDisclosure(data);
        return documentResponse(data);
      };
      await mount(tester, scale: 2);
      expect(tester.takeException(), isNull);
      await expectLater(find.byType(Scaffold),
          matchesGoldenFile('goldens/ride_documents_$width.png'));
      await tester.scrollUntilVisible(find.textContaining('Version:'), 300,
          scrollable: find.byType(Scrollable).first);
      expect(tester.takeException(), isNull);
    });
  }
  test(
      'journey source entry points remain wired and do not change ride commands',
      () {
    for (final path in [
      'lib/view/trip_history/trip_history.dart',
      'lib/view/home/widget/ride_rating_form.dart',
      'lib/view/home/widget/ride_participant_header.dart'
    ]) {
      expect(File(path).readAsStringSync(), contains('RideDocumentsButton('),
          reason: path);
    }
    expect(File('lib/view/legal/ride_documents_screen.dart').readAsStringSync(),
        contains('passenger information'));
  });
}
