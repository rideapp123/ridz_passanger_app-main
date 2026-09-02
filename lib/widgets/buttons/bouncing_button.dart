import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Bounce extends StatefulWidget {
  const Bounce({
    super.key,
    required this.child,
    required this.onTap,
    this.duration = const Duration(milliseconds: 100),
  });

  final VoidCallback onTap;
  final Widget child;
  final Duration duration;

  @override
  BounceState createState() => BounceState();
}

class BounceState extends State<Bounce> with SingleTickerProviderStateMixin {
  double _scale = 0;
  // bool _isLoading = false; // Add a loading state variable

  AnimationController? _animate;

  VoidCallback get onTap => widget.onTap;

  Duration get userDuration => widget.duration;

  @override
  void initState() {
    _animate = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 0.2,
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    _animate?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _animate!.value;
    return GestureDetector(
      onTap: _onTap,
      child: Transform.scale(
        scale: _scale,
        child: widget.child,
      ),
    );
  }

  Future<void> _onTap() async {
    // setState(() {
    //   _isLoading = true; // Set loading state to true
    // });

    _animate!.forward();

    Future.delayed(userDuration, () async {
      _animate!.reverse();

      widget.onTap(); // Wait for the async operation to complete

      // setState(() {
      //   _isLoading = false; // Set loading state to false
      // });
    });
  }
}
