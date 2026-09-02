import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/view/profile/widget/card_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChoosePaymentBottomSheet extends HookWidget {
  final String selectedCardId;
  final double totalAmount;
  const ChoosePaymentBottomSheet({
    super.key,
    required this.selectedCardId,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final selectedPayment = useState<String>(selectedCardId);
    final userStore = useMemoized(() => userStoreProvider());
    final isWalletSelected = useState(false);

    useEffect(() {
      userStore.getCard();
      userStore.getWallet();
      return null;
    }, []);

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.shadow,
              ),
            ),

            //
            SizedBox(height: SizeConfig.screenHeight * 0.015),

            Observer(builder: (context) {
              final isWalletLoading = userStore.isWalletLoading;
              return InkWell(
                onTap: () {
                  if (!isWalletLoading &&
                      userStore.walletBalance.balance >= totalAmount) {
                    isWalletSelected.value = true;

                    if (isWalletSelected.value) {
                      selectedPayment.value = '';
                    }
                  }
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isWalletSelected.value
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onPrimaryFixedVariant,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: .2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      //
                      SizedBox(
                        height: 34,
                        width: 60,
                        child: Center(
                          child: CustomImageView(
                            svgPath: Assets.walletIc,
                            height: 28,
                            width: 28,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wallet',
                              style: AppTextStyles.style15white.copyWith(
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            if (!isWalletLoading &&
                                userStore.walletBalance.balance < totalAmount)
                              Text(
                                'Insufficient Balance',
                                style: AppTextStyles.style12W500.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                          ],
                        ),
                      ),

                      Skeletonizer(
                        enabled: isWalletLoading,
                        child: Text(
                          isWalletLoading
                              ? '9090'
                              : '\$ ${userStore.walletBalance.balance.toString()}',
                          style: AppTextStyles.style12W500.copyWith(
                            color: Theme.of(context).colorScheme.onTertiary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 10),

            Observer(
              builder: (context) {
                final cardList = userStore.cardList?.cards ?? [];

                if (!userStore.isCardLoading && cardList.isEmpty) {
                  return SizedBox(
                    height: SizeConfig.screenHeight * 0.1,
                    child: Center(
                      child: Text(
                        AppStrings.noCards,
                        style: AppTextStyles.style23W600.copyWith(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  );
                }

                return Flexible(
                  child: Skeletonizer(
                    enabled: userStore.isCardLoading,
                    containersColor:
                        Theme.of(context).colorScheme.surfaceContainerHigh,
                    effect: ShimmerEffect(
                      baseColor: Theme.of(context).colorScheme.tertiaryFixed,
                    ),
                    child: ListView.separated(
                      itemCount: cardList.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      separatorBuilder: (context, _) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final cardDetail = cardList[index];
                        return GestureDetector(
                          onTap: () {
                            selectedPayment.value = cardDetail.id ?? '';
                            isWalletSelected.value = false;
                          },
                          child: CardWidget(
                            cardDetail: cardDetail,
                            isSelectableTile: true,
                            isSelected:
                                selectedPayment.value == (cardDetail.id ?? ''),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),

            SizedBox(
              height: SizeConfig.screenHeight * 0.02,
            ),

            CustomButton(
              text: 'Confirm',
              onTap: () {
                if (isWalletSelected.value) {
                  Navigator.of(context).pop([isWalletSelected.value, null]);
                  return;
                }

                final cardList = userStore.cardList?.cards ?? [];
                final cardDetails = cardList
                    .where(
                      (e) => e.id == selectedPayment.value,
                    )
                    .toList();

                if (cardDetails.isEmpty) return;
                final cardDetail = cardDetails.first;
                Navigator.of(context).pop([isWalletSelected.value, cardDetail]);
              },
            ),
          ],
        ),
      ),
    );
  }
}
