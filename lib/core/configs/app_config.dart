import 'dart:io';

import '../enums/app_flavor.dart';
import 'environment.dart';

abstract class AppConfig {
  static const stripePublishableKey =
      String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');
  static const amplitudeApiKey = String.fromEnvironment('AMPLITUDE_API_KEY');
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');
  static const mapboxPublicToken =
      String.fromEnvironment('MAPBOX_PUBLIC_TOKEN');
  static const socketPath =
      String.fromEnvironment('SOCKET_PATH', defaultValue: '/socket.io/');
  static const paymentUrlScheme = String.fromEnvironment('PAYMENT_URL_SCHEME');
  static late String apiRootUrl;
  static late String baseUrl;
  static late String socketUrl;
  static AppFlavor allFlavor = AppFlavor.develop;
  static const androidRewardedAdUnitId = String.fromEnvironment(
    'ADMOB_REWARDED_ANDROID_AD_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/5224354917',
  );
  static const iosRewardedAdUnitId = String.fromEnvironment(
    'ADMOB_REWARDED_IOS_AD_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/1712485313',
  );
  static String get rewardedAdUnitId =>
      Platform.isIOS ? iosRewardedAdUnitId : androidRewardedAdUnitId;

  static Future<void> setAppFlavor() async {
    final environment = await MobileEnvironment.load();
    MobileEnvironment.validateStripe(stripePublishableKey, environment.name);
    apiRootUrl = environment.apiUrl;
    baseUrl = '${environment.apiUrl}/passenger';
    socketUrl = environment.socketUrl;
    allFlavor =
        environment.name == 'prod' ? AppFlavor.production : AppFlavor.develop;
  }
}
