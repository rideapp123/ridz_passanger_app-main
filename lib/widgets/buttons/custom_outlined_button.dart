import '../../core/theme/ridzs_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomOutlinedButton extends StatelessWidget {
  const CustomOutlinedButton({
    super.key,
    this.width = 30,
    this.height = 52,
    this.isLoading = false,
    required this.text,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.hasIcon = false,
    this.iconData = Icons.warning,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.tapTargetSize,
    this.foregroundColor,
    this.child,
  });

  final double width;
  final double height;
  final String text;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLoading;
  final Color? textColor;
  final double? borderRadius;
  final bool hasIcon;
  final IconData iconData;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;
  final MaterialTapTargetSize? tapTargetSize;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final foreground = textColor ?? foregroundColor ?? RidzsTheme.ink(context);
    final background = backgroundColor ?? RidzsTheme.paper(context);
    return OutlinedButton(
      onPressed: isLoading || onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap!();
            },
      style: OutlinedButton.styleFrom(
        minimumSize: Size(width, height),
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        foregroundColor: foreground,
        backgroundColor: background,
        disabledForegroundColor: foreground.withValues(alpha: .5),
        disabledBackgroundColor: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
        ),
        tapTargetSize: tapTargetSize,
        side: BorderSide(color: foregroundColor ?? RidzsTheme.line(context)),
        animationDuration: const Duration(milliseconds: 160),
        textStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: fontSize ?? 15,
          fontWeight: fontWeight ?? FontWeight.w600,
          height: 1.3,
          letterSpacing: 0,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ExcludeSemantics(
            excluding: isLoading,
            child: Opacity(
              opacity: isLoading ? 0 : 1,
              child: child ??
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (hasIcon) Icon(iconData, size: 20),
                      if (hasIcon) const SizedBox(width: 10),
                      Flexible(child: Text(text, textAlign: TextAlign.center)),
                    ],
                  ),
            ),
          ),
          if (isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: foreground,
                semanticsLabel: '$text, loading',
              ),
            ),
        ],
      ),
    );
  }
}
