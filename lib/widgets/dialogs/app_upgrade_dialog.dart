import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:upgrader/upgrader.dart';

import '../../../core/configs/app_config.dart';
import '../../../core/constants/assets.dart';
import '../../../core/enums/app_flavor.dart';
import '../../../core/theme/size_config.dart';
import '../../../core/theme/styles.dart';
import '../buttons/custom_button.dart';

class CustomUpgrader extends Upgrader {
  CustomUpgrader({
    super.debugLogging,
    super.debugDisplayAlways,
  });

  @override
  bool isUpdateAvailable() {
    final storeVersion = currentAppStoreVersion;
    final installedVersion = currentInstalledVersion;
    debugPrint('storeVersion=$storeVersion');
    debugPrint('installedVersion=$installedVersion');
    return AppConfig.allFlavor == AppFlavor.develop
        ? false
        : super.isUpdateAvailable();
  }
}

class CustomUpgradeAlert extends UpgradeAlert {
  CustomUpgradeAlert({
    super.key,
    super.upgrader,
    super.child,
    super.shouldPopScope,
  });

  /// Override the [createState] method to provide a custom classd
  /// with overridden methods.
  @override
  UpgradeAlertState createState() => CustomUpgradeAlertState();
}

class CustomUpgradeAlertState extends UpgradeAlertState {
  @override
  void showTheDialog({
    Key? key,
    required BuildContext context,
    required String? title,
    required String message,
    required String? releaseNotes,
    required bool barrierDismissible,
    required UpgraderMessages messages,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AppUpgradeDialog(
            currentAppStoreVersion: widget.upgrader.currentAppStoreVersion,
            onUpdateNowTap: () {
              onUserUpdated(context, !widget.upgrader.blocked());
            });
      },
    );
  }
}

class AppUpgradeDialog extends StatelessWidget {
  const AppUpgradeDialog(
      {super.key, required this.onUpdateNowTap, this.currentAppStoreVersion});
  final VoidCallback onUpdateNowTap;
  final String? currentAppStoreVersion;

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
                  Assets.upgradeRocket,
                  height: 150,
                  width: SizeConfig.screenWidth * 0.2,
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 1),
                const Text(
                  'App Upgrade Required',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Styles.TEXT_TITLE_MEDIUM,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 1),
                Text(
                  'A new version of LesGo (v${currentAppStoreVersion ?? ''}) is available and required to continue using the app.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: Styles.TEXT_BODY_SMALL,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 1),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                CustomButton(
                  text: 'Update now',
                  color: Styles.COLOR_PRIMARY_ORANGE,
                  onTap: onUpdateNowTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
