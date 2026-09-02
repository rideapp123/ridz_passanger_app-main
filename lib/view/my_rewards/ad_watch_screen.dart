import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/core/services/toast_service.dart';
import 'package:ridzs_passenger_app/services/ride_service.dart';

class AdWatchScreen extends StatefulWidget {
  static const String routeNamed = 'AdWatchScreen';

  const AdWatchScreen({
    super.key,
    this.rideId,
  });

  final String? rideId;

  @override
  State<AdWatchScreen> createState() => _AdWatchScreenState();
}

class _AdWatchScreenState extends State<AdWatchScreen> {
  final RideService _rideService = RideService();

  String? _sessionId;
  String? _passengerId;
  RewardedAd? _rewardedAd;
  num _rewardAmount = 0.25;
  bool _isLoading = true;
  bool _isCompleting = false;
  bool _hasEarnedReward = false;
  bool _hasCompleted = false;
  String? _error;
  String _statusMessage = 'Loading ad...';

  @override
  void initState() {
    super.initState();
    _beginAdReward();
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  Future<void> _beginAdReward() async {
    try {
      final offer = await _rideService.getAdRewardOffer(rideId: widget.rideId);
      final amount = offer['rewardAmount'];
      final session = await _rideService.startAdReward(rideId: widget.rideId);
      final sessionId = (session['id'] ?? session['_id'] ?? '').toString();
      if (sessionId.isEmpty) {
        throw Exception('Ad reward session was not created');
      }
      final passengerId =
          (session['passengerId'] ?? userStoreProvider().loggedInUser?.id ?? '')
              .toString();
      if (passengerId.isEmpty) {
        throw Exception('Ad reward user was not resolved');
      }
      if (!mounted) return;
      setState(() {
        _rewardAmount = amount is num ? amount : _rewardAmount;
        _sessionId = sessionId;
        _passengerId = passengerId;
        _statusMessage = 'Preparing ad...';
      });
      _loadRewardedAd(sessionId: sessionId, passengerId: passengerId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _loadRewardedAd({
    required String sessionId,
    required String passengerId,
  }) {
    if (!Platform.isAndroid && !Platform.isIOS) {
      setState(() {
        _error = 'Rewarded ads are available on Android and iOS devices.';
        _isLoading = false;
      });
      return;
    }

    RewardedAd.load(
      adUnitId: AppConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.setServerSideOptions(
            ServerSideVerificationOptions(
              userId: passengerId,
              customData: sessionId,
            ),
          );
          ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
            onAdShowedFullScreenContent: (_) {
              if (!mounted) return;
              setState(() {
                _statusMessage = 'Ad is playing...';
                _isLoading = false;
              });
            },
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              if (!_hasEarnedReward && !_hasCompleted) {
                _cancelReward();
              }
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedAd = null;
              if (!mounted) return;
              setState(() {
                _error = 'Ad could not be shown. Please try again.';
                _isLoading = false;
              });
            },
          );
          _rewardedAd = ad;
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _statusMessage = 'Opening ad...';
          });
          ad.show(
            onUserEarnedReward: (ad, rewardItem) {
              _hasEarnedReward = true;
              _completeReward(
                rewardItem: rewardItem,
                adUnitId: AppConfig.rewardedAdUnitId,
              );
            },
          );
        },
        onAdFailedToLoad: (error) {
          if (!mounted) return;
          setState(() {
            _error = 'Ad could not be loaded. Please try again.';
            _isLoading = false;
          });
        },
      ),
    );
  }

  Future<void> _completeReward({
    RewardItem? rewardItem,
    String? adUnitId,
  }) async {
    if (_isCompleting || _hasCompleted || _sessionId == null) return;
    setState(() {
      _isCompleting = true;
      _statusMessage = 'Adding reward...';
    });
    try {
      final result = await _rideService.completeAdReward(
        _sessionId!,
        metadata: {
          if (adUnitId != null) 'adUnitId': adUnitId,
          if (rewardItem != null) 'rewardAmount': rewardItem.amount,
          if (rewardItem != null) 'rewardType': rewardItem.type,
          if (_passengerId != null) 'userId': _passengerId,
        },
      );
      final transaction = result['transaction'];
      num amount = _rewardAmount;
      if (transaction is Map && transaction['amount'] is num) {
        amount = transaction['amount'] as num;
      }
      await userStoreProvider().getWallet();
      if (!mounted) return;
      setState(() {
        _hasCompleted = true;
        _isCompleting = false;
      });
      Navigator.of(context).pop(amount);
    } catch (e) {
      final verifiedAmount = await _waitForServerVerifiedReward();
      if (verifiedAmount != null) {
        await userStoreProvider().getWallet();
        if (!mounted) return;
        setState(() {
          _hasCompleted = true;
          _isCompleting = false;
        });
        Navigator.of(context).pop(verifiedAmount);
        return;
      }
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isCompleting = false;
      });
    }
  }

  Future<num?> _waitForServerVerifiedReward() async {
    final sessionId = _sessionId;
    if (sessionId == null || sessionId.isEmpty) return null;

    for (var attempt = 0; attempt < 8; attempt++) {
      await Future.delayed(const Duration(seconds: 2));
      try {
        final session = await _rideService.getAdRewardSession(sessionId);
        if ((session['status'] ?? '').toString().toLowerCase() == 'completed') {
          final amount = session['rewardAmount'];
          return amount is num ? amount : _rewardAmount;
        }
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> _cancelReward() async {
    final sessionId = _sessionId;
    if (sessionId != null && sessionId.isNotEmpty && !_hasCompleted) {
      try {
        await _rideService.cancelAdReward(sessionId);
      } catch (_) {
        ToastService.show('Reward could not be cancelled');
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _cancelReward();
        }
      },
      child: Scaffold(
        backgroundColor: themeColor.secondary,
        body: SafeArea(
          child: Padding(
            padding: AppPadding.scaffold,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: _cancelReward,
                      child: Container(
                        height: 32,
                        width: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: themeColor.onTertiaryFixed,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: themeColor.surface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Advertisement',
                        style: AppTextStyles.style18W500,
                      ),
                    ),
                    Text(
                      '+\$${_rewardAmount.toStringAsFixed(2)}',
                      style: AppTextStyles.style15W600.copyWith(
                        color: themeColor.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Center(
                    child: _error != null
                        ? _buildError(themeColor)
                        : _buildAdSurface(themeColor),
                  ),
                ),
                const SizedBox(height: 20),
                if (_error == null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          color: themeColor.primary,
                          backgroundColor:
                              themeColor.tertiary.withValues(alpha: 0.12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.style12W500.copyWith(
                          color: themeColor.onTertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                CustomButton(
                  text: _error == null ? 'Cancel' : 'Close',
                  onTap: _cancelReward,
                  color: themeColor.secondary,
                  textColor: themeColor.tertiary,
                  border: Border.all(
                    color: themeColor.onTertiaryContainer.withValues(alpha: .2),
                  ),
                  showShadow: false,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdSurface(ColorScheme themeColor) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: themeColor.surfaceContainerHighest.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: themeColor.onTertiaryContainer.withValues(alpha: .15),
        ),
      ),
      child: AspectRatio(
        aspectRatio: 9 / 12,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isCompleting
                  ? Icons.account_balance_wallet_rounded
                  : Icons.play_circle_fill,
              size: 72,
              color: themeColor.primary,
            ),
            const SizedBox(height: 22),
            Text(
              _isLoading ? 'Loading ad...' : 'Rewarded ad',
              textAlign: TextAlign.center,
              style: AppTextStyles.style23W600.copyWith(
                color: themeColor.tertiary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Earn \$${_rewardAmount.toStringAsFixed(2)} for your wallet.',
              textAlign: TextAlign.center,
              style: AppTextStyles.style15w400.copyWith(
                color: themeColor.onTertiaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(ColorScheme themeColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline,
          size: 54,
          color: themeColor.error,
        ),
        const SizedBox(height: 14),
        Text(
          'Reward unavailable',
          style: AppTextStyles.style19W600,
        ),
        const SizedBox(height: 8),
        Text(
          'Please try again later.',
          textAlign: TextAlign.center,
          style: AppTextStyles.style15w400.copyWith(
            color: themeColor.onTertiaryContainer,
          ),
        ),
      ],
    );
  }
}
