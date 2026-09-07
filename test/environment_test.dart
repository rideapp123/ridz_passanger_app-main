import 'package:flutter_test/flutter_test.dart';
import 'package:ridzs_passenger_app/core/configs/environment.dart';

void main() {
  late Map<String, dynamic> registry;
  setUp(() {
    registry = {
      'local': {
        'API_BASE_URL': 'http://10.0.2.2:8081',
        'SOCKET_BASE_URL': 'http://10.0.2.2:8082'
      },
      'demo': {
        'API_BASE_URL': 'https://demo.example.test',
        'SOCKET_BASE_URL': 'https://demo.example.test'
      },
      'prod': {
        'API_BASE_URL': 'https://prod.example.test',
        'SOCKET_BASE_URL': 'https://prod.example.test'
      },
    };
  });
  test('demo resolves reviewed REST and socket origins', () {
    final config = MobileEnvironment.resolve(registry,
        flavor: 'demo', environment: 'demo');
    expect(config.apiUrl, 'https://demo.example.test');
    expect(config.socketUrl, config.apiUrl);
  });
  test('native flavor cannot select another environment', () {
    expect(
        () => MobileEnvironment.resolve(registry,
            flavor: 'demo', environment: 'prod'),
        throwsStateError);
  });
  test('demo rejects production overrides', () {
    expect(
        () => MobileEnvironment.resolve(registry,
            flavor: 'demo',
            environment: 'demo',
            apiOverride: 'https://prod.example.test'),
        throwsStateError);
  });
  test('demo rejects socket override independently of REST', () {
    expect(
        () => MobileEnvironment.resolve(registry,
            flavor: 'demo',
            environment: 'demo',
            socketOverride: 'https://prod.example.test'),
        throwsStateError);
  });
  test('distributed builds never fall back to localhost', () {
    registry['demo'] = {'API_BASE_URL': '', 'SOCKET_BASE_URL': ''};
    expect(
        () => MobileEnvironment.resolve(registry,
            flavor: 'demo', environment: 'demo'),
        throwsStateError);
  });
  test('distributed builds reject cleartext even in registry', () {
    registry['demo'] = {
      'API_BASE_URL': 'http://demo.example.test',
      'SOCKET_BASE_URL': 'http://demo.example.test'
    };
    expect(
        () => MobileEnvironment.resolve(registry,
            flavor: 'demo', environment: 'demo'),
        throwsStateError);
  });
  test('demo and production may not share origins', () {
    registry['prod'] = registry['demo'];
    expect(
        () => MobileEnvironment.resolve(registry,
            flavor: 'demo', environment: 'demo'),
        throwsStateError);
  });
  test('local supports a physical device backend override', () {
    final config = MobileEnvironment.resolve(registry,
        flavor: 'local',
        environment: 'local',
        apiOverride: 'http://192.168.1.8:8081',
        socketOverride: 'http://192.168.1.8:8082');
    expect(config.apiUrl, 'http://192.168.1.8:8081');
  });
  test('credentials and paths in origins are rejected', () {
    for (final url in [
      'https://user:password@demo.example.test',
      'https://demo.example.test/passenger'
    ]) {
      expect(
          () => MobileEnvironment.resolve(registry,
              flavor: 'local', environment: 'local', apiOverride: url),
          throwsStateError);
    }
  });
  test('Stripe modes must match the environment', () {
    expect(
        () => MobileEnvironment.validateStripe('pk_live_fixture', 'demo'),
        throwsStateError);
    expect(
        () => MobileEnvironment.validateStripe('pk_test_fixture', 'prod'),
        throwsStateError);
    MobileEnvironment.validateStripe('pk_test_fixture', 'demo');
  });
}
