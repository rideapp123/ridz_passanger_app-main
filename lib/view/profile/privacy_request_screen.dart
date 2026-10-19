import 'package:flutter/material.dart';
import '../../core/theme/ridzs_theme.dart';
import '../../services/privacy_request_service.dart';

class PrivacyRequestScreen extends StatefulWidget {
  const PrivacyRequestScreen({super.key, this.service});
  final PrivacyRequestService? service;
  @override
  State<PrivacyRequestScreen> createState() => _PrivacyRequestScreenState();
}

class _PrivacyRequestScreenState extends State<PrivacyRequestScreen> {
  late final PrivacyRequestService service;
  final details = TextEditingController();
  String kind = 'access';
  static const labels = {
    'access': 'Access my data',
    'correction': 'Correct my data',
    'erasure': 'Request erasure',
  };
  @override
  void initState() {
    super.initState();
    service = widget.service ?? PrivacyRequestService();
    service.addListener(_changed);
    service.load();
  }

  void _changed() {
    if (!mounted) return;
    if (service.ended || service.notice != null) details.clear();
    setState(() {});
  }

  @override
  void dispose() {
    service.removeListener(_changed);
    service.dispose();
    details.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saved = service.record;
    return Scaffold(
      backgroundColor: RidzsTheme.paper(context),
      appBar: AppBar(
          toolbarHeight: MediaQuery.textScalerOf(context).scale(20) * 2 + 16,
          title: const Text('Privacy requests', maxLines: 2),
          actions: [
            IconButton(
                tooltip: 'Refresh request status',
                icon: const Icon(Icons.refresh),
                onPressed: service.busy || service.ended ? null : service.load),
          ]),
      body: SafeArea(
          child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (service.busy) const LinearProgressIndicator(),
          if (service.ended)
            const Text('Session ended. Sign in again to view your request.')
          else ...[
            if (service.error != null)
              Text(service.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            if (service.notice != null) Text(service.notice!),
            if (saved != null) ...[
              Text(labels[saved.kind]!,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(saved.status == 'pending'
                  ? 'Awaiting review'
                  : 'Reviewed - fulfillment pending'),
              Text('Updated ${saved.updatedAt.toLocal()}'),
              const SizedBox(height: 12),
              Text(saved.details),
              const Divider(height: 32),
            ],
            const Text('Request fulfillment is pending.'),
            if (service.sourcePlan != null) ...[
              const SizedBox(height: 20),
              Text(service.sourcePlan!.title,
                  style: Theme.of(context).textTheme.titleMedium),
              Text(
                  'One ${service.sourcePlan!.domainLabel.toLowerCase()} record plan independently reviewed.'),
              Text(service.sourcePlan!.explanation),
            ],
            if (service.disposition != null) ...[
              const SizedBox(height: 16),
              Text('Request assessment',
                  style: Theme.of(context).textTheme.titleMedium),
              Text(service.disposition!.title),
              Text('Reviewed scope: ${service.disposition!.scopeLabel}'),
              Text(service.disposition!.explanation),
              const Text(
                  'This assessment does not complete your full request.'),
              const Divider(height: 24),
            ],
            if (service.disclosure != null) ...[
              const SizedBox(height: 16),
              Text(
                  'Approved ${service.disclosure!.hasContent ? 'content' : 'metadata'}: ${service.disclosure!.domainLabel}'),
              Text(
                  '${service.disclosure!.referenceLabel} ${service.disclosure!.rideId}'),
              OutlinedButton.icon(
                onPressed: service.canAccess ? service.accessDisclosure : null,
                icon: const Icon(Icons.description_outlined),
                label: Text(service.disclosure!.hasContent
                    ? 'View reviewed content'
                    : 'View approved metadata'),
              ),
            ],
            if (service.responsePackage != null) ...[
              const SizedBox(height: 16),
              Text('Response package',
                  style: Theme.of(context).textTheme.titleMedium),
              const Text(
                  'Partial coverage. Other records may remain outside this response.'),
              for (final page in service.responsePackage!.pages)
                Row(children: [
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                              '${page.domainLabel} - ${page.hasContent ? 'Reviewed content' : 'Metadata'}\n${page.referenceLabel} ${page.rideId}'))),
                  IconButton(
                      tooltip: 'View package page',
                      onPressed: service.canAccess
                          ? () => service.accessDisclosure(page)
                          : null,
                      icon: const Icon(Icons.description_outlined)),
                ]),
            ],
            if (service.disclosedPage != null) ...[
              const SizedBox(height: 16),
              Text(
                  service.disclosedPage!.summary.hasContent
                      ? 'Reviewed own content'
                      : 'Own record metadata',
                  style: Theme.of(context).textTheme.titleMedium),
              Text(service.disclosedPage!.summary.isBooking
                  ? service.disclosedPage!.summary.hasContent
                      ? 'Partial quote response. Locations may be redacted or withheld. Quoted amounts are not payment receipts. Payment identifiers and internal evidence excluded.'
                      : 'Location, payment details and internal evidence withheld. Records preserved for payment recovery.'
                  : service.disclosedPage!.summary.hasContent
                      ? 'Partial response. Text may be redacted or withheld after review.'
                      : 'Free text, other participants and internal notes excluded.'),
              if (service.disclosedPage!.records.isEmpty)
                const Text('No own records on this page.'),
              for (final row in service.disclosedPage!.records)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SelectableText(row.entries
                      .map((entry) => '${entry.key}: ${entry.value}')
                      .join('\n')),
                ),
              if (service.disclosedPage!.hasMore)
                const Text(
                    'More records remain for operator preparation and review.'),
              const Divider(),
            ],
            const SizedBox(height: 20),
            if (service.ready &&
                (saved == null || saved.status == 'reviewed')) ...[
              DropdownButtonFormField<String>(
                dropdownColor: RidzsTheme.paper(context),
                style: Theme.of(context).textTheme.bodyLarge,
                initialValue: kind,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Request type'),
                items: labels.entries
                    .map((entry) => DropdownMenuItem(
                        value: entry.key, child: Text(entry.value)))
                    .toList(),
                onChanged: service.canSubmit
                    ? (value) => setState(() => kind = value!)
                    : null,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: details,
                enabled: service.canSubmit,
                maxLength: 2000,
                minLines: 3,
                maxLines: 6,
                decoration: InputDecoration(
                    labelText: 'Request details',
                    counterStyle: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                            color:
                                RidzsTheme.ink(context).withValues(alpha: .65)),
                    border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: service.canSubmit
                    ? () => service.submit(kind, details.text)
                    : null,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Submit request'),
              ),
            ],
            if (service.hasPending)
              OutlinedButton.icon(
                onPressed: service.busy ? null : service.retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry unconfirmed request'),
              ),
          ],
        ],
      )),
    );
  }
}
