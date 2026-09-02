import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/assets.dart';
import '../../../core/theme/styles.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.color,
  });

  final bool isLoading;
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          if (isLoading)
            Container(
              color: color ?? Colors.black.withValues(alpha: 0.2),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset(
                    Assets.lottieLoader,
                    width: 100,
                    height: 100,
                    frameRate: FrameRate.max,
                    filterQuality: FilterQuality.low,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'LesGo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      color: Styles.COLOR_PRIMARY_ORANGE,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.width,
    this.height,
    this.color,
  });

  final double? width;
  final double? height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? Colors.black.withValues(alpha: 0.2),
      ),
      child: Center(
          child: Lottie.asset(
        Assets.lottieLoader,
        width: width ?? 50,
        height: height ?? 50,
      )),
    );
  }
}
