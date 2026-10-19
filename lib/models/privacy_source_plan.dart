import 'privacy_disposition.dart';

class PrivacySourcePlanSummary {
  const PrivacySourcePlanSummary(this.id, this.domain, this.reviewedAt,
      [this.execution = 'not_performed']);
  final String execution;
  String get title => switch (execution) {
        'applied' => 'Record change awaiting verification',
        'verified' => 'Record change verified',
        _ => 'Record action blocked',
      };
  String get explanation => switch (execution) {
        'applied' =>
          'The reviewed text change was applied to one record. Independent verification is pending.',
        'verified' =>
          'An independent operator verified the reviewed text change to one record. Your full request remains pending.',
        _ =>
          'Required checks remain unresolved. No record has been changed or deleted by this process.',
      };
  final String id, domain, reviewedAt;
  String get domainLabel => PrivacyDispositionSummary.scopes[domain]!;

  static PrivacySourcePlanSummary? parse(
      dynamic raw, PrivacyDispositionSummary? assessment) {
    if (raw == null) return null;
    const keys = {
      'id',
      'assessmentId',
      'kind',
      'domain',
      'status',
      'recordCount',
      'reviewedAt',
      'execution'
    };
    if (raw is! Map ||
        raw.keys.toSet().difference(keys).isNotEmpty ||
        !raw.keys.toSet().containsAll(keys) ||
        raw['id'] is! String ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(raw['id']) ||
        assessment == null ||
        assessment.decision != 'action_required' ||
        raw['assessmentId'] != assessment.id ||
        raw['kind'] != assessment.kind ||
        raw['domain'] != assessment.scope ||
        !const {'chat', 'ratings', 'safety'}.contains(raw['domain']) ||
        !const {
          'reviewed_blocked': 'not_performed',
          'applied_pending_verification': 'applied',
          'applied_verified': 'verified',
        }.containsKey(raw['status']) ||
        raw['recordCount'] is! int ||
        raw['recordCount'] != 1 ||
        raw['reviewedAt'] is! String ||
        DateTime.tryParse(raw['reviewedAt']) == null ||
        DateTime.parse(raw['reviewedAt'])
            .isBefore(DateTime.parse(assessment.reviewedAt)) ||
        const {
              'reviewed_blocked': 'not_performed',
              'applied_pending_verification': 'applied',
              'applied_verified': 'verified',
            }[raw['status']] !=
            raw['execution']) {
      throw const FormatException('Invalid record action plan');
    }
    return PrivacySourcePlanSummary(
        raw['id'], raw['domain'], raw['reviewedAt'], raw['execution']);
  }
}
