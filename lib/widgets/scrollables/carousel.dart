import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../core/theme/size_config.dart';
import '../../../core/theme/styles.dart';

class Carousel extends HookWidget {
  const Carousel({super.key, required this.containers});
  final List<Widget> containers;

  @override
  Widget build(
    BuildContext context,
  ) {
    var currentIndex = useState(0);

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            itemCount: containers.length,
            itemBuilder: (context, index) {
              return containers[index];
            },
            onPageChanged: (index) {
              currentIndex.value = index;
            },
          ),
        ),
        SizedBox(height: SizeConfig.blockSizeVertical * 1.25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildIndicators(currentIndex.value),
        ),
      ],
    );
  }

  List<Widget> _buildIndicators(int curIndex) {
    return containers.map((container) {
      int index = containers.indexOf(container);
      return Container(
        width: 8,
        height: 8,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: curIndex == index ? Styles.COLOR_ORANGE_BUTTON : Colors.grey,
        ),
      );
    }).toList();
  }
}
