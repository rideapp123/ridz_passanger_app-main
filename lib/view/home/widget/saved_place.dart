import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ridzs_passenger_app/core/constants/assets.dart';
import 'package:ridzs_passenger_app/core/theme/app_layout.dart';
import 'package:ridzs_passenger_app/widgets/containers/custom_image_view.dart';

import '../../../core/constants/strings_constant.dart';
import '../../../core/theme/app_text_styles.dart';

class SavedPlaces extends HookWidget {
  const SavedPlaces({super.key});
  @override
  Widget build(BuildContext context) {
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
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Theme.of(context).colorScheme.onTertiaryFixed,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      AppStrings.savedPlaces,
                      style: AppTextStyles.style23W600.copyWith(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 20,
                ),
                const Spacer(),
              ],
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
            ListView.builder(
              shrinkWrap: true,
              itemCount: 10,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).colorScheme.onSecondary),
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CustomImageView(
                            height: 22,
                            imagePath: Assets.imgLoctn,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Home',
                                style: AppTextStyles.style15W600.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiaryFixed),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                '2972 Westheimer Rd, Santa Ana, Illinois 85486',
                                style: AppTextStyles.style12W500.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiaryFixed),
                              ),
                            ],
                          )
                        ],
                      ),
                      CustomImageView(
                        height: 22,
                        imagePath: Assets.imgDelete,
                      ),
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
