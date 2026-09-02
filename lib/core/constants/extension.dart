import 'package:flutter/material.dart';

extension AddSpacing on List<Widget> {
  List<Widget> addVSpacing(double spacing) {
    List<Widget> a = [];

    for (final widget in this) {
      a.add(widget);
      a.add(SizedBox(
        height: spacing,
      ));
    }

    return a;
  }

  List<Widget> addVWidget(Widget widget) {
    List<Widget> a = [];

    for (int i = 0; i < length; i++) {
      a.add(this[i]);

      if (i != length - 1) {
        a.add(widget);
      }
    }
    return a;
  }

  //
  List<Widget> addHSpacing(double spacing) {
    List<Widget> a = [];

    for (int i = 0; i < length; i++) {
      a.add(this[i]);

      if (i != length - 1) {
        a.add(SizedBox(
          width: spacing,
        ));
      }
    }

    return a;
  }

  List<Widget> addHWidget(Widget widget) {
    List<Widget> a = [];

    for (int i = 0; i < length; i++) {
      a.add(this[i]);

      if (i != length - 1) {
        a.add(widget);
      }
    }

    return a;
  }
}



extension AppItemInPopup<T> on List<PopupMenuEntry<T>> {
 
  List<PopupMenuEntry<T>> addVWidget(PopupMenuEntry<T> widget) {
    List<PopupMenuEntry<T>> a = [];

    for (int i = 0; i < length; i++) {
      a.add(this[i]);

      if (i != length - 1) {
        a.add(widget);
      }
    }
    return a;
  }

  
  
}
