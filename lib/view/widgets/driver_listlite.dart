import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ridzs_passenger_app/core/theme/app_text_styles.dart';
import 'package:ridzs_passenger_app/view/rate_driver/widget/star_widget.dart';
import 'package:ridzs_passenger_app/widgets/containers/custom_image_view.dart';

class DriverListTie extends HookWidget {
  final String profileImage;
  final String userName;
  final String carModel;
  final double rating;
  final double starRating;
  final String licensePlate;

  const DriverListTie({
    super.key,
    required this.profileImage,
    required this.userName,
    required this.carModel,
    required this.rating,
    required this.starRating,
    required this.licensePlate,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: themeColor.primary, width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Center(
              child: CustomImageView(
                imagePath: profileImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userName,
                style: AppTextStyles.style15white
                    .copyWith(color: Theme.of(context).colorScheme.tertiary)),
            const SizedBox(height: 8),
            Text(
              carModel,
              style: AppTextStyles.style12W600.copyWith(
                color: themeColor.onTertiaryFixedVariant,
              ),
            ),
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                SingleStar(rating: starRating),
                const SizedBox(width: 4),
                Text(
                  rating.toString(),
                  style: AppTextStyles.style15white.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryFixed),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(
              licensePlate,
              style: AppTextStyles.style12W600.copyWith(
                color: themeColor.onTertiaryFixedVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
