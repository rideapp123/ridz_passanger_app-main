import 'package:sentry_flutter/sentry_flutter.dart';
import '../configs/app_config.dart';

class SentryService {
  factory SentryService() => _instance ??= SentryService._();

  SentryService._();
  static SentryService? _instance;

  Future<void> initialize() async {
    if (AppConfig.sentryDsn.isEmpty) return;
    await SentryFlutter.init((options) {
      options.dsn = AppConfig.sentryDsn;
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
    });
  }
}
