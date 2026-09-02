import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ScrollToTopButton extends HookWidget {
  const ScrollToTopButton({super.key, required this.controller});
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final showFab = useState(false);

    scrollListener() {
      if (controller.offset > 300) {
        showFab.value = true;
      } else {
        showFab.value = false;
      }
    }

    useEffect(() {
      controller.addListener(scrollListener);
      return null;
    }, []);

    return showFab.value
        ? Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: FloatingActionButton(
              mini: true,
              onPressed: () {
                controller.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              child: const Icon(Icons.arrow_upward),
            ),
          )
        : const SizedBox.shrink();
  }
}
