import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class BackgroundWithShadowContainer extends HookWidget {
  final Widget childWidget;
  final Color? backgroundColor;
  final Color shadowColor;
  final VoidCallback? onTap;
  final double height;
  final double? width;
  final BoxBorder? boxBorder;
  final double marginWithAll;
  final double border;

  const BackgroundWithShadowContainer({
    super.key,
    required this.childWidget,
    this.height = 40,
    this.width,
    this.onTap,
    this.boxBorder,
    this.marginWithAll = 0,
    this.border = 10,
    this.backgroundColor,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: backgroundColor ??
              Theme.of(context).colorScheme.onSecondaryFixedVariant,
          border: boxBorder,
          borderRadius: BorderRadius.circular(border),
        ),
        child: Container(
          width: width != null ? (width! * 0.80) : double.infinity,
          height: height * 0.80,
          margin: EdgeInsets.all(marginWithAll),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(border),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                spreadRadius: -3,
                blurRadius: 3,
              ),
            ],
          ),
          child: childWidget,
        ),
      ),
    );
  }
}
