import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart' as mobx;
import '../../../core/theme/ridzs_theme.dart';

import '../../../models/passenger_driver_credentials.dart';
import '../../../services/passenger_driver_credentials_service.dart';
import '../../../stores/map/map_store.dart';
import '../../../stores/users/user_store.dart';

class PassengerDriverCredentialsScreen extends StatefulWidget {
  const PassengerDriverCredentialsScreen(
      {super.key, required this.binding, this.serviceFactory});
  final CredentialRideBinding binding;
  final PassengerDriverCredentialsService Function()? serviceFactory;
  @override
  State<PassengerDriverCredentialsScreen> createState() =>
      _PassengerDriverCredentialsScreenState();
}

class _PassengerDriverCredentialsScreenState
    extends State<PassengerDriverCredentialsScreen>
    with WidgetsBindingObserver {
  PassengerDriverCredentialsService? _service;
  PassengerCredentialSnapshot? _snapshot;
  mobx.ReactionDisposer? _watch;
  Timer? _refresh;
  String? _error;
  bool _busy = false, _hidden = false, _ended = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    try {
      if (widget.serviceFactory != null) {
        _service = widget.serviceFactory!();
      } else {
        final users = userStoreProvider();
        final rides = mapStoreProvider();
        final owner = users.loggedInUser?.id ?? '';
        _service = PassengerDriverCredentialsService(
            ownerId: owner,
            binding: widget.binding,
            ownerReader: () => users.loggedInUser?.id,
            rideIsCurrent: () =>
                widget.binding.matches(rides.currentRide) &&
                rides.currentRide?.ride?.passengerId == owner);
      }
      _service!.addListener(_changed);
      _watch = mobx.reaction((_) => _service!.isCurrent, (current) {
        if (!current) _service!.invalidate();
      });
      _load();
    } catch (_) {
      _ended = true;
      _error = 'Return to your ride to check driver credentials.';
    }
  }

  void _clear() {
    _generation++;
    _refresh?.cancel();
    _service?.cancelRequests();
    _snapshot = null;
    _busy = false;
  }

  void _changed() {
    if (!mounted || _service?.isCurrent == true) return;
    setState(() {
      _clear();
      _ended = true;
      _error = 'Ride or session changed. Return to your ride.';
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
      final result = await _service!.load();
      if (!mounted || generation != _generation || _hidden) return;
      if (!_service!.isCurrent) {
        _changed();
        return;
      }
      if (result.remaining <= Duration.zero) {
        throw const FormatException('Expired observation');
      }
      setState(() {
        _snapshot = result;
        _busy = false;
      });
      _refresh = Timer(result.remaining, _load);
    } catch (_) {
      if (!mounted || generation != _generation || _hidden) return;
      setState(() {
        _busy = false;
        _error = 'Could not check driver credentials. Please retry.';
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _hidden = state != AppLifecycleState.resumed;
      _clear();
    });
    if (!_hidden && !_ended) _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _watch?.call();
    _clear();
    _service?.removeListener(_changed);
    _service?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    return Scaffold(
      backgroundColor: RidzsTheme.paper(context),
      appBar: AppBar(title: const Text('Credentials'), actions: [
        IconButton(
            tooltip: 'Refresh credentials',
            onPressed: _busy || _hidden || _ended ? null : _load,
            icon: const Icon(Icons.refresh)),
      ]),
      body: SafeArea(
          child: ListView(padding: const EdgeInsets.all(20), children: [
        if (_hidden)
          const Text('Credentials hidden while app is inactive.')
        else ...[
          const Text(
              'Issued by Ridzs. Not a government licence or a guarantee of driving eligibility.'),
          const SizedBox(height: 20),
          if (_busy) const LinearProgressIndicator(),
          if (_error != null) ...[
            Text(_error!),
            if (!_ended)
              Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'))),
          ],
          if (snapshot != null) ...[
            if (snapshot.data.credentials.isEmpty)
              const Text('No current Ridzs-issued credentials available.'),
            for (final credential in snapshot.data.credentials) ...[
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.badge_outlined),
                  title: Text(credential.label),
                  subtitle: const Text('Current at last check')),
              Text(
                  'Expires: ${credential.expiresAt.toIso8601String().replaceFirst('T', ' ').replaceFirst('Z', '')} UTC'),
              const Divider(height: 32),
            ],
          ],
        ],
      ])),
    );
  }
}
