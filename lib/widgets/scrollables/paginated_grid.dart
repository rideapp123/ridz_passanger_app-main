import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/theme/size_config.dart';
import '../../../core/theme/styles.dart';
import '../cards/no_items_card.dart';

class PaginatedGrid<T> extends StatefulWidget {
  const PaginatedGrid({
    super.key,
    required this.init,
    required this.list,
    required this.isLoading,
    required this.itemBuilder,
    required this.loaderPlaceholder,
    this.paginationCallback,
    this.onRefresh,
    this.shrinkWrap = false,
    this.padding,
    this.showPaginationLoader = false,
    this.controller,
    this.physics = const BouncingScrollPhysics(),
  });

  final VoidCallback init;
  final List<T> list;
  final bool isLoading;
  final Function(ScrollController)? paginationCallback;
  final Future<void> Function()? onRefresh;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final Widget loaderPlaceholder;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final bool showPaginationLoader;
  final ScrollPhysics? physics;

  ///Need to dispose manually if controller is passed
  final ScrollController? controller;

  @override
  State<PaginatedGrid<T>> createState() => _PaginatedGridState<T>();
}

class _PaginatedGridState<T> extends State<PaginatedGrid<T>>
    with AutomaticKeepAliveClientMixin {
  late final ScrollController controller;
  bool isScrolling = false;

  void isScrollingNotifier() {
    if (controller.position.isScrollingNotifier.value) {
      isScrolling = true;
    } else {
      isScrolling = false;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.init();

    controller = widget.controller ?? ScrollController();
    controller.addListener(isScrollingNotifier);

    if (widget.paginationCallback != null) {
      controller.addListener(() {
        widget.paginationCallback!(controller);
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      controller.removeListener(isScrollingNotifier);
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.onRefresh != null) {
      return RefreshIndicator.adaptive(
        onRefresh: widget.onRefresh!,
        child: Skeletonizer.zone(
          enabled: widget.isLoading,
          child: CustomScrollView(
            shrinkWrap: widget.shrinkWrap,
            controller: controller,
            physics: widget.physics,
            slivers: [
              getChild(),
            ],
          ),
        ),
      );
    } else {
      return Skeletonizer.zone(
        enabled: widget.isLoading,
        child: CustomScrollView(
          physics: widget.physics,
          shrinkWrap: widget.shrinkWrap,
          slivers: [
            getChild(),
          ],
        ),
      );
    }
  }

  Widget getChild() {
    if (widget.list.isNotEmpty && !widget.isLoading) {
      return SliverPadding(
        padding: widget.padding ?? const EdgeInsets.all(20),
        sliver: SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 1 / 0.73,
            crossAxisSpacing: 10,
            mainAxisSpacing: SizeConfig.screenWidth * 0.035,
          ),
          addAutomaticKeepAlives: false,
          itemBuilder: (context, index) {
            if (index == widget.list.length &&
                widget.showPaginationLoader &&
                isScrolling) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: CupertinoActivityIndicator(
                  color: Styles.COLOR_PRIMARY_ORANGE,
                ),
              );
            } else if (index < widget.list.length) {
              return widget.itemBuilder(context, index, widget.list[index]);
            }
            return null;
          },
          itemCount: widget.list.length +
              (widget.showPaginationLoader && isScrolling ? 1 : 0),
        ),
      );
    } else if (widget.isLoading) {
      return SliverPadding(
        padding: widget.padding ?? const EdgeInsets.all(20),
        sliver: SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 1 / 0.7,
            crossAxisSpacing: 10,
            mainAxisSpacing: SizeConfig.screenWidth * 0.035,
          ),
          itemBuilder: (context, index) => widget.loaderPlaceholder,
          itemCount: 20,
        ),
      );
    } else {
      return SliverFillRemaining(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.15),
          child: const FittedBox(child: NoItemsCard(title: 'restaurants')),
        ),
      );
    }
  }

  @override
  bool get wantKeepAlive => false;
}
