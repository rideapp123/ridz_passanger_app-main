import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/core/services/toast_service.dart';
import 'package:ridzs_passenger_app/services/ride_service.dart';
import 'package:ridzs_passenger_app/view/my_rewards/ad_watch_screen.dart';

class MyRewards extends HookWidget {
  static const String routeNamed = 'MyRewards';

  const MyRewards({super.key});

  @override
  Widget build(BuildContext context) {
    final userStore = userStoreProvider();
    final rideService = useMemoized(() => RideService());
    final themeColor = Theme.of(context).colorScheme;
    final isLoading = useState(true);
    final offer = useState(<String, dynamic>{});
    final sessions = useState(<Map<String, dynamic>>[]);

    Future<void> loadRewards() async {
      try {
        isLoading.value = true;
        await userStore.getWallet();
        final results = await Future.wait([
          rideService.getAdRewardOffer(),
          rideService.getAdRewardHistory(),
        ]);
        offer.value = results[0] as Map<String, dynamic>;
        sessions.value = (results[1] as List<Map<String, dynamic>>);
      } catch (_) {
        ToastService.show('Rewards could not be loaded');
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> watchAd() async {
      final rewardAmount = await NavigationService().navigateTo(
        AdWatchScreen.routeNamed,
      );
      if (rewardAmount is num) {
        await loadRewards();
        ToastService.show(
          '\$${rewardAmount.toStringAsFixed(2)} added to wallet',
        );
      }
    }

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        loadRewards();
      });
      return null;
    }, []);

    return Scaffold(
      backgroundColor: themeColor.secondary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const TitleRowWidget(text: AppStrings.muRewards),
            Expanded(
              child: RefreshIndicator(
                color: themeColor.primary,
                onRefresh: loadRewards,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    SizeConfig.screenWidth * 0.04,
                    12,
                    SizeConfig.screenWidth * 0.04,
                    24,
                  ),
                  children: [
                    Observer(
                      builder: (_) {
                        return _RewardsBalanceCard(
                          balance: userStore.walletBalance.balance,
                          rewardAmount:
                              (offer.value['rewardAmount'] as num?) ?? 0.25,
                          isLoading: isLoading.value,
                          onWatchAd: watchAd,
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    _SectionHeader(
                      title: 'Ad rewards',
                      trailing: isLoading.value
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: themeColor.primary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 10),
                    if (!isLoading.value && sessions.value.isEmpty)
                      _EmptyRewardsCard(onWatchAd: watchAd)
                    else
                      ...sessions.value.map(_RewardHistoryTile.new),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardsBalanceCard extends StatelessWidget {
  const _RewardsBalanceCard({
    required this.balance,
    required this.rewardAmount,
    required this.isLoading,
    required this.onWatchAd,
  });

  final num balance;
  final num rewardAmount;
  final bool isLoading;
  final VoidCallback onWatchAd;

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: themeColor.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wallet balance',
                      style: AppTextStyles.style12W500.copyWith(
                        color: themeColor.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${balance.toStringAsFixed(2)}',
                      style: AppTextStyles.style28W600.copyWith(
                        color: themeColor.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: themeColor.secondary.withValues(alpha: .18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_circle_fill,
                  color: themeColor.secondary,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Earn \$${rewardAmount.toStringAsFixed(2)} ride credit per completed ad.',
            style: AppTextStyles.style12W500.copyWith(
              color: themeColor.secondary,
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Watch ad',
            hasIcon: true,
            iconData: Icons.play_arrow_rounded,
            iconColor: themeColor.primary,
            textColor: themeColor.primary,
            color: themeColor.secondary,
            shadowColor: themeColor.secondary,
            showShadow: false,
            isLoading: isLoading,
            onTap: onWatchAd,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.style18W500,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _EmptyRewardsCard extends StatelessWidget {
  const _EmptyRewardsCard({
    required this.onWatchAd,
  });

  final VoidCallback onWatchAd;

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: themeColor.surfaceContainerHighest.withValues(alpha: .4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: themeColor.onTertiaryContainer.withValues(alpha: .15),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.wallet_giftcard_rounded,
            size: 40,
            color: themeColor.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'No ad rewards yet',
            style: AppTextStyles.style16W600,
          ),
          const SizedBox(height: 8),
          Text(
            'Completed ad rewards will appear here.',
            textAlign: TextAlign.center,
            style: AppTextStyles.style12W500.copyWith(
              color: themeColor.onTertiaryContainer,
            ),
          ),
          const SizedBox(height: 14),
          CustomButton(
            text: 'Watch ad',
            height: 44,
            hasIcon: true,
            iconData: Icons.play_arrow_rounded,
            textColor: themeColor.secondary,
            iconColor: themeColor.secondary,
            onTap: onWatchAd,
          ),
        ],
      ),
    );
  }
}

class _RewardHistoryTile extends StatelessWidget {
  const _RewardHistoryTile(this.session);

  final Map<String, dynamic> session;

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;
    final status = (session['status'] ?? '').toString().toLowerCase();
    final amount = (session['rewardAmount'] as num?) ?? 0;
    final createdAt = DateTime.tryParse(
      (session['completedAt'] ?? session['createdAt'] ?? '').toString(),
    );
    final isCompleted = status == 'completed';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: themeColor.secondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: themeColor.onTertiaryContainer.withValues(alpha: .15),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: (isCompleted ? themeColor.primary : themeColor.error)
                  .withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check_rounded : Icons.close_rounded,
              color: isCompleted ? themeColor.primary : themeColor.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCompleted ? 'Ad reward earned' : _titleForStatus(status),
                  style: AppTextStyles.style15W600,
                ),
                const SizedBox(height: 4),
                Text(
                  createdAt == null
                      ? 'Reward session'
                      : DateFormat('MMM d, h:mm a').format(createdAt),
                  style: AppTextStyles.style12W500.copyWith(
                    color: themeColor.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Text(
            isCompleted ? '+\$${amount.toStringAsFixed(2)}' : '\$0.00',
            style: AppTextStyles.style15W600.copyWith(
              color: isCompleted ? themeColor.primary : themeColor.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  String _titleForStatus(String status) {
    return switch (status) {
      'started' => 'Ad reward started',
      'cancelled' => 'Ad reward cancelled',
      _ => 'Ad reward',
    };
  }
}
