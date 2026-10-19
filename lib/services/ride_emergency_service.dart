import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import '../core/services/dio_service.dart';
import '../core/services/preferences_service.dart';

class RideSafetyIncident {
  const RideSafetyIncident(
      {required this.id,
      required this.rideId,
      required this.role,
      required this.reason,
      required this.status,
      required this.version,
      required this.reporterSafe,
      required this.updatedAt});
  final String id, rideId, role, reason, status;
  final int version;
  final bool reporterSafe;
  final DateTime updatedAt;

  factory RideSafetyIncident.parse(dynamic raw, String rideId, String role) {
    if (raw is! Map ||
        raw['id'] is! String ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(raw['id']) ||
        raw['rideId'] != rideId ||
        raw['by'] != role ||
        raw['reason'] is! String ||
        (raw['reason'] as String).length > 2000 ||
        !const {'open', 'acknowledged', 'resolved'}.contains(raw['status']) ||
        raw['version'] is! int ||
        raw['version'] < 0 ||
        raw['version'] > 1000 ||
        raw['reporterSafe'] is! bool ||
        raw['createdAt'] is! String ||
        DateTime.tryParse(raw['createdAt']) == null ||
        raw['updatedAt'] is! String ||
        DateTime.tryParse(raw['updatedAt']) == null) {
      throw const FormatException('Invalid safety report');
    }
    return RideSafetyIncident(
        id: raw['id'],
        rideId: rideId,
        role: role,
        reason: raw['reason'],
        status: raw['status'],
        version: raw['version'],
        reporterSafe: raw['reporterSafe'],
        updatedAt: DateTime.parse(raw['updatedAt']));
  }
}

class RideEmergencyService {
  RideEmergencyService(
      {required this.role,
      Dio? dio,
      Future<String?> Function()? tokenReader,
      this.onEnd})
      : _providedDio = dio,
        _tokenReader = tokenReader ?? PreferencesService.getAccessToken;
  final String role;
  final void Function()? onEnd;
  final Dio? _providedDio;
  final Future<String?> Function() _tokenReader;
  Dio get _dio => _providedDio ?? Api().dio;
  final record = Observable<RideSafetyIncident?>(null);
  final busy = Observable(false);
  final ready = Observable(false);
  final error = Observable<String?>(null);
  final ended = Observable(false);
  final notice = Observable<String?>(null);
  int _generation = 0;
  String? _rideId, _session;
  final CancelToken _cancel = CancelToken();
  String _path(String rideId) =>
      '/chat/${Uri.encodeComponent(rideId)}/emergency';

  Future<bool> load(String rideId) async {
    if (busy.value || ended.value) return false;
    final generation = _generation;
    runInAction(() {
      busy.value = true;
      error.value = null;
      ready.value = false;
    });
    try {
      final token = await _tokenReader();
      if (generation != _generation) return false;
      if (token == null ||
          token.isEmpty ||
          (_session != null && token != _session)) {
        endSession();
        return false;
      }
      _session = token;
      if (_rideId != rideId) {
        _rideId = rideId;
        runInAction(() {
          record.value = null;
          notice.value = null;
        });
      }
      final saved = await _get(rideId);
      if (!await _valid(generation, token)) return false;
      runInAction(() {
        record.value = saved;
        ready.value = true;
      });
      return true;
    } catch (_) {
      if (generation == _generation) {
        runInAction(
            () => error.value = 'Report status unavailable. Please retry.');
      }
      return false;
    } finally {
      if (generation == _generation) runInAction(() => busy.value = false);
    }
  }

  Future<RideSafetyIncident?> _get(String rideId) async {
    final data = _data(await _dio.get(_path(rideId), cancelToken: _cancel));
    if (data['rideId'] != rideId || data['hasIncident'] is! bool) {
      throw const FormatException('Invalid report lookup');
    }
    if (data['hasIncident'] == false && data['incident'] == null) return null;
    if (data['hasIncident'] != true) {
      throw const FormatException('Invalid report lookup');
    }
    return RideSafetyIncident.parse(data['incident'], rideId, role);
  }

  Future<bool> report(String rideId, String reason) =>
      _write(rideId, '', {'reason': reason.trim()});

  Future<bool> change(String rideId, String action) async {
    final saved = record.value;
    if (saved == null ||
        saved.rideId != rideId ||
        !const {'safe', 'reopen'}.contains(action)) {
      return false;
    }
    return _write(rideId, '/$action', {'version': saved.version});
  }

  Future<bool> _write(
      String rideId, String suffix, Map<String, dynamic> body) async {
    if (busy.value || ended.value || !ready.value || _rideId != rideId) {
      return false;
    }
    final generation = _generation, token = _session;
    runInAction(() {
      busy.value = true;
      error.value = null;
      notice.value = null;
    });
    try {
      if (token == null || !await _valid(generation, token)) return false;
      if (body['reason'] is String &&
          (body['reason'] as String).length > 2000) {
        throw const FormatException('Report too long');
      }
      final data = _data(await _dio.post('${_path(rideId)}$suffix',
          data: body, cancelToken: _cancel));
      if (!await _valid(generation, token)) return false;
      final saved = RideSafetyIncident.parse(data, rideId, role);
      if (suffix.isEmpty && saved.reason != body['reason']) {
        throw const FormatException('Report confirmation did not match');
      }
      if (suffix.isNotEmpty &&
          (saved.id != record.value?.id ||
              saved.version < (body['version'] as int) + 1)) {
        throw const FormatException('Status change not confirmed');
      }
      runInAction(() {
        record.value = saved;
        notice.value = suffix.isEmpty
            ? 'Report saved. Emergency services have not been contacted.'
            : 'Update saved. Current report status is shown below.';
      });
      return true;
    } on DioException catch (failure) {
      if (generation != _generation) return false;
      final response = failure.response?.data;
      if (failure.response?.statusCode == 409 &&
          response is Map &&
          const {
            'EMERGENCY_ALREADY_SAVED',
            'EMERGENCY_VERSION_CONFLICT',
            'EMERGENCY_STATE_CONFLICT'
          }.contains(response['code'])) {
        runInAction(() {
          ready.value = false;
          error.value =
              'Report changed. Refresh its status before acting again.';
        });
      } else {
        runInAction(() => error.value =
            'Update not confirmed. Check status or retry. Emergency services have not been contacted.');
      }
      return false;
    } catch (_) {
      if (generation == _generation) {
        runInAction(() => error.value =
            'Update not confirmed. Check status or retry. Emergency services have not been contacted.');
      }
      return false;
    } finally {
      if (generation == _generation) runInAction(() => busy.value = false);
    }
  }

  Future<bool> _valid(int generation, String token) async {
    if (generation != _generation) return false;
    final current = await _tokenReader();
    if (generation != _generation) return false;
    if (current != token) {
      endSession();
      return false;
    }
    return true;
  }

  Map<String, dynamic> _data(Response<dynamic> response) {
    final body = response.data;
    if (response.statusCode != 200 ||
        body is! Map ||
        body['success'] != true ||
        body['data'] is! Map) {
      throw const FormatException('Invalid safety response');
    }
    return Map<String, dynamic>.from(body['data']);
  }

  void endSession() {
    if (ended.value) return;
    _generation++;
    _cancel.cancel('Safety session ended');
    runInAction(() {
      record.value = null;
      ready.value = false;
      busy.value = false;
      error.value = null;
      notice.value = null;
      ended.value = true;
    });
    onEnd?.call();
  }
}
