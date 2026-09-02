import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

abstract class DummySkeletons {
  static Skeletonizer communityTextFeedCard(int index) {
    return const Skeletonizer(
      enabled: true,
      child: SizedBox(),
    );
  }
}
