import 'package:flutter/material.dart';
import 'package:ridzs_passenger_app/core/theme/app_layout.dart';

class CustomTextButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget childWidget;
  final Color? backgroundColor;
  final double height;
  final double borderRadius;

  const CustomTextButton({
    super.key,
    this.onTap,
    this.backgroundColor,
    this.height = 40,
    this.borderRadius = 10,
    required this.childWidget,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: AppPadding.container10,
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: childWidget,
      ),
    );
  }
}
