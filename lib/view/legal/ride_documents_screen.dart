import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart' as mobx;
import '../../core/theme/ridzs_theme.dart';
import '../../models/ride_disclosure.dart';
import '../../services/ride_disclosure_service.dart';
import '../../stores/users/user_store.dart';
import '../../stores/map/map_store.dart';

class RideDocumentsButton extends StatelessWidget {
  const RideDocumentsButton(
      {super.key,
      required this.rideId,
      this.active = false,
      this.serviceFactory});
  final String rideId;
  final bool active;
  final RideDisclosureService Function()? serviceFactory;
  @override
  Widget build(BuildContext context) => TextButton.icon(
      onPressed: RideDisclosure.validRideId(rideId)
          ? () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => RideDocumentsScreen(
                  rideId: rideId,
                  active: active,
                  serviceFactory: serviceFactory)))
          : null,
      icon: const Icon(Icons.article_outlined),
      label: const Text('Ride documents'));
}

class RideDocumentsScreen extends StatefulWidget {
  const RideDocumentsScreen(
      {super.key,
      required this.rideId,
      this.active = false,
      this.serviceFactory});
  final String rideId;
  final bool active;
  final RideDisclosureService Function()? serviceFactory;
  @override
  State<RideDocumentsScreen> createState() => _RideDocumentsScreenState();
}

class _RideDocumentsScreenState extends State<RideDocumentsScreen>
    with WidgetsBindingObserver {
  RideDisclosureService? _service;
  RideDisclosureSnapshot? _snapshot;
  mobx.ReactionDisposer? _watch;
  Timer? _expiry, _contextGuard;
  String _locale = 'en-CA', _section = 'ride_information';
  String? _error;
  int _generation = 0;
  bool _busy = false, _hidden = false, _ended = false;
  final _scroll = ScrollController();

  RideDisclosureService _create() {
    final users = userStoreProvider();
    final owner = users.loggedInUser?.id ?? '';
    final rides = widget.active ? mapStoreProvider() : null;
    return RideDisclosureService(
        ownerId: owner,
        rideId: widget.rideId,
        ownerReader: () => users.loggedInUser?.id,
        rideIsCurrent: () =>
            !widget.active ||
            rides?.currentRide?.ride?.sId == widget.rideId &&
                rides?.currentRide?.ride?.passengerId == owner);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _hidden = WidgetsBinding.instance.lifecycleState != null &&
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed;
    try {
      _service = widget.serviceFactory?.call() ?? _create();
      if (_service!.rideId != widget.rideId) {
        throw const FormatException('Wrong ride session');
      }
      _service!.addListener(_changed);
      _watch = mobx.reaction((_) => _service!.isCurrent, (current) {
        if (!current) _service!.invalidate();
      });
      // Base URL and interceptor replacement are not observable store fields.
      _contextGuard = Timer.periodic(const Duration(milliseconds: 250), (_) {
        if (_service?.isCurrent != true) _service?.invalidate();
      });
      _load();
    } catch (_) {
      _ended = true;
      _error = 'Ride documents are unavailable. Close and reopen this page.';
    }
  }

  void _clear() {
    _generation++;
    _expiry?.cancel();
    _service?.cancelRequests();
    _snapshot = null;
    _busy = false;
  }

  void _changed() {
    if (!mounted || _service?.isCurrent == true) return;
    setState(() {
      _clear();
      _ended = true;
      _error = 'Ride or session changed. Close and reopen this page.';
    });
  }

  void _expire() {
    if (!mounted || _hidden || _ended) return;
    setState(() {
      _clear();
      _error = 'Document check expired. Refresh to check again.';
    });
  }

  Future<void> _load() async {
    if (_hidden || _ended || _service == null) return;
    setState(() {
      _clear();
      _busy = true;
      _error = null;
    });
    final generation = _generation;
    try {
      final result = await _service!.load(_locale);
      if (!mounted || _hidden || generation != _generation) return;
      if (!result.isFresh) throw const RideDisclosureSessionEnded();
      setState(() {
        _snapshot = result;
        _busy = false;
      });
      _expiry = Timer(result.remaining, _expire);
    } catch (error) {
      if (!mounted || _hidden || generation != _generation) return;
      setState(() {
        _busy = false;
        _ended = error is RideDisclosureSessionEnded || !_service!.isCurrent;
        _error = _ended
            ? 'Ride or session changed. Close and reopen this page.'
            : error is RideDisclosureUnavailable
                ? 'Historical information is unavailable for this ride in ${_locale == 'en-CA' ? 'English' : 'French'}.'
                : 'Could not load ride documents. Please retry.';
      });
    }
  }

  @override
  void didUpdateWidget(covariant RideDocumentsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rideId != widget.rideId ||
        oldWidget.active != widget.active ||
        oldWidget.serviceFactory != widget.serviceFactory) {
      _service?.invalidate();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    setState(() {
      _hidden = state != AppLifecycleState.resumed;
      _clear();
    });
    if (!_hidden) _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _watch?.call();
    _contextGuard?.cancel();
    _clear();
    _service?.removeListener(_changed);
    _service?.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Widget _choice(String label, String value, Map<String, String> choices,
          void Function(String) change) =>
      InputDecorator(
          decoration: InputDecoration(labelText: label),
          child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                  key: ValueKey(label),
                  value: value,
                  isExpanded: true,
                  itemHeight: null,
                  onChanged: _hidden || _ended
                      ? null
                      : (next) {
                          if (next != null) change(next);
                        },
                  items: choices.entries
                      .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(e.value))))
                      .toList())));

  @override
  Widget build(BuildContext context) {
    final document =
        !_hidden && _snapshot?.isFresh == true ? _snapshot!.data : null;
    final section = document?.sections.firstWhere((s) => s.kind == _section);
    return Scaffold(
        backgroundColor: RidzsTheme.paper(context),
        appBar: AppBar(
            titleTextStyle: Theme.of(context).textTheme.titleMedium,
            title: const Text('Ride documents',
                maxLines: 1, overflow: TextOverflow.ellipsis),
            actions: [
              IconButton(
                  tooltip: 'Refresh ride documents',
                  onPressed: _busy || _hidden || _ended ? null : _load,
                  icon: const Icon(Icons.refresh))
            ]),
        body: SafeArea(
            child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: ListView(
                        controller: _scroll,
                        padding: const EdgeInsets.all(20),
                        children: [
                          if (_hidden)
                            const Text(
                                'Ride documents hidden while the app is inactive.')
                          else ...[
                            const Text('Historical passenger information'),
                            const SizedBox(height: 20),
                            _choice('Document language', _locale, const {
                              'en-CA': 'English (Canada)',
                              'fr-CA': 'French (Canada)'
                            }, (value) {
                              if (value == _locale) return;
                              _locale = value;
                              if (_scroll.hasClients) _scroll.jumpTo(0);
                              _load();
                            }),
                            const SizedBox(height: 20),
                            _choice(
                                'Document',
                                _section,
                                const {
                                  'terms': 'Terms',
                                  'privacy': 'Privacy',
                                  'ride_information': 'Ride information',
                                  'support': 'Support'
                                },
                                (value) => setState(() {
                                      _section = value;
                                    })),
                            const SizedBox(height: 24),
                            if (_busy)
                              const LinearProgressIndicator(
                                  semanticsLabel: 'Loading ride documents'),
                            if (_error != null) ...[
                              Semantics(liveRegion: true, child: Text(_error!)),
                              if (!_ended)
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                        onPressed: _load,
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Retry'))),
                            ],
                            if (document != null && section != null) ...[
                              Text(document.marketId,
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              Text(document.operatorName),
                              const Divider(height: 32),
                              Text(section.title,
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 16),
                              SelectableText(section.body,
                                  key: ValueKey(
                                      'ride-document-${section.kind}')),
                              const Divider(height: 32),
                              Text(
                                  'Recorded: ${document.capturedAt.toIso8601String()}'),
                              Text(
                                  'Original validity: ${document.effectiveFrom.toIso8601String()} to ${document.validUntil.toIso8601String()}'),
                              Text('Version: ${document.contentVersion}',
                                  style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 12),
                              const Text(
                                  'This historical record is not proof of acceptance or current service availability.'),
                            ],
                          ]
                        ])))));
  }
}
