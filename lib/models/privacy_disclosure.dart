class PrivacyDisclosureSummary {
  const PrivacyDisclosureSummary(
      this.id, this.domain, this.rideId, this.preparedAt,
      [this.scope = 'own_metadata_v1']);
  final String id, domain, rideId, preparedAt, scope;
  bool get hasContent =>
      scope == 'own_content_v1' || scope == 'own_booking_content_v1';
  bool get isBooking => bookingDomains.contains(domain);
  static const bookingDomains = {
    'booking_quotes',
    'booking_attempts',
    'quote_consumptions'
  };
  static const domains = {'chat', 'ratings', 'safety', ...bookingDomains};
  String get domainLabel => const {
        'chat': 'chat',
        'ratings': 'ratings',
        'safety': 'safety',
        'booking_quotes': 'Booking quotes',
        'booking_attempts': 'Quoted booking attempts',
        'quote_consumptions': 'Quote consumption records',
      }[domain]!;
  String get referenceLabel => isBooking ? 'Record' : 'Ride';
  static final _id = RegExp(r'^[a-f0-9]{64}$');
  static bool validId(dynamic value) => value is String && _id.hasMatch(value);
  static bool validDate(dynamic value) =>
      value is String && DateTime.tryParse(value) != null;
  static PrivacyDisclosureSummary? parse(dynamic raw) {
    if (raw == null) return null;
    if (raw is! Map ||
        raw.keys.toSet().difference(
            {'id', 'domain', 'rideId', 'preparedAt', 'scope'}).isNotEmpty ||
        !validId(raw['id']) ||
        !domains.contains(raw['domain']) ||
        raw['rideId'] is! String ||
        !RegExp(r'^[A-Za-z0-9_-]{1,120}$').hasMatch(raw['rideId']) ||
        !validDate(raw['preparedAt']) ||
        !const {
          'own_metadata_v1',
          'own_content_v1',
          'own_booking_metadata_v1',
          'own_booking_content_v1'
        }.contains(raw['scope']) ||
        (bookingDomains.contains(raw['domain']) !=
            const {'own_booking_metadata_v1', 'own_booking_content_v1'}
                .contains(raw['scope'])) ||
        (bookingDomains.contains(raw['domain']) && !validId(raw['rideId']))) {
      throw const FormatException('Invalid disclosure summary');
    }
    return PrivacyDisclosureSummary(raw['id'], raw['domain'], raw['rideId'],
        raw['preparedAt'], raw['scope']);
  }
}

class PrivacyResponsePackage {
  const PrivacyResponsePackage(this.id, this.publishedAt, this.pages);
  final String id, publishedAt;
  final List<PrivacyDisclosureSummary> pages;
  static PrivacyResponsePackage? parse(dynamic raw) {
    if (raw == null) return null;
    if (raw is! Map ||
        raw.keys.toSet().difference(
            {'id', 'publishedAt', 'coverageComplete', 'pages'}).isNotEmpty ||
        !PrivacyDisclosureSummary.validId(raw['id']) ||
        !PrivacyDisclosureSummary.validDate(raw['publishedAt']) ||
        raw['coverageComplete'] != false ||
        raw['pages'] is! List ||
        (raw['pages'] as List).isEmpty ||
        (raw['pages'] as List).length > 10) {
      throw const FormatException('Invalid response package');
    }
    final pages = <PrivacyDisclosureSummary>[];
    for (final value in raw['pages'] as List) {
      final page = PrivacyDisclosureSummary.parse(value);
      if (page == null || pages.any((item) => item.id == page.id)) {
        throw const FormatException('Invalid package page');
      }
      pages.add(page);
    }
    return PrivacyResponsePackage(
        raw['id'], raw['publishedAt'], List.unmodifiable(pages));
  }
}

class PrivacyDisclosurePage {
  const PrivacyDisclosurePage(
      this.summary, this.records, this.hasMore, this.nextCursor);
  final PrivacyDisclosureSummary summary;
  final List<Map<String, dynamic>> records;
  final bool hasMore;
  final String? nextCursor;
  static PrivacyDisclosurePage parse(
      dynamic raw, PrivacyDisclosureSummary expected) {
    if (raw is! Map ||
        raw.keys.toSet().difference({
          'id',
          'domain',
          'rideId',
          'preparedAt',
          'scope',
          'redaction',
          'records',
          'hasMore',
          'nextCursor',
          'pageSha256'
        }).isNotEmpty ||
        raw['id'] != expected.id ||
        raw['domain'] != expected.domain ||
        raw['rideId'] != expected.rideId ||
        raw['preparedAt'] != expected.preparedAt ||
        raw['scope'] != expected.scope ||
        raw['redaction'] !=
            (expected.isBooking
                ? expected.hasContent
                    ? 'operator_reviewed_booking_content'
                    : 'location_payment_and_internal_evidence_omitted'
                : expected.hasContent
                    ? 'operator_reviewed_content'
                    : 'free_text_and_third_party_omitted') ||
        !PrivacyDisclosureSummary.validId(raw['pageSha256']) ||
        raw['records'] is! List ||
        (raw['records'] as List).length > (expected.hasContent ? 5 : 20) ||
        raw['hasMore'] is! bool) {
      throw const FormatException('Invalid disclosure page');
    }
    final keys = {
      'id',
      if (!expected.isBooking) 'createdAt',
      if (expected.isBooking) ...['state', 'preservation'],
      if (expected.hasContent) ...['content', 'disposition'],
      if (expected.domain == 'ratings') 'stars',
      if (expected.domain == 'safety') ...[
        'status',
        'reporterSafe',
        'updatedAt'
      ]
    };
    final rows = <Map<String, dynamic>>[];
    String? previous;
    for (final row in raw['records'] as List) {
      if (row is! Map ||
          row.keys.toSet().difference(keys).isNotEmpty ||
          !row.keys.toSet().containsAll(keys) ||
          !PrivacyDisclosureSummary.validId(row['id']) ||
          (!expected.isBooking &&
              !PrivacyDisclosureSummary.validDate(row['createdAt'])) ||
          (previous != null && previous.compareTo(row['id']) >= 0)) {
        throw const FormatException('Invalid disclosed record');
      }
      if (expected.isBooking &&
          (row['id'] != expected.rideId ||
              row['preservation'] != 'payment_recovery' ||
              !(switch (expected.domain) {
                'booking_quotes' => const {'issued'},
                'booking_attempts' => const {
                    'PROCESSING',
                    'CONFIRMED',
                    'REJECTED'
                  },
                _ => const {'consumed'},
              })
                  .contains(row['state']))) {
        throw const FormatException('Invalid booking metadata');
      }
      if (expected.domain == 'ratings' &&
          (row['stars'] is! int || row['stars'] < 1 || row['stars'] > 5)) {
        throw const FormatException('Invalid rating metadata');
      }
      if (expected.hasContent &&
          (row['content'] is! String ||
              (row['content'] as String).length > 2500 ||
              !const {'full', 'redacted', 'withheld'}
                  .contains(row['disposition']) ||
              (row['disposition'] == 'withheld' && row['content'] != '') ||
              (row['disposition'] == 'redacted' &&
                  !(row['content'] as String).contains('[REDACTED]')))) {
        throw const FormatException('Invalid reviewed content');
      }
      if (expected.domain == 'safety' &&
          (!const {'open', 'acknowledged', 'resolved'}
                  .contains(row['status']) ||
              row['reporterSafe'] is! bool ||
              !PrivacyDisclosureSummary.validDate(row['updatedAt']))) {
        throw const FormatException('Invalid safety metadata');
      }
      previous = row['id'];
      rows.add(Map.unmodifiable(Map<String, dynamic>.from(row)));
    }
    if ((expected.isBooking && (rows.length != 1 || raw['hasMore'] != false)) ||
        (raw['hasMore'] == true &&
            (rows.length != (expected.hasContent ? 5 : 20) ||
                raw['nextCursor'] != rows.last['id'])) ||
        (raw['hasMore'] == false && raw['nextCursor'] != null)) {
      throw const FormatException('Invalid disclosure paging');
    }
    return PrivacyDisclosurePage(
        expected, List.unmodifiable(rows), raw['hasMore'], raw['nextCursor']);
  }
}
