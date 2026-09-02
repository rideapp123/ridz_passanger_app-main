import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/constants/assets.dart';
import '../../../core/theme/size_config.dart';
import '../../../core/theme/styles.dart';
import '../buttons/custom_button.dart';

class LocationPermissionDialog extends StatelessWidget {
  const LocationPermissionDialog(
      {super.key, required this.onNotNowTap, required this.onAllowLocationTap});

  final VoidCallback onNotNowTap;
  final VoidCallback onAllowLocationTap;

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
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: SizeConfig.safeBlockVertical * 1),
                    SvgPicture.asset(
                      Assets.locationPermission,
                      height: 150,
                      width: SizeConfig.screenWidth * 0.2,
                    ),
                    const Text(
                      'Location Permission Required',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: Styles.TEXT_TITLE_MEDIUM,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: SizeConfig.safeBlockVertical * 1),
                    const Text(
                      'LesGo needs your location to show nearby restaurants, manage visits, and unlock other convenient features.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: Styles.TEXT_BODY_SMALL,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: SizeConfig.safeBlockVertical * 1),
                    SizedBox(height: SizeConfig.safeBlockVertical * 2),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomButton(
                          text: 'Allow Location',
                          color: Styles.COLOR_PRIMARY_ORANGE,
                          onTap: onAllowLocationTap,
                        ),
                        TextButton(
                          onPressed: onNotNowTap,
                          child: const Text('Not Now'),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
