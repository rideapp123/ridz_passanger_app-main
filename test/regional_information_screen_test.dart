import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/core/configs/app_routes.dart';
import 'package:ridzs_passenger_app/core/theme/light_theme.dart';
import 'package:ridzs_passenger_app/core/theme/ridzs_theme.dart';
import 'package:ridzs_passenger_app/services/regional_disclosure_service.dart';
import 'package:ridzs_passenger_app/view/legal/regional_information_screen.dart';
import 'package:ridzs_passenger_app/view/legal/passenger_legal_links.dart';
import 'package:ridzs_passenger_app/view/legal/legal.dart';
import 'package:ridzs_passenger_app/view/faq_screen.dart';
import 'package:ridzs_passenger_app/view/terms_and_condition_screen.dart';
import 'fixtures/regional_disclosure.dart';
import 'session_request_test.dart' show TestAdapter;

ResponseBody ok(Object? data) =>
    ResponseBody.fromString(jsonEncode({'success': true, 'data': data}), 200,
        headers: {
          Headers.contentTypeHeader: ['application/json']
        });
ResponseBody unavailable() => ResponseBody.fromString(
        jsonEncode({
          'success': false,
          'code': 'DISCLOSURE_UNAVAILABLE',
          'message': 'PRIVATE reviewer trace'
        }),
        409,
        headers: {
          Headers.contentTypeHeader: ['application/json']
        });

void main() {
  setUpAll(() async {
    await (FontLoader('Poppins')
          ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf')))
        .load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });
  late List<RequestOptions> requests;
  late String root;
  late Future<ResponseBody> Function(RequestOptions) respond;
  setUp(() {
    requests = [];
    root = 'https://example.test';
    respond = (r) async => ok(r.uri.path.endsWith('regional-disclosure-markets')
        ? regionalMarketPage(locale: r.queryParameters['locale'] as String)
        : regionalDisclosure(locale: r.queryParameters['locale'] as String));
  });
  RegionalDisclosureService service() => RegionalDisclosureService(
      apiRootReader: () => root,
      adapter: TestAdapter((r) async {
        requests.add(r);
        return respond(r);
      }));
  ThemeData theme() => RidzsTheme.refine(ThemeData(
      useMaterial3: true, colorScheme: flexSchemeLight, fontFamily: 'Poppins'));
  Future<void> mount(WidgetTester tester,
      {double scale = 1,
      RegionalSection section = RegionalSection.terms}) async {
    await tester.pumpWidget(MaterialApp(
        theme: theme(),
        home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: RegionalInformationScreen(
                initialSection: section, serviceFactory: service))));
    await tester.pumpAndSettle();
  }

  Future<void> select(WidgetTester tester) async {
    await tester.tap(find.text('Synthetic market'));
    await tester.pumpAndSettle();
  }

  Future<void> choose(WidgetTester tester, String key, String label) async {
    await tester.ensureVisible(find.byKey(ValueKey(key)));
    await tester.tap(find.byKey(ValueKey(key)));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  Future<void> close(WidgetTester tester) =>
      tester.pumpWidget(const SizedBox());
  Future<void> dispatched(WidgetTester tester, int count) async {
    for (var i = 0; i < 10 && requests.length < count; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(requests, hasLength(count),
        reason: 'The delayed read must reach transport');
  }

  testWidgets(
      'server selection precedes exact anonymous read, all four sections are plain text',
      (tester) async {
    await mount(tester);
    expect(find.byType(SelectableText), findsNothing);
    expect(requests, hasLength(1));
    await select(tester);
    expect(find.text('Synthetic terms'), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
    for (final s in RegionalSection.values.skip(1)) {
      await choose(tester, 'Document', s.label);
      await tester.ensureVisible(find.text('Synthetic ${s.kind}'));
      expect(find.text('Synthetic ${s.kind}'), findsOneWidget);
    }
    expect(requests, hasLength(2));
    expect(
        requests.every((r) =>
            r.method == 'GET' && !r.headers.containsKey('Authorization')),
        isTrue);
    expect(find.textContaining('agree'), findsNothing);
    await close(tester);
  });
  testWidgets('withdrawal or refresh failure clears content before retry',
      (tester) async {
    await mount(tester);
    await select(tester);
    respond = (_) async => unavailable();
    await tester.tap(find.byTooltip('Refresh regional information'));
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsNothing);
    expect(find.textContaining('unavailable for this market'), findsOneWidget);
    expect(find.textContaining('PRIVATE'), findsNothing);
    respond = (_) async => ok(regionalDisclosure());
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsOneWidget);
    await close(tester);
  });
  testWidgets(
      'exact French unavailable never retains English or guesses a fallback',
      (tester) async {
    await mount(tester);
    await select(tester);
    respond = (_) async => unavailable();
    await choose(tester, 'Document language', 'French (Canada)');
    expect(find.byType(SelectableText), findsNothing);
    expect(find.textContaining('in French (Canada).'), findsOneWidget);
    expect(requests.last.queryParameters['locale'], 'fr-CA');
    expect(requests, hasLength(3));
    await close(tester);
  });
  testWidgets('language switch rejects an in-flight prior-language response',
      (tester) async {
    await mount(tester);
    await select(tester);
    final old = Completer<ResponseBody>();
    respond = (r) async =>
        r.queryParameters['locale'] == 'en-CA' ? old.future : unavailable();
    await tester.tap(find.byTooltip('Refresh regional information'));
    await dispatched(tester, 3);
    await choose(tester, 'Document language', 'French (Canada)');
    old.complete(ok(regionalDisclosure()));
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsNothing);
    expect(find.textContaining('in French (Canada).'), findsOneWidget);
    await close(tester);
  });
  testWidgets(
      'market change rejects a late document without choosing another market',
      (tester) async {
    await mount(tester);
    await select(tester);
    final old = Completer<ResponseBody>();
    respond = (r) async => r.uri.path.endsWith('regional-disclosure-markets')
        ? ok(regionalMarketPage())
        : old.future;
    await tester.tap(find.byTooltip('Refresh regional information'));
    await dispatched(tester, 3);
    await tester.tap(find.text('Change market'));
    await tester.pumpAndSettle();
    old.complete(ok(regionalDisclosure()));
    await tester.pumpAndSettle();
    expect(find.text('Market'), findsOneWidget);
    expect(find.byType(SelectableText), findsNothing);
    await close(tester);
  });
  testWidgets('empty filtered pages allow bounded next and previous navigation',
      (tester) async {
    respond = (r) async => ok(r.queryParameters['after'] == null
        ? (regionalMarketPage()
          ..['items'] = []
          ..['nextAfter'] = 'ON-city:fr-CA')
        : regionalMarketPage());
    await mount(tester);
    expect(find.text('No reviewed documents in this group.'), findsOneWidget);
    await tester.tap(find.text('More markets'));
    await tester.pumpAndSettle();
    expect(requests.last.queryParameters['after'], 'ON-city:fr-CA');
    expect(find.text('Synthetic market'), findsOneWidget);
    await tester.tap(find.text('Previous markets'));
    await tester.pumpAndSettle();
    expect(requests.last.queryParameters.containsKey('after'), isFalse);
    expect(find.text('No reviewed documents in this group.'), findsOneWidget);
    expect(requests, hasLength(3));
    await close(tester);
  });
  testWidgets(
      'empty terminal discovery is unavailable not a hardcoded city list',
      (tester) async {
    respond = (_) async => ok(regionalMarketPage()..['items'] = []);
    await mount(tester);
    expect(find.textContaining('unavailable in English'), findsOneWidget);
    expect(find.text('More markets'), findsNothing);
    expect(find.text('Ottawa'), findsNothing);
    await close(tester);
  });
  for (final fault in ['hash', 'revision', 'scope', 'network']) {
    testWidgets('$fault cannot display unverified document text',
        (tester) async {
      await mount(tester);
      respond = (_) async {
        if (fault == 'network') throw Exception('PRIVATE network detail');
        final data = regionalDisclosure();
        if (fault == 'hash') data['contentHash'] = 'a' * 64;
        if (fault == 'revision') {
          data['policyVersion'] = 3;
          sealDisclosure(data);
        }
        if (fault == 'scope') data['scope'] = 'driver_agreement';
        return ok(data);
      };
      await select(tester);
      expect(find.byType(SelectableText), findsNothing);
      expect(find.text('Could not load reviewed information. Please retry.'),
          findsOneWidget);
      expect(find.textContaining('PRIVATE'), findsNothing);
      await close(tester);
    });
  }
  testWidgets(
      'explicit refresh can adopt a newly reviewed policy, not infer acceptance',
      (tester) async {
    await mount(tester);
    await select(tester);
    final data = regionalDisclosure()..['policyVersion'] = 3;
    data['sections'][0]['body'] = 'Synthetic revised terms';
    sealDisclosure(data);
    respond = (_) async => ok(data);
    await tester.tap(find.byTooltip('Refresh regional information'));
    await tester.pumpAndSettle();
    expect(find.text('Synthetic revised terms'), findsOneWidget);
    expect(requests.every((r) => r.method == 'GET'), isTrue);
    await close(tester);
  });
  for (final document in [false, true]) {
    testWidgets(
        'expiry removes ${document ? "document" : "market"} observation without automatic traffic',
        (tester) async {
      await mount(tester);
      if (document) await select(tester);
      final count = requests.length;
      await tester.pump(const Duration(seconds: 31));
      await tester.pump();
      expect(find.byType(SelectableText), findsNothing);
      expect(find.text('Synthetic market'), findsNothing);
      expect(find.textContaining('expired'), findsOneWidget);
      expect(requests, hasLength(count));
      await close(tester);
    });
  }
  testWidgets('pause clears content and resume requires a new current read',
      (tester) async {
    await mount(tester);
    await select(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(find.byType(SelectableText), findsNothing);
    respond = (_) async => unavailable();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsNothing);
    expect(requests, hasLength(3));
    await close(tester);
  });
  testWidgets('dispose rejects late reply and cancels expiry timer',
      (tester) async {
    await mount(tester);
    await select(tester);
    final reply = Completer<ResponseBody>();
    respond = (_) => reply.future;
    await tester.tap(find.byTooltip('Refresh regional information'));
    await dispatched(tester, 3);
    await close(tester);
    reply.complete(ok(regionalDisclosure()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'backend change fails closed and does not send selected context to new origin',
      (tester) async {
    await mount(tester);
    await select(tester);
    root = 'https://other.test';
    await tester.tap(find.byTooltip('Refresh regional information'));
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsNothing);
    expect(find.textContaining('Close and reopen'), findsOneWidget);
    expect(requests, hasLength(2));
    expect(find.text('Retry'), findsNothing);
    await close(tester);
  });
  for (final menu in [false, true]) {
    for (final section in [RegionalSection.terms, RegionalSection.privacy]) {
      testWidgets(
          '${menu ? "settings" : "login"} opens exact ${section.kind} and preserves back navigation',
          (tester) async {
        await tester.pumpWidget(MaterialApp(
            theme: theme(),
            onGenerateRoute: (settings) {
              expect(settings.name, RegionalInformationScreen.routeNamed);
              return MaterialPageRoute(
                  builder: (_) => RegionalInformationScreen(
                      serviceFactory: service,
                      initialSection:
                          RegionalSection.fromArguments(settings.arguments)));
            },
            home: Scaffold(
                body: menu
                    ? const PassengerLegalMenu()
                    : const PassengerLegalLinks())));
        await tester.tap(find.text(
            section == RegionalSection.terms ? 'Terms' : 'Privacy notice'));
        await tester.pumpAndSettle();
        await select(tester);
        expect(find.text('Synthetic ${section.kind}'), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.byType(menu ? PassengerLegalMenu : PassengerLegalLinks),
            findsOneWidget);
        await close(tester);
      });
    }
  }
  testWidgets('software licence navigation uses real Flutter notices',
      (tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PassengerLegalMenu())));
    await tester.tap(find.text('Software licences'));
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
    await close(tester);
  });
  testWidgets(
      'legacy legal and FAQ routes resolve only to reviewed content screens',
      (tester) async {
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
      expect(
          (const Legal().build(context) as RegionalInformationScreen)
              .initialSection,
          RegionalSection.terms);
      expect(
          (const TermsAndConditionScreen().build(context)
                  as RegionalInformationScreen)
              .initialSection,
          RegionalSection.terms);
      expect(
          (const FAQScreen().build(context) as RegionalInformationScreen)
              .initialSection,
          RegionalSection.support);
      final route = generateRoute(const RouteSettings(
          name: RegionalInformationScreen.routeNamed,
          arguments: {'section': 'privacy'})) as MaterialPageRoute;
      expect(
          (route.builder(context) as RegionalInformationScreen).initialSection,
          RegionalSection.privacy);
      return const SizedBox();
    })));
    await close(tester);
  });
  test('both login variants use tested links with no implied acceptance', () {
    for (final path in [
      'lib/view/auth/login_page.dart',
      'lib/view/auth/login_with_email.dart'
    ]) {
      final source = File(path).readAsStringSync();
      expect(source, contains('PassengerLegalLinks()'));
      expect(source, isNot(contains('byContinuingYouAgreeToThe')));
    }
    expect(File('lib/view/settings/settings.dart').readAsStringSync(),
        contains('PassengerLegalMenu()'));
  });
  testWidgets('missing reader configuration is explicit and has no retry loop',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: RegionalInformationScreen(
            serviceFactory: () => throw StateError('PRIVATE config'))));
    await tester.pumpAndSettle();
    expect(find.textContaining('Close and reopen'), findsOneWidget);
    expect(find.textContaining('PRIVATE'), findsNothing);
    expect(find.text('Retry'), findsNothing);
    await close(tester);
  });
  testWidgets(
      'a failed page does not retain earlier market choices and retries the exact cursor',
      (tester) async {
    var fail = true;
    respond = (r) async {
      if (r.queryParameters['after'] != null && fail) {
        throw Exception('PRIVATE unavailable');
      }
      return ok(r.queryParameters['after'] == null
          ? (regionalMarketPage()..['nextAfter'] = 'ON-ottawa:fr-CA')
          : (regionalMarketPage()..['items'] = []));
    };
    await mount(tester);
    await tester.tap(find.text('More markets'));
    await tester.pumpAndSettle();
    expect(find.text('Synthetic market'), findsNothing);
    expect(find.text('Retry'), findsOneWidget);
    fail = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(requests.last.queryParameters['after'], 'ON-ottawa:fr-CA');
    expect(find.textContaining('No more reviewed documents'), findsOneWidget);
    await close(tester);
  });
  testWidgets(
      'backgrounding during a read rejects that response before a fresh resume read',
      (tester) async {
    await mount(tester);
    await select(tester);
    final old = Completer<ResponseBody>();
    respond = (_) => old.future;
    await tester.tap(find.byTooltip('Refresh regional information'));
    await dispatched(tester, 3);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    old.complete(ok(regionalDisclosure()));
    await tester.pump();
    expect(find.byType(SelectableText), findsNothing);
    respond = (_) async => unavailable();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsNothing);
    expect(requests, hasLength(4));
    await close(tester);
  });
  testWidgets(
      'server text is selectable literal content with no executable links',
      (tester) async {
    await mount(tester);
    final data = regionalDisclosure();
    data['sections'][0]['body'] =
        '<a href="https://example.test">Synthetic</a> <script>alert(1)</script>';
    sealDisclosure(data);
    respond = (_) async => ok(data);
    await select(tester);
    expect(tester.widget<SelectableText>(find.byType(SelectableText)).data,
        data['sections'][0]['body']);
    expect(requests, hasLength(2));
    await close(tester);
  });
  for (final width in [320.0, 390.0, 1000.0]) {
    testWidgets(
        '$width at 2x text fits selection, document, retry and version metadata',
        (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      respond = (r) async {
        if (r.uri.path.endsWith('regional-disclosure-markets')) {
          return ok(regionalMarketPage());
        }
        final data = regionalDisclosure();
        data['sections'][0]['body'] =
            'Synthetic regional content.\n\nNot approved legal wording. No acceptance is recorded by this test.';
        sealDisclosure(data);
        return ok(data);
      };
      await mount(tester, scale: 2);
      await select(tester);
      await tester.scrollUntilVisible(find.byType(SelectableText), 250,
          scrollable: find.byType(Scrollable).first);
      expect(tester.takeException(), isNull);
      await expectLater(find.byType(Scaffold),
          matchesGoldenFile('goldens/regional_documents_${width.toInt()}.png'));
      await tester.scrollUntilVisible(find.textContaining('Valid until:'), 250,
          scrollable: find.byType(Scrollable).first);
      expect(tester.takeException(), isNull);
      respond = (_) async => unavailable();
      await tester.tap(find.byTooltip('Refresh regional information'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Retry'), -200,
          scrollable: find.byType(Scrollable).first);
      expect(tester.takeException(), isNull);
      await close(tester);
    });
  }
}
