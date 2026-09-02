import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

abstract class DateTimeUtil {
  static const monthsArray = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static DateTime today() {
    return DateTime.now();
  }

  static DateTime tomorrow() {
    return DateTime.now().add(const Duration(days: 1));
  }

  static List<String> generateTimeList(String startTimeStr, String endTimeStr,
      [bool isToday = false]) {
    List<String> timeList = [];

    // The first item will always contain the hours and the second one is minutes.
    final start = startTimeStr.split(':').map(int.parse).toList();
    final end = endTimeStr.split(':').map(int.parse).toList();
    final suffix = (start.last < 10 ? '0${start.last}' : start.last).toString();

    // Calculate end hour by considering the transition to the next day if needed.
    var endHour = end.first;
    if (endHour <= start.first) {
      endHour += 24;
    }

    DateTime now = DateTime.now();
    int currentHour = now.hour;
    int currentMinute = now.minute;

    for (var i = start.first; i < endHour; i++) {
      final hour = i % 24;
      if (hour == 0) {
        break; // Stop at 00:00
      }

      if (isToday &&
          (hour < currentHour ||
              (hour == currentHour && int.parse(suffix) <= currentMinute))) {
        continue; // Skip times before the current time
      }

      final timeSlot = "${hour < 10 ? "0$hour" : hour}:$suffix";
      timeList.add(timeSlot);
    }
    return timeList;
  }

  static bool isPastTime(String bookingDate, int hour) {
    final today = DateTime.now();
    final format = formatDateInYMD(today);

    if (bookingDate == format) {
      final currentHour = today.hour.toString().padLeft(2, '0');

      return int.parse(currentHour) >= hour;
    }

    return false;
  }

  static bool isTomorrowsDate({
    required String date,
    required String endDate,
  }) {
    final tmpDate = int.parse(date.split(':')[0]);
    final tmpEndDate = int.parse(endDate.split(':')[0]);

    return tmpDate >= 0 && tmpDate <= tmpEndDate;
  }

  static Future<DateTime?> datePicker(
    BuildContext context, {
    DateTime? initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      // Opens the calendar with today's date selected
      firstDate: firstDate,
      // Allows dates from today
      lastDate: lastDate,
      // Allows dates up to a year from today
      builder: (BuildContext context, Widget? child) {
        return child!;
      },
    );
  }

  static String formatDayWithSuffix(int day) {
    if (!(day >= 1 && day <= 31)) {
      throw Exception('Invalid day of the month');
    }
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  static String formatDateInYMD(DateTime date) {
    final year = date.year;

    final month = date.month
        .toString()
        .padLeft(2, '0'); // Leading zero for single-digit months

    final day = date.day
        .toString()
        .padLeft(2, '0'); // Leading zero for single-digit days

    // Create and return the formatted string
    return '$year-$month-$day';
  }

  static String getNextDayInYMD(DateTime date) {
    // Add one day to the given date
    final nextDay = date.add(const Duration(days: 1));

    // Extract the year, month, and day, and format them with leading zeros if necessary
    final year = nextDay.year;
    final month = nextDay.month
        .toString()
        .padLeft(2, '0'); // Leading zero for single-digit months
    final day = nextDay.day
        .toString()
        .padLeft(2, '0'); // Leading zero for single-digit days

    // Create and return the formatted string
    return '$year-$month-$day';
  }

  static String formatDateInDMM(DateTime date) {
    final day = date.day;
    final month = getMonthNameFromDate(date).substring(0, 3);

    return '$day $month';
  }

  static String formatDateInDMMYY(DateTime date) {
    final day = date.day;
    final month = getMonthNameFromDate(date).substring(0, 3);
    final year = date.year;

    return '$day $month $year';
  }

  static String getMonthNameFromDate(DateTime date) {
    return monthsArray.elementAt(date.month - 1);
  }

  static String getCheckoutTimeFromCheckin(String label) {
    var time = label.split(':');
    var preNum = time.first;
    var prefix = int.parse(preNum) + 1;
    return "${prefix < 10 ? '0${prefix.toString()}' : prefix}:${time.last}";
  }

  static String getFuzzyMonthStampFromDate(DateTime date) {
    DateTime currentDate = DateTime.now();
    Duration difference = currentDate.difference(date);

    if (difference.inDays >= 1) {
      return '${difference.inDays}d';
    } else {
      int hours = difference.inHours;
      if (hours > 0) {
        return '${hours}h';
      } else {
        return 'Just now';
      }
    }
  }

  static int? convertTo12HrsNotation(String? time) {
    if (time == null) {
      return null;
    }

    // get hours
    final hours = time.split(':').map(int.parse).first;

    /// Edge case if the time is less than 1PM for example 11AM or 10AM
    /// It makes no sense in subtracting 12 from it since it'll just return a negative
    /// value.
    ///
    /// For example:
    ///
    /// In the case of 11AM.
    /// 11 - 12 used to be returned as 1, Which is definitely not correct.
    ///
    /// hence add a check whether we are past 12PM currently and only then convert
    /// to 12hrs notation.
    if (hours < 13) {
      return hours;
    }

    return (hours - 12).abs();
  }

  static String getMeridiemFromTime(String? time) {
    if (time == null) {
      return '';
    }

    // get hours
    final hours = time.split(':').map(int.parse).first;

    if (hours >= 12) {
      return 'PM';
    }

    return 'AM';
  }

  /// Converts 2024-05-12 to 12 May
  ///
  /// Input date string must be in the following format: YYYY-MM-DD
  static String convertStringDateToDMM(String date) {
    final p = date.split('-').map(int.parse);
    final d = DateTime(p.first, p.elementAt(1), p.last);

    return formatDateInDMM(d);
  }

  static DateTime? convertStringToDateTime(String? date) {
    if (date == null || date.isEmpty) {
      return null;
    }

    final p = date.split('-').map(int.parse);

    return DateTime(
      p.first,
      p.elementAt(1),
      p.last,
    );
  }

  // static DateTime? getSubscriptionValidityFromDateTime(
  //     DateTime? date, SubscriptionTypeEnum subscriptionType) {
  //   if (date == null) {
  //     return null;
  //   }
  //
  //   return switch (subscriptionType) {
  //     SubscriptionTypeEnum.monthly =>
  //       DateTime(date.year, date.month + 1, date.day),
  //     SubscriptionTypeEnum.half_yearly =>
  //       DateTime(date.year, date.month + 6, date.day),
  //     SubscriptionTypeEnum.yearly =>
  //       DateTime(date.year + 1, date.month, date.day),
  //   };
  // }
  //
  // static DateTime? getRequestValidityFromDateTime(
  //     DateTime date, ValidityTypeEnum? validityType, int? validity) {
  //   if (validityType == null || validity == null) {
  //     return null;
  //   }
  //
  //   return switch (validityType) {
  //     ValidityTypeEnum.hour =>
  //       DateTime(date.year, date.month, date.day, date.hour + validity),
  //     ValidityTypeEnum.day =>
  //       DateTime(date.year, date.month, date.day + validity),
  //     ValidityTypeEnum.week =>
  //       DateTime(date.year, date.month, date.day + (6 * validity)),
  //   };
  // }

  static String getVisitDateLabel(DateTime date) {
    DateTime now = DateTime.now();
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
    DateTime itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == DateTime(now.year, now.month, now.day)) {
      return 'Today, ${getFormattedDate(date)}';
    } else if (itemDate == yesterday) {
      return 'Yesterday, ${getFormattedDate(date)}';
    } else {
      return '${getFormattedDate(date)}, ${date.year}';
    }
  }

  static String getFormattedDate(DateTime date) {
    String day = date.day.toString();
    String month = monthsArray[date.month - 1].substring(0, 3);
    return '$day $month';
  }

  static String convertTo12HourFormat(String startTime, String endTime) {
    // Parse 24-hour format time strings to DateTime objects
    DateFormat dateFormat = DateFormat('HH:mm');
    DateTime startDt = dateFormat.parse(startTime);
    DateTime endDt = dateFormat.parse(endTime);

    // Format DateTime objects to 12-hour format
    DateFormat twelveHourFormat = DateFormat('hh:mm a');
    String start12Hour = twelveHourFormat.format(startDt);
    String end12Hour = twelveHourFormat.format(endDt);

    // Check if endTime is less than startTime
    String nextDay = '';
    if (endDt.isBefore(startDt)) {
      nextDay = '\u207A\u00B9';
    }

    // Create the final string
    String result = '$start12Hour - $end12Hour$nextDay';

    return result;
  }

  static String convert24To12(String time24) {
    try {
      final DateFormat inputFormat = DateFormat('HH:mm');
      final DateFormat outputFormat = DateFormat('hh:mm a');

      final DateTime dateTime = inputFormat.parse(time24);
      final String time12 = outputFormat.format(dateTime);

      return time12;
    } catch (e) {
      return 'Error';
    }
  }
}
