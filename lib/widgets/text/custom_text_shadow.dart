import 'package:flutter/material.dart';
import '../../../core/theme/styles.dart';

class CustomTextShadow extends StatelessWidget {
  const CustomTextShadow({
    super.key,
    required this.text,
    this.color,
    this.blurColor,
    this.fontSize,
    this.fontWeight,
  });

  final String text;
  final Color? color;
  final Color? blurColor;
  final double? fontSize;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? Styles.COLOR_PRIMARY_BLACK,
        fontFamily: 'Poppins',
        fontSize: fontSize ?? Styles.TEXT_BODY,
        fontWeight: fontWeight ?? FontWeight.w600,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
