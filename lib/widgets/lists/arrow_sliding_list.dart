import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../core/theme/size_config.dart';

class ArrowSlidingList<T> extends HookWidget {
  const ArrowSlidingList({
    super.key,
    required this.list,
    required this.itemBuilder,
    this.height,
    this.width,
  });

  final List<T> list;
  final Widget Function(
    BuildContext context,
    int index,
    T item,
  ) itemBuilder;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final shouldShowPrev = useState(false);
    final shouldShowNext = useState(true);

    final controller = usePageController();

    useEffect(() {
      controller.addListener(() {
        if (controller.page != null) {
          if (controller.page!.toInt() == 0) {
            shouldShowNext.value = true;
            shouldShowPrev.value = false;
          } else if (controller.page!.toInt() == list.length) {
            shouldShowPrev.value = true;
            shouldShowNext.value = false;
          } else {
            shouldShowPrev.value = true;
            shouldShowNext.value = true;
          }
        }
      });

      return () {};
    }, [
      controller,
      shouldShowNext,
      shouldShowPrev,
    ]);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (shouldShowPrev.value)
          GestureDetector(
            onTap: () => controller.previousPage(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeIn,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
        SizedBox(
          height: height ?? SizeConfig.screenHeight * 0.4,
          width: width ?? SizeConfig.screenWidth * 0.75,
          child: PageView.builder(
            controller: controller,
            itemCount: list.length,
            itemBuilder: (context, index) =>
                itemBuilder(context, index, list[index]),
          ),
        ),
        if (shouldShowNext.value)
          GestureDetector(
            onTap: () => controller.nextPage(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeIn,
            ),
            child: const Icon(Icons.arrow_forward_ios_rounded),
          ),
      ],
    );
  }
}
