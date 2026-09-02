import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../cards/no_items_card.dart';

class PaginatedList<T> extends StatefulWidget {
  const PaginatedList({
    super.key,
    required this.init,
    required this.list,
    required this.isLoading,
    required this.itemBuilder,
    required this.loaderPlaceholder,
    this.paginationCallback,
    this.onRefresh,
    this.shrinkWrap = false,
    this.itemName,
  });

  final VoidCallback init;
  final List<T> list;
  final bool isLoading;
  final Function(ScrollController)? paginationCallback;
  final Future<void> Function()? onRefresh;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final Widget loaderPlaceholder;
  final bool shrinkWrap;

  /// For No Items String eg: Chats, Subscriptions etc
  final String? itemName;

  @override
  State<PaginatedList<T>> createState() => _PaginatedListState<T>();
}

class _PaginatedListState<T> extends State<PaginatedList<T>>
    with AutomaticKeepAliveClientMixin {
  late final ScrollController controller;

  @override
  void initState() {
    super.initState();
    widget.init();

    controller = ScrollController();

    if (widget.paginationCallback != null) {
      controller.addListener(() {
        widget.paginationCallback!(controller);
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
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
            physics: const AlwaysScrollableScrollPhysics(),
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
          physics: const AlwaysScrollableScrollPhysics(),
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
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => widget.itemBuilder(
            context,
            index,
            widget.list[index],
          ),
          childCount: widget.list.length,
        ),
      );
    } else if (widget.isLoading) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => widget.loaderPlaceholder,
          childCount: 20,
        ),
      );
    } else {
      return SliverFillRemaining(
        child: LayoutBuilder(builder: (context, constraints) {
          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: constraints.maxHeight * 0.1,
              horizontal: constraints.maxWidth * 0.2,
            ),
            child: FittedBox(
              child: NoItemsCard(title: widget.itemName ?? 'items'),
            ),
          );
        }),
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
