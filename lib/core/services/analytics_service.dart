import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:amplitude_flutter/events/event_options.dart';
// import '../../stores/users/user_store.dart';
import '../../stores/users/user_store.dart';
import '../configs/app_config.dart';
import '../enums/analytic_event.dart';
import '../enums/app_flavor.dart';

class AnalyticService {
  factory AnalyticService() => _instance ??= AnalyticService._();

  AnalyticService._();
  static AnalyticService? _instance;
  late Amplitude _analytics;

  void initialize() {
    _analytics = Amplitude(Configuration(instanceName: 'project', apiKey: ''));
    // _analytics.init('');
  }

  void logEvent(AnalyticEventType event, Map<String, dynamic> eventProperties) {
    if (AppConfig.allFlavor == AppFlavor.production) {
      _analytics.track(
        BaseEvent(event.name),
        EventOptions(
          extra: {
            'user_id': userStoreProvider().loggedInUser?.id,
            'username': userStoreProvider().loggedInUser?.username,
            ...eventProperties,
          },
        ),
      );
    }
  }
}
