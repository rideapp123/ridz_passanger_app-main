import 'package:flutter/material.dart';
import 'package:ridzs_passenger_app/widgets/containers/custom_image_view.dart';

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    this.title,
    required this.icon,
    this.onTap,
    this.borderRadius,
    this.iconColor,
    this.borderColor,
    this.textColor,
    this.height,
    this.width,
    this.backgroundColors,
  });
  final String? title;
  final String icon;
  final VoidCallback? onTap;
  final double? borderRadius;
  final Color? iconColor;
  final Color? textColor;
  final Color? backgroundColors;
  final Color? borderColor;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: backgroundColors ?? Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius ?? 0),
          border: Border.all(color: borderColor ?? Colors.transparent),
        ),
        child: Center(
          child: CustomImageView(
            imagePath: icon,
            color: iconColor,
            height: height ?? double.infinity,
            width: width ?? double.infinity,
          ),
        ),
      ),
    );
  }
}
