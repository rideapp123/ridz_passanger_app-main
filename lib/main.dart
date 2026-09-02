import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:ridzs_passenger_app/core/services/notification_service.dart';
import 'package:ridzs_passenger_app/view/home/app.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'core/configs/app_providers.dart';
import 'core/exports/common_exports.dart';
import 'core/services/analytics_service.dart';
import 'core/services/firebase_service.dart';
import 'core/services/sentry_service.dart';

final firebaseNotificationService = FirebaseNotificationService();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('_firebaseMessagingBackgroundHandler : : ${message.data['type']}');
}

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    AppConfig.setAppFlavor();

    await setPreferredOrientations();
    setStatusBarColor();
    await FirebaseService().initializeFirebase();
    await MobileAds.instance.initialize();
    GoogleAuthService().initialize();
    if (AppConfig.allFlavor == AppFlavor.production) {
      AnalyticService().initialize();
      await SentryService().initialize();
    }
    tz.initializeTimeZones();
    try {
      const stripeKey = String.fromEnvironment('STRIPE_PK',
          defaultValue:
              'pk_test_51Pyen4P9sQVndu6ghKTndZ4gTTbBgA90QRxLfQhaJmLzCIUmVq0yLmeSIaTVRCzFg5evO7W6F3lqmF0WUTfl55L2003nz67X1P');
      Stripe.publishableKey = stripeKey;
      await Stripe.instance.applySettings();
    } catch (e) {
      log('Failed to initialize Stripe: $e');
    }
    runApp(
      MultiProvider(
        providers: appProviders,
        child: const RestartWidget(
          child: App(),
        ),
      ),
    );
  }, (exception, stackTrace) async {
    if (AppConfig.allFlavor == AppFlavor.production) {
      await Sentry.captureException(exception, stackTrace: stackTrace);
    }
    debugPrintStack(stackTrace: stackTrace);
  });
}

Future<void> setPreferredOrientations() {
  return SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

void setStatusBarColor() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
}
