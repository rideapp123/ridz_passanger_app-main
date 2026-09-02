import 'dart:async';

import 'package:flutter/material.dart';
import '../../widgets/dialogs/email_verification_dialog.dart';
import '../../widgets/dialogs/location_permission_dialog.dart';
import '../../widgets/dialogs/phone_verification_with_phone_dialog.dart';
import 'navigation_service.dart';

abstract class DialogService {
  static BuildContext get context => NavigationService.navigatorKey.currentContext!;

  static Future<void> showEmailVerificationDialog(String email) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return EmailVerificationDialog(email: email);
      },
    );
  }

  static Future<void> showPhoneVerificationWithPhone() {
    return showDialog(
      context: context,
      builder: (context) {
        return const PhoneVerificationWithPhoneDialog();
      },
    );
  }

  static Future<bool> showLocationPermissionDialog(
      {required void Function() onAllowLocationTap,
      required void Function() onNotNowTap}) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return LocationPermissionDialog(
          onAllowLocationTap: onAllowLocationTap,
          onNotNowTap: onNotNowTap,
        );
      },
    );
  }
}
