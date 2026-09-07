import 'dart:convert';

import 'package:flutter/services.dart';

class MobileEnvironment {
  const MobileEnvironment(this.name, this.apiUrl, this.socketUrl);
  final String name;
  final String apiUrl;
  final String socketUrl;

  static Future<MobileEnvironment> load() async {
    final registry = jsonDecode(
      await rootBundle.loadString('config/environments.json'),
    ) as Map<String, dynamic>;
    return resolve(
      registry,
      flavor: appFlavor ?? 'local',
      environment:
          const String.fromEnvironment('ENVIRONMENT', defaultValue: 'local'),
      apiOverride: const String.fromEnvironment('API_BASE_URL'),
      socketOverride: const String.fromEnvironment('SOCKET_BASE_URL'),
    );
  }

  static MobileEnvironment resolve(
    Map<String, dynamic> registry, {
    required String flavor,
    required String environment,
    String apiOverride = '',
    String socketOverride = '',
  }) {
    if (!['local', 'demo', 'prod'].contains(environment) ||
        flavor != environment) {
      throw StateError(
          'Native flavor and ENVIRONMENT must match: local, demo or prod.');
    }
    final entry = registry[environment] as Map<String, dynamic>?;
    if (entry == null) throw StateError('Environment is not registered.');
    final api = apiOverride.isEmpty
        ? entry['API_BASE_URL'] as String? ?? ''
        : apiOverride;
    final socket = socketOverride.isEmpty
        ? entry['SOCKET_BASE_URL'] as String? ?? ''
        : socketOverride;
    for (final value in [api, socket]) {
      final uri = Uri.tryParse(value);
      if (uri == null ||
          uri.host.isEmpty ||
          uri.userInfo.isNotEmpty ||
          uri.hasQuery ||
          uri.hasFragment ||
          !['', '/'].contains(uri.path) ||
          !['http', 'https'].contains(uri.scheme)) {
        throw StateError(
            'Backend URLs must be HTTP(S) origins without credentials.');
      }
      if (environment != 'local' &&
          (uri.scheme != 'https' ||
              uri.host == 'localhost' ||
              uri.host == '::1' ||
              RegExp(r'^\d+\.\d+\.\d+\.\d+$').hasMatch(uri.host))) {
        throw StateError(
            'Distributed builds require public HTTPS backend origins.');
      }
    }
    if (environment != 'local') {
      if (api != entry['API_BASE_URL'] || socket != entry['SOCKET_BASE_URL']) {
        throw StateError(
            'Backend overrides must match the reviewed environment registry.');
      }
      final other = registry[environment == 'demo' ? 'prod' : 'demo']
          as Map<String, dynamic>?;
      if (other != null &&
          [other['API_BASE_URL'], other['SOCKET_BASE_URL']]
              .whereType<String>()
              .map((value) => value.replaceFirst(RegExp(r'/$'), ''))
              .any((value) =>
                  value == api.replaceFirst(RegExp(r'/$'), '') ||
                  value == socket.replaceFirst(RegExp(r'/$'), ''))) {
        throw StateError(
            'Demo and production must have separate backend origins.');
      }
    }
    return MobileEnvironment(environment, api.replaceFirst(RegExp(r'/$'), ''),
        socket.replaceFirst(RegExp(r'/$'), ''));
  }

  static void validateStripe(String key, String environment) {
    if (key.isEmpty) return;
    final prefix = environment == 'prod' ? 'pk_live_' : 'pk_test_';
    if (!key.startsWith(prefix)) {
      throw StateError(
          'STRIPE_PUBLISHABLE_KEY does not match the environment.');
    }
  }
}
