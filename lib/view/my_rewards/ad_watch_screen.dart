import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import '../../services/ad_reward_flow.dart';

class AdWatchScreen extends StatefulWidget {
  static const String routeNamed = 'AdWatchScreen';
  const AdWatchScreen({super.key, this.rideId, this.sessionId, this.flow});
  final String? rideId, sessionId;
  final AdRewardFlow? flow;
  @override
  State<AdWatchScreen> createState() => _AdWatchScreenState();
}

class _AdWatchScreenState extends State<AdWatchScreen>
    with WidgetsBindingObserver {
  late final AdRewardFlow _flow;
  bool _leaving = false;
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    if (widget.flow != null) {
      _flow = widget.flow!;
    } else {
      final store = userStoreProvider();
      _flow = AdRewardFlow(
        owner: store.loggedInUser?.id ?? '',
        sdkUnit: AppConfig.rewardedAdUnitId,
        ownerReader: () => store.loggedInUser?.id,
        refreshWallet: store.getWallet,
      );
    }
    _flow.addListener(_changed);
    WidgetsBinding.instance.addObserver(this);
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _flow.retryAfter != null) setState(() {});
    });
    unawaited(_flow.initialize(
        rideId: widget.rideId, resumeSessionId: widget.sessionId));
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      _flow.foreground(state == AppLifecycleState.resumed);

  Future<void> _close() async {
    if (_leaving) return;
    setState(() => _leaving = true);
    final closed = await _flow.close();
    if (!mounted) return;
    if (closed && ModalRoute.of(context)?.isCurrent == true) {
      Navigator.of(context).pop(_flow.active ? _flow.credit : null);
    } else {
      setState(() => _leaving = false);
    }
  }

  @override
  void dispose() {
    _clock?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _flow.removeListener(_changed);
    _flow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final phase = _flow.phase;
    final title = switch (phase) {
      RewardPhase.loading => 'Preparing advertisement',
      RewardPhase.playing => 'Advertisement',
      RewardPhase.pending => 'Awaiting confirmation',
      RewardPhase.confirmed => 'Reward confirmed',
      RewardPhase.cancelled => 'Reward cancelled',
      RewardPhase.expired => 'Reward window ended',
      RewardPhase.unavailable => 'Rewards unavailable',
      RewardPhase.review => 'Reward needs review',
      RewardPhase.ended => 'Session ended',
    };
    final detail = switch (phase) {
      RewardPhase.pending =>
        'No credit confirmed yet. You can close this screen and check your rewards later.',
      RewardPhase.confirmed => _flow.walletRefreshFailed
          ? 'Your reward is confirmed. Wallet balance could not be refreshed.'
          : 'Your ride credit is in your wallet for a future ride.',
      RewardPhase.expired =>
        'No credit has been confirmed. Check once more for a previous confirmation.',
      RewardPhase.review =>
        'This reward could not be verified. No new credit is shown.',
      RewardPhase.ended => 'Sign in again to view your rewards.',
      RewardPhase.cancelled => 'No ride credit was added.',
      RewardPhase.unavailable => 'Please try again later.',
      _ => 'Ride credit is added after server verification.',
    };
    final retry = {
      RewardPhase.pending,
      RewardPhase.expired,
      RewardPhase.unavailable,
      RewardPhase.review
    }.contains(phase);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_close());
      },
      child: Scaffold(
        backgroundColor: color.secondary,
        appBar: AppBar(
          backgroundColor: color.secondary,
          title: const Text('Ad reward'),
          leading: IconButton(
              tooltip: 'Close',
              onPressed: _leaving ? null : _close,
              icon: const Icon(Icons.close)),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Icon(
                  phase == RewardPhase.confirmed
                      ? Icons.check_circle_outline
                      : phase == RewardPhase.pending
                          ? Icons.schedule
                          : Icons.play_circle_outline,
                  size: 56,
                  color: color.primary),
              const SizedBox(height: 24),
              LayoutBuilder(builder: (context, constraints) {
                var size = 22.0;
                final base = DefaultTextStyle.of(context).style;
                final scaler = MediaQuery.textScalerOf(context);
                final painter = TextPainter(
                    textDirection: Directionality.of(context),
                    textScaler: scaler);
                // Keep long status words intact at accessibility text sizes.
                while (size > 12) {
                  var fits = true;
                  for (final word in title.split(' ')) {
                    painter.text = TextSpan(
                        text: word,
                        style: base.copyWith(
                            fontSize: size, fontWeight: FontWeight.w600));
                    painter.layout();
                    if (painter.width > constraints.maxWidth) fits = false;
                  }
                  if (fits) break;
                  size -= 1;
                }
                painter.dispose();
                return Text(title,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: size, fontWeight: FontWeight.w600));
              }),
              const SizedBox(height: 12),
              if (_flow.active && _flow.session != null) ...[
                Text(_flow.session!.money,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: color.primary)),
                const SizedBox(height: 12),
              ],
              Text(detail, textAlign: TextAlign.center),
              if (_flow.message != null && phase != RewardPhase.ended) ...[
                const SizedBox(height: 12),
                Text(_flow.message!, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 24),
              if (_flow.busy)
                const Center(
                    child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2))),
              if (retry) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _flow.canRetry && !_leaving ? _flow.retry : null,
                  icon: const Icon(Icons.refresh),
                  label: Text(
                      _flow.retryAfter != null && !_flow.canRetry && !_flow.busy
                          ? 'Please wait to retry'
                          : _flow.session == null || _flow.canCancel
                              ? 'Retry'
                              : 'Check reward'),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                  onPressed: _leaving ? null : _close,
                  child:
                      Text(phase == RewardPhase.confirmed ? 'Done' : 'Close')),
            ],
          ),
        ),
      ),
    );
  }
}
