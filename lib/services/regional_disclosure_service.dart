import 'package:dio/dio.dart';

import '../core/configs/app_config.dart';
import '../models/regional_disclosure.dart';

class DisclosureReadEnded implements Exception {
  const DisclosureReadEnded();
}

class DisclosureUnavailable implements Exception {
  const DisclosureUnavailable();
}

class DisclosureObservation<T> {
  DisclosureObservation._(
      this.data, this._elapsed, this._lifetime, this._current);
  final T data;
  final Stopwatch _elapsed;
  final Duration _lifetime;
  final bool Function() _current;
  Duration get remaining => _lifetime - _elapsed.elapsed;
  bool get isFresh => _current() && remaining > Duration.zero;
}

/// Owns an anonymous transport, never the authenticated passenger Dio singleton.
class RegionalDisclosureService {
  RegionalDisclosureService(
      {String Function()? apiRootReader, HttpClientAdapter? adapter})
      : _rootReader = apiRootReader ?? (() => AppConfig.apiRootUrl) {
    _root = _rootReader();
    final uri = Uri.tryParse(_root);
    if (uri == null ||
        !const ['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw const FormatException('Invalid regional information server');
    }
    _dio = Dio(BaseOptions(
      baseUrl: '${_root.replaceFirst(RegExp(r'/+$'), '')}/public/',
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      followRedirects: false,
      headers: {'Cache-Control': 'no-store', 'Accept': 'application/json'},
    ));
    if (adapter != null) _dio.httpClientAdapter = adapter;
  }
  final String Function() _rootReader;
  late final String _root;
  late final Dio _dio;
  CancelToken _cancel = CancelToken();
  bool _disposed = false;

  bool _current(CancelToken token) {
    if (!_disposed && _rootReader() != _root) dispose();
    return !_disposed && !token.isCancelled;
  }

  Future<Object?> _read(
      String path, Map<String, Object> query, CancelToken token) async {
    if (!_current(token)) throw const DisclosureReadEnded();
    try {
      final response =
          await _dio.get(path, queryParameters: query, cancelToken: token);
      if (!_current(token)) throw const DisclosureReadEnded();
      final body = response.data;
      if (response.statusCode != 200 ||
          body is! Map ||
          body['success'] != true ||
          body['data'] is! Map) {
        throw const FormatException('Invalid regional information response');
      }
      return body['data'];
    } on DioException catch (error) {
      if (!_current(token) || CancelToken.isCancel(error)) {
        throw const DisclosureReadEnded();
      }
      final body = error.response?.data;
      if (error.response?.statusCode == 409 &&
          body is Map &&
          body['code'] == 'DISCLOSURE_UNAVAILABLE') {
        throw const DisclosureUnavailable();
      }
      rethrow;
    }
  }

  Future<DisclosureObservation<DisclosureMarketPage>> markets(
      {required String locale, String? after}) async {
    if (!DisclosureMarket.validLocale(locale) ||
        after != null && !DisclosureMarket.validCursor(after)) {
      throw const FormatException('Invalid regional information request');
    }
    final token = _cancel;
    final elapsed = Stopwatch()..start();
    final raw = await _read('regional-disclosure-markets',
        {'locale': locale, if (after != null) 'after': after}, token);
    final data = DisclosureMarketPage.parse(raw, locale: locale, after: after);
    final result = DisclosureObservation._(data, elapsed,
        data.refreshAfter.difference(data.serverTime), () => _current(token));
    if (!result.isFresh) throw const DisclosureReadEnded();
    return result;
  }

  Future<DisclosureObservation<RegionalDisclosure>> load(
      {required String marketId,
      required String locale,
      int? expectedPolicyVersion}) async {
    if (!DisclosureMarket.validId(marketId) ||
        !DisclosureMarket.validLocale(locale) ||
        expectedPolicyVersion != null &&
            (expectedPolicyVersion < 0 ||
                expectedPolicyVersion > 9007199254740991)) {
      throw const FormatException('Invalid regional information request');
    }
    final token = _cancel;
    final elapsed = Stopwatch()..start();
    final raw = await _read(
        'regional-disclosures/$marketId', {'locale': locale}, token);
    final data = RegionalDisclosure.parse(raw,
        marketId: marketId,
        locale: locale,
        expectedPolicyVersion: expectedPolicyVersion);
    final result = DisclosureObservation._(data, elapsed,
        data.refreshAfter.difference(data.serverTime), () => _current(token));
    if (!result.isFresh) throw const DisclosureReadEnded();
    return result;
  }

  void cancelRequests() {
    _cancel.cancel('Regional information view ended');
    _cancel = CancelToken();
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    cancelRequests();
    _dio.close(force: true);
  }
}
