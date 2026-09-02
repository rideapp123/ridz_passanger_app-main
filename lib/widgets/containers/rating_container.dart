import 'package:flutter/material.dart';
import '../../../core/theme/styles.dart';

class RatingContainer extends StatelessWidget {
  const RatingContainer({super.key, required this.rating, this.fontSize});
  final double? rating;
  final double? fontSize;
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Styles.COLOR_GREEN,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$rating',
              style: TextStyle(color: Colors.white, fontSize: fontSize ?? 10),
            ),
            const SizedBox(width: 5),
            Icon(
              Icons.star,
              color: Colors.white,
              size: fontSize ?? 10,
            ),
          ],
        ),
      ),
    );
  }
}
