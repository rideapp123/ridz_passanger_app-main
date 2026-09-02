import 'package:flutter/material.dart';

import '../../../core/theme/styles.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider(this.text,
      {super.key,
      this.color,
      this.dividerColor,
      this.fontSize,
      this.fontWeight,
      this.isButton = false,
      this.onTap});
  final String text;
  final Color? color;
  final Color? dividerColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool isButton;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            thickness: 1,
            endIndent: 8,
            indent: 4,
            color: dividerColor ?? Colors.black12,
          ),
        ),
        if (isButton)
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 25,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Styles.COLOR_PRIMARY_ORANGE,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                text,
                style: TextStyle(
                  color: Styles.COLOR_PRIMARY_ORANGE,
                  fontSize: fontSize ?? Styles.TEXT_HEADING_4,
                  fontWeight: fontWeight ?? FontWeight.w700,
                ),
              ),
            ),
          ),
        if (!isButton)
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? Styles.TEXT_HEADING_4,
              fontWeight: FontWeight.w600,
              color: color ?? Styles.COLOR_PRIMARY_BLACK,
            ),
          ),
        Expanded(
          child: Divider(
            thickness: 1,
            indent: 8,
            endIndent: 4,
            color: dividerColor ?? Colors.black12,
          ),
        ),
      ],
    );
  }
}
