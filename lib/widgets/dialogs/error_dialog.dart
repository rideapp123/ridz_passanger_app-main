import 'package:flutter/material.dart';

import '../../../core/services/navigation_service.dart';
import '../../../core/theme/styles.dart';
import '../buttons/custom_button.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    super.key,
    this.onRetry,
    this.message,
  });

  final VoidCallback? onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Uh oh!'),
      content: message != null
          ? Text(message!)
          : const Text('Something went wrong, please try again later.'),
      actionsAlignment: onRetry != null
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.center,
      actions: [
        CustomButton(
          text: 'Close',
          color: Styles.COLOR_PRIMARY_ORANGE,
          onTap: () => NavigationService().pop(),
        ),
        if (onRetry != null)
          CustomButton(
            text: 'Retry',
            color: Styles.COLOR_PRIMARY_ORANGE,
            onTap: () => onRetry!(),
          )
      ],
    );
  }
}
