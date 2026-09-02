import 'package:sentry_flutter/sentry_flutter.dart';

class SentryService {
  factory SentryService() => _instance ??= SentryService._();

  SentryService._();
  static SentryService? _instance;

  Future<void> initialize() async {
    await SentryFlutter.init((options) {
      options.dsn = '';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
    });
  }
}
