import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/styles.dart';
import '../text/heading_text.dart';

class CustomOutlinedButton extends StatelessWidget {
  const CustomOutlinedButton({
    super.key,
    this.width = 30,
    this.height = 45,
    this.isLoading = false,
    required this.text,
    this.onTap,
    this.backgroundColor = Colors.white,
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
  final Color backgroundColor;
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
    return OutlinedButton(
      onPressed: () async {
        if (Platform.isAndroid) {
          HapticFeedback.heavyImpact();
        } else {
          HapticFeedback.lightImpact();
        }

        onTap?.call();
      },
      style: OutlinedButton.styleFrom(
        minimumSize: Size(width, height),
        padding: padding,
        foregroundColor: foregroundColor ?? Styles.COLOR_PRIMARY_ORANGE,
        backgroundColor:
            isLoading ? backgroundColor.withValues(alpha: 0.8) : backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 10),
        ),
        disabledForegroundColor: Colors.transparent.withValues(alpha: 0.38),
        disabledBackgroundColor: Colors.transparent.withValues(alpha: 0.12),
        shadowColor: Colors.transparent,
        tapTargetSize: tapTargetSize,
        animationDuration: const Duration(milliseconds: 1500),
        side: BorderSide(
          color: foregroundColor ?? Styles.COLOR_PRIMARY_ORANGE,
          width: 2.0,
        ),
      ),
      child: child ??
          (isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white70,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasIcon)
                      Icon(
                        iconData,
                        color: textColor ?? Styles.COLOR_PRIMARY_ORANGE,
                        size: 16,
                      ),
                    if (hasIcon)
                      const SizedBox(
                        width: 5,
                      ),
                    HeadingText(
                      text: text,
                      color: textColor ?? Styles.COLOR_PRIMARY_ORANGE,
                      size: fontSize ?? Styles.TEXT_BODY,
                      fontWeight: fontWeight ?? FontWeight.normal,
                    ),
                  ],
                )),
    );
  }
}
