import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/view/cancel_trip/widgets/check_list.dart';

class CancelTrip extends HookWidget {
  static const String routeNamed = 'CancelTrip';

  CancelTrip({super.key});

  final TextEditingController otherController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Container(
        height: SizeConfig.screenHeight,
        width: SizeConfig.screenWidth,
        color: Theme.of(context).colorScheme.primary,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Padding(
              padding: AppPadding.scaffoldWithTop,
              child: TitleRowWidget(text: AppStrings.cancelTrip),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.03),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 120,
                  width: 120,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: AssetImage('assets/png/profile_image.png'),
                          fit: BoxFit.cover)),
                ),
                Positioned(
                    right: -6,
                    top: 10,
                    child: Container(
                      height: 28,
                      width: 28,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: CustomImageView(
                        imagePath: Assets.icCancel,
                      ),
                    ))
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              height: SizeConfig.screenHeight * 0.68,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(20), right: Radius.circular(20)),
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: AppPadding.scaffoldWithTop,
                      child: Text(
                        AppStrings.whyDoYouWantToCancel,
                        style: AppTextStyles.subtitle
                            .copyWith(fontSize: 20)
                            .copyWith(
                                color: Theme.of(context).colorScheme.tertiary),
                      ),
                    ),
                    const CustomCheckBoxTile(
                      label: AppStrings.waitingForLongTime,
                    ),
                    const CustomCheckBoxTile(
                      label: AppStrings.unableTOContactDriver,
                    ),
                    const CustomCheckBoxTile(
                      label: AppStrings.driverDeniedToGOToTheDestination,
                    ),
                    const CustomCheckBoxTile(
                      label: AppStrings.driverDeniedToComeToPickup,
                    ),
                    const CustomCheckBoxTile(
                      label: AppStrings.wrongAddressShown,
                    ),
                    const CustomCheckBoxTile(
                      label: AppStrings.thePriceIsNotReasonable,
                    ),
                    const CustomCheckBoxTile(
                      label: AppStrings.other,
                    ),
                    Padding(
                      padding: AppPadding.scaffoldWithTop,
                      child: customTextFormField(
                        controller: otherController,
                        inputTextColor:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                        label: AppStrings.other,
                        hintText: AppStrings.pleaseEnterTheReason,
                      ),
                    ),
                    SizedBox(height: SizeConfig.screenHeight * 0.074),
                    Padding(
                      padding: AppPadding.container16,
                      child: CustomButton(
                        onTap: () {},
                        borderRadius: 16,
                        text: AppStrings.submit,
                        color: Theme.of(context).colorScheme.primary,
                        width: double.infinity,
                      ),
                    ),
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
