import '../../core/theme/ridzs_theme.dart';

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
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: RidzsTheme.line(context))),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 20, 12),
        child: Row(
          children: [
            IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () => NavigationService().pop(),
              icon: Icon(Icons.arrow_back_rounded,
                  color: RidzsTheme.ink(context)),
              constraints: const BoxConstraints.tightFor(width: 48, height: 48),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (trailingWidget != null) ...[
              const SizedBox(width: 12),
              trailingWidget!,
            ],
          ],
        ),
      ),
    );
  }
}
