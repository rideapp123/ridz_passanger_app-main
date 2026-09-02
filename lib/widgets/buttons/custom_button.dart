import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ridzs_passenger_app/widgets/containers/custom_image_view.dart';
import 'package:ridzs_passenger_app/widgets/text/heading_text.dart';
import '../../../core/theme/styles.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.text,
    this.onTap,
    this.width,
    this.height = 50,
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
    this.showShadow = true,
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
    bool isSvg = false;
    if (imageIcon) {
      isSvg = iconPath?.split('/').last.contains('.svg') ?? false;
    }
    return GestureDetector(
      onTap: () async {
        if (Platform.isAndroid) {
          HapticFeedback.heavyImpact();
        } else {
          HapticFeedback.lightImpact();
        }
        if (isLoading) return;
        onTap?.call();
      },
      child: Container(
        width: width ?? MediaQuery.of(context).size.width,
        height: height,
        decoration: BoxDecoration(
          color: shadowColor ?? Theme.of(context).colorScheme.onPrimaryFixed,
          borderRadius: BorderRadius.circular(borderRadius ?? height * 0.3),
          border: border,
        ),
        child: Container(
          width: width ?? MediaQuery.of(context).size.width * 0.80,
          height: height * 0.80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius ?? height * 0.20),
            boxShadow: [
              if (showShadow)
                BoxShadow(
                    color: color ?? Theme.of(context).colorScheme.primary,
                    spreadRadius: -4,
                    blurRadius: 4,
                    offset: const Offset(3, 3)),
            ],
          ),
          child: isLoading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (imageIcon)
                      if (isSvg)
                        CustomImageView(
                          height: iconHeight,
                          width: iconWidth,
                          color: iconColor ?? textColor ?? Colors.white,
                          svgPath: iconPath,
                        )
                      else
                        CustomImageView(
                          imagePath: iconPath,
                          height: iconHeight,
                          width: iconWidth,
                          color: iconColor ?? textColor ?? Colors.white,
                        ),

                    if (hasIcon)
                      Icon(
                        iconData,
                        color: iconColor ?? textColor ?? Colors.white,
                        size: iconSize,
                      ),

                    const SizedBox(
                      width: 10,
                    ),

                    //
                    if (text != null)
                      HeadingText(
                        text: text ?? "",
                        color: textColor ?? Colors.black,
                        size: fontSize ?? Styles.TEXT_BODY,
                        fontWeight: fontWeight ?? FontWeight.w700,
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
