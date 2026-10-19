class PrivacyDispositionSummary {
  const PrivacyDispositionSummary(this.id, this.kind, this.scope, this.decision,
      this.reason, this.reviewedAt);
  final String id, kind, scope, decision, reason, reviewedAt;
  static const scopes = {
    'chat': 'Chat',
    'ratings': 'Ratings',
    'safety': 'Safety reports',
    'account': 'Account data',
    'external_systems': 'External systems',
    'booking_quotes': 'Booking quotes',
    'booking_attempts': 'Quoted booking attempts',
    'quote_consumptions': 'Quote consumption records',
  };
  static const decisions = {
    'needs_information': 'More information needed',
    'action_required': 'Action required',
    'no_change_identified': 'No change identified',
    'retained': 'Records retained',
  };
  static const reasons = {
    'identity_check': 'Identity verification is needed.',
    'scope_clarification': 'The request scope needs clarification.',
    'correction_review': 'Correction requires further action.',
    'erasure_review': 'Erasure requires further action.',
    'no_matching_records':
        'No matching records were identified in the reviewed scope.',
    'already_accurate': 'The reviewed information was assessed as accurate.',
    'retention_review': 'Records are retained following retention review.',
    'preservation_review':
        'Records are retained following preservation review.',
  };
  String get title => decisions[decision]!;
  String get scopeLabel => scopes[scope]!;
  String get explanation => reasons[reason]!;

  static PrivacyDispositionSummary? parse(dynamic raw, String? expectedKind) {
    if (raw == null) return null;
    const keys = {
      'id',
      'kind',
      'scope',
      'decision',
      'reason',
      'reviewedAt',
      'execution'
    };
    if (raw is! Map ||
        raw.keys.toSet().difference(keys).isNotEmpty ||
        !raw.keys.toSet().containsAll(keys) ||
        raw['id'] is! String ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(raw['id']) ||
        !const {'correction', 'erasure'}.contains(raw['kind']) ||
        raw['kind'] != expectedKind ||
        !scopes.containsKey(raw['scope']) ||
        !decisions.containsKey(raw['decision']) ||
        !reasons.containsKey(raw['reason']) ||
        raw['reviewedAt'] is! String ||
        DateTime.tryParse(raw['reviewedAt']) == null ||
        raw['execution'] != 'not_performed') {
      throw const FormatException('Invalid request assessment');
    }
    final allowed = switch (raw['decision']) {
      'needs_information' => const {'identity_check', 'scope_clarification'},
      'action_required' => {
          raw['kind'] == 'correction' ? 'correction_review' : 'erasure_review'
        },
      'no_change_identified' => {
          'no_matching_records',
          if (raw['kind'] == 'correction') 'already_accurate'
        },
      'retained' => raw['kind'] == 'erasure'
          ? const {'retention_review', 'preservation_review'}
          : <String>{},
      _ => <String>{},
    };
    if (!allowed.contains(raw['reason'])) {
      throw const FormatException('Invalid assessment reason');
    }
    return PrivacyDispositionSummary(raw['id'], raw['kind'], raw['scope'],
        raw['decision'], raw['reason'], raw['reviewedAt']);
  }
}
