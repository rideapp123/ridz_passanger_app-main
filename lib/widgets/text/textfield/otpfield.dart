import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:ridzs_passenger_app/core/theme/app_text_styles.dart';
import '../../../../core/theme/styles.dart';

class OTPField extends StatelessWidget {
  const OTPField({
    super.key,
    required this.controller,
    required this.onCompleted,
    this.keyboardType,
  });

  final TextEditingController controller;
  final VoidCallback onCompleted;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 65,
      height: 56,
      textStyle: AppTextStyles.title.copyWith(color: Theme.of(context).colorScheme.tertiary),
      decoration: BoxDecoration(
        border: Border.all(color: Styles.COLOR_CARD_GREY_93),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(
        color: Styles.COLOR_CARD_GREY_93,
      ),
      borderRadius: BorderRadius.circular(8),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: Styles.COLOR_ERROR_RED),
      ),
    );

    return Pinput(
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      errorPinTheme: errorPinTheme,
      length: 4,
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.number,
      onCompleted: (pin) {
        onCompleted();
      },
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      showCursor: true,
    );
  }
}