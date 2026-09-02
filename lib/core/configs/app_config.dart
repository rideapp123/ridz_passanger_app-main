import 'dart:io';

import 'package:flutter/foundation.dart';

import '../enums/app_flavor.dart';

abstract class AppConfig {
  static late String baseUrl;
  static late String socketUrl;
  static late AppFlavor allFlavor;
  static const String _defaultBaseUrl = 'http://10.0.2.2:8081';
  static const String _defaultSocketUrl = 'http://10.0.2.2:8082';
  static const String _androidRewardedTestAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _iosRewardedTestAdUnitId =
      'ca-app-pub-3940256099942544/1712485313';
  static const String androidRewardedAdUnitId = String.fromEnvironment(
    'ADMOB_REWARDED_ANDROID_AD_UNIT_ID',
    defaultValue: _androidRewardedTestAdUnitId,
  );
  static const String iosRewardedAdUnitId = String.fromEnvironment(
    'ADMOB_REWARDED_IOS_AD_UNIT_ID',
    defaultValue: _iosRewardedTestAdUnitId,
  );

  static String get rewardedAdUnitId {
    if (Platform.isIOS) return iosRewardedAdUnitId;
    return androidRewardedAdUnitId;
  }

  static setAppFlavor() {
    const envBaseUrl = String.fromEnvironment('BACKEND_BASE_URL');
    const envSocketUrl = String.fromEnvironment('SOCKET_URL');
    final resolvedBaseUrl =
        envBaseUrl.isNotEmpty ? envBaseUrl : _defaultBaseUrl;
    final resolvedSocketUrl =
        envSocketUrl.isNotEmpty ? envSocketUrl : _defaultSocketUrl;

    const String? appFlavor = String.fromEnvironment('FLUTTER_APP_FLAVOR') != ''
        ? String.fromEnvironment('FLUTTER_APP_FLAVOR')
        : null;
    debugPrint('App Flavor: $appFlavor');
    switch (appFlavor) {
      case 'production':
        baseUrl = '$resolvedBaseUrl/passenger';
        socketUrl = resolvedSocketUrl;
        allFlavor = AppFlavor.production;
        return;
      case 'develop':
        baseUrl = '$resolvedBaseUrl/passenger';
        socketUrl = resolvedSocketUrl;
        allFlavor = AppFlavor.develop;
        return;
      default:
        baseUrl = '$resolvedBaseUrl/passenger';
        socketUrl = resolvedSocketUrl;
        allFlavor = AppFlavor.develop;
        return;
    }
  }
}
