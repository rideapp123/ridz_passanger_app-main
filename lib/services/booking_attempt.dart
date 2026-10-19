import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import '../core/services/preferences_service.dart';
import '../models/common/ride_response/ride_response.dart';
import 'ride_service.dart';

/// Persist the immutable request before the first POST; every retry uses its key.
class BookingAttempt {
  BookingAttempt({
    required RideService service,
    Future<String?> Function()? tokenReader,
    Future<Map<String, dynamic>?> Function(String)? read,
    Future<void> Function(String, Map<String, dynamic>)? write,
    Future<void> Function(String)? remove,
  })  : _service = service,
        _tokenReader = tokenReader ?? PreferencesService.getAccessToken,
        _read = read ?? PreferencesService.getJson,
        _write = write ?? PreferencesService.setJson,
        _remove = remove ?? PreferencesService.remove;

  final RideService _service;
  final Future<String?> Function() _tokenReader;
  final Future<Map<String, dynamic>?> Function(String) _read;
  final Future<void> Function(String, Map<String, dynamic>) _write;
  final Future<void> Function(String) _remove;
  final busy = Observable(false);
  final pending = Observable(false);
  final error = Observable<String?>(null);
  String? _scope;
  Map<String, dynamic>? _attempt;
  int _epoch = 0;
  Future<void>? _restoring;

  Future<void> restore() {
    if (_scope != null) return Future.value();
    final epoch = _epoch;
    return _restoring ??= _restore().whenComplete(() {
      if (epoch == _epoch) _restoring = null;
    });
  }

  Future<void> _restore() async {
    final epoch = _epoch;
    final token = await _tokenReader();
    if (epoch != _epoch) throw StateError('Session ended');
    if (token == null || token.isEmpty) throw StateError('Sign in required');
    final scope = 'booking_attempt_${sha256.convert(utf8.encode(token))}';
    final stored = await _read(scope);
    if (epoch != _epoch) throw StateError('Session ended');
    if (stored != null &&
        (stored['key'] is! String || stored['payload'] is! Map)) {
      throw const FormatException('Invalid saved booking');
    }
    _scope = scope;
    _attempt = stored;
    runInAction(() => pending.value = stored != null);
  }

  Future<RideRequest> submit([Map<String, dynamic>? payload]) async {
    if (busy.value) throw StateError('Booking already in progress');
    final epoch = _epoch;
    runInAction(() {
      busy.value = true;
      error.value = null;
    });
    try {
      await restore();
      if (epoch != _epoch) throw StateError('Session ended');
      if (_attempt == null) {
        if (payload == null) throw StateError('No pending booking');
        final random = Random.secure();
        _attempt = {
          'key':
              base64Url.encode(List.generate(24, (_) => random.nextInt(256))),
          'payload': jsonDecode(jsonEncode(payload))
        };
      }
      final attempt = _attempt!;
      final scope = _scope!;
      await _write(scope, attempt);
      if (epoch != _epoch) throw StateError('Session ended');
      runInAction(() => pending.value = true);
      final ride = await _service.createBooking(
          Map<String, dynamic>.from(attempt['payload']), attempt['key']);
      if (epoch != _epoch) throw StateError('Session ended');
      await _remove(scope);
      if (epoch != _epoch) throw StateError('Session ended');
      _attempt = null;
      runInAction(() => pending.value = false);
      return ride;
    } catch (exception) {
      if (epoch == _epoch) {
        final body =
            exception is DioException ? exception.response?.data : null;
        if (body is Map && body['code'] == 'BOOKING_REJECTED') {
          await _remove(_scope!);
          if (epoch != _epoch) rethrow;
          _attempt = null;
          runInAction(() {
            pending.value = false;
            error.value =
                'Booking was not placed. Review your trip and payment method.';
          });
        } else {
          runInAction(() => error.value =
              'Booking could not be confirmed. Retry to check the same request.');
        }
      }
      rethrow;
    } finally {
      if (epoch == _epoch) runInAction(() => busy.value = false);
    }
  }

  void dispose() {
    _epoch++;
    _restoring = null;
    _scope = null;
    _attempt = null;
    runInAction(() {
      busy.value = false;
      pending.value = false;
      error.value = null;
    });
  }
}
