import 'package:flutter/material.dart';
import 'package:ridzs_passenger_app/core/constants/assets.dart';
import 'package:ridzs_passenger_app/core/theme/app_text_styles.dart';
import 'package:ridzs_passenger_app/widgets/buttons/custom_button.dart';

import '../containers/custom_image_view.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: Theme.of(context).colorScheme.primary, width: 1.5)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomImageView(
            imagePath: Assets.icSedEmoji,
            height: 70,
            width: 70,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.title
                .copyWith(color: Theme.of(context).colorScheme.tertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.subtitle2
                .copyWith(color: Theme.of(context).colorScheme.tertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            onTap: onPressed,
            borderRadius: 12,
            width: 100,
            text: buttonText,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
          ),
          // ElevatedButton(
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.purple, // Button color
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(20),
          //     ),
          //     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
          //   ),
          //   onPressed: onPressed,
          //   child: Text(buttonText),
          // ),
        ],
      ),
    );
  }
}

// Function to show the custom dialog
void showCustomDialog(
    {required BuildContext context,
    required String title,
    required String message}) {
  showDialog(
    context: context,
    builder: (context) {
      return CustomDialog(
        title: title,
        message: message,
        buttonText: 'Retry',
        onPressed: () {
          Navigator.of(context).pop(); // Close the dialog
          // Add your retry logic here
        },
      );
    },
  );
}

// Usage Example
// You can call the showCustomDialog function in response to an event:
// showCustomDialog(context);
