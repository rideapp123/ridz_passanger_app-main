import 'package:dio/dio.dart';

import '../models/ride/booking_quote.dart';

/// Own one instance per confirmation session and dispose on logout/navigation.
/// sessionReader must return a new identity for every login, including the same user.
class BookingQuoteService {
  BookingQuoteService(
      {required Dio dio,
      required Object? Function() sessionReader,
      String? expectedAuthToken})
      : _dio = dio,
        _expectedAuthToken = expectedAuthToken,
        _sessionReader = sessionReader;

  final Dio _dio;
  final String? _expectedAuthToken;
  final Object? Function() _sessionReader;
  final Map<String, BookingQuote> _quotes = {};
  final Map<String, String> _keys = {};
  final Set<CancelToken> _pending = {};
  Object? _session;
  bool _disposed = false;

  bool owns(BookingQuote quote) =>
      !_disposed &&
      _session != null &&
      identical(_session, _sessionReader()) &&
      identical(_quotes[quote.id], quote);

  Future<BookingQuote> issue(Map<String, dynamic> request, String key) {
    if (key.trim().isEmpty ||
        key.length > 128 ||
        RegExp(r'[\x00-\x1f\x7f-\x9f]').hasMatch(key)) {
      throw ArgumentError('A valid quote key is required');
    }
    return _fetch(request: BookingQuote.canonicalRequest(request), key: key);
  }

  Future<BookingQuote> get(String id) {
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(id)) {
      throw ArgumentError('A valid quote identity is required');
    }
    return _fetch(id: id);
  }

  Future<BookingQuote> _fetch(
      {String? id, Map<String, dynamic>? request, String? key}) async {
    final session = _sessionReader();
    if (_disposed || session == null) throw StateError('Quote session ended');
    if (!identical(_session, session)) {
      _clear();
      _session = session;
    }
    final cancel = CancelToken();
    _pending.add(cancel);
    final stopwatch = Stopwatch()..start();
    try {
      final response = id == null
          ? await _dio.post('/ride-quotes',
              data: request,
              cancelToken: cancel,
              options: Options(headers: {
                'Idempotency-Key': key
              }, extra: {
                if (_expectedAuthToken != null)
                  'expectedAuthToken': _expectedAuthToken,
              }))
          : await _dio.get('/ride-quotes/$id',
              cancelToken: cancel,
              options: Options(extra: {
                if (_expectedAuthToken != null)
                  'expectedAuthToken': _expectedAuthToken,
              }));
      if (_disposed ||
          !identical(session, _sessionReader()) ||
          !identical(session, _session)) {
        throw StateError('Quote session ended');
      }
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      final raw = data is Map ? data['quote'] : null;
      if (response.statusCode != 200 ||
          body is! Map ||
          body['success'] != true ||
          raw is! Map<String, dynamic>) {
        throw const FormatException('Quote was not confirmed');
      }
      final quote =
          BookingQuote.fromJson(raw, requestDuration: stopwatch.elapsed);
      if ((id != null && id != quote.id) ||
          (request != null && !quote.matchesRequest(request)) ||
          (key != null && _keys[key] != null && _keys[key] != quote.id)) {
        throw const FormatException('Quote identity changed');
      }
      final existing = _quotes[quote.id];
      if (existing != null) {
        existing.retainEarlierDeadline(quote);
      } else {
        // Do not evict live deadlines: replay must never start a new countdown.
        if (_quotes.length >= 64) throw StateError('Quote session is full');
        _quotes[quote.id] = quote;
      }
      if (key != null) {
        if (!_keys.containsKey(key) && _keys.length >= 64) {
          throw StateError('Quote session is full');
        }
        _keys[key] = quote.id;
      }
      return existing ?? quote;
    } finally {
      _pending.remove(cancel);
      stopwatch.stop();
    }
  }

  void _clear() {
    for (final pending in _pending) {
      pending.cancel('Quote session ended');
    }
    _pending.clear();
    _quotes.clear();
    _keys.clear();
  }

  void dispose() {
    _disposed = true;
    _clear();
  }
}
