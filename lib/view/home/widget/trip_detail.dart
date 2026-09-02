import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ridzs_passenger_app/core/constants/assets.dart';
import 'package:ridzs_passenger_app/core/services/bottomsheet_service.dart';
import 'package:ridzs_passenger_app/core/services/navigation_service.dart';
import 'package:ridzs_passenger_app/core/theme/app_layout.dart';
import 'package:ridzs_passenger_app/view/cancel_trip/cancel_trip.dart';
import 'package:ridzs_passenger_app/view/home/widget/trip_for_driver.dart';
import 'package:ridzs_passenger_app/widgets/containers/custom_image_view.dart';
import '../../../core/constants/strings_constant.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../stores/map/map_store.dart';
import '../../../widgets/containers/background_with_shadow_container.dart';
import '../../widgets/driver_listlite.dart';

class TripDetails extends HookWidget {
  const TripDetails({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SingleChildScrollView(
        child: Padding(
          padding: AppPadding.scaffold,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 3,
                width: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.tertiary),
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back_outlined,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    AppStrings.tripDetails,
                    style: AppTextStyles.style23W600.copyWith(
                        color: Theme.of(context).colorScheme.tertiary),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      CustomImageView(
                        imagePath: Assets.imgLocationGrey,
                        height: 22,
                        width: 22,
                      ),
                      buildDashedLine(),
                      CustomImageView(
                        imagePath: Assets.imgLocationBlue,
                        height: 22,
                        width: 22,
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildLocationDetails(
                            title: mapStoreProvider()
                                    .selectedSuggestionsFrom
                                    ?.properties
                                    ?.fullAddress ??
                                '',
                            address: mapStoreProvider()
                                    .selectedSuggestionsTo
                                    ?.properties
                                    ?.fullAddress ??
                                '',
                            context: context),
                        const SizedBox(height: 10),
                        buildLocationDetails(
                          title: mapStoreProvider()
                                  .selectedSuggestionsTo
                                  ?.properties
                                  ?.name ??
                              '',
                          context: context,
                          address: '1901 Thornridge Cir. Shiloh, Hawaii 81063',
                          distance:
                              '${(mapStoreProvider().getKilometer(mapStoreProvider().directions?.routes?[0].distance ?? 0.0)).toInt()} km',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Divider(
                color: Theme.of(context)
                    .colorScheme
                    .onTertiaryFixed
                    .withValues(alpha: 0.3),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.paymentInfo,
                    style: AppTextStyles.subtitle.copyWith(
                        color: Theme.of(context).colorScheme.tertiary),
                  ),
                  Text(
                    '\$170.71',
                    style: AppTextStyles.subtitle.copyWith(
                        color: Theme.of(context).colorScheme.tertiary),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.promoCode,
                    style: AppTextStyles.style12W500.copyWith(
                        color: Theme.of(context).colorScheme.tertiary),
                  ),
                  Text(
                    'Avail10D',
                    style: AppTextStyles.style12W500.copyWith(
                        color: Theme.of(context).colorScheme.tertiary),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Divider(
                color: Theme.of(context)
                    .colorScheme
                    .onTertiaryFixed
                    .withValues(alpha: 0.3),
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomImageView(
                        imagePath: Assets.imgVisaWhite,
                        width: 45,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        '**** **** **** 8970',
                        style: AppTextStyles.style15W600.copyWith(
                            color:
                                Theme.of(context).colorScheme.onTertiaryFixed),
                      ),
                    ],
                  ),
                  CustomImageView(
                    imagePath: Assets.icRightArrow,
                    width: 24,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.driverArriving,
                    style: AppTextStyles.subtitle.copyWith(
                        color: Theme.of(context).colorScheme.tertiary),
                  ),
                  Text(
                    '2 mins',
                    style: AppTextStyles.style15W600.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onTertiaryFixedVariant),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Divider(
                color: Theme.of(context)
                    .colorScheme
                    .onTertiaryFixed
                    .withValues(alpha: 0.3),
              ),
              const SizedBox(
                height: 20,
              ),
              const DriverListTie(
                profileImage: 'assets/png/profile_image.png',
                userName: 'Daniel Austin',
                carModel: 'Mercedes-Benz E-class',
                rating: 4.4,
                starRating: 2.5,
                licensePlate: 'HSW 4736 XK',
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BackgroundWithShadowContainer(
                    onTap: () {
                      NavigationService().navigateTo(CancelTrip.routeNamed);
                    },
                    height: 60,
                    border: 100,
                    width: 60,
                    backgroundColor: const Color(0xffa30f15),
                    shadowColor: const Color(0xffc1272d),
                    childWidget: Padding(
                      padding: const EdgeInsets.all(17),
                      child: CustomImageView(
                        imagePath: Assets.icClose,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      middleBottomSheetService(const TripForDriver(),
                          height: 0.7);
                    },
                    child: BackgroundWithShadowContainer(
                      height: 60,
                      width: 60,
                      border: 100,
                      backgroundColor:
                          Theme.of(context).colorScheme.onPrimaryFixed,
                      shadowColor: Theme.of(context).colorScheme.primary,
                      childWidget: Padding(
                        padding: const EdgeInsets.all(17),
                        child: CustomImageView(
                          imagePath: Assets.icCall,
                        ),
                      ),
                    ),
                  ),
                  BackgroundWithShadowContainer(
                    height: 60,
                    border: 100,
                    width: 60,
                    backgroundColor:
                        Theme.of(context).colorScheme.onPrimaryFixed,
                    shadowColor: Theme.of(context).colorScheme.primary,
                    childWidget: Padding(
                      padding: const EdgeInsets.all(17),
                      child: CustomImageView(
                        imagePath: Assets.icMessage,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
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
              Text(title,
                  style: AppTextStyles.subtitle
                      .copyWith(color: Theme.of(context).colorScheme.tertiary)),
              const SizedBox(height: 4),
              Text(address,
                  style: AppTextStyles.link.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onTertiaryFixedVariant)),
            ],
          ),
        ),
        if (distance != null)
          Text(distance,
              style: AppTextStyles.subtitle.copyWith(
                  color: Theme.of(context).colorScheme.onTertiaryFixedVariant)),
      ],
    );
  }

  // Vertical Dashed Line
  Widget buildDashedLine() {
    return Column(
      children: List.generate(15, (index) {
        return Container(
          width: 1,
          height: index % 2 == 0 ? 4 : 2,
          color: index % 2 == 0
              ? Colors.grey
              : Colors.transparent, // Dashed effect
        );
      }),
    );
  }
}
