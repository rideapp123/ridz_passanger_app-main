import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import '../core/services/dio_service.dart';

class SavedRideRating {
  const SavedRideRating(
      {required this.id,
      required this.rideId,
      required this.by,
      required this.stars,
      required this.feedback});
  final String id, rideId, by, feedback;
  final int stars;

  factory SavedRideRating.parse(dynamic raw, String rideId, String role) {
    if (raw is! Map ||
        raw['id'] is! String ||
        (raw['id'] as String).isEmpty ||
        raw['rideId'] != rideId ||
        raw['by'] != role ||
        raw['rating'] is! int ||
        raw['rating'] < 1 ||
        raw['rating'] > 5 ||
        raw['feedback'] is! String ||
        (raw['feedback'] as String).length > 2000 ||
        raw['createdAt'] is! String ||
        DateTime.tryParse(raw['createdAt']) == null) {
      throw const FormatException('Invalid saved rating');
    }
    return SavedRideRating(
        id: raw['id'],
        rideId: rideId,
        by: role,
        stars: raw['rating'],
        feedback: raw['feedback']);
  }
}

class RideRatingService {
  RideRatingService({required this.role, Dio? dio}) : _providedDio = dio;
  final String role;
  final Dio? _providedDio;
  Dio get _dio => _providedDio ?? Api().dio;
  final record = Observable<SavedRideRating?>(null);
  final loading = Observable(false);
  final saving = Observable(false);
  final loadError = Observable<String?>(null);
  final error = Observable<String?>(null);
  int _generation = 0;
  int _read = 0;
  CancelToken _cancel = CancelToken();

  String _path(String rideId) => '/chat/${Uri.encodeComponent(rideId)}/rating';

  Future<SavedRideRating?> load(String rideId) async {
    final generation = _generation, read = ++_read;
    runInAction(() {
      loading.value = true;
      loadError.value = null;
      record.value = null;
    });
    try {
      final saved = await _get(rideId);
      if (generation != _generation || read != _read) return null;
      runInAction(() {
        record.value = saved;
        error.value = null;
      });
      return saved;
    } catch (_) {
      if (generation == _generation && read == _read) {
        runInAction(() => loadError.value = 'Your rating could not be loaded.');
      }
      return null;
    } finally {
      if (generation == _generation && read == _read) {
        runInAction(() => loading.value = false);
      }
    }
  }

  Future<SavedRideRating?> _get(String rideId) async {
    final data = _data(await _dio.get(_path(rideId), cancelToken: _cancel));
    if (data['rideId'] != rideId || data['hasRating'] is! bool) {
      throw const FormatException('Invalid rating lookup');
    }
    if (data['hasRating'] == false && data['rating'] == null) return null;
    if (data['hasRating'] != true) {
      throw const FormatException('Invalid rating lookup');
    }
    return SavedRideRating.parse(data['rating'], rideId, role);
  }

  Future<SavedRideRating?> submit(
      String rideId, int stars, String feedback) async {
    if (saving.value || loading.value) return null;
    final generation = _generation;
    ++_read;
    runInAction(() {
      saving.value = true;
      error.value = null;
    });
    try {
      feedback = feedback.trim();
      if (stars < 1 || stars > 5 || feedback.length > 2000) {
        throw const FormatException(
            'Choose 1 to 5 stars and keep feedback within 2000 characters.');
      }
      SavedRideRating? saved =
          record.value?.rideId == rideId ? record.value : null;
      if (saved == null) {
        try {
          final data = _data(await _dio.post(_path(rideId),
              data: {'rating': stars, 'feedback': feedback},
              cancelToken: _cancel));
          saved = SavedRideRating.parse(data, rideId, role);
          if (saved.stars != stars || saved.feedback != feedback) {
            throw const FormatException('Rating confirmation did not match.');
          }
        } on DioException catch (failure) {
          final body = failure.response?.data;
          if (failure.response?.statusCode != 409 ||
              body is! Map ||
              body['code'] != 'RATING_ALREADY_SAVED') {
            rethrow;
          }
          if (generation != _generation) return null;
          saved = await _get(rideId);
          if (saved == null) {
            throw const FormatException(
                'Existing rating could not be confirmed.');
          }
        }
      }
      if (generation != _generation) return null;
      runInAction(() => record.value = saved);
      return saved;
    } catch (_) {
      if (generation == _generation) {
        runInAction(() => error.value =
            'Rating not confirmed. Your feedback is still here; please retry.');
      }
      return null;
    } finally {
      if (generation == _generation) runInAction(() => saving.value = false);
    }
  }

  Map<String, dynamic> _data(Response<dynamic> response) {
    final body = response.data;
    if (response.statusCode != 200 ||
        body is! Map ||
        body['success'] != true ||
        body['data'] is! Map) {
      throw const FormatException('Invalid rating response');
    }
    return Map<String, dynamic>.from(body['data']);
  }

  void reset() {
    _generation++;
    _read++;
    _cancel.cancel('Rating session ended');
    _cancel = CancelToken();
    runInAction(() {
      record.value = null;
      loading.value = false;
      saving.value = false;
      loadError.value = null;
      error.value = null;
    });
  }
}
