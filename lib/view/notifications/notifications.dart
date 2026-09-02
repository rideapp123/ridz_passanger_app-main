import 'package:ridzs_passenger_app/core/exports/common_exports.dart';

class Notifications extends HookWidget {
  static const String routeNamed = 'Notifications';

  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: themeColor.secondary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            //
            const TitleRowWidget(
              text: AppStrings.notification,
            ),

            //
            Expanded(
              child: ListView.builder(
                itemCount: 8,
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.screenWidth * 0.04,
                ),
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      index == 0 || index == 3 || index == 6
                          ? Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  index == 0
                                      ? AppStrings.today
                                      : index == 6
                                          ? 'May, 27 2023'
                                          : 'Yesterday',
                                  style: AppTextStyles.body
                                      .copyWith(color: themeColor.tertiary),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),

                      const SizedBox(height: 10),

                      //
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color:
                                    themeColor.surfaceContainer.withValues(alpha: .1),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomImageView(
                                    width: 24,
                                    height: 24,
                                    imagePath:
                                        index == 0 || index == 3 || index == 7
                                            ? Assets.icDiscount
                                            : Assets.icPaymentSuccess,
                                    color: themeColor.surfaceContainer,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    index == 0 || index == 3 || index == 7
                                        ? '30% Special Discount!'
                                        : AppStrings.paymentSuccessfully,
                                    style: AppTextStyles.subtitle
                                        .copyWith(color: themeColor.tertiary),
                                  ),
                                  Text(
                                    'Lorem ipsum dolor sit amet consectetur. Ultrici es tincidunt eleifend vitae',
                                    style: AppTextStyles.style12W500.copyWith(
                                        color: themeColor.tertiary,
                                        fontWeight: FontWeight.w400),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
