import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ridzs_passenger_app/core/theme/app_layout.dart';
import 'package:ridzs_passenger_app/view/home/widget/saved_place.dart';
import 'package:ridzs_passenger_app/widgets/buttons/custom_button.dart';
import 'package:ridzs_passenger_app/widgets/text/custom_textfield.dart';

import '../../../core/constants/strings_constant.dart';
import '../../../core/services/bottomsheet_service.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/containers/background_with_shadow_container.dart';
import '../../widgets/driver_listlite.dart';

class TripForDriver extends HookWidget {
  const TripForDriver({super.key});
  @override
  Widget build(BuildContext context) {
    final selected = useState(0);
    return SingleChildScrollView(
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
                  AppStrings.tripForDrover,
                  style: AppTextStyles.style23W600
                      .copyWith(color: Theme.of(context).colorScheme.tertiary),
                ),
                const Spacer(),
                const SizedBox(
                  width: 20,
                ),
                InkWell(
                  onTap: () {},
                  child: Text(
                    AppStrings.skip,
                    style: AppTextStyles.style12W500.copyWith(
                        color: Theme.of(context).colorScheme.tertiary),
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
            Divider(
              color: Theme.of(context)
                  .colorScheme
                  .onTertiaryFixed
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Do you want to add additional tip for Daniel?',
              style: AppTextStyles.style12W600.copyWith(
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return buildSavedPlaceItem(
                        placeName: '\$5',
                        context: context,
                        isSelected: index == selected.value,
                        onTap: () {
                          selected.value = index;
                        },
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, right: 10),
                    child: SizedBox(
                        width: 70,
                        child: customTextFormField(
                            labelColor: Theme.of(context).colorScheme.tertiary,
                            hintText: '\$20',
                            label: 'Tip')),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: AppPadding.scaffoldWithTop,
              child: CustomButton(
                onTap: () {
                  Navigator.pop(context);
                  middleBottomSheetService(const SavedPlaces(), height: 0.6);
                },
                width: 120,
                text: AppStrings.addTrip,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildSavedPlaceItem(
      {required String placeName,
      required BuildContext context,
      required bool isSelected,
      void Function()? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 10),
      child: BackgroundWithShadowContainer(
        height: 50,
        width: 70,
        boxBorder: !isSelected
            ? Border.all(color: Theme.of(context).colorScheme.primary)
            : null,
        backgroundColor: !isSelected
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.onPrimaryFixed,
        shadowColor: !isSelected
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.primary,
        childWidget: Center(
          child: Text(
            placeName,
            style: AppTextStyles.subtitle1.copyWith(
              color: !isSelected
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.surface,
            ),
          ),
        ),
      ),
    );
  }
}
