import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import '../../core/services/preferences_service.dart';
import '../../models/ad_reward.dart';
import '../../services/ad_reward_service.dart';
import 'ad_watch_screen.dart';
import '../my_wallet/my_wallet.dart';

class MyRewards extends StatefulWidget {
  static const String routeNamed = 'MyRewards';
  const MyRewards({super.key, this.service});
  final AdRewardService? service;
  @override
  State<MyRewards> createState() => _MyRewardsState();
}

class _MyRewardsState extends State<MyRewards> {
  late final AdRewardService _service;
  late final String? _owner;
  String? _token;
  AdRewardOffer? _offer;
  final _sessions = <Map<String, dynamic>>[];
  bool _loading = false, _more = false, _ended = false;
  int _page = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? AdRewardService();
    _owner = userStoreProvider().loggedInUser?.id;
    _load();
  }

  Future<bool> _valid() async {
    final token = await PreferencesService.getAccessToken();
    final valid = mounted &&
        !_ended &&
        _owner != null &&
        _owner == userStoreProvider().loggedInUser?.id &&
        _token != null &&
        token == _token;
    if (!valid && mounted) {
      setState(() {
        _ended = true;
        _offer = null;
        _sessions.clear();
      });
    }
    return valid;
  }

  Future<void> _load({bool more = false}) async {
    if (_loading || _ended) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _token ??= await PreferencesService.getAccessToken();
      if (!await _valid()) return;
      final page = more ? _page + 1 : 1;
      // History remains available when new rewards are disabled.
      final rows = await _service.history(_token!, page: page);
      if (!await _valid()) return;
      setState(() {
        if (!more) _sessions.clear();
        final ids = _sessions.map((row) => row['id'] ?? row['_id']).toSet();
        _sessions.addAll(rows.where((row) => ids.add(row['id'] ?? row['_id'])));
        _page = page;
        _more = rows.length == 20;
      });
    } catch (_) {
      if (await _valid()) {
        setState(() => _error = 'Reward history could not be refreshed.');
      }
    }
    if (!more && await _valid()) {
      AdRewardOffer? offer;
      try {
        offer = await _service.offer(_token!);
        if (!approvedRewardUnit(offer.units, AppConfig.rewardedAdUnitId)) {
          offer = null;
        }
      } catch (_) {
        offer = null;
      }
      if (await _valid()) setState(() => _offer = offer);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _open([String? sessionId]) async {
    if (!await _valid() || !mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AdWatchScreen(sessionId: sessionId),
    ));
    if (await _valid()) await _load();
  }

  Widget _row(Map<String, dynamic> raw) {
    AdRewardSession? value;
    try {
      value = AdRewardSession.parse(raw, _owner!);
    } catch (_) {/* Unverified legacy rows stay held. */}
    if (value == null) {
      return const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Reward needs review'),
          subtitle: Text('Credit could not be verified.'));
    }
    final session = value;
    final expired =
        !DateTime.now().toUtc().isBefore(session.confirmationDeadline);
    final title = session.confirmed
        ? 'Reward confirmed'
        : session.status == 'cancelled'
            ? 'Cancelled'
            : expired
                ? 'Confirmation window ended'
                : 'Awaiting confirmation';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(session.confirmed
          ? Icons.check_circle_outline
          : session.status == 'cancelled'
              ? Icons.cancel_outlined
              : Icons.schedule),
      title: Text(title),
      subtitle: Text(
          '${session.money}\n${session.notBefore.toLocal().toString().split(".").first}'),
      isThreeLine: true,
      trailing: session.status == 'started'
          ? IconButton(
              tooltip: 'Check reward',
              onPressed: () => _open(session.id),
              icon: const Icon(Icons.refresh))
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: color.secondary,
      appBar: AppBar(
          backgroundColor: color.secondary, title: const Text('My rewards')),
      body: Observer(builder: (_) {
        final currentOwner = userStoreProvider().loggedInUser?.id;
        if (_ended || currentOwner != _owner) {
          return const Center(
              child: Text('Sign in again to view your rewards.'));
        }
        return RefreshIndicator(
          onRefresh: _load,
          child: ListView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Text('Ride credit',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: color.primary)),
                const SizedBox(height: 8),
                Text(_offer == null
                    ? 'New ad rewards are unavailable.'
                    : 'USD ${(_offer!.minor / 100).toStringAsFixed(2)} per verified ad'),
                const SizedBox(height: 12),
                FilledButton.icon(
                    onPressed:
                        _offer == null || _loading ? null : () => _open(),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Watch ad')),
                TextButton.icon(
                    onPressed: () async {
                      if (!await _valid()) return;
                      await NavigationService().navigateTo(MyWallet.routeNamed);
                    },
                    icon: const Icon(Icons.account_balance_wallet_outlined),
                    label: const Text('View wallet')),
                const SizedBox(height: 28),
                const Text('Ad rewards',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                if (_loading) const LinearProgressIndicator(),
                if (_error != null)
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(_error!)),
                if (!_loading && _sessions.isEmpty && _error == null)
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('No ad rewards yet.')),
                ..._sessions.map(_row),
                if (_more)
                  TextButton.icon(
                      onPressed: _loading ? null : () => _load(more: true),
                      icon: const Icon(Icons.expand_more),
                      label: const Text('Load more')),
              ]),
        );
      }),
    );
  }
}
