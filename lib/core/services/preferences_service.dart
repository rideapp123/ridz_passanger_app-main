// ignore_for_file: unused_element

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../configs/app_config.dart';

class PreferencesService {
  static const String accessToken = 'access_token';

  static const String onBoardingKey = 'is_onboarding';

  static const String showCommunityIntroDialog = 'community_intro_dialog_shown';

  static const String showUpdateUsernameDialog = 'update_username_dialog_shown';

  static const String communityCodeRequested = 'community_code_requested';

  static const String homePageTutorialCompleted =
      'home_page_tutorial_completed';

  static const String globalPageTutorialCompleted =
      'global_page_tutorial_completed';

  static const String appFeedbackDialogShown = 'app_feedback_dialog';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
      aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ));

  static Future<String?> getAccessToken() async {
    return await _get(PreferencesService.accessToken);
  }

  static Future<void> removeAccessToken() async {
    return await remove(PreferencesService.accessToken);
  }

  static Future<void> setAccessToken(String? token) async {
    return await _set(PreferencesService.accessToken, token);
  }

  static Future<String?> getOnboardingStatus() async {
    //tmp for disabling onboarding
    return _get(onBoardingKey);
  }

  static Future<void> setOnboardingStatus(String? value) async {
    return _set(onBoardingKey, value);
  }

  static Future<String?> getHomeTutorialStatus() async {
    return _get(homePageTutorialCompleted);
  }

  static Future<void> setHomeTutorialStatus() async {
    return _set(homePageTutorialCompleted, 'done');
  }

  static Future<String?> getGlobalTutorialStatus() async {
    return _get(globalPageTutorialCompleted);
  }

  static Future<void> setGlobalTutorialStatus() async {
    return _set(globalPageTutorialCompleted, 'done');
  }

  static Future<String?> getAppFeedbackDialogStatus() async {
    return _get(appFeedbackDialogShown);
  }

  static Future<void> setAppFeedbackDialogStatus() async {
    return _set(appFeedbackDialogShown, 'shown');
  }

  static Future<void> setAppFlavor() async {
    return _set('app_flavor', AppConfig.allFlavor.name);
  }

  static Future<String?> getAppFlavor() async {
    return _get('app_flavor');
  }

  static Future<void> setCommunityIntroDialogStatus() async {
    _set(showCommunityIntroDialog, 'shown');
  }

  static Future<bool> getIsCommunityIntroDialogShown() async {
    return await _get(showCommunityIntroDialog) == 'shown';
  }

  static Future<void> setUserNameUpdateDialogStatus() async {
    _set(showUpdateUsernameDialog, 'shown');
  }

  static Future<bool> getIsUserNameUpdateDialogShown() async {
    return await _get(showUpdateUsernameDialog) == 'shown';
  }

  static Future<void> setCommunityCodeRequested() async {
    _set(communityCodeRequested, 'requested');
  }

  static Future<bool> getIsCommunityCodeRequested() async {
    return await _get(communityCodeRequested) == 'requested';
  }

  static Future<void> setThemeMode(ThemeMode themeMode) async {
    return _set('theme_mode', themeMode.name);
  }

  static Future<ThemeMode> getThemeMode() async {
    String? themeMode = await _get('theme_mode');
    return themeMode != null
        ? ThemeMode.values.firstWhere((e) => e.name == themeMode)
        : ThemeMode.system;
  }

  static Future<void> _set(String token, String? value) async {
    return _storage.write(key: token, value: value);
  }

  static Future<void> setJson(String token, Map<String, dynamic> value) async {
    return await _set(token, json.encode(value));
  }

  static Future<String?> _get(String token) async {
    return _storage.read(key: token);
  }

  static Future<Map<String, dynamic>?> getJson(String token) async {
    String? value = await _get(token);
    return value != null ? json.decode(value) as Map<String, dynamic> : null;
  }

  static Future<void> remove(String token) async {
    return _storage.delete(key: token);
  }
}
