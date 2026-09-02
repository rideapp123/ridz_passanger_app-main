import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/view/rate_driver/widget/star_widget.dart';
import 'package:ridzs_passenger_app/view/widgets/driver_listlite.dart';

class RateDriver extends HookWidget {
  static const String routeNamed = 'RateDriver';

  const RateDriver({super.key});

  @override
  Widget build(BuildContext context) {
    List texts = [
      'on time',
      'Good Behaviour',
      'Nice maintenance',
      'Write your feedback',
    ];
    final themeColor = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: themeColor.primary,
      body: Stack(
        children: [
          Container(
            height: SizeConfig.screenHeight,
            width: SizeConfig.screenWidth,
            decoration: BoxDecoration(
              color: themeColor.primary,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: AppPadding.scaffoldWithTop,
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      const Spacer(),
                      Text(
                        AppStrings.rateDriver,
                        style: AppTextStyles.style23W600
                            .copyWith(color: themeColor.secondary),
                      ),
                      const Spacer(),
                      Text(
                        AppStrings.skip,
                        style: AppTextStyles.style12W600
                            .copyWith(color: themeColor.onSecondaryContainer),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: SizeConfig.screenHeight * 0.08,
                ),
                Container(
                  height: SizeConfig.screenHeight * 0.80,
                  width: SizeConfig.screenWidth,
                  decoration: BoxDecoration(
                    color: themeColor.secondary,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: AppPadding.scaffoldWithTop,
                    child: Column(
                      children: [
                        const DriverListTie(
                          profileImage: 'assets/png/profile_image.png',
                          userName: 'Daniel Austin',
                          carModel: 'Mercedes-Benz E-class',
                          rating: 4.4,
                          starRating: 2.5,
                          licensePlate: 'HSW 4736 XK',
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: Text(
                            AppStrings.howsYourTrip,
                            style: AppTextStyles.style19W600
                                .copyWith(color: themeColor.tertiary),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const StarRating(),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: texts.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Container(
                                  height: SizeConfig.screenHeight,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryFixedVariant,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Container(
                                    height: SizeConfig.screenHeight * 0.80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryFixedVariant,
                                          spreadRadius: -3,
                                          blurRadius: 3,
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                          child: Text(
                                        texts[index],
                                        style: AppTextStyles.style12W500
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onTertiaryFixed),
                                      )),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            AppStrings.tripDetails,
                            style: AppTextStyles.style23W600.copyWith(
                                color: Theme.of(context).colorScheme.tertiary),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                CustomImageView(
                                  imagePath: Assets.imgLocationGrey,
                                  height: 24,
                                  width: 24,
                                ),
                                buildDashedLine(context),
                                CustomImageView(
                                  imagePath: Assets.imgLocationBlue,
                                  height: 24,
                                  width: 24,
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildLocationDetails(
                                      title: "Current location",
                                      address:
                                          '2972 Westheimer Rd. Santa Ana, Illinois 85486 ',
                                      context: context),
                                  const SizedBox(height: 20),
                                  buildLocationDetails(
                                    title: "Office",
                                    context: context,
                                    address:
                                        '1901 Thornridge Cir. Shiloh, Hawaii 81063',
                                    distance: '30Km',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: AppPadding.scaffoldWithTop,
                  child: CustomButton(
                    onTap: () {},
                    width: 120,
                    text: AppStrings.submit,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDashedLine(BuildContext context) {
    return Column(
      children: List.generate(18, (index) {
        return Container(
          width: 1,
          height: index % 2 == 0 ? 4 : 2,
          color: index % 2 == 0
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent, // Dashed effect
        );
      }),
    );
  }

  // Widget to build location details
  Widget buildLocationDetails(
      {required String title,
      required String address,
      String? distance,
      required BuildContext context}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.subtitle),
              const SizedBox(height: 4),
              Text(address,
                  style: AppTextStyles.link.copyWith(
                      color: Theme.of(context).colorScheme.onTertiaryFixed)),
            ],
          ),
        ),
        if (distance != null) Text(distance, style: AppTextStyles.subtitle),
      ],
    );
  }
}
