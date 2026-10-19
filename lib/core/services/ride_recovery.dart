import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'dio_service.dart';
import 'preferences_service.dart';
import 'ride_booking_hint.dart';

/// One recovery flight per session; live mutations invalidate older reads.
class RideRecovery {
  RideRecovery({
    required this.restore,
    required this.currentRideId,
    Dio? dio,
    Future<String?> Function()? tokenReader,
    Future<Map<String, dynamic>?> Function(String)? readHint,
    Future<void> Function(String, Map<String, dynamic>)? writeHint,
    Future<void> Function(String)? removeHint,
    this.canReconcile,
  })  : _providedDio = dio,
        _tokenReader = tokenReader ?? PreferencesService.getAccessToken,
        _readHint = readHint ?? PreferencesService.getJson,
        _writeHint = writeHint ?? PreferencesService.setJson,
        _removeHint = removeHint ?? PreferencesService.remove;

  final Future<void> Function(Map<String, dynamic>?) restore;
  final String? Function() currentRideId;
  final bool Function()? canReconcile;
  final Dio? _providedDio;
  Dio get _dio => _providedDio ?? Api().dio;
  final Future<String?> Function() _tokenReader;
  final Future<Map<String, dynamic>?> Function(String) _readHint;
  final Future<void> Function(String, Map<String, dynamic>) _writeHint;
  final Future<void> Function(String) _removeHint;
  final loading = Observable(false);
  final ready = Observable(false);
  final error = Observable<String?>(null);
  int _generation = 0;
  int _revision = 0;
  bool _active = false;
  bool _again = false;
  String? _hintKey;
  CancelToken _cancel = CancelToken();
  Future<void>? _flight;
  Future<void> _writes = Future.value();
  Timer? _reconcileTimer;
  Timer? _hintCooldown;
  bool _foreground = false;
  bool _reconciling = false;
  ({RideBookingHint hint, String token})? _bookingHint;
  final _bookingNotices = <String>{};

  bool get reconciling => _reconciling;

  void handleBookingHint(dynamic payload, String expectedToken) {
    if (!_active ||
        !_foreground ||
        _hintCooldown != null ||
        expectedToken.isEmpty) {
      return;
    }
    final hint = RideBookingHint.parse(payload);
    if (hint == null || _bookingNotices.contains(hint.notificationId)) return;
    if (_bookingNotices.length >= 64) {
      _bookingNotices.remove(_bookingNotices.first);
    }
    _bookingNotices.add(hint.notificationId);
    _bookingHint = (hint: hint, token: expectedToken);
    _hintCooldown = Timer(const Duration(seconds: 2), () {
      _hintCooldown = null;
    });
    changed();
    unawaited(refresh(reconcile: true));
  }

  // Hints only invalidate HTTP reads; they never contain authoritative ride state.
  void handleSyncHint(dynamic payload) {
    if (!_active ||
        !_foreground ||
        _hintCooldown != null ||
        payload is! Map ||
        payload.length != 2 ||
        payload['type'] != 'RIDE_ACCEPTANCE_SYNC' ||
        payload['notificationId'] is! String ||
        !RegExp(r'^[a-f0-9]{64}$')
            .hasMatch(payload['notificationId'] as String)) {
      return;
    }
    _hintCooldown = Timer(const Duration(seconds: 2), () {
      _hintCooldown = null;
    });
    changed();
    unawaited(refresh(reconcile: true));
  }

  void setForeground(bool foreground) {
    _foreground = foreground;
    _reconcileTimer?.cancel();
    _reconcileTimer = null;
    _scheduleReconciliation();
  }

  void _scheduleReconciliation() {
    if (!_active ||
        !_foreground ||
        _flight != null ||
        _reconcileTimer != null) {
      return;
    }
    // Wait after the previous flight, so a slow/offline connection cannot queue polls.
    _reconcileTimer = Timer(const Duration(seconds: 15), () {
      _reconcileTimer = null;
      unawaited(refresh(reconcile: true));
    });
  }

  bool get active => _active;

  void activate() {
    if (_active) return;
    _active = true;
    _generation++;
    _cancel = CancelToken();
    runInAction(() {
      ready.value = false;
      error.value = null;
    });
    _scheduleReconciliation();
  }

  void changed() {
    _revision++;
  }

  void remember(String? id) {
    if (!_active) return;
    final generation = _generation;
    _writes = _writes.catchError((Object _) {}).then((_) async {
      final key = _hintKey;
      if (!_active || generation != _generation || key == null) return;
      if (id == null) {
        await _removeHint(key);
      } else {
        await _writeHint(key, {'rideId': id});
      }
    }).catchError((Object _) {
      // A hint is not ride state; the server remains authoritative.
    });
  }

  Future<void> forget() async {
    final key = _hintKey;
    if (key == null) return;
    _writes = _writes.catchError((Object _) {}).then((_) => _removeHint(key));
    await _writes;
  }

  void dispose() {
    _bookingHint = null;
    _bookingNotices.clear();
    _hintCooldown?.cancel();
    _hintCooldown = null;
    _reconcileTimer?.cancel();
    _reconcileTimer = null;
    _foreground = false;
    _reconciling = false;
    _active = false;
    _generation++;
    _revision++;
    _cancel.cancel('Ride session ended');
    _flight = null;
    _hintKey = null;
    runInAction(() {
      loading.value = false;
      ready.value = false;
      error.value = null;
    });
  }

  Future<void> refresh({bool reconcile = false}) {
    if (!_active) return Future.value();
    if (reconcile && canReconcile?.call() == false) {
      _scheduleReconciliation();
      return Future.value();
    }
    if (_flight != null) {
      if (!reconcile) {
        _again = true;
        _reconciling = false;
        runInAction(() {
          loading.value = true;
          ready.value = false;
        });
      }
      return _flight!;
    }
    _reconcileTimer?.cancel();
    _reconcileTimer = null;
    _reconciling = reconcile && ready.value;
    final generation = _generation;
    final flight = _recover(generation, reconcile: reconcile);
    _flight = flight;
    return flight.whenComplete(() {
      if (generation == _generation) {
        _flight = null;
        _reconciling = false;
        _scheduleReconciliation();
      }
    });
  }

  Future<void> requireRefresh() {
    runInAction(() => ready.value = false);
    return refresh();
  }

  bool _valid(int generation) => _active && generation == _generation;

  Future<void> _recover(int generation, {required bool reconcile}) async {
    runInAction(() {
      loading.value = !_reconciling;
      if (!_reconciling) ready.value = false;
      error.value = null;
    });
    try {
      do {
        _again = false;
        if (reconcile && canReconcile?.call() == false) return;
        final revision = _revision;
        final bookingHint = _bookingHint;
        final token = await _tokenReader();
        if (!_valid(generation)) return;
        if (token == null || token.isEmpty) {
          throw const FormatException('No session');
        }
        if (bookingHint != null && bookingHint.token != token) {
          if (_bookingHint == bookingHint) _bookingHint = null;
          throw const FormatException('Booking hint session changed');
        }
        final key = 'ride_recovery_${sha256.convert(utf8.encode(token))}';
        if (_hintKey != null && _hintKey != key) {
          throw const FormatException('Session changed');
        }
        _hintKey = key;
        await _writes;
        final hint = await _readHint(key);
        if (!_valid(generation)) return;
        final previousId = currentRideId() ??
            bookingHint?.hint.rideId ??
            hint?['rideId'] as String?;
        final options = Options(extra: {'expectedAuthToken': token});
        final current = _payload(await _dio.get('/rides/current',
            options: options, cancelToken: _cancel));
        if (!_valid(generation)) return;
        Map<String, dynamic>? snapshot;
        if (current['hasActiveRide'] == true) {
          snapshot = _snapshot(current);
        } else if (current['hasActiveRide'] == false &&
            current['ride'] == null) {
          if (previousId != null && previousId.isNotEmpty) {
            try {
              snapshot = _snapshot(_payload(await _dio.get(
                '/rides/${Uri.encodeComponent(previousId)}',
                options: options,
                cancelToken: _cancel,
              )));
              if (snapshot['ride']['id'] != previousId) {
                throw const FormatException('Wrong ride');
              }
            } on DioException catch (exception) {
              if (exception.response?.statusCode != 404) rethrow;
            }
          }
        } else {
          throw const FormatException('Invalid current ride');
        }
        if (!_valid(generation)) return;
        final currentToken = await _tokenReader();
        if (!_valid(generation)) return;
        if (currentToken != token) {
          throw const FormatException(
              'Passenger account changed during recovery');
        }
        if (revision != _revision) {
          _again = true;
          continue;
        }
        // A command may have started while HTTP was in flight. Keep the hint
        // for the next idle poll instead of applying a pre-command snapshot.
        if (reconcile && canReconcile?.call() == false) return;
        await restore(snapshot);
        if (!_valid(generation)) return;
        if (revision != _revision) {
          _again = true;
          continue;
        }
        final ride = snapshot?['ride'] as Map?;
        if (_bookingHint == bookingHint) _bookingHint = null;
        remember(
            ride?['status'] == 'cancelled' ? null : ride?['id'] as String?);
        runInAction(() => ready.value = true);
      } while (_again && _valid(generation));
    } catch (_) {
      if (_valid(generation)) {
        runInAction(() {
          ready.value = false;
          error.value = 'Ride status could not be confirmed.';
        });
      }
    } finally {
      if (_valid(generation)) runInAction(() => loading.value = false);
    }
  }

  Map<String, dynamic> _payload(Response<dynamic> response) {
    final body = response.data;
    if (response.statusCode != 200 ||
        body is! Map ||
        body['success'] != true ||
        body['data'] is! Map) {
      throw const FormatException('Invalid ride response');
    }
    return Map<String, dynamic>.from(body['data']);
  }

  Map<String, dynamic> _snapshot(Map<String, dynamic> payload) {
    final ride = payload['ride'];
    const states = {
      'requested',
      'searching',
      'accepted',
      'arrived',
      'started',
      'completed',
      'cancelled'
    };
    if (ride is! Map || !states.contains(ride['status'])) {
      throw const FormatException('Invalid ride snapshot');
    }
    final id = ride['id'] ?? ride['_id'];
    if (id is! String ||
        id.isEmpty ||
        (ride['_id'] != null && ride['_id'] != id)) {
      throw const FormatException('Invalid ride identity');
    }
    return {
      ...payload,
      'ride': {...Map<String, dynamic>.from(ride), 'id': id, '_id': id}
    };
  }
}
