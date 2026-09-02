import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/constants/assets.dart';
import '../../../core/theme/size_config.dart';
import '../../../core/theme/styles.dart';
import '../buttons/custom_button.dart';

class EnableNFCDialog extends StatelessWidget {
  const EnableNFCDialog(
      {super.key, required this.onDoneTap, required this.onEnableTap});
  final VoidCallback onDoneTap;
  final VoidCallback onEnableTap;

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
                SizedBox(height: SizeConfig.safeBlockVertical * 1),
                SvgPicture.asset(
                  Assets.nfc,
                  width: SizeConfig.screenWidth * 0.25,
                  colorFilter: const ColorFilter.mode(
                    Styles.COLOR_LIGHT_ORANGE_BACKGROUND,
                    BlendMode.srcATop,
                  ),
                ),
                const Text(
                  'Please Enable NFC',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Styles.TEXT_TITLE_MEDIUM,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomButton(
                      text: 'Open NFC Settings',
                      color: Styles.COLOR_PRIMARY_ORANGE,
                      onTap: onEnableTap,
                    ),
                    TextButton(
                      onPressed: onDoneTap,
                      child: const Text('Done'),
                    ),
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
