import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/constants/assets.dart';
import '../../../core/theme/size_config.dart';
import '../../../core/theme/styles.dart';
import '../../../stores/ui/ui_store.dart';
import '../buttons/custom_button.dart';

class CompleteProfileDialog extends StatelessWidget {
  const CompleteProfileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(20),
        clipBehavior: Clip.hardEdge,
        width: SizeConfig.screenWidth * 0.8,
        child: IntrinsicHeight(
          child: Material(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  Assets.completeProfile,
                  height: 200,
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                const Text(
                  'Complete Your Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                const Text(
                  'Complete your profile and dive deeper into personalized recommendations and exclusive perks',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      child: const Text('later'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    CustomButton(
                      text: 'Done',
                      color: Styles.COLOR_PRIMARY_ORANGE,
                      onTap: () {
                        Navigator.of(context).pop();
                        uiStoreProvider().setIsUserEditingProfile(true);
                        // NavigationService()
                        //     .navigateTo(DietaryRestrictionPage.routeNamed);
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
