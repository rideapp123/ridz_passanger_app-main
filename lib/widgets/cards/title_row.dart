import 'package:flutter_svg/flutter_svg.dart';

import '../../core/exports/common_exports.dart';

class TitleRowWidget extends HookWidget {
  final String text;
  final TextStyle? textStyle;
  final String? imagePath;
  final bool? rightSide;
  final Color? imageColor;
  final double? imageHeight;
  final double? imageWidth;
  final Widget? trailingWidget;

  const TitleRowWidget({
    super.key,
    required this.text,
    this.textStyle,
    this.imageColor,
    this.rightSide = false,
    this.imagePath = Assets.icRemove,
    this.imageHeight = 20,
    this.trailingWidget,
    this.imageWidth = 20,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeConfig.screenHeight * 0.08,
      child: Column(
        children: [
          Padding(
            padding: AppPadding.scaffold,
            child: Row(
              children: [
                //
                GestureDetector(
                  onTap: () {
                    NavigationService().pop();
                  },
                  child: Container(
                    height: 32,
                    width: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onTertiaryFixed,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.3),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: SvgPicture.asset(
                      Assets.backIc,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.surface,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    text,
                    style: AppTextStyles.style18W500.copyWith(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),

                if (trailingWidget != null) trailingWidget!
              ],
            ),
          ),

          //
          SizedBox(
            height: SizeConfig.screenHeight * 0.01,
          ),

          const Divider()
        ],
      ),
    );
  }
}
