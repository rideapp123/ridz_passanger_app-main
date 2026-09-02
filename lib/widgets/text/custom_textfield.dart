import 'package:flutter/foundation.dart';
import '../../core/exports/common_exports.dart';

// Validator for Email
String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your email';
  }

  // Regular expression for email validation (excluding plus addressing)
  String pattern =
      r"^[a-zA-Z0-9.!#$%&\'*=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\.(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?)+$";
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(value)) {
    return 'Enter a valid email address';
  }

  return null;
}

// Validator for Password (customize as needed)
String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your password';
  }
  // Add your password validation logic here if needed
  else if (value.length < 6) {
    return 'Password should be of atleast 6 characters';
  }
  return null;
}

String maskString(String input) {
  return '*' *
      input
          .length; // Create a string of asterisks with the same length as the input
}

String formattedCardNumber(
    {required String cardNumber, bool isVisibleFourDigit = false}) {
  if (isVisibleFourDigit) {
    // Remove spaces, dots, or any other unwanted characters
    cardNumber = cardNumber.replaceAll(RegExp(r'\s+|\.|●'), '');

    // Mask all except the last 4 digits
    final maskedPart = cardNumber
        .substring(0, cardNumber.length - 4)
        .replaceAll(RegExp(r'.'), '*');

    final last4Digits = cardNumber.substring(cardNumber.length - 4);

    // Combine masked part with the last 4 digits
    final formatted =
        (maskedPart + last4Digits).split('').asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value;
      return (index > 0 && index % 4 == 0) ? ' $value' : value;
    }).join('');
    return formatted;
  } else {
    cardNumber = cardNumber.replaceAll(RegExp(r'\s+|\.|●'), '');

    final formatted = cardNumber
        .split('')
        .map((char) => '●')
        .toList()
        .asMap()
        .entries
        .map((entry) {
      final index = entry.key;
      final value = entry.value;
      return (index > 0 && index % 4 == 0) ? ' $value' : value;
    }).join('');

    return formatted;
  }
}

String? instagramShareValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Paste the link here';
  }

  final List<String> validPaths = ['p', 'tv', 'reel'];
  final Uri parsedUrl = Uri.tryParse(value) ?? Uri.parse('');

  // Check if the URL is valid
  if (!parsedUrl.isAbsolute ||
      !parsedUrl.hasAuthority ||
      parsedUrl.authority != 'instagram.com' &&
          parsedUrl.authority != 'www.instagram.com') {
    return 'Invalid URL';
  }

  if (!validPaths.contains(parsedUrl.pathSegments.first)) {
    return 'Invalid URL';
  }

  return null;
}

String? instagramUserNameValidator(String? username,
    [bool canBeEmpty = false]) {
  if (username == null || username.trim().isEmpty) {
    return canBeEmpty ? null : 'Username cannot be empty.';
  }

  // Regular expression for valid Instagram username
  final usernameRegex = RegExp(r'^([a-zA-Z0-9_]{3,30})$');

  if (!usernameRegex.hasMatch(username)) {
    return 'Username must be 3-30 characters long and can only contain letters, numbers, and underscores.';
  }

  return null; // Username is valid
}

String? phoneNumberValidator(String? phoneNumber) {
  if (phoneNumber == null || phoneNumber.isEmpty) {
    // return null;
    return 'Please enter your phone number';
  }

  // Remove non-digit characters
  String cleanedPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

  // Check if the cleaned number is 10 or 12 digits (without or with international dialing code)
  if (cleanedPhoneNumber.length != 10 && cleanedPhoneNumber.length != 12) {
    return 'Invalid phone number';
  }

  // If the number starts with the international dialing code, remove it
  if (cleanedPhoneNumber.length == 12 && cleanedPhoneNumber.startsWith('91')) {
    cleanedPhoneNumber = cleanedPhoneNumber.substring(2);
  }

  // Check if the remaining number is 10 digits
  if (cleanedPhoneNumber.length != 10) {
    return 'Invalid phone number';
  }

  // Check if the number starts with a valid Indian mobile number prefix
  List<String> validPrefixes = ['9', '8', '7', '6'];
  if (!validPrefixes.contains(cleanedPhoneNumber.substring(0, 1))) {
    return 'Invalid phone number';
  }

  // If all checks pass, consider it a valid Indian phone number
  return null;
}

String? nameValidator(String? name) {
  if (name == null || name.isEmpty) {
    return 'Field cannot be empty';
  }

  // Remove leading and trailing whitespaces
  String trimmedName = name.trim();

  // Check if the name contains only alphabetic characters
  if (!RegExp(r'^[a-zA-Z.]+$').hasMatch(trimmedName)) {
    return 'Name should only contain alphabets';
  }

  return null;
}

String? userNameValidator(String? username) {
  if (username == null || username.isEmpty) {
    return 'Username cannot be empty';
  }

  // Regular expression for valid username
  final usernameRegex = RegExp(r'^([a-zA-Z0-9_]{3,30})$');

  if (!usernameRegex.hasMatch(username)) {
    return 'Username must be 3-30 characters long and can only contain letters, numbers, and underscores.';
  }

  return null; // Username is valid
}

String? reviewValidator(String? review) {
  if (review == null || review.isEmpty) {
    return 'Review cannot be empty';
  }

  if (review.length < 10) {
    return 'Minimum 10 characters are required';
  }

  return null;
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text.replaceAll(' ', '');

    String formattedText = '';
    for (int i = 0; i < newText.length; i++) {
      formattedText += newText[i];
      if ((i + 1) % 4 == 0 && i != newText.length - 1) {
        formattedText += ' ';
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Get the new text
    String text = newValue.text;

    if (text.length < oldValue.text.length) {
      return newValue;
    }

    if (text.length == 2) {
      if (int.tryParse(text.substring(0, 2))! > 12) {
        return oldValue;
      }
      text = '$text/';
    } else if (text.length > 5) {
      return oldValue;
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

TextFormField customTextFormField({
  Key? key,
  String? label,
  required String hintText,
  IconData? prefixIconData,
  Color? prefixIconColor,
  IconData? suffixIconData,
  Widget? suffix,
  String? initialValue,
  int? maxLines,
  int? maxLength,
  Widget? prefix,
  bool removePrefix = false,
  void Function()? onTap,
  bool enabled = true,
  bool readOnly = false,
  EdgeInsetsGeometry? contentPadding,
  void Function()? onSuffixIconTap,
  bool obscureText = false,
  TextEditingController? controller,
  String? Function(String?)? customValidator,
  void Function(String)? onChanged,
  AutovalidateMode? autovalidateMode,
  TextAlign? textAlign,
  Color? suffixIconColor,
  FocusNode? focusNode,
  Color? hintColor,
  TextInputType? textInputType,
  InputBorder? inputBorder,
  double? borderWidth,
  Color? labelColor,
  Color? inputTextColor,
  Color? fillColor,
  Color? focusedBorderColor,
  BuildContext? context,
  bool autoFocus = false,
  List<TextInputFormatter>? inputFormatters,
  EdgeInsets? scrollPadding,
}) {
  final context = NavigationService.navigatorKey.currentContext!;
  return TextFormField(
      // key: key ?? UniqueKey(),
      focusNode: focusNode,
      onChanged: onChanged,
      scrollPadding: scrollPadding ?? const EdgeInsets.all(20),
      autofocus: autoFocus,
      style: TextStyle(
          color: inputTextColor ?? Theme.of(context).colorScheme.tertiary,
          fontSize: 14.0),
      autovalidateMode: autovalidateMode,
      onTap: onTap,
      controller: controller,
      readOnly: readOnly,
      keyboardType: textInputType ?? TextInputType.text,
      cursorColor: Theme.of(context).colorScheme.primary,
      enabled: enabled,
      maxLength: maxLength,
      obscureText: obscureText,
      initialValue: initialValue,
      inputFormatters: inputFormatters,
      maxLines: (maxLines == null) ? 1 : maxLines,
      textAlign: textAlign ?? TextAlign.start,
      onTapOutside: (_) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      decoration: InputDecoration(
        floatingLabelStyle: const TextStyle(
          color: Colors.black,
        ),
        alignLabelWithHint: false,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: prefix,
        suffixIcon: suffix,
        suffixIconColor: suffixIconColor ??
            Theme.of(context).colorScheme.onTertiaryContainer,
        prefixIconColor: prefixIconColor ??
            Theme.of(context).colorScheme.onTertiaryContainer,
        contentPadding:
            contentPadding ?? const EdgeInsets.only(left: 10, right: 10),
        fillColor: fillColor,
        filled: fillColor != null,
        border: inputBorder,
        enabledBorder: OutlineInputBorder(
          borderRadius:
              const BorderRadius.all(Radius.circular(AppRadius.common10)),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onTertiaryContainer,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius:
              const BorderRadius.all(Radius.circular(AppRadius.common10)),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onTertiaryContainer,
          ),
        ),
        focusedBorder: DecoratedInputBorder(
          child: OutlineInputBorder(
            borderSide: BorderSide(
              color: focusedBorderColor ??
                  Theme.of(context).colorScheme.onTertiaryContainer,
              width: borderWidth ?? 2,
            ),
            borderRadius: Styles.textFieldBorderRadius,
          ),
          shadow: const BoxShadow(
            color: Colors.transparent,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: focusedBorderColor ?? Theme.of(context).colorScheme.error,
            width: borderWidth ?? 2,
          ),
          borderRadius: Styles.textFieldBorderRadius,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: Styles.textFieldBorderRadius,
          borderSide: BorderSide(
            color: Colors.red,
            width: borderWidth ?? 2, // Color for focused error border
          ),
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: hintColor ?? Theme.of(context).colorScheme.onTertiaryContainer,
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          color: labelColor ?? Theme.of(context).colorScheme.shadow,
          fontSize: 14,
        ),
        label: label == null
            ? null
            : Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: labelColor ?? Theme.of(context).colorScheme.shadow,
                ),
              ),
      ),
      validator: customValidator
      // ??
      // (value) {
      //   // Use customValidator if provided
      //   if (value == null || value.isEmpty) {
      //     return 'Enter your $hintText';
      //   } else if (value.length < 3) {
      //     return 'Enter valid $hintText';
      //   }
      //   return null;
      // },
      );
}

///use for text field shadow
class DecoratedInputBorder extends InputBorder {
  DecoratedInputBorder({
    required this.child,
    required this.shadow,
  }) : super(borderSide: child.borderSide);

  final InputBorder child;

  final BoxShadow shadow;

  @override
  bool get isOutline => child.isOutline;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      child.getInnerPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      child.getOuterPath(rect, textDirection: textDirection);

  @override
  EdgeInsetsGeometry get dimensions => child.dimensions;

  @override
  InputBorder copyWith(
      {BorderSide? borderSide,
      InputBorder? child,
      BoxShadow? shadow,
      bool? isOutline}) {
    return DecoratedInputBorder(
      child: (child ?? this.child).copyWith(borderSide: borderSide),
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  ShapeBorder scale(double t) {
    final scaledChild = child.scale(t);

    return DecoratedInputBorder(
      child: scaledChild is InputBorder ? scaledChild : child,
      shadow: BoxShadow.lerp(null, shadow, t)!,
    );
  }

  @override
  void paint(Canvas canvas, Rect rect,
      {double? gapStart,
      double gapExtent = 0.0,
      double gapPercentage = 0.0,
      TextDirection? textDirection}) {
    final clipPath = Path()
      ..addRect(const Rect.fromLTWH(-5000, -5000, 10000, 10000))
      ..addPath(getInnerPath(rect), Offset.zero)
      ..fillType = PathFillType.evenOdd;
    canvas.clipPath(clipPath);

    final Paint paint = shadow.toPaint();
    final Rect bounds = rect.shift(shadow.offset).inflate(shadow.spreadRadius);

    canvas.drawPath(getOuterPath(bounds), paint);

    child.paint(canvas, rect,
        gapStart: gapStart,
        gapExtent: gapExtent,
        gapPercentage: gapPercentage,
        textDirection: textDirection);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is DecoratedInputBorder &&
        other.borderSide == borderSide &&
        other.child == child &&
        other.shadow == shadow;
  }

  @override
  int get hashCode => Object.hash(borderSide, child, shadow);

  @override
  String toString() {
    return '${objectRuntimeType(this, 'DecoratedInputBorder')}($borderSide, $shadow, $child)';
  }
}
