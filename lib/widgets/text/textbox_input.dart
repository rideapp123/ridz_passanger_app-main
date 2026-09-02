import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../core/theme/styles.dart';

class TextBoxInput extends HookWidget {
  const TextBoxInput({
    super.key,
    required this.onUpdate,
  });

  /// Following callback is called each time the input changes in the inner [TextField].
  ///
  /// Cleanup is handled by [useEffect] automatically and any controllers are diposed
  /// when the widget is dropped from the tree.
  ///
  /// ## Example:
  /// ```dart
  /// TextBoxInput(onUpdate: (message) => uiStoreProvider().setCustomMessage(message),);
  /// ```
  ///
  /// or
  ///
  /// ```dart
  /// TextBoxInput(onUpdate: uiStoreProvider().setCustomMessage);
  /// ```
  final void Function(String value) onUpdate;

  @override
  Widget build(BuildContext context) {
    final controller =
        useTextEditingController.fromValue(TextEditingValue.empty);

    useEffect(() {
      controller.addListener(() {
        onUpdate(controller.text.trim());
      });

      return null;
    }, [controller]);

    return Container(
      height: 150, // Adjust the height as per your requirement
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: Styles.defaultBorderRadius,
      ),
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 8,
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Enter your custom message',
          border: InputBorder.none,
        ),
        maxLines: null, // Allow multiple lines of text
      ),
    );
  }
}
