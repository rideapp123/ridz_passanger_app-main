import 'package:flutter/material.dart';

class PersistentHeader extends StatelessWidget {
  const PersistentHeader({
    super.key,
    required this.child,
    this.minHeight = 50.0,
    this.maxHeight = 50.0,
    this.innerPadding,
    this.backgroundColor,
  });

  final double minHeight;
  final double maxHeight;
  final EdgeInsets? innerPadding;
  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        minHeight: minHeight,
        maxHeight: maxHeight,
        child: Container(
          padding: innerPadding,
          color: backgroundColor ?? Theme.of(context).colorScheme.onSecondary,
          child: child,
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
