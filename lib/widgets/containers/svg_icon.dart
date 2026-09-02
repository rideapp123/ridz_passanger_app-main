import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  const SvgIcon({
    super.key,
    required this.icon,
    this.color,
    this.width,
    this.height,
    this.alignment,
  });

  final String icon;
  final Color? color;
  final double? width;
  final double? height;
  final Alignment? alignment;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon,
      width: width,
      height: height,
      alignment: alignment ?? Alignment.center,
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcATop) : null,
    );
  }
}
