import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/ride_emergency_service.dart';
import '../../core/theme/ridzs_theme.dart';

void openRideSafety(
    BuildContext context, String rideId, RideEmergencyService service) {
  Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => RideSafetyScreen(rideId: rideId, service: service)));
}

class RideSafetyScreen extends StatefulWidget {
  const RideSafetyScreen(
      {super.key, required this.rideId, required this.service});
  final String rideId;
  final RideEmergencyService service;
  @override
  State<RideSafetyScreen> createState() => _RideSafetyScreenState();
}

class _RideSafetyScreenState extends State<RideSafetyScreen>
    with WidgetsBindingObserver {
  final _reason = TextEditingController();
  Timer? _refresh;
  String? _dialError;
  AppLifecycleState _lifecycle = AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.service.load(widget.rideId);
    _refresh = Timer.periodic(const Duration(seconds: 15), (_) {
      if (_lifecycle == AppLifecycleState.resumed &&
          ModalRoute.of(context)?.isCurrent == true &&
          widget.service.record.value != null) {
        widget.service.load(widget.rideId);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycle = state;
    if (state == AppLifecycleState.resumed) widget.service.load(widget.rideId);
  }

  @override
  void dispose() {
    _refresh?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    widget.service.endSession();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _dial() async {
    try {
      final opened = await launchUrl(Uri(scheme: 'tel', path: '911'),
          mode: LaunchMode.externalApplication);
      if (!opened) throw StateError('Dialer unavailable');
    } catch (_) {
      if (mounted) {
        setState(() =>
            _dialError = 'Phone app unavailable. Dial 911 from your phone.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: RidzsTheme.paper(context),
      appBar: AppBar(
          toolbarHeight: MediaQuery.textScalerOf(context).scale(24) * 2 + 16,
          title: const Text('Ride safety',
              maxLines: 2, style: TextStyle(fontSize: 18)),
          actions: [
            Observer(
                builder: (_) => IconButton(
                    tooltip: 'Refresh report status',
                    icon: const Icon(Icons.refresh),
                    onPressed: service.busy.value || service.ended.value
                        ? null
                        : () => service.load(widget.rideId))),
          ]),
      body: SafeArea(child: Observer(builder: (_) {
        final saved = service.record.value;
        final enabled =
            service.ready.value && !service.busy.value && !service.ended.value;
        return Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(padding: const EdgeInsets.all(20), children: [
                  Icon(Icons.health_and_safety_outlined,
                      size: 40, color: colors.error),
                  const SizedBox(height: 12),
                  const Text('Immediate danger?',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text(
                      'This report does not contact emergency services. A response time is not guaranteed.'),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                      onPressed: _dial,
                      icon: const Icon(Icons.phone),
                      label:
                          const Text('Call 911', textAlign: TextAlign.center)),
                  if (_dialError != null)
                    Text(_dialError!, style: TextStyle(color: colors.error)),
                  const Divider(height: 32),
                  if (service.ended.value)
                    const Text(
                        'Session ended. Close this screen and sign in again.')
                  else ...[
                    if (service.busy.value) const LinearProgressIndicator(),
                    if (service.error.value != null) ...[
                      Semantics(
                          liveRegion: true,
                          child: Text(service.error.value!,
                              style: TextStyle(color: colors.error))),
                      TextButton.icon(
                          onPressed: service.busy.value
                              ? null
                              : () => service.load(widget.rideId),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Check report status')),
                    ],
                    if (service.notice.value != null)
                      Semantics(
                          liveRegion: true, child: Text(service.notice.value!)),
                    const SizedBox(height: 12),
                    if (saved == null) ...[
                      const Text('Private safety report',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      TextField(
                          controller: _reason,
                          enabled: !service.busy.value,
                          minLines: 3,
                          maxLines: 6,
                          maxLength: 2000,
                          decoration: const InputDecoration(
                              labelText: 'What happened? (optional)',
                              border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      FilledButton(
                          onPressed: enabled
                              ? () =>
                                  service.report(widget.rideId, _reason.text)
                              : null,
                          child: const Text('Submit safety report',
                              textAlign: TextAlign.center)),
                    ] else ...[
                      Text(
                          switch (saved.status) {
                            'acknowledged' => 'Acknowledged by an operator',
                            'resolved' => 'Closed by an operator',
                            _ => 'Saved - awaiting operator review',
                          },
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Text('Last update: ${saved.updatedAt.toLocal()}'),
                      if (saved.reason.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(saved.reason),
                      ],
                      const SizedBox(height: 16),
                      if (saved.reporterSafe)
                        const Text(
                            'You reported being safe. This does not close the operator review.'),
                      if (saved.status != 'resolved' && !saved.reporterSafe)
                        OutlinedButton(
                            onPressed: enabled
                                ? () => service.change(widget.rideId, 'safe')
                                : null,
                            child: const Text('I am safe now',
                                textAlign: TextAlign.center)),
                      if (saved.status == 'resolved' || saved.reporterSafe)
                        FilledButton(
                            onPressed: enabled
                                ? () => service.change(widget.rideId, 'reopen')
                                : null,
                            child: const Text('Request further review',
                                textAlign: TextAlign.center)),
                    ],
                  ],
                ])));
      })),
    );
  }
}
