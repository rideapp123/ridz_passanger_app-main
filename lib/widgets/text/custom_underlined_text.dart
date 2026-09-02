import 'package:flutter/material.dart';
import '../../../core/theme/styles.dart';

class CustomUnderlinedText extends StatelessWidget {
  const CustomUnderlinedText({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.isButton = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isButton;

  @override
  Widget build(BuildContext context) {
    if (isButton) {
      return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize
              .shrinkWrap, // Reduces the tap area to the size of the child
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: color ??
                    Styles.COLOR_PRIMARY_ORANGE, // Your underline color
                width: 1, // Your underline thickness
              ),
            ),
          ),
          padding: const EdgeInsets.only(bottom: 0.5),
          // Space between text and underline, adjust as needed
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color ?? Styles.COLOR_PRIMARY_ORANGE, // Your text color
            ),
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color:
                  color ?? Styles.COLOR_PRIMARY_ORANGE, // Your underline color
              width: 1, // Your underline thickness
            ),
          ),
        ),
        padding: const EdgeInsets.only(bottom: 0.5),
        // Space between text and underline, adjust as needed
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: color ?? Styles.COLOR_PRIMARY_ORANGE, // Your text color
            // Remove the decoration from here since we're using a border now
          ),
        ),
      );
    }
  }
}
