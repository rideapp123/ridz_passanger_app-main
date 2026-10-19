import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/models/privacy_disclosure.dart';
import 'package:ridzs_passenger_app/models/privacy_disposition.dart';
import 'package:ridzs_passenger_app/services/privacy_request_service.dart';
import 'package:ridzs_passenger_app/view/profile/privacy_request_screen.dart';
import 'package:ridzs_passenger_app/core/theme/ridzs_theme.dart';
import 'package:ridzs_passenger_app/core/theme/light_theme.dart';

Map<String, dynamic> summary(String domain) => {
      'id': 'a' * 64,
      'domain': domain,
      'rideId': 'b' * 64,
      'preparedAt': '2026-01-01T00:00:00Z',
      'scope': 'own_booking_metadata_v1',
    };
Map<String, dynamic> page(String domain) => {
      ...summary(domain),
      'pageSha256': 'c' * 64,
      'redaction': 'location_payment_and_internal_evidence_omitted',
      'hasMore': false,
      'records': [
        {
          'id': 'b' * 64,
          'state': domain == 'booking_quotes'
              ? 'issued'
              : domain == 'booking_attempts'
                  ? 'PROCESSING'
                  : 'consumed',
          'preservation': 'payment_recovery',
        }
      ],
    };
void main() {
  for (final domain in PrivacyDisclosureSummary.bookingDomains) {
    test('$domain reviewed content has strict scope, identity and redaction',
        () {
      final raw = page(domain)
        ..['scope'] = 'own_booking_content_v1'
        ..['redaction'] = 'operator_reviewed_booking_content';
      final row = (raw['records'] as List).single as Map;
      row.addAll(<String, String>{
        'content': 'Pickup address: [REDACTED]',
        'disposition': 'redacted'
      });
      final expected = PrivacyDisclosureSummary.parse(
          {...summary(domain), 'scope': 'own_booking_content_v1'})!;
      expect(expected.hasContent, true);
      expect(
          PrivacyDisclosurePage.parse(raw, expected).summary.isBooking, true);
      for (final mutation in [
        {'content': 'hidden location', 'disposition': 'withheld'},
        {'content': 'unredacted location', 'disposition': 'redacted'},
        {'content': 'location', 'disposition': 'unknown'},
        {'content': 'x' * 2501, 'disposition': 'full'},
      ]) {
        final invalid = {
          ...raw,
          'records': [
            {...row, ...mutation}
          ]
        };
        expect(() => PrivacyDisclosurePage.parse(invalid, expected),
            throwsFormatException);
      }
      expect(
          () => PrivacyDisclosurePage.parse(
              {...raw, 'redaction': 'operator_reviewed_content'}, expected),
          throwsFormatException);
      expect(
          () => PrivacyDisclosureSummary.parse(
              {...summary('chat'), 'scope': 'own_booking_content_v1'}),
          throwsFormatException);
      expect(
          () => PrivacyDisclosurePage.parse({
                ...raw,
                'records': [
                  {...row, 'snapshot': 'PRIVATE'}
                ]
              }, expected),
          throwsFormatException);
      final package = PrivacyResponsePackage.parse({
        'id': 'd' * 64,
        'publishedAt': '2026-01-01T00:00:00Z',
        'coverageComplete': false,
        'pages': [
          {...summary(domain), 'scope': 'own_booking_content_v1'}
        ],
      })!;
      expect(package.pages.single.hasContent, true);
    });
    test('$domain accepts only protected metadata with exact identity', () {
      final expected = PrivacyDisclosureSummary.parse(summary(domain))!;
      expect(expected.isBooking, true);
      expect(expected.referenceLabel, 'Record');
      expect(
          PrivacyDisclosurePage.parse(page(domain), expected)
              .records
              .single['preservation'],
          'payment_recovery');
      for (final extra in ['snapshot', 'latitude', 'cardId', 'passengerId']) {
        final raw = page(domain);
        (raw['records'] as List).single[extra] = 'PRIVATE';
        expect(() => PrivacyDisclosurePage.parse(raw, expected),
            throwsFormatException);
      }
      for (final change in [
        {'state': 'paid'},
        {'preservation': 'deleted'},
        {'id': 'd' * 64},
      ]) {
        final raw = page(domain);
        (raw['records'] as List).single.addAll(change);
        expect(() => PrivacyDisclosurePage.parse(raw, expected),
            throwsFormatException);
      }
      expect(
          () => PrivacyDisclosurePage.parse(
              {...page(domain), 'records': []}, expected),
          throwsFormatException);
      expect(
          () => PrivacyDisclosurePage.parse(
              {...page(domain), 'hasMore': true}, expected),
          throwsFormatException);
      expect(
          () => PrivacyDisclosureSummary.parse(
              {...summary(domain), 'scope': 'own_content_v1'}),
          throwsFormatException);
      expect(
          () => PrivacyDisclosureSummary.parse(
              {...summary(domain), 'rideId': 'ride-one'}),
          throwsFormatException);
    });
    test('$domain retention assessment never reports deletion', () {
      final raw = {
        'id': 'a' * 64,
        'kind': 'erasure',
        'scope': domain,
        'decision': 'retained',
        'reason': 'preservation_review',
        'reviewedAt': '2026-01-01T00:00:00Z',
        'execution': 'not_performed',
      };
      expect(PrivacyDispositionSummary.parse(raw, 'erasure')!.title,
          'Records retained');
      expect(
          () => PrivacyDispositionSummary.parse(
              {...raw, 'execution': 'deleted'}, 'erasure'),
          throwsFormatException);
    });
  }

  for (final content in [false, true]) {
    testWidgets(
        'booking content=$content needs explicit access and remains readable at large text',
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
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/passenger'));
      final requests = <RequestOptions>[];
      final offered = {
        ...summary('booking_quotes'),
        if (content) 'scope': 'own_booking_content_v1'
      };
      final disclosed = page('booking_quotes');
      if (content) {
        disclosed['scope'] = 'own_booking_content_v1';
        disclosed['redaction'] = 'operator_reviewed_booking_content';
        (disclosed['records'] as List).single.addAll({
          'content': 'Pickup address: [REDACTED]\nQuoted total (USD): 12.35',
          'disposition': 'redacted',
        });
      }
      dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
        requests.add(options);
        handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: jsonDecode(jsonEncode({
              'success': true,
              'data': {
                'hasRequest': true,
                'fulfilled': false,
                'deletionEnabled': false,
                'request': {
                  'id': 'd' * 64,
                  'role': 'passenger',
                  'kind': 'access',
                  'details': 'Requested metadata',
                  'status': 'reviewed',
                  'version': options.method == 'POST' ? 5 : 4,
                  'submittedAt': '2026-01-01T00:00:00Z',
                  'updatedAt': '2026-01-01T00:00:00Z',
                },
                'disclosure': offered,
                if (options.method == 'POST') 'disclosedPage': disclosed,
              }
            }))));
      }));
      final service = PrivacyRequestService(
          dio: dio, tokenReader: () async => 'test-token');
      await tester.pumpWidget(MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: RidzsTheme.refine(ThemeData(colorScheme: flexSchemeLight)),
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!),
          home: PrivacyRequestScreen(service: service)));
      await tester.pumpAndSettle();
      expect(service.error, isNull);
      expect(service.disclosure, isNotNull);
      expect(service.disclosedPage, isNull);
      expect(requests.where((r) => r.method == 'POST'), isEmpty);
      final action =
          content ? 'View reviewed content' : 'View approved metadata';
      await tester.scrollUntilVisible(find.text(action), 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(find.text(action));
      await tester.pumpAndSettle();
      expect(service.disclosedPage, isNotNull);
      final notice = find.textContaining(content
          ? 'Quoted amounts are not payment receipts.'
          : 'Records preserved for payment recovery.');
      await tester.scrollUntilVisible(notice, 100,
          scrollable: find.byType(Scrollable).first);
      expect(notice, findsOneWidget);
      await tester.scrollUntilVisible(find.byType(SelectableText), 200,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      if (content) {
        await expectLater(find.byType(MaterialApp),
            matchesGoldenFile('goldens/booking_content_large_text.png'));
        PrivacyRequestService.endAllSessions();
        await tester.pumpAndSettle();
        expect(find.byType(SelectableText), findsNothing);
        expect(service.disclosedPage, isNull);
      }
      await tester.pumpWidget(const SizedBox());
      dio.close(force: true);
    });
  }
}
