import 'package:dio/dio.dart';
import 'dart:math';
import '../models/privacy_disclosure.dart';
import '../models/privacy_disposition.dart';
import '../models/privacy_source_plan.dart';
import 'package:flutter/foundation.dart';
import '../core/services/dio_service.dart';
import '../core/services/preferences_service.dart';

class PrivacyRequest {
  const PrivacyRequest(this.id, this.kind, this.details, this.status,
      this.version, this.updatedAt);
  final String id, kind, details, status;
  final int version;
  final DateTime updatedAt;

  static PrivacyRequest? parse(dynamic data) {
    if (data is! Map ||
        data['fulfilled'] != false ||
        data['deletionEnabled'] != false ||
        data['hasRequest'] is! bool) {
      throw const FormatException('Invalid privacy response');
    }
    final r = data['request'];
    if (data['hasRequest'] == false && r == null) return null;
    if (data['hasRequest'] != true) {
      throw const FormatException('Invalid privacy response');
    }
    if (r is! Map ||
        r['id'] is! String ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(r['id']) ||
        r['role'] != 'passenger' ||
        !const {'access', 'correction', 'erasure'}.contains(r['kind']) ||
        !const {'pending', 'reviewed'}.contains(r['status']) ||
        r['details'] is! String ||
        (r['details'] as String).length > 2000 ||
        r['version'] is! int ||
        r['version'] < 1 ||
        r['version'] > 100 ||
        r['submittedAt'] is! String ||
        DateTime.tryParse(r['submittedAt']) == null ||
        r['updatedAt'] is! String ||
        DateTime.tryParse(r['updatedAt']) == null) {
      throw const FormatException('Invalid privacy request');
    }
    return PrivacyRequest(r['id'], r['kind'], r['details'], r['status'],
        r['version'], DateTime.parse(r['updatedAt']));
  }
}

class PrivacyRequestService extends ChangeNotifier {
  PrivacyRequestService({Dio? dio, Future<String?> Function()? tokenReader})
      : _providedDio = dio,
        _tokenReader = tokenReader ?? PreferencesService.getAccessToken {
    _sessions.add(this);
  }
  static final _sessions = <PrivacyRequestService>{};
  static void endAllSessions() {
    for (final session in _sessions.toList()) {
      session.endSession();
    }
  }

  final Dio? _providedDio;
  final Future<String?> Function() _tokenReader;
  final _cancel = CancelToken();
  Dio get _dio => _providedDio ?? Api().dio;
  PrivacyRequest? record;
  PrivacyDispositionSummary? disposition;
  PrivacySourcePlanSummary? sourcePlan;
  PrivacyDisclosureSummary? disclosure;
  PrivacyResponsePackage? responsePackage;
  List<PrivacyDisclosureSummary> get availablePages => [
        if (disclosure != null) disclosure!,
        ...?responsePackage?.pages.where((page) => page.id != disclosure?.id)
      ];
  PrivacyDisclosurePage? disclosedPage;
  bool busy = false, ready = false, ended = false;
  String? error, notice, _token;
  Map<String, dynamic>? _pending;
  Map<String, dynamic>? _pendingAccess;
  PrivacyDisclosureSummary? _accessSummary;
  bool get hasPending => _pending != null || _pendingAccess != null;
  bool get canAccess =>
      ready &&
      !busy &&
      !ended &&
      !hasPending &&
      availablePages.isNotEmpty &&
      (record?.version ?? 100) < 100;
  bool get canSubmit =>
      ready &&
      !busy &&
      !ended &&
      !hasPending &&
      (record == null || record!.status == 'reviewed') &&
      (record?.version ?? 0) < 100;

  Future<bool> _valid() async {
    if (ended) return false;
    final token = await _tokenReader();
    if (ended) return false;
    if (token == null || token.isEmpty || (_token != null && _token != token)) {
      endSession();
      return false;
    }
    _token = token;
    return true;
  }

  Future<void> load() => _run(false);
  Future<void> submit(String kind, String details) async {
    if (!canSubmit) return;
    if (!const {'access', 'correction', 'erasure'}.contains(kind) ||
        details.trim().isEmpty ||
        details.length > 2000) {
      error = 'Enter request details (up to 2000 characters).';
      notifyListeners();
      return;
    }
    _pending = Map.unmodifiable({
      'version': record?.version ?? 0,
      'kind': kind,
      'details': details.trim()
    });
    await _run(true);
  }

  Future<void> retry() async {
    if (_pendingAccess != null) {
      await _run(true, access: true);
    } else if (_pending != null) {
      await _run(true);
    }
  }

  Future<void> accessDisclosure([PrivacyDisclosureSummary? selected]) async {
    if (!canAccess) return;
    final candidates = availablePages
        .where((page) =>
            page.id ==
            (selected?.id ?? disclosure?.id ?? availablePages.first.id))
        .toList();
    if (candidates.length != 1) return;
    final target = candidates.single;
    final random = Random.secure();
    final receipt = List.generate(
            16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'))
        .join();
    _pendingAccess = Map.unmodifiable({
      'version': record!.version,
      'disclosureId': target.id,
      'receiptId': receipt
    });
    _accessSummary = target;
    await _run(true, access: true);
  }

  Future<void> _run(bool write, {bool access = false}) async {
    if (ended || busy) return;
    busy = true;
    error = null;
    notice = null;
    disclosedPage = null;
    disposition = null;
    sourcePlan = null;
    if (!write) {
      ready = false;
      disclosure = null;
      responsePackage = null;
    }
    notifyListeners();
    try {
      if (!await _valid()) return;
      final command = access ? _pendingAccess : _pending;
      final expectedDisclosure = access ? _accessSummary : disclosure;
      final options = Options(extra: {'expectedAuthToken': _token});
      final response = write
          ? await _dio.post(
              access ? '/privacy-request/disclosure' : '/privacy-request',
              data: command,
              options: options,
              cancelToken: _cancel)
          : await _dio.get('/privacy-request',
              options: options, cancelToken: _cancel);
      if (!await _valid()) return;
      final body = response.data;
      if (response.statusCode != 200 ||
          body is! Map ||
          body['success'] != true) {
        throw const FormatException('Invalid privacy response');
      }
      final saved = PrivacyRequest.parse(body['data']);
      final assessment = PrivacyDispositionSummary.parse(
          body['data']['disposition'], saved?.kind);
      if (assessment != null && saved?.status != 'reviewed') {
        throw const FormatException('Invalid assessment state');
      }
      final plan = PrivacySourcePlanSummary.parse(
          body['data']['sourcePlan'], assessment);
      if (write &&
          (saved == null ||
              saved.version < (command!['version'] as int) + 1 ||
              (record != null && record!.id != saved.id))) {
        throw const FormatException('Request was not confirmed');
      }
      if (write &&
          !access &&
          saved!.version == (command!['version'] as int) + 1 &&
          (saved.kind != command['kind'] ||
              saved.details != command['details'])) {
        throw const FormatException('Request confirmation did not match');
      }
      final approved =
          PrivacyDisclosureSummary.parse(body['data']['disclosure']);
      final package =
          PrivacyResponsePackage.parse(body['data']['responsePackage']);
      if ((approved != null || package != null) &&
          (saved?.status != 'reviewed' || saved?.kind != 'access')) {
        throw const FormatException('Invalid disclosure state');
      }
      PrivacyDisclosurePage? page;
      if (access) {
        final summaries = [if (approved != null) approved, ...?package?.pages];
        if (expectedDisclosure == null ||
            !summaries.any((page) =>
                page.id == expectedDisclosure.id &&
                page.scope == expectedDisclosure.scope &&
                page.domain == expectedDisclosure.domain &&
                page.rideId == expectedDisclosure.rideId &&
                page.preparedAt == expectedDisclosure.preparedAt)) {
          throw const FormatException('Disclosure changed');
        }
        page = PrivacyDisclosurePage.parse(
            body['data']['disclosedPage'], expectedDisclosure);
      }
      record = saved;
      disposition = assessment;
      sourcePlan = plan;
      disclosure = approved;
      responsePackage = package;
      disclosedPage = page;
      _pending = null;
      _pendingAccess = null;
      _accessSummary = null;
      ready = true;
      notice = access
          ? 'Approved page received. Request fulfillment remains pending.'
          : write
              ? 'Request received. Fulfillment remains pending.'
              : null;
    } on DioException catch (failure) {
      if (ended) return;
      if (failure.response?.statusCode == 401 ||
          failure.response?.statusCode == 403) {
        endSession();
        return;
      }
      if (const {400, 404, 409}.contains(failure.response?.statusCode)) {
        _pending = null;
        _pendingAccess = null;
        _accessSummary = null;
        disclosure = null;
        responsePackage = null;
        ready = false;
        error = 'Request changed or could not be accepted. Refresh its status.';
      } else {
        error = write
            ? 'Request not confirmed. Retry or refresh status.'
            : 'Request status unavailable. Please retry.';
      }
    } catch (_) {
      if (!ended) {
        error = write
            ? 'Request not confirmed. Retry or refresh status.'
            : 'Request status unavailable. Please retry.';
      }
    } finally {
      if (!ended) {
        busy = false;
        notifyListeners();
      }
    }
  }

  void endSession() {
    if (ended) return;
    ended = true;
    _cancel.cancel('Privacy session ended');
    _token = null;
    _pending = null;
    _pendingAccess = null;
    _accessSummary = null;
    disclosure = null;
    responsePackage = null;
    disclosedPage = null;
    record = null;
    disposition = null;
    sourcePlan = null;
    ready = false;
    busy = false;
    error = null;
    notice = null;
    _sessions.remove(this);
    notifyListeners();
  }

  @override
  void dispose() {
    endSession();
    super.dispose();
  }
}
