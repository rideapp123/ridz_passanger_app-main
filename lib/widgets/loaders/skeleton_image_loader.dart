import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/theme/styles.dart';

class SkeletonImageLoader extends StatelessWidget {
  const SkeletonImageLoader({
    super.key,
    required this.src,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
    this.isUser = false,
    this.loader,
  });

  /// Network URL of the image
  final String? src;

  final BoxFit fit;

  final double? height;

  final double? width;

  final Widget? loader;

  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final loaderWidget = Skeletonizer(
      enabled: true,
      containersColor: Colors.grey.shade300,
      child: Skeleton.shade(
        child: Container(
          height: height,
          width: width,
          color: Colors.grey,
        ),
      ),
    );

    final placeholderWidget = isUser
        ? Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade300,
                width: 0.5,
              ),
            ),
            child: const FittedBox(
              fit: BoxFit.contain,
              child: Icon(
                Icons.person,
                color: Styles.COLOR_PRIMARY_ORANGE,
              ),
            ),
          )
        : CachedNetworkImage(
            imageUrl: '',

            ///Tmp for testing text visibility
            // imageUrl: 'https://picsum.photos/seed/picsum/1000/1000',
            height: height,
            width: width,
            fit: fit,
            filterQuality: FilterQuality.high,
          );

    if (src != null && src != '') {
      return CachedNetworkImage(
        imageUrl: src!,
        cacheKey: src!,
        height: height,
        width: width,
        fit: fit,
        placeholder: (context, url) => loader ?? loaderWidget,
        fadeInDuration: const Duration(milliseconds: 10),
        errorWidget: (context, url, error) => placeholderWidget,
      );
    } else {
      return placeholderWidget;
    }
  }
}
