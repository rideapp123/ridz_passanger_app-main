import 'package:flutter/material.dart';

enum BookingView { submitting, unconfirmed, searching, exhausted }

class BookingStatusPanel extends StatelessWidget {
  const BookingStatusPanel(
      {super.key,
      required this.state,
      this.busy = false,
      this.error,
      this.onRetry,
      this.onCancel});
  final BookingView state;
  final bool busy;
  final String? error;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searching = state == BookingView.searching;
    final sending = state == BookingView.submitting;
    final title = switch (state) {
      BookingView.submitting => 'Requesting your ride',
      BookingView.unconfirmed => 'Booking confirmation pending',
      BookingView.searching => 'Looking for a driver',
      BookingView.exhausted => 'No drivers available',
    };
    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Icon(
                        searching || sending
                            ? Icons.local_taxi_outlined
                            : Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(title, style: theme.textTheme.titleLarge)),
                  ]),
                  const SizedBox(height: 16),
                  if (searching || sending || busy)
                    const LinearProgressIndicator(),
                  if (state == BookingView.exhausted)
                    const Text('Your ride request is still open.'),
                  if (error != null)
                    Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(error!,
                            style: TextStyle(color: theme.colorScheme.error))),
                  if (state == BookingView.exhausted ||
                      state == BookingView.unconfirmed) ...[
                    const SizedBox(height: 16),
                    FilledButton.icon(
                        onPressed: busy ? null : onRetry,
                        icon: const Icon(Icons.refresh),
                        label: Text(state == BookingView.exhausted
                            ? 'Search again'
                            : 'Retry confirmation')),
                  ],
                  if (onCancel != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                        onPressed: busy ? null : onCancel,
                        icon: const Icon(Icons.close),
                        label: const Text('Cancel request')),
                  ],
                ]),
          )),
    );
  }
}
