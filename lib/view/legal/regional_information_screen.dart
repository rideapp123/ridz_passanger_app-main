import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/ridzs_theme.dart';
import '../../models/regional_disclosure.dart';
import '../../services/regional_disclosure_service.dart';

enum RegionalSection {
  terms('terms', 'Terms'),
  privacy('privacy', 'Privacy'),
  ride('ride_information', 'Ride information'),
  support('support', 'Support');

  const RegionalSection(this.kind, this.label);
  final String kind, label;
  static RegionalSection fromArguments(Object? arguments) {
    final kind = arguments is Map ? arguments['section'] : null;
    return values.firstWhere((v) => v.kind == kind, orElse: () => terms);
  }
}

class RegionalInformationScreen extends StatefulWidget {
  const RegionalInformationScreen(
      {super.key,
      this.initialSection = RegionalSection.terms,
      this.pickupMarketId,
      this.contextChanges,
      this.contextIsCurrent,
      this.serviceFactory});
  static const routeNamed = 'RegionalInformationScreen';
  final RegionalSection initialSection;
  final String? pickupMarketId;
  final Listenable? contextChanges;
  final bool Function()? contextIsCurrent;
  final RegionalDisclosureService Function()? serviceFactory;
  @override
  State<RegionalInformationScreen> createState() =>
      _RegionalInformationScreenState();
}

class _RegionalInformationScreenState extends State<RegionalInformationScreen>
    with WidgetsBindingObserver {
  RegionalDisclosureService? _service;
  DisclosureObservation<DisclosureMarketPage>? _page;
  DisclosureObservation<RegionalDisclosure>? _document;
  DisclosureMarket? _selected;
  late RegionalSection _section;
  String _locale = 'en-CA';
  List<String?> _cursors = [null];
  int _pageIndex = 0, _generation = 0;
  Timer? _expiry;
  bool _busy = false, _hidden = false, _reopen = false;
  String? _error;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _section = widget.initialSection;
    widget.contextChanges?.addListener(_contextChanged);
    _hidden = WidgetsBinding.instance.lifecycleState != null &&
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed;
    try {
      if (widget.pickupMarketId != null &&
          !DisclosureMarket.validId(widget.pickupMarketId)) {
        throw const FormatException('Invalid pickup market');
      }
      _service = widget.serviceFactory?.call() ?? RegionalDisclosureService();
      _fetch();
    } catch (_) {
      _reopen = true;
      _error =
          'Regional information is unavailable. Close and reopen this page.';
    }
  }

  void _clear() {
    _generation++;
    _expiry?.cancel();
    _service?.cancelRequests();
    _page = null;
    _document = null;
    _busy = false;
  }

  bool get _contextCurrent => widget.contextIsCurrent?.call() ?? true;
  void _contextChanged() {
    if (!mounted || _contextCurrent || _reopen) return;
    _clear();
    _reopen = true;
    _error = 'Pickup changed. Close and reopen this page.';
    scheduleMicrotask(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant RegionalInformationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contextChanges != widget.contextChanges) {
      oldWidget.contextChanges?.removeListener(_contextChanged);
      widget.contextChanges?.addListener(_contextChanged);
    }
    if (oldWidget.pickupMarketId != widget.pickupMarketId) {
      _clear();
      _reopen = true;
      _error = 'Pickup changed. Close and reopen this page.';
    }
    _contextChanged();
  }

  void _expire() {
    if (!mounted || _hidden) return;
    setState(() {
      _clear();
      _error = 'Regional information expired. Refresh to check again.';
    });
  }

  Future<void> _fetch({int? expectedPolicyVersion}) async {
    if (!_contextCurrent) {
      _contextChanged();
      return;
    }
    if (_hidden || _reopen || _service == null) return;
    setState(() {
      _clear();
      _busy = true;
      _error = null;
    });
    final generation = _generation;
    final marketId = widget.pickupMarketId ?? _selected?.marketId;
    try {
      if (marketId == null) {
        final result = await _service!
            .markets(locale: _locale, after: _cursors[_pageIndex]);
        if (!mounted || _hidden || generation != _generation) return;
        if (!result.isFresh) throw const DisclosureReadEnded();
        setState(() {
          _page = result;
          _busy = false;
        });
        _expiry = Timer(result.remaining, _expire);
      } else {
        final result = await _service!.load(
            marketId: marketId,
            locale: _locale,
            expectedPolicyVersion: expectedPolicyVersion);
        if (!mounted || _hidden || generation != _generation) return;
        if (!_contextCurrent) {
          _contextChanged();
          return;
        }
        if (!result.isFresh) throw const DisclosureReadEnded();
        setState(() {
          _document = result;
          _selected = result.data.market;
          _busy = false;
        });
        _expiry = Timer(result.remaining, _expire);
      }
    } catch (error) {
      if (!mounted || _hidden || generation != _generation) return;
      setState(() {
        _busy = false;
        _reopen = error is DisclosureReadEnded;
        _error = _reopen
            ? 'Regional information changed. Close and reopen this page.'
            : error is DisclosureUnavailable
                ? 'Reviewed information is unavailable for this market in $_languageLabel.'
                : 'Could not load reviewed information. Please retry.';
      });
    }
  }

  String get _languageLabel =>
      _locale == 'en-CA' ? 'English (Canada)' : 'French (Canada)';
  void _top() {
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _select(DisclosureMarket market) {
    if (_page?.isFresh != true) {
      _expire();
      return;
    }
    _selected = market;
    _top();
    _fetch(expectedPolicyVersion: market.policyVersion);
  }

  void _changeMarket() {
    _selected = null;
    _cursors = [null];
    _pageIndex = 0;
    _top();
    _fetch();
  }

  void _turnPage(bool forward) {
    final page = _page;
    if (page?.isFresh != true) {
      _expire();
      return;
    }
    if (forward) {
      final next = page!.data.nextAfter;
      if (next == null) return;
      _cursors = [..._cursors.take(_pageIndex + 1), next];
      _pageIndex++;
    } else if (_pageIndex > 0) {
      _pageIndex--;
    } else {
      return;
    }
    _top();
    _fetch();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    setState(() {
      _hidden = state != AppLifecycleState.resumed;
      _clear();
      _cursors = [null];
      _pageIndex = 0;
    });
    if (!_hidden) _fetch();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.contextChanges?.removeListener(_contextChanged);
    _clear();
    _service?.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Widget _choice(
      {required String label,
      required String value,
      required Map<String, String> choices,
      required void Function(String) onChanged}) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
        key: ValueKey(label),
        value: value,
        isExpanded: true,
        itemHeight: null,
        onChanged: _hidden || _reopen
            ? null
            : (next) {
                if (next != null) onChanged(next);
              },
        items: choices.entries
            .map((entry) => DropdownMenuItem(
                value: entry.key,
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(entry.value))))
            .toList(),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = _page?.isFresh == true ? _page!.data : null;
    final document =
        _contextCurrent && _document?.isFresh == true ? _document!.data : null;
    final section =
        document?.sections.firstWhere((s) => s.kind == _section.kind);
    return Scaffold(
      backgroundColor: RidzsTheme.paper(context),
      appBar: AppBar(
          titleTextStyle: Theme.of(context).textTheme.titleMedium,
          title: const Text('Documents',
              maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: [
            IconButton(
                tooltip: 'Refresh regional information',
                onPressed: _busy || _hidden || _reopen
                    ? null
                    : () {
                        if (_selected == null) {
                          _cursors = [null];
                          _pageIndex = 0;
                        }
                        _fetch();
                      },
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
                      'Regional information hidden while the app is inactive.')
                else ...[
                  _choice(
                      label: 'Document language',
                      value: _locale,
                      choices: const {
                        'en-CA': 'English (Canada)',
                        'fr-CA': 'French (Canada)'
                      },
                      onChanged: (value) {
                        if (value == _locale) return;
                        _locale = value;
                        _cursors = [null];
                        _pageIndex = 0;
                        _fetch();
                      }),
                  const SizedBox(height: 20),
                  _choice(
                      label: 'Document',
                      value: _section.kind,
                      choices: {
                        for (final s in RegionalSection.values) s.kind: s.label
                      },
                      onChanged: (value) => setState(() {
                            _section = RegionalSection.values
                                .firstWhere((s) => s.kind == value);
                          })),
                  const SizedBox(height: 24),
                  if (_selected != null || widget.pickupMarketId != null) ...[
                    Text(widget.pickupMarketId ?? _selected!.marketId,
                        style: Theme.of(context).textTheme.titleMedium),
                    if (widget.pickupMarketId == null)
                      Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                              onPressed: _reopen ? null : _changeMarket,
                              icon: const Icon(Icons.location_on_outlined),
                              label: const Text('Change market'))),
                  ],
                  if (_busy)
                    const LinearProgressIndicator(
                        semanticsLabel: 'Loading reviewed information'),
                  if (_error != null) ...[
                    Semantics(liveRegion: true, child: Text(_error!)),
                    if (!_reopen)
                      Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                              onPressed: () => _fetch(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'))),
                  ],
                  if (page != null) ...[
                    Text('Market',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    if (page.items.isEmpty)
                      Text(page.nextAfter != null
                          ? 'No reviewed documents in this group.'
                          : _pageIndex > 0
                              ? 'No more reviewed documents in $_languageLabel.'
                              : 'Reviewed regional information is unavailable in $_languageLabel.'),
                    for (final market in page.items) ...[
                      ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(market.marketName),
                          subtitle: Text(market.marketId),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _select(market)),
                      const Divider(height: 1),
                    ],
                    const SizedBox(height: 16),
                    Wrap(spacing: 12, runSpacing: 8, children: [
                      if (_pageIndex > 0)
                        TextButton.icon(
                            onPressed: () => _turnPage(false),
                            icon: const Icon(Icons.chevron_left),
                            label: const Text('Previous markets')),
                      if (page.nextAfter != null)
                        TextButton.icon(
                            onPressed: () => _turnPage(true),
                            icon: const Icon(Icons.chevron_right),
                            label: const Text('More markets')),
                    ]),
                  ],
                  if (document != null && section != null) ...[
                    Text(document.market.marketName,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(document.operatorName),
                    const Divider(height: 32),
                    Text(section.title,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    SelectableText(section.body,
                        key: ValueKey(
                            'document-${document.contentVersion}-${section.kind}')),
                    const Divider(height: 32),
                    Text('Version: ${document.contentVersion}',
                        style: Theme.of(context).textTheme.bodySmall),
                    Text(
                        'Effective: ${document.effectiveFrom.toIso8601String()}',
                        style: Theme.of(context).textTheme.bodySmall),
                    Text(
                        'Valid until: ${document.validUntil.toIso8601String()}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ],
              ]),
        ),
      )),
    );
  }
}
