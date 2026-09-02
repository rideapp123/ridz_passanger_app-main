import 'package:flutter/material.dart';

import '../../../core/theme/styles.dart';

class CustomChoiceChip extends StatelessWidget {
  const CustomChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
    this.selectedColor = Styles.COLOR_PRIMARY_ORANGE,
    this.disabledColor = Styles.COLOR_OFF_GREY,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
  });

  final Widget label;
  final bool selected;
  final void Function(bool)? onSelected;
  final Color selectedColor;
  final Color disabledColor;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: label,
      selected: selected,
      onSelected: onSelected,
      surfaceTintColor: Colors.transparent,
      backgroundColor: backgroundColor ?? Styles.COLOR_BG_OFF_WHITE,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black,
        fontSize: Styles.TEXT_BODY,
        fontWeight: FontWeight.w600,
      ),

      selectedColor: selectedColor,
      disabledColor: disabledColor,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 30.0),
        side: BorderSide(
          color: selected ? selectedColor : Styles.COLOR_OFF_GREY,
        ),
      ),
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 12.0), // Horizontal padding
      labelPadding: const EdgeInsets.symmetric(
        horizontal: 12.0,
      ), // Horizontal padding
    );
  }
}
