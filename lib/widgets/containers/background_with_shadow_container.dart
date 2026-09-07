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
    this.border = 8,
    this.backgroundColor,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(border);
    return Container(
      width: width,
      constraints: BoxConstraints(minHeight: height),
      decoration: BoxDecoration(
        color: backgroundColor ??
            Theme.of(context).colorScheme.onSecondaryFixedVariant,
        border: boxBorder,
        borderRadius: radius,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: EdgeInsets.all(marginWithAll),
            child: childWidget,
          ),
        ),
      ),
    );
  }
}
