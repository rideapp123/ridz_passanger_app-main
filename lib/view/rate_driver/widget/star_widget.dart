import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class StarRating extends HookWidget {
  final int totalStars;
  final Color? filledStarColor;
  final Color emptyStarColor;

  const StarRating({
    super.key,
    this.totalStars = 5,
    this.filledStarColor,
    this.emptyStarColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    final currentRating = useState(0);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalStars, (index) {
        return InkWell(
          onTap: () {
            currentRating.value = index + 1;
          },
          child: Icon(
            size: 30,
            index < currentRating.value ? Icons.star : Icons.star_border,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      }),
    );
  }
}

class SingleStar extends HookWidget {
  final double rating;
  final double starSize;

  const SingleStar({
    super.key,
    required this.rating,
    this.starSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    double fractionalPart = useMemoized(() => rating / 5, [rating]);

    return Stack(
      children: [
        Icon(
          Icons.star_border,
          color: Theme.of(context).colorScheme.primary,
          size: starSize,
        ),
        ClipRect(
          clipper: _StarClipper(fractionalPart),
          child: Icon(
            Icons.star,
            color: Theme.of(context).colorScheme.primary,
            size: starSize,
          ),
        ),
      ],
    );
  }
}

class _StarClipper extends CustomClipper<Rect> {
  final double fillPercentage;

  _StarClipper(this.fillPercentage);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * fillPercentage, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return true;
  }
}
