import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ridzs_passenger_app/widgets/containers/custom_image_view.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.text,
    this.onTap,
    this.width,
    this.height = 52,
    this.iconHeight = 20,
    this.iconWidth = 20,
    this.iconColor,
    this.isLoading = false,
    this.textColor,
    this.borderRadius,
    this.hasIcon = false,
    this.imageIcon = false,
    this.iconData = Icons.warning,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.tapTargetSize,
    this.border,
    this.color,
    this.iconSize,
    this.iconPath,
    this.shadowColor,
    this.showShadow = false,
  });

  final double? width;
  final double height;
  final double iconWidth;
  final double iconHeight;
  final bool showShadow;
  final String? text;
  final String? iconPath;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color? textColor;
  final Color? color;
  final Color? shadowColor;
  final double? borderRadius;
  final bool hasIcon;
  final bool imageIcon;
  final IconData iconData;
  final double? fontSize;
  final Border? border;
  final double? iconSize;
  final Color? iconColor;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;
  final MaterialTapTargetSize? tapTargetSize;

  @override
  Widget build(BuildContext context) {
    final background =
        color ?? shadowColor ?? Theme.of(context).colorScheme.primary;
    final foreground = textColor ??
        (ThemeData.estimateBrightnessForColor(background) == Brightness.dark
            ? Colors.white
            : const Color(0xff070707));
    final enabled = onTap != null && !isLoading;
    final label = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (imageIcon && iconPath != null)
          CustomImageView(
            height: iconHeight,
            width: iconWidth,
            color: iconColor ?? foreground,
            svgPath: iconPath!.toLowerCase().endsWith('.svg') ? iconPath : null,
            imagePath:
                iconPath!.toLowerCase().endsWith('.svg') ? null : iconPath,
          ),
        if (hasIcon)
          Icon(iconData, color: iconColor ?? foreground, size: iconSize ?? 20),
        if ((hasIcon || (imageIcon && iconPath != null)) && text != null)
          const SizedBox(width: 10),
        if (text != null)
          Flexible(
            child: Text(text!, textAlign: TextAlign.center),
          ),
      ],
    );
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: enabled
            ? () {
                HapticFeedback.selectionClick();
                onTap!();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor:
              isLoading ? background : background.withValues(alpha: .25),
          disabledForegroundColor:
              isLoading ? foreground : foreground.withValues(alpha: .55),
          minimumSize: Size(48, height),
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          tapTargetSize: tapTargetSize,
          elevation: showShadow ? 1 : 0,
          shadowColor: shadowColor ?? Colors.black.withValues(alpha: .12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 8),
            side: border?.top ?? BorderSide.none,
          ),
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
            // Keep the label's layout while loading, including larger text sizes.
            ExcludeSemantics(
              excluding: isLoading,
              child: Opacity(opacity: isLoading ? 0 : 1, child: label),
            ),
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foreground,
                  semanticsLabel: text == null ? 'Loading' : '$text, loading',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
