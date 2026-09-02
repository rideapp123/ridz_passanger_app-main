import 'package:flutter/material.dart';

class AnimatedFill extends StatefulWidget {
  const AnimatedFill({
    super.key,
    this.shouldAnimate = false,
  });

  final bool shouldAnimate;

  @override
  State<AnimatedFill> createState() => _AnimatedFillState();
}

class _AnimatedFillState extends State<AnimatedFill>
    with TickerProviderStateMixin {
  late final List<AnimationController> controllers;
  late final List<Animation<double>> scaleAnimations;
  late final List<Color> colors;

  void start() {
    for (final c in controllers) {
      c
        ..forward()
        ..repeat(reverse: true)
        ..addListener(() {
          setState(() {});
        });
    }
  }

  void stop() {
    for (final c in controllers) {
      c.reset();
    }
  }

  @override
  void initState() {
    super.initState();
    colors = [
      const Color(0xffee7441),
      const Color(0xfff3a785),
      const Color(0xfff7cab2),
    ];

    controllers = List.generate(colors.length, (index) {
      return AnimationController(
        duration: Duration(milliseconds: 750 + (index * 100)),
        vsync: this,
      );
    });

    scaleAnimations = controllers
        .map((c) => Tween<double>(begin: 0, end: 2.5).animate(c))
        .toList();
  }

  @override
  void didUpdateWidget(covariant AnimatedFill oldWidget) {
    if (oldWidget.shouldAnimate != widget.shouldAnimate) {
      if (widget.shouldAnimate) {
        start();
      } else {
        stop();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: controllers.indexed
          .map((item) => Transform.scale(
                scale: scaleAnimations[item.$1].value,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors[item.$1],
                  ),
                ),
              ))
          .toList(),
    );
  }
}
