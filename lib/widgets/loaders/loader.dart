import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/services/navigation_service.dart';
import '../../../core/theme/size_config.dart';
import '../../../core/theme/styles.dart';

class Loader {
  static bool _isLoading = false;

  static void showLoader() {
    if (!_isLoading) {
      _isLoading = true;

      showDialog(
        context: NavigationService.navigatorKey.currentState!.context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (BuildContext context) {
          return const LoadingWidget();
        },
      );
    }
  }

  static void hideLoader() {
    if (_isLoading) {
      _isLoading = false;
      NavigationService().pop();
    }
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSecondary.withAlpha(50),
      body: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 5.0),
              child: Container(
                height: SizeConfig.screenHeight,
                color: Colors.grey.withAlpha(50),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingDots extends StatefulWidget {
  const LoadingDots({super.key});

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Getting things ready',
              style: Styles.textStyleNormalText(fontWeight: FontWeight.w600),
            ),
            SizedBox(
                width: 30, child: Text('.' * (_controller.value * 4).floor()))
          ],
        );
      },
    );
  }
}
