import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/view/my_wallet/add_topup_wallet_screen.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../models/payment/transaction_response_model.dart';
import '../../models/payment/wallet_response_model.dart';

class MyWallet extends HookWidget {
  static const String routeNamed = 'MyWallet';

  const MyWallet({super.key});

  @override
  Widget build(BuildContext context) {
    final userStore = userStoreProvider();
    final scrollController = useScrollController();
    final themeColor = Theme.of(context).colorScheme;
    double height = SizeConfig.screenHeight;
    double width = SizeConfig.screenWidth;

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        userStore.getWallet();
        userStore.getTransactionList();

        if (userStore.loadMoreData) {
          scrollController.addListener(() {
            if (scrollController.position.pixels ==
                scrollController.position.maxScrollExtent) {
              userStore.transactionPageNo++;

              userStore.getTransactionList();
            }
          });
        }
      });
      return null;
    }, []);

    return Scaffold(
      backgroundColor: themeColor.secondary,
      body: SafeArea(
        bottom: false,
        child: Observer(
          builder: (context) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //
                _buildAppBar(context: context, themeColor: themeColor),

                Skeletonizer(
                  enabled: userStore.isWalletLoading,
                  effect: ShimmerEffect(
                    baseColor: Theme.of(context).colorScheme.tertiaryFixed,
                  ),
                  containersColor:
                      Theme.of(context).colorScheme.surfaceContainerHigh,
                  child: _buildBalanceBanner(
                    context: context,
                    themeColor: themeColor,
                    balance: userStore.walletBalance,
                  ),
                ),

                SizedBox(height: height * 0.01),

                //
                _buildTransactionsContainer(
                  context: context,
                  themeColor: themeColor,
                  height: height,
                  width: width,
                  scrollController: scrollController,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar({
    required BuildContext context,
    required ColorScheme themeColor,
  }) {
    return TitleRowWidget(
      text: AppStrings.myWallet,
      imageColor: themeColor.secondary,
      textStyle: AppTextStyles.style23W600.copyWith(
        color: themeColor.secondary,
      ),
    );
  }

  Widget _buildBalanceBanner({
    required BuildContext context,
    required ColorScheme themeColor,
    required Balance balance,
  }) {
    return Container(
      height: SizeConfig.screenHeight * 0.12,
      width: SizeConfig.screenWidth,
      margin: EdgeInsets.symmetric(
        horizontal: SizeConfig.screenWidth * 0.04,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.screenWidth * 0.04,
      ),
      decoration: BoxDecoration(
        color: themeColor.primary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: themeColor.primary,
        ),
        gradient: LinearGradient(
          colors: [
            themeColor.primary.withValues(alpha: .8),
            themeColor.primary.withValues(alpha: .5),
            themeColor.primary.withValues(alpha: .2),
            // themeColor.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          //
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //
                Text(
                  'Your Balance',
                  style: TextStyle(
                    color: themeColor.tertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                Text(
                  '\$${balance.balance}',
                  style: TextStyle(
                    color: themeColor.tertiary,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: SizeConfig.screenHeight * 0.05,
            width: SizeConfig.screenWidth * 0.003,
            decoration: BoxDecoration(color: themeColor.primary),
          ),

          SizedBox(
            width: SizeConfig.screenWidth * 0.04,
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.screenWidth * 0.02,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //
                GestureDetector(
                  onTap: () {
                    // final userStore = userStoreProvider();
                    // userStore.makeDirectPayment(100);
                    // userStore.addWalletAmount(100);
                    NavigationService().navigateTo(
                      AddTopUpWalletScreen.routeName,
                    );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: SizeConfig.screenHeight * 0.04,
                    width: SizeConfig.screenHeight * 0.04,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: themeColor.primaryContainer,
                    ),
                    child: Container(
                      height: SizeConfig.screenHeight * 0.025,
                      width: SizeConfig.screenHeight * 0.025,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: themeColor.secondary,
                      ),
                      child: Icon(
                        Icons.add,
                        color: themeColor.primaryContainer,
                        size: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Top up',
                  style: AppTextStyles.subtitle2.copyWith(
                    color: themeColor.tertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Padding _buildBalanceRow({
  //   required BuildContext context,
  //   required ColorScheme themeColor,
  // }) {
  //   return Padding(
  //     padding: AppPadding.scaffold,
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               AppStrings.currentBalance,
  //               style: AppTextStyles.style12W500
  //                   .copyWith(color: themeColor.onSecondary),
  //             ),
  //             RichText(
  //               text: TextSpan(
  //                 children: [
  //                   TextSpan(
  //                     text: '\$',
  //                     style: AppTextStyles.subtitle.copyWith(
  //                       fontSize: 10,
  //                       color: themeColor.secondary,
  //                       fontWeight: FontWeight.w700,
  //                     ),
  //                   ),
  //                   TextSpan(
  //                     text: '349',
  //                     style: AppTextStyles.subtitle.copyWith(
  //                       fontSize: 16,
  //                       color: themeColor.secondary,
  //                       fontWeight: FontWeight.w700,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),

  //         //
  //         GestureDetector(
  //           onTap: () {},
  //           child: Container(
  //             alignment: Alignment.center,
  //             height: SizeConfig.screenHeight * 0.05,
  //             padding: EdgeInsets.symmetric(
  //               horizontal: SizeConfig.screenWidth * 0.05,
  //             ),
  //             decoration: BoxDecoration(
  //               color: themeColor.onPrimary,
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //             child: Text(
  //               'Top up',
  //               style: AppTextStyles.subtitle2.copyWith(
  //                 color: themeColor.secondary,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildTransactionsContainer({
    required BuildContext context,
    required ColorScheme themeColor,
    required double height,
    required double width,
    required ScrollController scrollController,
  }) {
    final userStore = userStoreProvider();
    return Expanded(
      child: Padding(
        padding: AppPadding.scaffoldWithTop,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //
            Text(
              'Recent Transactions',
              style: AppTextStyles.subtitle2.copyWith(
                color: themeColor.tertiary,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 14),

            Observer(builder: (context) {
              if (userStore.transactionList.isEmpty &&
                  !userStore.isTransactionLoading) {
                return Expanded(
                  child: Center(
                    child: Text(
                      'No transactions found',
                      style: AppTextStyles.error.copyWith(
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }
              return Expanded(
                child: Skeletonizer(
                  enabled: userStore.isTransactionLoading,
                  effect: ShimmerEffect(
                    baseColor: Theme.of(context).colorScheme.tertiaryFixed,
                  ),
                  containersColor:
                      Theme.of(context).colorScheme.surfaceContainerHigh,
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: userStore.transactionList.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(
                      bottom: SizeConfig.screenHeight * 0.04,
                    ),
                    itemBuilder: (_, index) {
                      final transactionData = userStore.transactionList[index];
                      return _detailsContainer(
                        context: context,
                        themeColor: themeColor,
                        transaction: transactionData,
                      );
                    },
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _detailsContainer({
    required BuildContext context,
    required ColorScheme themeColor,
    required Transaction transaction,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final createdDate = DateTime.parse(transaction.createdAt.toString());
    final formattedDate = DateFormat('dd/MM/yyyy').format(createdDate);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: themeColor.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: themeColor.onPrimaryFixedVariant,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.description,
                style: TextStyle(
                  color: themeColor.tertiary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${transaction.type == 'credit' ? '+' : '-'}\$${transaction.amount}',
                style: TextStyle(
                  color: transaction.type == 'credit'
                      ? Colors.green
                      : themeColor.error,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          //
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formattedDate,
                style: AppTextStyles.style12W500.copyWith(
                  color: isDarkMode
                      ? const Color(0xffBABABA)
                      : const Color(0xff9A9A9A),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                transaction.metadata.paymentId,
                style: AppTextStyles.style12W500.copyWith(
                  color: isDarkMode
                      ? const Color(0xffBABABA)
                      : const Color(0xff9A9A9A),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
