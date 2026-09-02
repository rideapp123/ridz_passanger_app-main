import 'package:flutter/cupertino.dart';
import 'package:geocode/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_launcher/map_launcher.dart';

import 'permission_service.dart';
import 'toast_service.dart';

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> geoLocator() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

double distanceBetweenMeAndPosition(
    double lat1, double lng1, double lat2, double lng2) {
  return (Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000)
      .abs();
}

Future<String?> getMyAddress() async {
  final isEnabled = await PermissionService.showPermissionDialogIfNotGiven();
  if (isEnabled == false) {
    return null;
  }
  var myPosition = await geoLocator();
  GeoCode geoCode = GeoCode();
  try {
    Address address = await geoCode.reverseGeocoding(
        latitude: myPosition.latitude, longitude: myPosition.longitude);

    if (address.streetAddress != null &&
        address.streetAddress!.startsWith('Throttled')) {
      return null;
    }
    return '${address.streetAddress}, ${address.city}, ${address.countryName}, ${address.postal}';
  } catch (err) {
    return null;
  }
}

Future<void> launchMap(double lat1, double lng1, String title) async {
  var googleMapAvailable =
      await MapLauncher.isMapAvailable(MapType.google) ?? false;
  var appleMapAvailable =
      await MapLauncher.isMapAvailable(MapType.apple) ?? false;

  var avail = googleMapAvailable || appleMapAvailable;

  debugPrint('Google Map Available: $googleMapAvailable');
  debugPrint('Apple Map Available: $appleMapAvailable');

  if (avail) {
    await MapLauncher.showMarker(
      mapType: googleMapAvailable ? MapType.google : MapType.apple,
      coords: Coords(lat1, lng1),
      title: title,
    );
  } else {
    ToastService.show('Could not open the map.');
  }
  // var appleUrl = Uri.parse(
  //     'https://maps.apple.com/?saddr=$lat1,$lng1&daddr=$lat2,$lng2&directionsmode=driving');
  // var googleUrl =
  //     Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat2,$lat2');

  // if (Platform.isIOS) {
  //   if (await canLaunchUrl(appleUrl)) {
  //     await launchUrl(appleUrl);
  //   } else {
  //     if (await canLaunchUrl(googleUrl)) {
  //       await launchUrl(googleUrl);
  //     } else {
  //       ToastService.show("Could not open the map.");
  //     }
  //   }
  // } else {
  //   if (await canLaunchUrl(googleUrl)) {
  //     await launchUrl(googleUrl);
  //   } else {
  //     ToastService.show("Could not open the map.");
  //   }
  // }
}
