import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// Exercise the installed plugin's real method codec and callback dispatch.
// ignore: implementation_imports
import 'package:google_mobile_ads/src/ad_instance_manager.dart';
import 'package:ridzs_passenger_app/services/reward_ad_player.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final channel = instanceManager.channel;
  late List<MethodCall> calls;
  late Completer<void> optionsReady;
  late Completer<int> loaded;
  Future<void> event(int id, String name,
      [Map<String, dynamic> extra = const {}]) async {
    final done = Completer<void>();
    messenger.handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(
            MethodCall('onAdEvent', {'adId': id, 'eventName': name, ...extra})),
        (_) => done.complete());
    await done.future;
  }

  setUp(() {
    calls = [];
    optionsReady = Completer<void>();
    loaded = Completer<int>();
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'loadRewardedAd') {
        loaded.complete(call.arguments['adId']);
      }
      if (call.method == 'setServerSideVerificationOptions') {
        await optionsReady.future;
      }
      return null;
    });
  });
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test(
      'SSV options and durable presentation check precede show; earned waits for dismissal',
      () async {
    final player = GoogleRewardAdPlayer();
    var earned = 0, checks = 0, finished = false;
    final showing = player.show('unit', 'owner1', 'session1', () async {
      checks++;
      return true;
    }, () => earned++).then((_) => finished = true);
    final id = await loaded.future;
    await event(id, 'onAdLoaded');
    expect(checks, 0);
    expect(calls.where((c) => c.method == 'showAdWithoutView'), isEmpty);
    final options = calls.last.arguments['serverSideVerificationOptions']
        as ServerSideVerificationOptions;
    expect(options.userId, 'owner1');
    expect(options.customData, 'session1');
    optionsReady.complete();
    await Future<void>.delayed(Duration.zero);
    expect(checks, 1);
    expect(calls.where((c) => c.method == 'showAdWithoutView'), hasLength(1));
    await event(id, 'onRewardedAdUserEarnedReward',
        {'rewardItem': RewardItem(1, 'credit')});
    expect(earned, 1);
    expect(finished, false);
    await event(id, 'onAdDismissedFullScreenContent');
    await showing;
    expect(finished, true);
    player.dispose();
  });

  test('close while SSV options are pending prevents show and earned delivery',
      () async {
    final player = GoogleRewardAdPlayer();
    var earned = 0, checks = 0;
    final showing = player.show('unit', 'owner1', 'session1', () async {
      checks++;
      return true;
    }, () => earned++);
    final id = await loaded.future;
    await event(id, 'onAdLoaded');
    player.dispose();
    optionsReady.complete();
    await showing;
    await Future<void>.delayed(Duration.zero);
    expect(checks, 0);
    expect(earned, 0);
    expect(calls.where((c) => c.method == 'showAdWithoutView'), isEmpty);
  });

  test('failed durable presentation check prevents show', () async {
    final player = GoogleRewardAdPlayer();
    final showing = player.show('unit', 'owner1', 'session1', () async => false,
        () => fail('Unexpected reward'));
    final id = await loaded.future;
    optionsReady.complete();
    await event(id, 'onAdLoaded');
    await showing;
    expect(calls.where((c) => c.method == 'showAdWithoutView'), isEmpty);
    player.dispose();
  });
}
