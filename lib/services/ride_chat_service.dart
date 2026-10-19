import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import '../models/chat/chat_message_model.dart';
import '../core/services/dio_service.dart';
import '../core/services/preferences_service.dart';

/// A single immutable, securely stored outgoing command per ride and login session.
class RideChatService {
  RideChatService({
    required this.role,
    Dio? dio,
    Future<String?> Function()? tokenReader,
    Future<Map<String, dynamic>?> Function(String)? readPending,
    Future<void> Function(String, Map<String, dynamic>)? writePending,
    Future<void> Function(String)? removePending,
    DateTime Function()? now,
  })  : _providedDio = dio,
        _tokenReader = tokenReader ?? PreferencesService.getAccessToken,
        _readPending = readPending ?? PreferencesService.getJson,
        _writePending = writePending ?? PreferencesService.setJson,
        _removePending = removePending ?? PreferencesService.remove,
        _now = now ?? DateTime.now;

  final String role;
  final Dio? _providedDio;
  Dio get _dio => _providedDio ?? Api().dio;
  final Future<String?> Function() _tokenReader;
  final Future<Map<String, dynamic>?> Function(String) _readPending;
  final Future<void> Function(String, Map<String, dynamic>) _writePending;
  final Future<void> Function(String) _removePending;
  final DateTime Function() _now;
  final retryAfterSeconds = Observable(0);
  DateTime? _retryAt;
  Timer? _cooldownTimer;
  DateTime? _historyRetryAt;
  String? _typingRide;
  DateTime? _typingStartedAt;

  bool shouldSendTyping(String rideId, bool active) {
    final now = _now();
    if (!active) {
      if (_typingRide != rideId || _typingStartedAt == null) return false;
      _typingStartedAt = null;
      return true;
    }
    if (_typingRide == rideId &&
        _typingStartedAt != null &&
        now.difference(_typingStartedAt!) < const Duration(seconds: 2)) {
      return false;
    }
    _typingRide = rideId;
    _typingStartedAt = now;
    return true;
  }

  final sending = Observable(false);
  final sendError = Observable<String?>(null);
  final historyError = Observable<String?>(null);
  final nextCursor = Observable<String?>(null);
  String? _historyRide;
  int _generation = 0;
  int _historyRead = 0;
  CancelToken _cancel = CancelToken();
  Timer? _recoveryTimer;
  CancelToken? _recoveryCancel;
  int _recoveryEpoch = 0;
  int _manualHistoryReads = 0;
  String? _recoveryError;

  /// Revisit durable history independently of the user's older-message cursor.
  /// Each round refreshes the head and at most one page of a continuing sweep.
  void startRecovery(String rideId, void Function(List<RideMessage>) onMessages,
      {bool Function()? canRead}) {
    stopRecovery();
    final epoch = _recoveryEpoch;
    final generation = _generation;
    final cancel = CancelToken();
    _recoveryCancel = cancel;
    String? before;
    String? sessionToken;
    var failures = 0;
    bool active() =>
        epoch == _recoveryEpoch &&
        generation == _generation &&
        !cancel.isCancelled;

    Future<void> round() async {
      var delay = const Duration(seconds: 10);
      try {
        if (!active() || !(canRead?.call() ?? true) || _manualHistoryReads > 0) {
          return;
        }
        final retryAt = _historyRetryAt;
        if (retryAt != null && _now().isBefore(retryAt)) {
          delay = Duration(
              milliseconds:
                  max(10000, retryAt.difference(_now()).inMilliseconds));
          return;
        }
        final token = await _tokenReader();
        if (!active()) return;
        if (token == null ||
            token.isEmpty ||
            (sessionToken != null && sessionToken != token)) {
          stopRecovery();
          return;
        }
        sessionToken = token;
        Future<bool> sameSession() async =>
            active() &&
            await _tokenReader() == token &&
            active() &&
            (canRead?.call() ?? true);
        final head = await _recoveryPage(rideId, null, cancel);
        if (!await sameSession()) return;
        onMessages(head.messages);
        if (!active() || !(canRead?.call() ?? true)) return;
        if (before == null) {
          before = head.nextCursor;
        } else if (_manualHistoryReads == 0) {
          final page = await _recoveryPage(rideId, before, cancel);
          if (!await sameSession()) return;
          onMessages(page.messages);
          before = page.nextCursor;
        }
        failures = 0;
        if (historyError.value == _recoveryError) {
          runInAction(() => historyError.value = null);
        }
        _recoveryError = null;
      } catch (failure) {
        if (!active() || !(canRead?.call() ?? true)) return;
        failures = min(failures + 1, 4);
        delay = Duration(seconds: min(60, 10 * (1 << (failures - 1))));
        if (failure is DioException && failure.response?.statusCode == 429) {
          final values = failure.response?.headers['retry-after'];
          final seconds =
              (int.tryParse(values?.length == 1 ? values!.single : '') ?? 60)
                  .clamp(1, 60);
          _historyRetryAt = _now().add(Duration(seconds: seconds));
          delay = Duration(seconds: max(10, seconds));
        }
        if (failure is DioException &&
            const {401, 403, 404}.contains(failure.response?.statusCode)) {
          stopRecovery();
          return;
        }
        if (historyError.value == null ||
            historyError.value == _recoveryError) {
          _recoveryError = 'Chat sync interrupted. Retrying shortly.';
          runInAction(() => historyError.value = _recoveryError);
        }
      } finally {
        if (active()) _recoveryTimer = Timer(delay, round);
      }
    }

    _recoveryTimer = Timer(const Duration(seconds: 10), round);
  }

  void stopRecovery() {
    _recoveryEpoch++;
    _recoveryTimer?.cancel();
    _recoveryTimer = null;
    _recoveryCancel?.cancel('Chat recovery stopped');
    _recoveryCancel = null;
    if (historyError.value == _recoveryError) {
      runInAction(() => historyError.value = null);
    }
    _recoveryError = null;
  }

  Future<({List<RideMessage> messages, String? nextCursor})> _recoveryPage(
      String rideId, String? before, CancelToken cancel) async {
    final body = _payload(await _dio.get('/chat/${Uri.encodeComponent(rideId)}',
        queryParameters: {if (before != null) 'before': before, 'limit': 100},
        options: Options(
            receiveTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 10)),
        cancelToken: cancel));
    if (body['rideId'] != rideId ||
        body['messages'] is! List ||
        (body['messages'] as List).length > 100) {
      throw const FormatException('Invalid chat recovery page');
    }
    final cursor = body['nextCursor'];
    final keyPattern = RegExp(r'^[0-9]{13}[0-9a-f]{24}$');
    if (cursor != null &&
        (cursor is! String ||
            !keyPattern.hasMatch(cursor) ||
            (before != null && cursor.compareTo(before) >= 0))) {
      throw const FormatException('Invalid chat recovery cursor');
    }
    final messages = <RideMessage>[];
    final ids = <String>{};
    String? previous = before;
    for (final raw in body['messages'] as List) {
      if (raw is! Map) throw const FormatException('Invalid chat record');
      final message = RideMessage.fromJson(Map<String, dynamic>.from(raw));
      final key = message.orderKey;
      if (message.rideId != rideId ||
          message.id == null ||
          message.id!.isEmpty ||
          !ids.add(message.id!) ||
          key == null ||
          !keyPattern.hasMatch(key) ||
          (previous != null && key.compareTo(previous) >= 0)) {
        throw const FormatException('Invalid chat recovery order');
      }
      messages.add(message);
      previous = key;
    }
    if (cursor != null &&
        (messages.isEmpty || cursor != messages.last.orderKey)) {
      throw const FormatException('Invalid chat recovery boundary');
    }
    return (messages: messages, nextCursor: cursor as String?);
  }

  String _key(String token, String rideId) =>
      'ride_chat_pending_${sha256.convert(utf8.encode('$role:$token:$rideId'))}';

  Future<String?> pendingDraft(String rideId) async {
    final generation = _generation;
    final token = await _tokenReader();
    if (token == null || token.isEmpty || generation != _generation) {
      return null;
    }
    final pending = await _readPending(_key(token, rideId));
    if (generation != _generation) return null;
    return pending?['message'] as String?;
  }

  Future<List<RideMessage>> history(String rideId, {bool older = false}) async {
    _manualHistoryReads++;
    try {
      return await _history(rideId, older: older);
    } finally {
      _manualHistoryReads--;
    }
  }

  Future<List<RideMessage>> _history(String rideId,
      {bool older = false}) async {
    final retryAt = _historyRetryAt;
    if (retryAt != null && _now().isBefore(retryAt)) {
      final seconds = (retryAt.difference(_now()).inMilliseconds / 1000).ceil();
      throw FormatException('Chat history is busy. Try again in ${seconds}s.');
    }
    final generation = _generation;
    final read = ++_historyRead;
    final before = older && _historyRide == rideId ? nextCursor.value : null;
    if (older && before == null) return [];
    late final Map<String, dynamic> body;
    try {
      body = _payload(await _dio.get('/chat/${Uri.encodeComponent(rideId)}',
          queryParameters: {if (before != null) 'before': before, 'limit': 100},
          cancelToken: _cancel));
    } on DioException catch (failure) {
      if (generation != _generation || read != _historyRead) rethrow;
      if (failure.response?.statusCode == 429) {
        final values = failure.response?.headers['retry-after'];
        final raw = values?.length == 1 ? values!.single : null;
        final seconds = (int.tryParse(raw ?? '') ?? 60).clamp(1, 60);
        _historyRetryAt = _now().add(Duration(seconds: seconds));
        throw FormatException(
            'Chat history is busy. Try again in ${seconds}s.');
      }
      if (failure.response?.statusCode == 503) {
        throw const FormatException(
            'Chat history temporarily unavailable. Try again shortly.');
      }
      rethrow;
    }
    if (generation != _generation || read != _historyRead) {
      throw const FormatException('History superseded');
    }
    if ((body['rideId'] != null && body['rideId'] != rideId) ||
        body['messages'] is! List) {
      throw const FormatException('Invalid chat history');
    }
    final cursor = body['nextCursor'];
    if (cursor != null &&
        (cursor is! String ||
            !RegExp(r'^[0-9]{13}[0-9a-f]{24}$').hasMatch(cursor) ||
            cursor == before)) {
      throw const FormatException('Invalid chat cursor');
    }
    final messages = (body['messages'] as List).map((raw) {
      final message =
          RideMessage.fromJson(Map<String, dynamic>.from(raw as Map));
      if (message.rideId != rideId) throw const FormatException('Wrong ride');
      return message;
    }).toList();
    runInAction(() => nextCursor.value = cursor as String?);
    _historyRide = rideId;
    return messages;
  }

  Future<RideMessage?> send(String rideId, String text) async {
    _updateCooldown();
    if (retryAfterSeconds.value > 0) return null;
    if (sending.value) return null;
    final generation = _generation;
    runInAction(() {
      sending.value = true;
      sendError.value = null;
    });
    try {
      text = text.trim();
      if (text.isEmpty || text.length > 2000) {
        throw const FormatException(
            'Message must contain 1 to 2000 characters.');
      }
      final token = await _tokenReader();
      if (generation != _generation) return null;
      if (token == null || token.isEmpty) {
        throw const FormatException('Sign in again.');
      }
      final key = _key(token, rideId);
      var pending = await _readPending(key);
      if (generation != _generation) return null;
      if (pending != null && pending['message'] != text) {
        throw const FormatException(
            'Retry the unconfirmed draft before sending a different message.');
      }
      pending ??= {
        'clientMessageId': List.generate(
            24,
            (_) => Random.secure()
                .nextInt(256)
                .toRadixString(16)
                .padLeft(2, '0')).join(),
        'message': text,
      };
      await _writePending(key, pending);
      if (generation != _generation || await _tokenReader() != token) {
        return null;
      }
      if (generation != _generation) return null;
      final body = _payload(await _dio.post(
          '/chat/${Uri.encodeComponent(rideId)}',
          data: pending,
          cancelToken: _cancel));
      final message = RideMessage.fromJson(body);
      if (message.id == null ||
          message.id!.isEmpty ||
          message.rideId != rideId ||
          message.sender != role ||
          message.message != text ||
          message.clientMessageId != pending['clientMessageId']) {
        throw const FormatException(
            'Message confirmation was invalid. Retry the same draft.');
      }
      if (generation != _generation) return null;
      await _removePending(key);
      if (generation != _generation) return null;
      return message;
    } catch (failure) {
      if (generation == _generation) {
        if (failure is DioException && failure.response?.statusCode == 429) {
          final values = failure.response?.headers['retry-after'];
          final raw = values?.length == 1 ? values!.single : null;
          final seconds = int.tryParse(raw ?? '') ?? 60;
          _startCooldown(seconds.clamp(1, 60));
        } else {
          runInAction(() => sendError.value = failure is FormatException
              ? failure.message
              : failure is DioException && failure.response?.statusCode == 503
                  ? 'Chat temporarily unavailable. Your draft is saved; try again.'
                  : 'Message not confirmed. Retry the same draft.');
        }
      }
      return null;
    } finally {
      if (generation == _generation) runInAction(() => sending.value = false);
    }
  }

  void _startCooldown(int seconds) {
    _cooldownTimer?.cancel();
    _retryAt = _now().add(Duration(seconds: seconds));
    runInAction(() {
      retryAfterSeconds.value = seconds;
      sendError.value = 'Message limit reached. Your draft is saved.';
    });
    _cooldownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateCooldown());
  }

  void _updateCooldown() {
    final retryAt = _retryAt;
    if (retryAt == null) return;
    final remaining =
        (retryAt.difference(_now()).inMilliseconds / 1000).ceil().clamp(0, 60);
    runInAction(() => retryAfterSeconds.value = remaining);
    if (remaining == 0) {
      _cooldownTimer?.cancel();
      _cooldownTimer = null;
      _retryAt = null;
      runInAction(() => sendError.value = 'You can retry the same draft.');
    }
  }

  Map<String, dynamic> _payload(Response<dynamic> response) {
    final body = response.data;
    if (response.statusCode != 200 ||
        body is! Map ||
        body['success'] != true ||
        body['data'] is! Map) {
      throw const FormatException('Chat response could not be confirmed.');
    }
    return Map<String, dynamic>.from(body['data']);
  }

  void reset() {
    stopRecovery();
    _historyRetryAt = null;
    _typingRide = null;
    _typingStartedAt = null;
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    _retryAt = null;
    _generation++;
    _historyRead++;
    _cancel.cancel('Chat session ended');
    _cancel = CancelToken();
    _historyRide = null;
    runInAction(() {
      sending.value = false;
      retryAfterSeconds.value = 0;
      sendError.value = null;
      historyError.value = null;
      nextCursor.value = null;
    });
  }
}
