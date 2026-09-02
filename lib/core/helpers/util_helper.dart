import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import 'package:url_launcher/url_launcher.dart';

import '../enums/value_type.dart';

abstract class JsonConvertible<T> {
  T fromJson(Map<String, dynamic> json);
}

abstract class UtilsHelper {
  /// Returns a formatted string with price and appropriate currency label.
  static String convertPriceToCurrency(int price, [String? currency]) {
    return '₹$price';
  }

  // static String subscriptionTypeToString(SubscriptionTypeEnum? type) {
  //   if (type == null) {
  //     return '';
  //   }
  //
  //   return switch (type) {
  //     SubscriptionTypeEnum.monthly => 'month',
  //     SubscriptionTypeEnum.yearly => 'year',
  //     SubscriptionTypeEnum.half_yearly => 'half year',
  //   };
  // }

  static Color hexToColor(String hexString) {
    hexString = hexString.toUpperCase().replaceAll('#', '');
    if (hexString.length == 6) {
      hexString = 'FF$hexString'; // Add alpha for 6-digit hex
    }
    final int intValue = int.parse(hexString, radix: 16);
    return Color(intValue);
  }

  static String formatHHMMTime(DateTime dateTime) {
    // Create a DateFormat object with the desired format
    final DateFormat format = DateFormat('hh:mm a');
    // Use the format method to convert the DateTime object to a string
    return format.format(dateTime.toLocal());
  }

  static String formatUtcDate(DateTime? utcDate) {
    // Format the date in the desired format (US English locale)
    if (utcDate == null) {
      return '';
    }

    final formatter = DateFormat('MMMM d, y', 'en_US');

    // Convert UTC date to local date (assuming you want to display in local time)
    final localDate = utcDate.toLocal();

    // Format the local date and return the string
    return formatter.format(localDate);
  }

  static Map<String, dynamic> mergeObjects(
      Map<String, dynamic> obj1, Map<String, dynamic> obj2) {
    // Create a new instance of the same type as obj1
    Map<String, dynamic> mergedObject = {};
    // Get the list of keys from both objects
    Set<dynamic> keys = {...obj1.keys, ...obj2.keys};

    // Iterate through each key and merge the values
    for (final key in keys) {
      dynamic value1 = obj1[key];
      dynamic value2 = obj2[key];

      // Check if both objects have values for the key
      if (value1 != null && value2 != null) {
        mergedObject[key] = value2;
      }
      // If only obj1 has a value for the key, use it
      else if (value1 != null) {
        mergedObject[key] = value1;
      }
      // If only obj2 has a value for the key, use it
      else if (value2 != null) {
        mergedObject[key] = value2;
      }
    }

    return mergedObject;
  }

  static String formatCurrency(dynamic number, {bool includeSymbol = false}) {
    number ??= 0;

    final formatCurrency = NumberFormat.compactCurrency(
      decimalDigits: 0,
      symbol: includeSymbol ? '₹' : '',
      locale: Intl.defaultLocale,
    );
    return formatCurrency.format(number);
  }

  static String removePlus91(String? mobileNumber) {
    if (mobileNumber == null) {
      return '';
    }

    // Check if the mobile number starts with +91
    if (mobileNumber.startsWith('+91')) {
      // Remove the +91 prefix
      return mobileNumber.substring(3);
    }

    // Return the mobile number as it is
    return mobileNumber;
  }

  ///2019-05-01 output
  static String formatDate(
      {required int day, required int month, required int year}) {
    // Ensure leading zeros for single-digit values
    String formattedDay = day.toString().padLeft(2, '0');
    String formattedMonth = month.toString().padLeft(2, '0');

    // Return the formatted date string
    return '$year-$formattedMonth-$formattedDay';
  }

  // static Future<void> shareImage(
  //     {required String? url, required String text}) async {
  //   if (url != null) {
  //     final cache = DefaultCacheManager(); // Gives a Singleton instance
  //     final localCachedFile = await cache.getSingleFile(url);
  //     await Share.shareXFiles(
  //       [XFile(localCachedFile.path)],
  //       text: text,
  //     );
  //   } else {
  //     await Share.share(text);
  //   }
  //   // cache.dispose();
  // }

  static Future<void> openURLinBrowser(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  //tmp
  static bool isValidUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  static bool isOutletOpenToday(List<String> openDays) {
    // Get the current day of the week as a string
    String today = DateFormat('EEE').format(DateTime.now()).toLowerCase();

    // Truncate any element in openDays to three characters if it's longer
    List<String> truncatedOpenDays = openDays.map((day) {
      return day.length > 3
          ? day.substring(0, 3).toLowerCase()
          : day.toLowerCase();
    }).toList();

    // Check if today is in the list of open days
    return truncatedOpenDays.contains(today);
  }

  static String getGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour < 4) {
      return 'Hello';
    } else if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else if (hour < 20) {
      return 'Good evening';
    } else {
      return 'Hello';
    }
  }

  static String getRandomString(int minLength, int maxLength) {
    final random = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final length = minLength + random.nextInt(maxLength - minLength + 1);
    return String.fromCharCodes(
      List.generate(
        length,
        (_) => chars.codeUnitAt(
          random.nextInt(chars.length),
        ),
      ),
    );
  }

  // Formats a number into a human-readable format (e.g., 1,000 to 1K, 1,000,000 to 1M)
  static String formatToReadable(int number) {
    if (number >= 1000000000000) {
      return '${(number / 1000000000000).toStringAsFixed(1)}T';
    } else if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  /// Use to change current focus
  static void changeFocus(
      {FocusNode? currentFocusNode, FocusNode? nexFocusNode}) {
    if (currentFocusNode?.hasFocus == true) {
      currentFocusNode?.unfocus();
      nexFocusNode?.requestFocus();
    } else {
      nexFocusNode?.requestFocus();
    }
  }

  static double calculateFinalAmount(
      String amountStr, double discountAmount, ValueType? discountType) {
    double amount = double.tryParse(amountStr) ?? 0.0;
    switch (discountType) {
      case ValueType.percentage:
        return amount - (amount * discountAmount / 100);
      case ValueType.absolute:
        return amount - discountAmount;
      default:
        return amount;
    }
  }
}
