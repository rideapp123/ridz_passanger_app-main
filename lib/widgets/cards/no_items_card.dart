import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/constants/assets.dart';
import '../../../core/theme/size_config.dart';

class NoItemsCard extends StatelessWidget {
  const NoItemsCard(
      {super.key, this.customText, this.title, this.showStayTuned = false});
  final String? customText;
  final String? title;
  final bool showStayTuned;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          Assets.waitingBg,
          width: SizeConfig.screenWidth * 0.5,
        ),
        Text(
          customText ?? 'Looks like there are no $title yet',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black38,
          ),
        ),
        if (showStayTuned)
          const Text(
            'Stay tuned',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xffFF5B00),
            ),
          )
      ],
    );
  }
}
