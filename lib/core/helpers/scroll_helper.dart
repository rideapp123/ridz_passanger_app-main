import 'package:flutter/material.dart';

import '../services/toast_service.dart';

abstract class ScrollHelper {
  /// A reusable helper function for pagination
  static void paginate(
      ScrollController controller, bool shouldPaginate, VoidCallback fetch,
      [bool showToast = true]) {
    // Check if the controller has attached to a scrollable widget
    if (!controller.hasClients) {
      return;
    }

    final currentPosition = controller.offset;
    final maxExtent = controller.position.maxScrollExtent;

    // // 90% of the scroll view will be the trigger point for us to fetch
    // // the next batch of items.
    // final triggerDelta = maxExtent * 0.9;

    // Define a small threshold to avoid precision issues
    const double threshold = 20.0;

    // Check if the current position is within the threshold of the trigger point
    if ((maxExtent - currentPosition) <= threshold && shouldPaginate) {
      fetch();
    } else if (currentPosition == maxExtent && !shouldPaginate) {
      if (showToast) {
        ToastService.show("You're all caught up!");
      }
    }
  }
}
