import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract class RewardAdPlayer {
  Future<void> show(String unit, String owner, String session,
      Future<bool> Function() beforeShow, void Function() earned);
  void dispose();
}

class GoogleRewardAdPlayer implements RewardAdPlayer {
  RewardedAd? _ad;
  Completer<void>? _done;
  bool _disposed = false;

  @override
  Future<void> show(String unit, String owner, String session,
      Future<bool> Function() beforeShow, void Function() earned) {
    if (_disposed ||
        kIsWeb ||
        !{TargetPlatform.android, TargetPlatform.iOS}
            .contains(defaultTargetPlatform)) {
      return Future.error(StateError('Rewarded ads require a mobile device'));
    }
    final done = _done = Completer<void>();
    void fail(Object error) {
      if (!done.isCompleted) done.completeError(error);
    }

    unawaited(RewardedAd.load(
        adUnitId: unit,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (ad) async {
              if (_disposed) {
                ad.dispose();
                return;
              }
              _ad = ad;
              try {
                await ad.setServerSideOptions(ServerSideVerificationOptions(
                    userId: owner, customData: session));
                if (_disposed || !await beforeShow() || _disposed) {
                  ad.dispose();
                  if (!done.isCompleted) done.complete();
                  return;
                }
                ad.fullScreenContentCallback = FullScreenContentCallback(
                  onAdDismissedFullScreenContent: (ad) {
                    ad.dispose();
                    _ad = null;
                    if (!done.isCompleted) done.complete();
                  },
                  onAdFailedToShowFullScreenContent: (ad, error) {
                    ad.dispose();
                    _ad = null;
                    fail(StateError('Ad could not be shown'));
                  },
                );
                await ad.show(onUserEarnedReward: (ad, reward) {
                  if (!_disposed) earned();
                });
              } catch (error) {
                ad.dispose();
                _ad = null;
                fail(error);
              }
            },
            onAdFailedToLoad: (_) =>
                fail(StateError('Ad could not be loaded')))).catchError(fail));
    return done.future;
  }

  @override
  void dispose() {
    _disposed = true;
    _ad?.dispose();
    _ad = null;
    if (_done != null && !_done!.isCompleted) _done!.complete();
  }
}
