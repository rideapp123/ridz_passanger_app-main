import 'package:geolocator/geolocator.dart';
// import '../../stores/ui/ui_store.dart';
import 'dialog_service.dart';
import 'navigation_service.dart';

abstract class PermissionService {
  static Future<bool>? showPermissionDialogIfNotGiven(
      {bool showDialogAgain = false}) async {
    if (await isLocationPermissionGiven() && await isGPSEnabled()) {
      return true;
    } else {
      // if (uiStoreProvider().isLocationPermissionGiven == false &&
      //     !showDialogAgain) {
      //   return false;
      // }

      return await showPermissionDialog();
    }
  }

  static Future<bool> isLocationPermissionPermanentlyDenied() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    return permission == LocationPermission.deniedForever;
  }

  static Future<bool> isLocationPermissionGiven() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }

  static Future<bool> isGPSEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static showPermissionDialog() async {
    return await DialogService.showLocationPermissionDialog(
      onAllowLocationTap: () async {
        if (!await isLocationPermissionGiven()) {
          await Geolocator.requestPermission();
        }

        if (!await isGPSEnabled()) {
          await Geolocator.openLocationSettings();
        }

        if (await isLocationPermissionGiven() && await isGPSEnabled()) {
          NavigationService().pop(true);
        } else {
          if (!await isLocationPermissionGiven()) {
            await Geolocator.openAppSettings();
          }
        }
      },
      onNotNowTap: () async {
        // uiStoreProvider().isLocationPermissionGiven = false;
        NavigationService().pop(false);
      },
    );
  }
}
