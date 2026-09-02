import 'package:flutter/material.dart';
import '../../../core/theme/styles.dart';

class HeadingText extends StatelessWidget {
  const HeadingText({
    super.key,
    required this.text,
    this.fontWeight = FontWeight.bold,
    this.size,
    this.color,
    this.overflow,
  });

  final String text;
  final FontWeight? fontWeight;
  final double? size;
  final Color? color;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: Styles.textStyleHeading3(
            fontWeight: fontWeight ?? FontWeight.bold,
            size: size,
            color: color ?? Styles.COLOR_PRIMARY_BLACK,
            overflow: overflow ?? TextOverflow.ellipsis)

        // TextStyle(
        //   fontFamily: Styles.HEADING_FONT,
        //   fontSize: size ?? Styles.TEXT_HEADING_3,
        //   fontWeight: fontWeight ?? FontWeight.bold,
        //   color: color ?? Styles.COLOR_PRIMARY_BLACK,
        //   overflow: overflow ?? TextOverflow.ellipsis,
        // ),
        );
  }
}
