import '../../core/theme/ridzs_theme.dart';
import '../../widgets/buttons/map_control_button.dart';
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
      left: 16,
      top: MediaQuery.paddingOf(context).top + 12,
      child: MapControlButton(
        icon: Icons.menu_rounded,
        tooltip: 'Open menu',
        onPressed: () => scaffoldKey.currentState?.openDrawer(),
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
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CurrentLocationButton(),
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
      child: Padding(
        padding: const EdgeInsets.only(right: 16, bottom: 16),
        child: MapControlButton(
          icon: Icons.my_location_rounded,
          tooltip: 'My location',
          onPressed: () => mapStore.moveToCurrentLocation(),
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
    return Material(
      color: RidzsTheme.paper(context),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: .12),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .6),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Where to?',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                const SearchDestinationField(),
                const SizedBox(height: 20),
                RecentTripsSection(mapStore: mapStore),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Search Destination Field Widget
class SearchDestinationField extends StatelessWidget {
  const SearchDestinationField({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => showRideBottomSheet(),
      style: OutlinedButton.styleFrom(
        backgroundColor: RidzsTheme.ink(context).withValues(alpha: .03),
        padding: const EdgeInsets.all(16),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: RidzsTheme.ink(context), size: 22),
          const SizedBox(width: 12),
          const Expanded(child: Text('Search destinations')),
          Icon(Icons.arrow_forward_rounded,
              color: RidzsTheme.ink(context), size: 20),
        ],
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
