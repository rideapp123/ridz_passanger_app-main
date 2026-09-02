import 'package:ridzs_passenger_app/core/exports/common_exports.dart';

class AppDialog extends HookWidget {
  const AppDialog({
    super.key,
    required this.subTitle,
    required this.onYesPressed,
    required this.title,
    required this.actionButtonTitle,
    required this.icon,
    required this.color,
    this.isDelete = false,
    this.showActionButton = true,
    this.cancelTitle,
    this.iconColor,
    this.leftText,
    this.rightText,
  });

  final bool isDelete;
  final Color color;
  final Color? iconColor;
  final String icon;
  final String subTitle;
  final bool showActionButton;
  final String actionButtonTitle;
  final String? leftText;
  final String? cancelTitle;
  final String? rightText;
  final String title;
  final VoidCallback onYesPressed;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      // shadowColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //
            if (icon.isNotEmpty)
              Container(
                alignment: Alignment.center,
                height: SizeConfig.screenHeight * 0.1,
                width: SizeConfig.screenHeight * 0.1,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .1),
                  shape: BoxShape.circle,
                ),
                child: CustomImageView(
                  svgPath: icon,
                  height: 50,
                  width: 50,
                  color: iconColor,
                ),
              ),

            SizedBox(
              height: SizeConfig.screenHeight * 0.02,
            ),

            Text(
              title,
              style: AppTextStyles.subtitle.copyWith(
                color: Theme.of(context).colorScheme.tertiary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              subTitle,
              style: AppTextStyles.subtitle2.copyWith(
                color: Theme.of(context).colorScheme.primaryFixedDim,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            //
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //
                if (showActionButton)
                  CustomButton(
                    onTap: onYesPressed,
                    shadowColor: color,
                    text: actionButtonTitle,
                    showShadow: false,
                    textColor: Colors.white,
                  ),

                const SizedBox(height: 10),

                CustomButton(
                  onTap: () {
                    NavigationService().pop();
                  },
                  shadowColor:
                      Theme.of(context).colorScheme.surfaceContainerHigh,
                  text: cancelTitle ?? 'Cancel',
                  showShadow: false,
                  textColor: Theme.of(context).colorScheme.tertiary,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primaryFixedDim,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
