import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:ridzs_passenger_app/view/profile/edit_profile_screen.dart';

import '../../../core/exports/common_exports.dart';

class UserProfileCard extends HookWidget {
  const UserProfileCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Observer(builder: (context) {
      final userData = userStoreProvider().meResponse?.user;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).colorScheme.onPrimaryFixedVariant,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: .2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //
                const SizedBox(
                  height: 32,
                  width: 32,
                ),

                if ((userData?.profilePicture ?? '').isEmpty)
                  Container(
                    alignment: Alignment.center,
                    height: SizeConfig.screenHeight * 0.1,
                    width: SizeConfig.screenHeight * 0.1,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.primary,
                    ),
                    child: Icon(
                      Icons.person,
                      size: SizeConfig.screenHeight * 0.05,
                      color: Colors.white,
                    ),
                  )
                else
                  ClipOval(
                    child: CustomImageView(
                      url: userData?.profilePicture,
                      fit: BoxFit.cover,
                      height: SizeConfig.screenHeight * 0.1,
                      width: SizeConfig.screenHeight * 0.1,
                    ),
                  ),

                GestureDetector(
                  onTap: () {
                    NavigationService().navigateTo(
                      EditProfileScreen.routeNamed,
                    );
                  },
                  child: CustomImageView(
                    svgPath: Assets.icEdit2,
                  ),
                ),
              ],
            ),

            //
            const SizedBox(height: 12),

            Text(
              userData?.username ?? '',
              style: AppTextStyles.style15W700.copyWith(
                color: theme.tertiary,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            // Row(
            //   mainAxisSize: MainAxisSize.min,
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            //     //
            //     CustomImageView(
            //       imagePath: Assets.icLocation,
            //       height: 16,
            //       width: 16,
            //       color: theme.secondaryFixed,
            //     ),

            //     const SizedBox(width: 5),

            //     Text(
            //       'San Francisco, USA',
            //       style: AppTextStyles.style12W500.copyWith(
            //         color: theme.onTertiaryContainer,
            //       ),
            //     ),

            //     const SizedBox(width: 10),

            //     CustomImageView(
            //       svgPath: Assets.starIc,
            //       height: 16,
            //       width: 16,
            //     ),

            //     const SizedBox(width: 5),

            //     Text(
            //       '4.5 Star',
            //       style: AppTextStyles.style12W500.copyWith(
            //         color: theme.onTertiaryContainer,
            //       ),
            //     ),
            //   ],
            // )
          ],
        ),
      );
    });
  }
}

extension StringEllipsis on String {
  String ellipse(int maxLength) {
    if (length <= maxLength) {
      return this;
    }
    return '${substring(0, maxLength)}...';
  }
}
