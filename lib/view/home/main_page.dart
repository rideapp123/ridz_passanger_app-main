import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/models/ride/get_ride_response.dart';
import 'package:ridzs_passenger_app/stores/map/map_store.dart';
import 'package:ridzs_passenger_app/view/home/widget/destination_arrived_bottom_sheet.dart';
import 'package:ridzs_passenger_app/view/home/widget/ride_arriving_bottom_sheet.dart';
import 'package:ridzs_passenger_app/view/home/widget/ride_started_widget.dart';
import 'package:ridzs_passenger_app/widgets/dialogs/app_dialog.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/enums/ride.dart';
import '../../models/common/ride_response/ride_response.dart';
import '../../widgets/buttons/swipe_button.dart';
import '../../widgets/overlays/radius_circles_overlay.dart';
import 'widget/ride_waiting_bottom_sheet.dart';

class MainPage extends HookWidget {
  const MainPage({super.key});

  static const String routeNamed = 'MainPage';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final mapStore = mapStoreProvider();
    final userStore = userStoreProvider();
    final mapStyleString = useState('');
    final appLifeCycleState = useAppLifecycleState();

    final themeColor = Theme.of(context).colorScheme;
    final currentLocationController = useTextEditingController();
    final designationController = useTextEditingController();
    final mainScfKey = useMemoized(() => GlobalKey<ScaffoldState>());

    // Handle text controllers
    useEffect(() {
      currentLocationController.text = mapStore.currentLocationController.text;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        mapStore.getCurrentRide();
        userStore.getMeMainPage();
        userStore.getCard();
        userStore.updateFCMToken();
        mapStore.getAllRide();
        rootBundle
            .loadString((userStore.themeMode == ThemeMode.dark ||
                        userStore.themeMode == ThemeMode.system) &&
                    isDarkMode
                ? 'assets/map_style/map_style_dark.json'
                : 'assets/map_style/map_style.json')
            .then((string) {
          mapStyleString.value = string;
        });
      });
      return null;
    }, [mapStore.currentLocationController.text]);

    useEffect(() {
      designationController.text = mapStore.designationController.text;
      return null;
    }, [mapStore.designationController.text]);

    useEffect(() {
      if (appLifeCycleState == AppLifecycleState.resumed) {
        rootBundle
            .loadString((userStore.themeMode == ThemeMode.dark ||
                        userStore.themeMode == ThemeMode.system) &&
                    isDarkMode
                ? 'assets/map_style/map_style_dark.json'
                : 'assets/map_style/map_style.json')
            .then((string) {
          mapStyleString.value = string;
        });
      }
      return;
    }, [appLifeCycleState]);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: mainScfKey,
      drawer: SizedBox(
        width: SizeConfig.screenWidth * 0.75,
        child: const NavigationDrawerMain(),
      ),
      backgroundColor: themeColor.secondary,
      body: CustomUpgradeAlert(
        shouldPopScope: () => AppConfig.allFlavor != AppFlavor.production,
        upgrader: CustomUpgrader(debugDisplayAlways: false),
        child: Observer(
          builder: (context) {
            return Stack(
              children: [
                // Google Map
                MapWidget(
                  mapStore: mapStore,
                  mapStyleString: mapStyleString.value,
                ),

                // Ride creation overlay
                if (mapStoreProvider().isCreatingRide)
                  RideCreationOverlay(
                    isRideCancelling: mapStoreProvider().isCancellingRide,
                  ),

                //
                if (!mapStoreProvider().isCreatingRide &&
                    !mapStoreProvider().isRideAccepted) ...[
                  MenuButton(
                    scaffoldKey: mainScfKey,
                    themeColor: themeColor,
                  ),
                  BottomSectionWidget(
                    currentLocationController: currentLocationController,
                    designationController: designationController,
                  ),
                ],

                // Ride status section
                if (mapStoreProvider().isRideAccepted &&
                    mapStoreProvider().currentRide != null)
                  RideStatusSection(
                    currentRide: mapStoreProvider().currentRide!,
                  ),

                // const RideArrivingBottomSheet(),
              ],
            );
          },
        ),
      ),
    );
  }

  // Future<void> _initializeMapMarkers() async {
  //   try {
  //     if (mapStoreProvider().nearbyDrivers.isNotEmpty) {
  //       // await _addDriverMarkers();
  //     }
  //   } catch (e) {
  //     debugPrint('Error initializing map markers: $e');
  //   }
  // }

  // Future<void> _addDriverMarkers() async {
  //   try {
  //     final drivers = mapStoreProvider().nearbyDrivers;

  //     final mapController = mapStoreProvider().mapController.value;
  //     // Add or update markers
  //     for (var entry in drivers.entries) {
  //       final driverId = entry.key;
  //       final driver = entry.value;
  //       final newPosition = GeoPoint(
  //         latitude: driver.position.latitude,
  //         longitude: driver.position.longitude,
  //       );

  //       if (mapStoreProvider().markerMap.containsKey(driverId)) {
  //         try {
  //           await mapController.changeLocationMarker(
  //             oldLocation: mapStoreProvider().markerMap[driverId]!,
  //             newLocation: newPosition,
  //           );
  //         } catch (e) {
  //           // If changing location fails, try removing and re-adding the marker
  //           await mapController
  //               .removeMarker(mapStoreProvider().markerMap[driverId]!);
  //           await mapController.addMarker(
  //             newPosition,
  //             markerIcon: const MarkerIcon(
  //               icon: Icon(
  //                 Icons.local_taxi,
  //                 color: Colors.orange,
  //                 size: 48,
  //               ),
  //             ),
  //           );
  //         }
  //       } else {
  //         await mapController.addMarker(
  //           newPosition,
  //           markerIcon: const MarkerIcon(
  //             icon: Icon(
  //               Icons.local_taxi,
  //               color: Colors.orange,
  //               size: 48,
  //             ),
  //           ),
  //         );
  //       }

  //       final newMap = Map<String, GeoPoint>.from(mapStoreProvider().markerMap);
  //       newMap[driverId] = newPosition;
  //       mapStoreProvider().markerMap = newMap;
  //     }

  //     // Remove old markers
  //     final toRemove = mapStoreProvider()
  //         .markerMap
  //         .keys
  //         .where((id) => !drivers.containsKey(id))
  //         .toList();
  //     for (var id in toRemove) {
  //       try {
  //         await mapController.removeMarker(mapStoreProvider().markerMap[id]!);
  //         final newMap =
  //             Map<String, GeoPoint>.from(mapStoreProvider().markerMap);
  //         newMap.remove(id);
  //         mapStoreProvider().markerMap = newMap;
  //       } catch (e) {
  //         debugPrint('Error removing marker $id: $e');
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('Error handling markers: $e');
  //   }
  // }

  // Future<void> _updateMapLocation() async {
  //   final currentLocation = await Geolocator.getCurrentPosition();
  //   await mapStoreProvider().mapController.value.moveTo(
  //         GeoPoint(
  //           latitude: currentLocation.latitude,
  //           longitude: currentLocation.longitude,
  //         ),
  //         animate: true,
  //       );
  // }

  // Widget _buildTextButtonContent(BuildContext context, String text) {
  //   return Center(
  //     child: Row(
  //       children: [
  //         CustomImageView(
  //           imagePath: Assets.icRefresh,
  //           height: 18,
  //           width: 18,
  //           color: Theme.of(context).colorScheme.surfaceContainerLowest,
  //         ),
  //         const SizedBox(width: 10),
  //         Text(
  //           text,
  //           style: AppTextStyles.style12W600.copyWith(
  //             color: Theme.of(context).colorScheme.surfaceContainerLowest,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

// Menu Button Widget
class MenuButton extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final ColorScheme themeColor;

  const MenuButton({
    super.key,
    required this.scaffoldKey,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 14,
      top: 50,
      child: GestureDetector(
        onTap: () => scaffoldKey.currentState?.openDrawer(),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withValues(
                  alpha: 0.6,
                ),
            borderRadius: BorderRadius.circular(12),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withValues(alpha: 0.4),
            //     blurRadius: 8,
            //     offset: const Offset(0, 2),
            //   ),
            // ],
          ),
          child: Icon(
            Icons.menu,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
      ),
    );
  }
}

// Bottom Section Widget
class BottomSectionWidget extends StatelessWidget {
  final TextEditingController currentLocationController;
  final TextEditingController designationController;

  const BottomSectionWidget({
    super.key,
    required this.currentLocationController,
    required this.designationController,
  });

  @override
  Widget build(BuildContext context) {
    final mapStore = mapStoreProvider();

    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CurrentLocationButton(),
          const SafetyTripBannerWidget(),
          DestinationSearchWidget(mapStore: mapStore),
        ],
      ),
    );
  }
}

// Current Location Button Widget
class CurrentLocationButton extends StatelessWidget {
  const CurrentLocationButton({super.key});

  @override
  Widget build(BuildContext context) {
    final mapStore = mapStoreProvider();

    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () async {
          await mapStore.moveToCurrentLocation();
        },
        child: Container(
          height: 32,
          width: 32,
          alignment: Alignment.center,
          margin: EdgeInsets.only(
            right: SizeConfig.screenWidth * 0.04,
            bottom: SizeConfig.screenHeight * 0.02,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SvgPicture.asset(
            Assets.gpsOutlinedIc,
            height: 20,
            width: 20,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.surface,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

// Destination Search Widget
class DestinationSearchWidget extends StatelessWidget {
  final MapStore mapStore;

  const DestinationSearchWidget({
    super.key,
    required this.mapStore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: SizeConfig.screenHeight * 0.02,
        horizontal: SizeConfig.screenWidth * .04,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: SizeConfig.screenWidth * .04,
        vertical: SizeConfig.screenHeight * 0.01,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: SizeConfig.screenHeight * 0.02),
          Text(
            'Where are you going today?',
            style: AppTextStyles.style18W500.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.02),
          const SearchDestinationField(),
          SizedBox(height: SizeConfig.screenHeight * 0.02),
          RecentTripsSection(mapStore: mapStore),
        ],
      ),
    );
  }
}

// Search Destination Field Widget
class SearchDestinationField extends StatelessWidget {
  const SearchDestinationField({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showRideBottomSheet(),
      child: Container(
        height: 56,
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.screenWidth * 0.04,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryFixed,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              Assets.searchIc,
              height: 16,
              width: 16,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.surface,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: SizeConfig.screenWidth * 0.02),
            Text(
              'Search destinations',
              style: AppTextStyles.caption.copyWith(
                color: const Color(0xff9A9CA0),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Recent Trips Section Widget
class RecentTripsSection extends StatelessWidget {
  final MapStore mapStore;

  const RecentTripsSection({
    super.key,
    required this.mapStore,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      if (!mapStore.isRideHistoryLoading && mapStore.rideHistory.isEmpty) {
        return const SizedBox();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Trips',
            style: AppTextStyles.caption.copyWith(
              color: Theme.of(context).colorScheme.surface.withValues(
                    alpha: 0.76,
                  ),
              fontSize: 14,
            ),
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.01),
          Skeletonizer(
            enabled: mapStore.isRideHistoryLoading,
            containersColor: Theme.of(context).colorScheme.surfaceContainerHigh,
            effect: ShimmerEffect(
              baseColor: Theme.of(context).colorScheme.tertiaryFixed,
            ),
            child: ListView.builder(
              itemCount: mapStore.rideHistory.take(2).length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final ride = mapStore.rideHistory[index];
                return RecentTripItem(ride: ride);
              },
            ),
          ),
        ],
      );
    });
  }
}

// Recent Trip Item Widget
class RecentTripItem extends StatelessWidget {
  final Ride ride;

  const RecentTripItem({
    super.key,
    required this.ride,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showRideBottomSheet(ride: ride);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            SvgPicture.asset(
              Assets.locationIc,
              height: 24,
              width: 24,
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ride.destination.address,
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context).colorScheme.surface.withValues(
                            alpha: 0.76,
                          ),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    ride.pickup.address,
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context).colorScheme.surface.withValues(
                            alpha: 0.4,
                          ),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SafetyTripBannerWidget extends StatelessWidget {
  const SafetyTripBannerWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: SizeConfig.screenHeight * 0.02,
        horizontal: SizeConfig.screenWidth * .04,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: SizeConfig.screenWidth * .04,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          //
          SvgPicture.asset(
            Assets.safetyIcon,
            height: 32,
            width: 32,
          ),

          SizedBox(width: SizeConfig.screenWidth * 0.03),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Make your trip safety first',
                  style: AppTextStyles.subtitle2.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  'Ensuring your safety every step of the way',
                  style: AppTextStyles.style10W400.copyWith(
                    color: const Color(0xff94A3B8),
                  ),
                ),
              ],
            ),
          ),

          SvgPicture.asset(
            Assets.forwardArrowIcon,
            height: 24,
            width: 24,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.surface,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
}

// Ride Creation Overlay Widget
class RideCreationOverlay extends StatelessWidget {
  final bool isRideCancelling;
  const RideCreationOverlay({
    super.key,
    required this.isRideCancelling,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: isRideCancelling
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : const RadiusCirclesOverlay(
                  radiusLevels: [0.15, 0.3, 0.45, 0.6],
                  color: Colors.orange,
                ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.white.withValues(alpha: 0.5),
                  Colors.white.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              isRideCancelling
                  ? 'Cancelling ride request'
                  : 'Looking for drivers',
              style: AppTextStyles.style18W500.copyWith(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Positioned(
          bottom: 24,
          left: 24,
          right: 24,
          child: SwipeButton(
            onSwipeComplete: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (_) {
                  return AppDialog(
                    onYesPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    title: 'Cancel Ride',
                    subTitle: 'Are you sure you want to cancel the ride?',
                    actionButtonTitle: 'Cancel Ride',
                    icon: Assets.cancelIc,
                    color: Theme.of(context).colorScheme.error,
                  );
                },
              );

              if (result ?? false) {
                await mapStoreProvider().cancelRide('Cancelled by passenger');
              }
            },
          ),
        ),
      ],
    );
  }
}

// Ride Status Section Widget
class RideStatusSection extends StatelessWidget {
  final RideRequest currentRide;

  const RideStatusSection({
    super.key,
    required this.currentRide,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: () {
            switch (currentRide.ride!.status) {
              case RideStatus.accepted:
                return RideArrivingBottomSheet(rideRequest: currentRide);
              case RideStatus.arrived:
                return RideWaitingBottomSheet(rideRequest: currentRide);
              case RideStatus.started:
                return RideStartedWidget(rideRequest: currentRide);
              case RideStatus.completed:
                return DestinationArrivedBottomSheet(rideRequest: currentRide);
              case RideStatus.requested:
              case RideStatus.searching:
              case RideStatus.cancelled:
              case null:
                return const SizedBox();
            }
          }(),
        ),
      ],
    );
  }
}

// Map Widget
class MapWidget extends StatelessWidget {
  final MapStore mapStore;
  final String mapStyleString;

  const MapWidget({
    super.key,
    required this.mapStore,
    required this.mapStyleString,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: mapStore.mapCameraPosition,
      onMapCreated: (GoogleMapController controller) async {
        try {
          mapStore.googleMapController = controller;

          Future.delayed(const Duration(seconds: 1), () async {
            await mapStore.moveToCurrentLocation();
          });
        } catch (e) {
          debugPrint('Error in onMapCreated: $e');
        }
      },
      myLocationEnabled: true,
      style: mapStyleString,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      markers: Set<Marker>.from(mapStore.markers),
      polylines: mapStore.polylines,
    );
  }
}
