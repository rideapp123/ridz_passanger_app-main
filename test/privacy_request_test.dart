import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/services/privacy_request_service.dart';
import 'package:ridzs_passenger_app/core/services/dio_service.dart';
import 'package:ridzs_passenger_app/view/profile/privacy_request_screen.dart';
import 'package:ridzs_passenger_app/core/theme/ridzs_theme.dart';
import 'package:ridzs_passenger_app/core/theme/light_theme.dart';
import 'package:ridzs_passenger_app/models/privacy_disclosure.dart';
import 'package:ridzs_passenger_app/models/privacy_disposition.dart';
import 'package:ridzs_passenger_app/models/privacy_source_plan.dart';

class PrivacyAdapter implements HttpClientAdapter {
  PrivacyAdapter(this.respond);
  final Future<ResponseBody> Function(RequestOptions) respond;
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream,
          Future<void>? cancelFuture) =>
      respond(options);
  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Dio dio;
  late PrivacyRequestService service;
  late String? token;
  late List<RequestOptions> requests;
  late Future<ResponseBody> Function(RequestOptions) respond;
  Map<String, dynamic> saved({String status = 'pending', int version = 1}) => {
        'id': 'a' * 64,
        'role': 'passenger',
        'kind': 'access',
        'details': 'Private request',
        'status': status,
        'version': version,
        'submittedAt': '2026-09-20T12:00:00Z',
        'updatedAt': '2026-09-20T12:00:00Z',
      };
  ResponseBody reply(dynamic record, {int status = 200}) =>
      ResponseBody.fromString(
          jsonEncode({
            'success': status == 200,
            'data': {
              'hasRequest': record != null,
              'request': record,
              'fulfilled': false,
              'deletionEnabled': false
            }
          }),
          status,
          headers: {
            'content-type': ['application/json']
          });
  setUp(() {
    token = 'account-one';
    requests = [];
    dio = Dio(BaseOptions(baseUrl: 'https://example.test/passenger'));
    dio.interceptors.add(AuthInterceptor(dio, tokenReader: () async => token));
    respond = (r) async => reply(r.method == 'GET' ? null : saved());
    dio.httpClientAdapter = PrivacyAdapter((r) async {
      requests.add(r);
      return respond(r);
    });
    service = PrivacyRequestService(dio: dio, tokenReader: () async => token);
  });
  tearDown(() {
    service.dispose();
    dio.close(force: true);
  });

  Map<String, dynamic> disclosureSummary() => {
        'id': 'd' * 64,
        'domain': 'ratings',
        'rideId': 'ride-one',
        'preparedAt': '2026-09-20T12:00:00Z',
        'scope': 'own_metadata_v1'
      };
  Map<String, dynamic> disclosedPage() => {
        ...disclosureSummary(),
        'pageSha256': 'e' * 64,
        'redaction': 'free_text_and_third_party_omitted',
        'hasMore': false,
        'records': [
          {'id': 'f' * 64, 'createdAt': '2026-01-01T00:00:00Z', 'stars': 4}
        ]
      };
  ResponseBody disclosureReply(
          {bool content = false,
          bool reviewedContent = false,
          int version = 4,
          Map<String, dynamic>? page}) =>
      ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'data': {
              'hasRequest': true,
              'request': saved(status: 'reviewed', version: version),
              'disclosure': {
                ...disclosureSummary(),
                if (reviewedContent) 'scope': 'own_content_v1'
              },
              'fulfilled': false,
              'deletionEnabled': false,
              if (content) 'disclosedPage': page ?? disclosedPage()
            }
          }),
          200,
          headers: {
            'content-type': ['application/json']
          });

  Map<String, dynamic> contentPage() => {
        ...disclosedPage(),
        'scope': 'own_content_v1',
        'redaction': 'operator_reviewed_content',
        'records': [
          {
            ...(disclosedPage()['records'] as List).single
                as Map<String, dynamic>,
            'content': 'My ride with [REDACTED] was comfortable.',
            'disposition': 'redacted'
          }
        ]
      };

  Map<String, dynamic> packageSummary() => {
        'id': 'b' * 64,
        'publishedAt': '2026-09-21T12:00:00Z',
        'coverageComplete': false,
        'pages': [
          disclosureSummary(),
          {...disclosureSummary(), 'id': 'c' * 64, 'rideId': 'ride-two'}
        ]
      };
  ResponseBody packageReply({bool content = false, int version = 10}) =>
      ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'data': {
              'hasRequest': true,
              'request': saved(status: 'reviewed', version: version),
              'fulfilled': false,
              'deletionEnabled': false,
              'responsePackage': packageSummary(),
              if (content)
                'disclosedPage': {
                  ...disclosedPage(),
                  'id': 'c' * 64,
                  'rideId': 'ride-two'
                }
            }
          }),
          200,
          headers: {
            'content-type': ['application/json']
          });

  test(
      'package pages are selectable without an active disclosure and retries bind selection',
      () async {
    respond = (_) async => packageReply();
    await service.load();
    expect(service.disclosure, isNull);
    expect(service.availablePages.length, 2);
    expect(service.canAccess, true);
    respond = (r) async => throw DioException(
        requestOptions: r, type: DioExceptionType.receiveTimeout);
    await service.accessDisclosure(service.responsePackage!.pages.last);
    final command = Map<String, dynamic>.from(requests.last.data);
    expect(command['disclosureId'], 'c' * 64);
    respond = (_) async => packageReply(content: true, version: 11);
    await service.retry();
    expect(requests.last.data, command);
    expect(service.disclosedPage!.summary.rideId, 'ride-two');
    PrivacyRequestService.endAllSessions();
    expect(service.responsePackage, isNull);
    expect(service.availablePages, isEmpty);
  });
  test('package removal conflicts clear visible content and available pages',
      () async {
    respond = (_) async => packageReply();
    await service.load();
    respond = (r) async => throw DioException(
        requestOptions: r,
        response: Response(requestOptions: r, statusCode: 409),
        type: DioExceptionType.badResponse);
    await service.accessDisclosure(service.responsePackage!.pages.last);
    expect(service.responsePackage, isNull);
    expect(service.disclosedPage, isNull);
    expect(service.canAccess, false);
  });
  test(
      'package parser rejects forged completeness, private fields, duplicates and unbounded pages',
      () {
    final valid = packageSummary();
    expect(PrivacyResponsePackage.parse(valid)!.pages.length, 2);
    for (final changes in [
      {'coverageComplete': true},
      {'audit': []},
      {'pages': []},
      {
        'pages': [disclosureSummary(), disclosureSummary()]
      },
      {
        'pages': List.generate(
            11,
            (i) => {
                  ...disclosureSummary(),
                  'id': (i + 1).toRadixString(16).padLeft(64, '0')
                })
      },
      {
        'pages': [
          {...disclosureSummary(), 'reviewSource': 'private'}
        ]
      },
    ]) {
      expect(() => PrivacyResponsePackage.parse({...valid, ...changes}),
          throwsFormatException);
    }
  });
  testWidgets(
      'package page selector fits compact large text and clears on logout',
      (tester) async {
    final font = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    respond = (r) async => packageReply(
        content: r.method == 'POST', version: r.method == 'POST' ? 11 : 10);
    await tester.pumpWidget(MaterialApp(
        theme: RidzsTheme.refine(ThemeData(colorScheme: flexSchemeLight)),
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!),
        home: RepaintBoundary(
            key: const ValueKey('package-golden'),
            child: PrivacyRequestScreen(service: service))));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Response package'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('View package page'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
    await expectLater(find.byKey(const ValueKey('package-golden')),
        matchesGoldenFile('goldens/response_package_large_text.png'));
    await tester.ensureVisible(find.byTooltip('View package page').last);
    await tester.tap(find.byTooltip('View package page').last);
    await tester.pumpAndSettle();
    expect(service.disclosedPage!.summary.rideId, 'ride-two');
    PrivacyRequestService.endAllSessions();
    await tester.pumpAndSettle();
    expect(find.text('Response package'), findsNothing);
    expect(find.byType(SelectableText), findsNothing);
    await tester.pumpWidget(const SizedBox());
    service = PrivacyRequestService(dio: dio, tokenReader: () async => token);
  });

  Map<String, dynamic> assessment() => {
        'id': 'e' * 64,
        'kind': 'erasure',
        'scope': 'chat',
        'decision': 'retained',
        'reason': 'preservation_review',
        'reviewedAt': '2026-09-22T12:00:00Z',
        'execution': 'not_performed'
      };
  ResponseBody assessmentReply({Map<String, dynamic>? value}) =>
      ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'data': {
              'hasRequest': true,
              'request': {
                ...saved(status: 'reviewed', version: 4),
                'kind': 'erasure'
              },
              'disposition': value ?? assessment(),
              'fulfilled': false,
              'deletionEnabled': false
            }
          }),
          200,
          headers: {
            'content-type': ['application/json']
          });
  test(
      'approved assessment is read only and clears on refresh failure and logout',
      () async {
    respond = (_) async => assessmentReply();
    await service.load();
    expect(service.disposition!.title, 'Records retained');
    expect(service.disposition!.scopeLabel, 'Chat');
    respond = (r) async => throw DioException(
        requestOptions: r, type: DioExceptionType.connectionError);
    await service.load();
    expect(service.disposition, isNull);
    expect(service.ready, false);
    respond = (_) async => assessmentReply();
    await service.load();
    PrivacyRequestService.endAllSessions();
    expect(service.disposition, isNull);
  });
  test(
      'assessment parser rejects private fields, mixed kinds and execution claims',
      () {
    expect(PrivacyDispositionSummary.parse(assessment(), 'erasure')!.decision,
        'retained');
    for (final change in [
      {'execution': 'completed'},
      {'kind': 'correction'},
      {'note': 'Private note'},
      {'reference': 'Private evidence'},
      {'reason': 'already_accurate'},
      {'scope': 'all_data'},
      {'decision': 'fulfilled'},
      {'reviewedAt': 'invalid'}
    ]) {
      expect(
          () => PrivacyDispositionSummary.parse(
              {...assessment(), ...change}, 'erasure'),
          throwsFormatException);
    }
    expect(
        PrivacyDispositionSummary.parse({
          ...assessment(),
          'kind': 'correction',
          'decision': 'action_required',
          'reason': 'correction_review'
        }, 'correction')!
            .title,
        'Action required');
  });
  test(
      'untrusted assessment makes the response unavailable instead of claiming success',
      () async {
    respond = (_) async =>
        assessmentReply(value: {...assessment(), 'execution': 'deleted'});
    await service.load();
    expect(service.disposition, isNull);
    expect(service.ready, false);
    expect(service.error, isNotNull);
  });
  testWidgets(
      'approved assessment fits compact large text without a completion claim',
      (tester) async {
    final font = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    respond = (_) async => assessmentReply();
    await tester.pumpWidget(MaterialApp(
        theme: RidzsTheme.refine(ThemeData(colorScheme: flexSchemeLight)),
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!),
        home: RepaintBoundary(
            key: const ValueKey('assessment-golden'),
            child: PrivacyRequestScreen(service: service))));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Request assessment'));
    await tester.pumpAndSettle();
    expect(find.text('Records retained'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await expectLater(find.byKey(const ValueKey('assessment-golden')),
        matchesGoldenFile('goldens/privacy_assessment_large_text.png'));
    PrivacyRequestService.endAllSessions();
    await tester.pumpAndSettle();
    expect(find.text('Records retained'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    service = PrivacyRequestService(dio: dio, tokenReader: () async => token);
  });

  Map<String, dynamic> sourcePlan() => {
        'id': 'f' * 64,
        'assessmentId': 'e' * 64,
        'kind': 'erasure',
        'domain': 'chat',
        'status': 'reviewed_blocked',
        'recordCount': 1,
        'reviewedAt': '2026-09-22T13:00:00Z',
        'execution': 'not_performed'
      };
  Map<String, dynamic> actionAssessment() => {
        ...assessment(),
        'decision': 'action_required',
        'reason': 'erasure_review'
      };
  ResponseBody planReply({Map<String, dynamic>? plan}) =>
      ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'data': {
              'hasRequest': true,
              'request': {
                ...saved(status: 'reviewed', version: 6),
                'kind': 'erasure'
              },
              'disposition': actionAssessment(),
              'sourcePlan': plan ?? sourcePlan(),
              'fulfilled': false,
              'deletionEnabled': false
            }
          }),
          200,
          headers: {
            'content-type': ['application/json']
          });

  test('record plan is read only and clears on failure and session end',
      () async {
    respond = (_) async => planReply();
    await service.load();
    expect(service.sourcePlan!.domainLabel, 'Chat');
    expect(requests.every((r) => r.method == 'GET'), isTrue);
    respond = (r) async => throw DioException(
        requestOptions: r, type: DioExceptionType.connectionError);
    await service.load();
    expect(service.sourcePlan, isNull);
    expect(service.ready, false);
    respond = (_) async => planReply();
    await service.load();
    PrivacyRequestService.endAllSessions();
    expect(service.sourcePlan, isNull);
  });
  test('record plan rejects private data and mismatched or completed outcomes',
      () {
    final a = PrivacyDispositionSummary.parse(actionAssessment(), 'erasure');
    expect(PrivacySourcePlanSummary.parse(sourcePlan(), a)!.domain, 'chat');
    for (final change in [
      {'recordId': 'private'},
      {'reference': 'private'},
      {'status': 'completed'},
      {'execution': 'deleted'},
      {'execution': 'applied'},
      {'status': 'applied_verified', 'execution': 'applied'},
      {'assessmentId': 'a' * 64},
      {'domain': 'ratings'},
      {'recordCount': 2},
      {'kind': 'correction'},
      {'reviewedAt': 'invalid'},
      {'reviewedAt': '2020-01-01T00:00:00Z'},
    ]) {
      expect(
          () => PrivacySourcePlanSummary.parse({...sourcePlan(), ...change}, a),
          throwsFormatException);
    }
    expect(() => PrivacySourcePlanSummary.parse(sourcePlan(), null),
        throwsFormatException);
  });
  test('private mutation intent never enters the participant plan contract',
      () async {
    for (final privateField in [
      {
        'mutation': {
          'operation': 'replace_text',
          'field': 'text',
          'replacement': 'PRIVATE PROPOSAL'
        }
      },
      {'replacement': 'PRIVATE PROPOSAL'},
      {'executionOutcomes': []},
      {'intentReviewed': true},
      {
        'preflight': {
          'eligible': false,
          'blockingReasons': ['PRIVATE_REASON']
        }
      },
      {'executionEnabled': true},
      {'operatorExecutionPreparations': []},
      {'executionPreparations': []},
      {
        'preservationDecision': {'decision': 'permit_planned_change'}
      },
      {
        'operatorPreservationDecision': {'note': 'PRIVATE EVIDENCE'}
      },
    ]) {
      respond =
          (_) async => planReply(plan: {...sourcePlan(), ...privateField});
      await service.load();
      expect(service.ready, false);
      expect(service.sourcePlan, isNull);
      expect(service.disposition, isNull);
    }
    respond = (_) async => planReply();
    await service.load();
    expect(service.ready, true);
    expect(service.sourcePlan!.domainLabel, 'Chat');
  });

  test('untrusted source plan fails the entire response closed', () async {
    final assessment =
        PrivacyDispositionSummary.parse(actionAssessment(), 'erasure');
    for (final execution in ['applied', 'verified']) {
      final raw = {
        ...sourcePlan(),
        'execution': execution,
        'status': execution == 'applied'
            ? 'applied_pending_verification'
            : 'applied_verified'
      };
      final parsed = PrivacySourcePlanSummary.parse(raw, assessment)!;
      expect(parsed.execution, execution);
      expect(
          parsed.title,
          contains(
              execution == 'applied' ? 'awaiting verification' : 'verified'));
      expect(parsed.explanation, isNot(contains('No record has been changed')));
      respond = (_) async => planReply(plan: raw);
      await service.load();
      expect(service.sourcePlan!.execution, execution);
    }
    respond =
        (_) async => planReply(plan: {...sourcePlan(), 'status': 'completed'});
    await service.load();
    expect(service.ready, false);
    expect(service.sourcePlan, isNull);
    expect(service.disposition, isNull);
  });
  testWidgets(
      'blocked record plan fits compact large text and clears on logout',
      (tester) async {
    await (FontLoader('Poppins')
          ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf')))
        .load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    respond = (_) async => planReply();
    await tester.pumpWidget(MaterialApp(
        theme: RidzsTheme.refine(ThemeData(colorScheme: flexSchemeLight)),
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!),
        home: RepaintBoundary(
            key: const ValueKey('source-plan-golden'),
            child: PrivacyRequestScreen(service: service))));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Record action blocked'));
    await tester.pumpAndSettle();
    expect(find.text('One chat record plan independently reviewed.'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
    await expectLater(find.byKey(const ValueKey('source-plan-golden')),
        matchesGoldenFile('goldens/privacy_source_plan_large_text.png'));
    for (final execution in ['applied', 'verified']) {
      respond = (_) async => planReply(plan: {
            ...sourcePlan(),
            'execution': execution,
            'status': execution == 'applied'
                ? 'applied_pending_verification'
                : 'applied_verified'
          });
      final loading = service.load();
      await tester.pumpAndSettle();
      await loading;
      await tester.ensureVisible(find.text(service.sourcePlan!.title));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
          find.byKey(const ValueKey('source-plan-golden')),
          matchesGoldenFile(
              'goldens/privacy_source_${execution}_large_text.png'));
    }
    PrivacyRequestService.endAllSessions();
    await tester.pumpAndSettle();
    expect(find.text('Record action blocked'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    service = PrivacyRequestService(dio: dio, tokenReader: () async => token);
  });

  test('reviewed content needs explicit access and clears on logout', () async {
    respond = (r) async => disclosureReply(
        reviewedContent: true,
        content: r.method == 'POST',
        version: r.method == 'POST' ? 5 : 4,
        page: contentPage());
    await service.load();
    expect(service.disclosure!.hasContent, true);
    expect(service.disclosedPage, isNull);
    await service.accessDisclosure();
    expect(service.disclosedPage!.records.single['content'],
        contains('[REDACTED]'));
    PrivacyRequestService.endAllSessions();
    expect(service.disclosedPage, isNull);
    expect(service.disclosure, isNull);
  });

  test(
      'reviewed content schema rejects private fields and invalid dispositions',
      () {
    final summary = PrivacyDisclosureSummary.parse(
        {...disclosureSummary(), 'scope': 'own_content_v1'})!;
    final page = contentPage();
    expect(PrivacyDisclosurePage.parse(page, summary).records.length, 1);
    for (final changes in [
      {'content': 'Secret', 'disposition': 'withheld'},
      {'content': 'Not redacted', 'disposition': 'redacted'},
      {'reviewSource': 'Original secret'},
      {'reason': 'restricted'},
      {'content': 'x' * 2501},
      {'disposition': 'pending'},
    ]) {
      final row = {
        ...(page['records'] as List).single as Map<String, dynamic>,
        ...changes
      };
      expect(
          () => PrivacyDisclosurePage.parse({
                ...page,
                'records': [row]
              }, summary),
          throwsFormatException);
    }
    expect(
        () =>
            PrivacyDisclosurePage.parse({...page, 'reviewSource': {}}, summary),
        throwsFormatException);
    expect(
        () => PrivacyDisclosurePage.parse(
            page, PrivacyDisclosureSummary.parse(disclosureSummary())!),
        throwsFormatException);
  });

  test('five-record content pages support all domains and explicit withholding',
      () {
    for (final domain in ['chat', 'ratings', 'safety']) {
      final summary = PrivacyDisclosureSummary.parse({
        ...disclosureSummary(),
        'domain': domain,
        'scope': 'own_content_v1'
      })!;
      final rows = List.generate(
          5,
          (i) => {
                'id': (i + 1).toRadixString(16).padLeft(64, '0'),
                'createdAt': '2026-01-01T00:00:00Z',
                if (domain == 'ratings') 'stars': 4,
                if (domain == 'safety') ...{
                  'status': 'open',
                  'reporterSafe': false,
                  'updatedAt': '2026-01-01T00:00:00Z'
                },
                'content': '',
                'disposition': 'withheld'
              });
      final page = {
        ...contentPage(),
        'domain': domain,
        'records': rows,
        'hasMore': true,
        'nextCursor': rows.last['id']
      };
      expect(PrivacyDisclosurePage.parse(page, summary).hasMore, true);
      expect(
          () => PrivacyDisclosurePage.parse({
                ...page,
                'records': [...rows, rows.last]
              }, summary),
          throwsFormatException);
    }
  });

  testWidgets(
      'reviewed content is readable at compact large text and clears on refresh',
      (tester) async {
    final font = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    respond = (r) async => disclosureReply(
        reviewedContent: true,
        content: r.method == 'POST',
        version: r.method == 'POST' ? 5 : 4,
        page: contentPage());
    await tester.pumpWidget(MaterialApp(
        theme: RidzsTheme.refine(ThemeData(colorScheme: flexSchemeLight)),
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!),
        home: RepaintBoundary(
            key: const ValueKey('content-golden'),
            child: PrivacyRequestScreen(service: service))));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('View reviewed content'));
    await tester.tap(find.text('View reviewed content'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Reviewed own content'));
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsOneWidget);
    expect(tester.takeException(), isNull);
    await expectLater(find.byKey(const ValueKey('content-golden')),
        matchesGoldenFile('goldens/reviewed_content_large_text.png'));
    final refresh = service.load();
    await tester.pumpAndSettle();
    await refresh;
    expect(find.byType(SelectableText), findsNothing);
    await tester.pumpWidget(const SizedBox());
    service = PrivacyRequestService(dio: dio, tokenReader: () async => token);
  });

  test(
      'approved summary requires explicit audited access before displaying content',
      () async {
    respond = (_) async => disclosureReply();
    await service.load();
    expect(service.canAccess, true);
    expect(service.disclosedPage, isNull);
    respond = (_) async => disclosureReply(content: true, version: 5);
    await service.accessDisclosure();
    expect(requests.last.path, '/privacy-request/disclosure');
    expect(requests.last.data['version'], 4);
    expect(requests.last.data['receiptId'], matches(RegExp(r'^[a-f0-9]{32}$')));
    expect(service.record!.version, 5);
    expect(service.disclosedPage!.records.single['stars'], 4);
    expect(service.notice, contains('fulfillment remains pending'));
    respond = (_) async => disclosureReply(version: 5);
    await service.load();
    expect(service.disclosedPage, isNull);
  });
  test('unconfirmed access retries the same receipt and version', () async {
    respond = (_) async => disclosureReply();
    await service.load();
    respond = (r) async => throw DioException(
        requestOptions: r, type: DioExceptionType.receiveTimeout);
    await service.accessDisclosure();
    expect(service.hasPending, true);
    expect(service.disclosedPage, isNull);
    final command = Map<String, dynamic>.from(requests.last.data);
    respond = (_) async => disclosureReply(content: true, version: 5);
    await service.retry();
    expect(requests.last.data, command);
    expect(service.disclosedPage, isNotNull);
    expect(service.hasPending, false);
  });
  test('failed refresh does not rebind a pending access retry', () async {
    respond = (_) async => disclosureReply();
    await service.load();
    respond = (r) async => throw DioException(
        requestOptions: r, type: DioExceptionType.receiveTimeout);
    await service.accessDisclosure();
    final command = requests.last.data;
    await service.load();
    respond = (_) async => disclosureReply(content: true, version: 5);
    await service.retry();
    expect(requests.last.data, command);
    expect(service.disclosedPage, isNotNull);
  });
  test('source conflict clears the approved page and requires refresh',
      () async {
    respond = (_) async => disclosureReply();
    await service.load();
    respond = (_) async => reply(null, status: 409);
    await service.accessDisclosure();
    expect(service.ready, false);
    expect(service.disclosure, isNull);
    expect(service.disclosedPage, isNull);
    expect(service.hasPending, false);
  });
  test('unexpected free text and mismatched disclosure IDs are never shown',
      () async {
    respond = (_) async => disclosureReply();
    await service.load();
    final bad = disclosedPage();
    (bad['records'] as List).single['feedback'] = 'PRIVATE THIRD PARTY TEXT';
    respond =
        (_) async => disclosureReply(content: true, version: 5, page: bad);
    await service.accessDisclosure();
    expect(service.disclosedPage, isNull);
    expect(service.notice, isNull);
    expect(service.hasPending, true);
    respond = (_) async => disclosureReply(
        content: true, version: 5, page: {...disclosedPage(), 'id': 'b' * 64});
    await service.retry();
    expect(service.disclosedPage, isNull);
  });
  test('logout suppresses late disclosed content and clears all private state',
      () async {
    respond = (_) async => disclosureReply();
    await service.load();
    final entered = Completer<void>(), release = Completer<void>();
    respond = (_) async {
      entered.complete();
      await release.future;
      return disclosureReply(content: true, version: 5);
    };
    final loading = service.accessDisclosure();
    await entered.future;
    PrivacyRequestService.endAllSessions();
    release.complete();
    await loading;
    expect(service.disclosedPage, isNull);
    expect(service.disclosure, isNull);
    expect(service.record, isNull);
    expect(service.hasPending, false);
  });
  test(
      'disclosure parser rejects invalid fields in every domain and cursor claims',
      () {
    final summary = PrivacyDisclosureSummary.parse(disclosureSummary())!;
    expect(
        () => PrivacyDisclosurePage.parse(
            {...disclosedPage(), 'hasMore': true, 'nextCursor': 'f' * 64},
            summary),
        throwsFormatException);
    for (final domain in ['chat', 'safety']) {
      final header = {...disclosureSummary(), 'domain': domain};
      final expected = PrivacyDisclosureSummary.parse(header)!;
      final row = {
        'id': 'f' * 64,
        'createdAt': '2026-01-01T00:00:00Z',
        if (domain == 'safety') ...{
          'status': 'open',
          'reporterSafe': false,
          'updatedAt': '2026-01-02T00:00:00Z'
        }
      };
      final page = {
        ...disclosedPage(),
        ...header,
        'records': [row]
      };
      expect(PrivacyDisclosurePage.parse(page, expected).records, hasLength(1));
      row['reason'] = 'PRIVATE';
      expect(() => PrivacyDisclosurePage.parse(page, expected),
          throwsFormatException);
    }
  });
  test('loads explicit absence and submits only version kind and details',
      () async {
    await service.load();
    expect(service.canSubmit, true);
    await service.submit('access', ' Private request ');
    expect(requests.last.path, '/privacy-request');
    expect(requests.last.data,
        {'version': 0, 'kind': 'access', 'details': 'Private request'});
    expect(service.record!.status, 'pending');
    expect(service.canSubmit, false);
    expect(service.notice, contains('Fulfillment remains pending'));
  });
  test('lost response locks intent and exact retry recovers current state',
      () async {
    await service.load();
    respond = (r) async => throw DioException(
        requestOptions: r, type: DioExceptionType.receiveTimeout);
    await service.submit('access', 'Private request');
    expect(service.hasPending, true);
    expect(service.canSubmit, false);
    await service.submit('erasure', 'Changed');
    expect(requests, hasLength(2));
    respond = (_) async => reply(saved(status: 'reviewed', version: 2));
    await service.retry();
    expect(requests[1].data, requests[2].data);
    expect(service.record!.version, 2);
    expect(service.hasPending, false);
  });
  test('conflict needs refresh and does not silently rebase a command',
      () async {
    await service.load();
    respond = (_) async => reply(null, status: 409);
    await service.submit('access', 'Private request');
    expect(service.ready, false);
    expect(service.hasPending, false);
    expect(service.error, contains('Refresh'));
    await service.submit('access', 'Different');
    expect(requests, hasLength(2));
    respond = (_) async => reply(saved(status: 'reviewed', version: 2));
    await service.load();
    expect(service.canSubmit, true);
  });
  test('missing or malformed envelope never means absence or confirmation',
      () async {
    respond = (_) async =>
        ResponseBody.fromString('{"success":true,"data":{}}', 200, headers: {
          'content-type': ['application/json']
        });
    await service.load();
    expect(service.ready, false);
    respond = (_) async => reply(null);
    await service.load();
    respond = (_) async => reply(null);
    await service.submit('access', 'Private request');
    expect(service.hasPending, true);
    expect(service.notice, isNull);
  });
  test('wrong role or future contract fulfillment claim is rejected', () {
    final other = saved()..['role'] = 'admin';
    expect(
        () => PrivacyRequest.parse({
              'hasRequest': true,
              'request': other,
              'fulfilled': false,
              'deletionEnabled': false
            }),
        throwsFormatException);
    expect(
        () => PrivacyRequest.parse({
              'hasRequest': true,
              'request': saved(),
              'fulfilled': true,
              'deletionEnabled': false
            }),
        throwsFormatException);
  });
  test('failed initial lookup never enables submission', () async {
    respond = (_) async => reply(null, status: 503);
    await service.load();
    await service.submit('access', 'Private request');
    expect(service.ready, false);
    expect(requests, hasLength(1));
  });
  test('explicit absence accepts omitted null but not a contradictory record',
      () {
    expect(
        PrivacyRequest.parse({
          'hasRequest': false,
          'fulfilled': false,
          'deletionEnabled': false
        }),
        isNull);
    expect(
        () => PrivacyRequest.parse({
              'hasRequest': false,
              'request': saved(),
              'fulfilled': false,
              'deletionEnabled': false
            }),
        throwsFormatException);
  });
  test('same revision with different submitted content is not confirmation',
      () async {
    await service.load();
    respond = (_) async => reply(saved()..['details'] = 'Different request');
    await service.submit('access', 'Private request');
    expect(service.notice, isNull);
    expect(service.hasPending, true);
    expect(service.record, isNull);
  });
  test(
      'restart recovers only GET and reviewed case can submit at current revision',
      () async {
    respond = (_) async => reply(saved(status: 'reviewed', version: 2));
    await service.load();
    expect(service.canSubmit, true);
    respond = (_) async => reply(saved(version: 3));
    await service.submit('access', 'Private request');
    expect(requests.last.data['version'], 2);
    expect(service.record!.version, 3);
  });
  test('session change prevents reuse of private intent', () async {
    await service.load();
    token = 'account-two';
    await service.submit('access', 'Private request');
    expect(service.ended, true);
    expect(service.record, isNull);
    expect(service.hasPending, false);
    expect(requests, hasLength(1));
  });
  test('interceptor checks expected account at actual send time', () async {
    dio.interceptors.clear();
    dio.interceptors.add(
        AuthInterceptor(dio, tokenReader: () async => 'different-account'));
    await service.load();
    expect(requests, isEmpty);
    expect(service.ready, false);
  });
  test('logout clears pending and suppresses late response', () async {
    final entered = Completer<void>(), release = Completer<void>();
    respond = (_) async {
      entered.complete();
      await release.future;
      return reply(saved());
    };
    final loading = service.load();
    await entered.future;
    PrivacyRequestService.endAllSessions();
    release.complete();
    await loading;
    expect(service.ended, true);
    expect(service.record, isNull);
    expect(service.ready, false);
  });
  test('401 expires the local private session', () async {
    respond = (_) async => reply(null, status: 401);
    await service.load();
    expect(service.ended, true);
    expect(service.record, isNull);
  });

  testWidgets(
      'approved disclosure fits compact large text and clears on refresh',
      (tester) async {
    final font = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    respond = (r) async => disclosureReply(
        content: r.method == 'POST', version: r.method == 'POST' ? 5 : 4);
    await tester.pumpWidget(MaterialApp(
        theme: RidzsTheme.refine(ThemeData(colorScheme: flexSchemeLight)),
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!),
        home: RepaintBoundary(
            key: const ValueKey('disclosure-golden'),
            child: PrivacyRequestScreen(service: service))));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('View approved metadata'));
    await tester.tap(find.text('View approved metadata'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Own record metadata'));
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsOneWidget);
    expect(tester.takeException(), isNull);
    await expectLater(find.byKey(const ValueKey('disclosure-golden')),
        matchesGoldenFile('goldens/disclosure_large_text.png'));
    respond = (_) async => reply(saved(status: 'pending', version: 6));
    final refresh = service.load();
    await tester.pumpAndSettle();
    await refresh;
    expect(find.byType(SelectableText), findsNothing);
    expect(find.text('View approved metadata'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    service = PrivacyRequestService(dio: dio, tokenReader: () async => token);
  });
  testWidgets('compact screen supports submission and clears details on logout',
      (tester) async {
    final font = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: RidzsTheme.refine(ThemeData(colorScheme: flexSchemeLight)),
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!),
        home: RepaintBoundary(
            key: const ValueKey('privacy-golden'),
            child: PrivacyRequestScreen(service: service))));
    await tester.pumpAndSettle();
    await expectLater(find.byKey(const ValueKey('privacy-golden')),
        matchesGoldenFile('goldens/privacy_large_text.png'));
    await tester.enterText(find.byType(TextField), 'Private request');
    await tester.ensureVisible(find.text('Submit request'));
    await tester.tap(find.text('Submit request'));
    await tester.pumpAndSettle();
    expect(find.text('Awaiting review'), findsOneWidget);
    expect(tester.takeException(), isNull);
    PrivacyRequestService.endAllSessions();
    await tester.pumpAndSettle();
    expect(find.text('Private request'), findsNothing);
    expect(find.textContaining('Session ended.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    // The screen owns and disposes its session; replace the test fixture.
    service = PrivacyRequestService(dio: dio, tokenReader: () async => token);
  });
}
