import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/configs/app_config.dart';
import '../core/services/preferences_service.dart';
import '../models/ad_reward.dart';
import 'ad_reward_service.dart';
import 'reward_ad_player.dart';

enum RewardPhase {
  loading,
  playing,
  pending,
  confirmed,
  cancelled,
  expired,
  unavailable,
  review,
  ended
}

class AdRewardFlow extends ChangeNotifier {
  AdRewardFlow(
      {required this.owner,
      required this.sdkUnit,
      required String? Function() ownerReader,
      required Future<void> Function() refreshWallet,
      AdRewardService? service,
      RewardAdPlayer? player,
      Future<String?> Function()? tokenReader,
      Future<Map<String, dynamic>?> Function(String)? read,
      Future<void> Function(String, Map<String, dynamic>)? write,
      Future<void> Function(String)? remove,
      DateTime Function()? now,
      String? environment,
      this.pollInterval = const Duration(seconds: 3)})
      : _ownerReader = ownerReader,
        _refreshWallet = refreshWallet,
        _service = service ?? AdRewardService(),
        _player = player ?? GoogleRewardAdPlayer(),
        _tokenReader = tokenReader ?? PreferencesService.getAccessToken,
        _read = read ?? PreferencesService.getJson,
        _write = write ?? PreferencesService.setJson,
        _remove = remove ?? PreferencesService.remove,
        _now = now ?? DateTime.now,
        _scope =
            'ad_reward_attempt_v1_${sha256.convert(utf8.encode('${environment ?? AppConfig.baseUrl}\n$owner'))}' {
    _flows.add(this);
  }

  static final _flows = <AdRewardFlow>{};
  static Future<void> _storageTail = Future.value();
  static void endAllSessions() {
    for (final flow in _flows.toList()) {
      flow._end();
    }
  }

  final String owner, sdkUnit, _scope;
  final String? Function() _ownerReader;
  final Future<void> Function() _refreshWallet;
  final AdRewardService _service;
  final RewardAdPlayer _player;
  final Future<String?> Function() _tokenReader;
  final Future<Map<String, dynamic>?> Function(String) _read;
  final Future<void> Function(String, Map<String, dynamic>) _write;
  final Future<void> Function(String) _remove;
  final DateTime Function() _now;
  final Duration pollInterval;
  String? _token;
  String? _rideId, _resumeId;
  Map<String, dynamic>? _attempt;
  bool _disposed = false,
      _closing = false,
      _initialized = false,
      _foreground = true;
  bool _presented = false;
  Timer? _poll;
  int _polls = 0;
  bool busy = false, walletRefreshFailed = false;
  RewardPhase phase = RewardPhase.loading;
  AdRewardSession? session;
  DateTime? retryAfter;
  String? message;
  bool get active => !_disposed && phase != RewardPhase.ended;
  bool get canCancel => !_presented && session?.status == 'started';
  bool get canRetry =>
      active && !busy && (retryAfter == null || !_now().isBefore(retryAfter!));
  AdRewardCredit? get credit =>
      phase == RewardPhase.confirmed && session != null
          ? AdRewardCredit(session!)
          : null;

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  void _end() {
    if (_disposed) return;
    phase = RewardPhase.ended;
    _poll?.cancel();
    _player.dispose();
    _emit();
  }

  Future<void> _check() async {
    if (!active ||
        _ownerReader() != owner ||
        await _tokenReader() != _token ||
        !active) {
      _end();
      throw StateError('Account session ended');
    }
  }

  Future<T> _storage<T>(Future<T> Function() operation) {
    final result = _storageTail.then((_) async {
      await _check();
      return operation();
    });
    _storageTail = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  Future<void> _save() async {
    final value = Map<String, dynamic>.from(_attempt!);
    await _storage(() => _write(_scope, value));
    await _check();
  }

  Future<void> _clear() async {
    final request = _attempt?['requestId'];
    if (request == null) return;
    await _storage(() async {
      final current = await _read(_scope);
      await _check();
      if (current?['requestId'] == request) await _remove(_scope);
    });
    await _check();
  }

  Future<void> initialize({String? rideId, String? resumeSessionId}) =>
      _run(() async {
        if (_initialized) return;
        _rideId = rideId;
        _resumeId = resumeSessionId;
        _token = await _tokenReader();
        if (_token == null || _token!.isEmpty || !rewardId(owner)) {
          _end();
          return;
        }
        await _check();
        for (final other in _flows.toList()) {
          if (other != this && other._scope == _scope) other._end();
        }
        _initialized = true;
        if (resumeSessionId != null) {
          _presented = true;
          session = await _service.detail(_token!, owner, resumeSessionId);
          await _check();
          await _accept(session!);
          _schedule();
          return;
        }
        final stored = await _storage(() => _read(_scope));
        await _check();
        if (stored != null) {
          if (stored['owner'] != owner ||
              !rewardId(stored['requestId']) ||
              stored['presented'] is! bool ||
              (stored['sessionId'] != null && !rewardId(stored['sessionId'])) ||
              (stored['rideId'] != null && stored['rideId'] is! String)) {
            throw const FormatException('Saved reward needs review');
          }
          _attempt = Map.from(stored);
          _presented = stored['presented'];
          if (stored['sessionId'] != null) {
            await _refreshId(stored['sessionId']);
            // Recovery never replays an ad whose presentation may already have started.
            if (_presented || session!.status != 'started') {
              _schedule();
              return;
            }
          }
        } else {
          final offer = await _service.offer(_token!, rideId: rideId);
          await _check();
          _requireUnit(offer.units);
          final random = Random.secure();
          _attempt = {
            'owner': owner,
            'requestId':
                base64UrlEncode(List.generate(24, (_) => random.nextInt(256))),
            'rideId': rideId,
            'presented': false
          };
          await _save();
        }
        await _startOrShow();
      });

  Future<void> _startOrShow() async {
    await _check();
    if (session == null) {
      final value = await _service.start(
          _token!, owner, _attempt!['requestId'], _attempt!['rideId']);
      await _check();
      session = value;
      _attempt!['sessionId'] = value.id;
      await _save();
    }
    if (session!.status != 'started') {
      await _accept(session!);
      return;
    }
    if (_presented) {
      await _refreshId(session!.id);
      _schedule();
      return;
    }
    final offer = await _service.offer(_token!, rideId: _attempt!['rideId']);
    await _check();
    _requireUnit(offer.units);
    _requireUnit(session!.units);
    if (!_now().toUtc().isBefore(session!.watchDeadline)) {
      phase = RewardPhase.expired;
      message = 'The ad viewing window has ended.';
      return;
    }
    phase = RewardPhase.loading;
    message = null;
    _emit();
    await _player.show(sdkUnit, owner, session!.id, () async {
      await _check();
      if (_closing ||
          !_foreground ||
          !_now().toUtc().isBefore(session!.watchDeadline)) {
        return false;
      }
      _attempt!['presented'] = true;
      await _save();
      if (_closing || !active) return false;
      _presented = true;
      phase = RewardPhase.playing;
      _emit();
      return true;
    }, () {
      if (active && !_closing) {
        phase = RewardPhase.pending;
        _emit();
      }
    });
    await _check();
    if (_closing) return;
    await _refreshId(session!.id);
    _schedule();
  }

  void _requireUnit(Set<String> units) {
    if (!approvedRewardUnit(units, sdkUnit)) {
      throw const FormatException('This ad unit is not approved for rewards');
    }
  }

  Future<void> _accept(AdRewardSession value) async {
    final previous = session;
    if (previous != null &&
        (previous.id != value.id ||
            previous.minor != value.minor ||
            previous.notBefore != value.notBefore ||
            previous.watchDeadline != value.watchDeadline ||
            previous.confirmationDeadline != value.confirmationDeadline ||
            !setEquals(previous.units, value.units))) {
      throw const FormatException('Reward terms changed unexpectedly');
    }
    session = value;
    message = null;
    if (value.confirmed) {
      phase = RewardPhase.confirmed;
      _poll?.cancel();
      try {
        await _check();
        await _refreshWallet();
        await _check();
        walletRefreshFailed = false;
      } catch (_) {
        if (active) walletRefreshFailed = true;
      }
    } else if (value.status == 'cancelled') {
      phase = RewardPhase.cancelled;
      _poll?.cancel();
    } else {
      phase = _now().toUtc().isBefore(value.confirmationDeadline)
          ? RewardPhase.pending
          : RewardPhase.expired;
    }
  }

  Future<void> _refreshId(String id) async {
    final value = await _service.detail(_token!, owner, id);
    await _check();
    await _accept(value);
  }

  Future<void> retry() async {
    if (_attempt == null && session == null && _resumeId == null) {
      _initialized = false;
      await initialize(rideId: _rideId);
    } else {
      await _run(() async {
        await _check();
        if (session == null && _resumeId != null) {
          await _refreshId(_resumeId!);
        } else if (!_presented && _attempt != null) {
          await _save();
          await _startOrShow();
        } else if (session != null) {
          await _refreshId(session!.id);
        }
      });
    }
    _schedule();
  }

  Future<void> refresh() => _run(() async {
        await _check();
        if (session != null) {
          await _refreshId(session!.id);
        } else if (_attempt != null) {
          await _save();
          await _startOrShow();
        }
      });

  void _schedule() {
    _poll?.cancel();
    if (_closing ||
        !_foreground ||
        !active ||
        phase != RewardPhase.pending ||
        _polls >= 8) {
      return;
    }
    _poll = Timer(pollInterval, () async {
      if (busy) {
        _schedule();
        return;
      }
      _polls++;
      await refresh();
      _schedule();
    });
  }

  void foreground(bool value) {
    _foreground = value;
    _poll?.cancel();
    if (value && active && _initialized) {
      _polls = 0;
      unawaited(refresh().then((_) => _schedule()));
    }
  }

  Future<void> _run(Future<void> Function() work) async {
    if (busy || !active || _closing || !canRetry) return;
    busy = true;
    message = null;
    _emit();
    try {
      await work();
    } catch (error) {
      if (active && !_closing) {
        if (error is DioException && error.response?.statusCode == 429) {
          final seconds = int.tryParse(
                  error.response?.headers.value('Retry-After') ?? '') ??
              60;
          retryAfter = _now().add(Duration(seconds: seconds.clamp(1, 3600)));
          phase = RewardPhase.pending;
          message = 'Please wait before retrying this reward.';
        } else if (error is FormatException) {
          phase = RewardPhase.review;
          message = error.message;
        } else {
          phase = _attempt != null || session != null
              ? RewardPhase.pending
              : RewardPhase.unavailable;
          message = session != null
              ? 'Confirmation is unavailable. Check this reward again.'
              : _attempt != null
                  ? 'Start was not confirmed. Retry the saved request.'
                  : 'Rewards are unavailable right now.';
        }
      }
    } finally {
      if (!_disposed) {
        busy = false;
        _emit();
      }
    }
  }

  /// Once presentation starts, leaving never cancels a potentially earned reward.
  Future<bool> close() async {
    if (_closing) return false;
    _closing = true;
    _poll?.cancel();
    if (phase == RewardPhase.ended) return true;
    try {
      await _check();
      if (canCancel) {
        final cancelled = await _service.cancel(_token!, owner, session!.id);
        await _check();
        await _accept(cancelled);
      }
      if (session != null) await _clear();
      await _check();
      return true;
    } catch (_) {
      return active;
    } finally {
      _player.dispose();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _poll?.cancel();
    _player.dispose();
    _flows.remove(this);
    super.dispose();
  }
}
