import 'dart:developer';

import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/models/response/maps/search_place.dart';
import 'package:ridzs_passenger_app/models/ride/get_ride_response.dart';
import 'package:ridzs_passenger_app/services/debouncer_service.dart';
import 'package:ridzs_passenger_app/stores/map/map_store.dart';
import 'package:ridzs_passenger_app/view/home/widget/choose_trip.dart';

class BottomSheetService extends HookWidget {
  static BuildContext get context => NavigationService.navigatorKey.currentContext!;

  const BottomSheetService({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// static Future<void> showLoginBottomSheet() async {
//   return showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     constraints: BoxConstraints(
//       maxHeight: SizeConfig.screenHeight * 0.95,
//     ),
//     builder: (_) {
//       return const AuthBottomSheet();
//     },
//   );
// }

Future<void> middleBottomSheetService(
  Widget child, {
  double? height,
  Color? backgroundColor,
  bool applyTheme = true,
}) async {
  final context = NavigationService.navigatorKey.currentContext!;
  return showModalBottomSheet(
    context: context,
    barrierColor: Colors.transparent,
    backgroundColor:
        backgroundColor ?? Theme.of(context).colorScheme.onPrimaryContainer,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: SizeConfig.screenHeight * (height ?? 0.6),
    ),
    builder: (_) {
      return Container(
        color: applyTheme
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : null,
        child: child,
      );
    },
  );
}

Future<void> bigBottomSheetService(Widget child) async {
  final context = NavigationService.navigatorKey.currentContext!;
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.secondary,
    constraints: BoxConstraints(
      maxHeight: SizeConfig.screenHeight * 0.9,
    ),
    builder: (_) {
      return Container(
          color: Theme.of(context).colorScheme.secondary, child: child);
    },
  );
}

Future<void> showRideBottomSheet({Ride? ride}) async {
  mapStoreProvider().setSearchPlacesModel(null);
  mapStoreProvider().designationController.clear();
  mapStoreProvider().currentLocationController.clear();

  if (ride != null) {
    mapStoreProvider().currentLocationController.text = ride.pickup.address;
    mapStoreProvider().designationController.text = ride.destination.address;

    mapStoreProvider().selectedSuggestionsFrom = Features(
      properties: Properties(
        name: ride.pickup.address,
        fullAddress: ride.pickup.address,
        coordinates: Coordinates(
          latitude: ride.pickup.latitude,
          longitude: ride.pickup.longitude,
        ),
      ),
    );

    mapStoreProvider().selectedSuggestionsTo = Features(
      properties: Properties(
        name: ride.destination.address,
        fullAddress: ride.destination.address,
        coordinates: Coordinates(
          latitude: ride.destination.latitude,
          longitude: ride.destination.longitude,
        ),
      ),
    );
  }

  final context = NavigationService.navigatorKey.currentContext!;
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    backgroundColor: Theme.of(context).colorScheme.secondary,
    constraints: BoxConstraints(
      maxHeight: SizeConfig.screenHeight * 0.9,
    ),
    builder: (_) {
      return const BottomSheetContent();
    },
  );
}

class BottomSheetContent extends HookWidget {
  const BottomSheetContent({super.key});

  static List<String> times = [AppStrings.pickUpNow, 'For me'];
  static List<String> icons = [Assets.icTime, Assets.icParson];

  @override
  Widget build(BuildContext context) {
    final debounce = Debouncer(
      delay: const Duration(milliseconds: 500),
    );
    return Column(
      children: [
        Padding(
          padding: AppPadding.scaffoldWithTop,
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back_outlined,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              const Spacer(),
              Text(
                AppStrings.planYourRide,
                style: AppTextStyles.style23W600
                    .copyWith(color: Theme.of(context).colorScheme.tertiary),
              ),
              const SizedBox(width: 20),
              const Spacer(),
            ],
          ),
        ),
        // const SizedBox(height: 20),
        // Padding(
        //   padding: AppPadding.scaffold,
        //   child: SizedBox(
        //     height: 32,
        //     child: ListView.builder(
        //       itemCount: 2,
        //       scrollDirection: Axis.horizontal,
        //       itemBuilder: (context, index) {
        //         return Padding(
        //           padding: const EdgeInsets.only(left: 10),
        //           child: InkWell(
        //             onTap: () {
        //               // Navigator.pop(context);
        //               // bigBottomSheetService(ChooseTrip());
        //             },
        //             child: Container(
        //               padding: const EdgeInsets.all(4),
        //               decoration: BoxDecoration(
        //                   color:
        //                       Theme.of(context).colorScheme.surfaceContainerLow,
        //                   borderRadius:
        //                       const BorderRadius.all(Radius.circular(5))),
        //               child: Center(
        //                   child: Row(
        //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
        //                 crossAxisAlignment: CrossAxisAlignment.center,
        //                 children: [
        //                   CustomImageView(
        //                     imagePath: icons[index],
        //                     height: 15,
        //                     width: 15,
        //                     color: Theme.of(context)
        //                         .colorScheme
        //                         .surfaceContainerLowest,
        //                   ),
        //                   const SizedBox(width: 4),
        //                   Text(
        //                     times[index],
        //                     style: AppTextStyles.style12W600.copyWith(
        //                         color: Theme.of(context)
        //                             .colorScheme
        //                             .surfaceContainerLowest),
        //                   ),
        //                   const SizedBox(width: 8),
        //                   CustomImageView(
        //                     imagePath: Assets.icDropdown,
        //                     height: 5,
        //                     width: 9,
        //                     color: Theme.of(context)
        //                         .colorScheme
        //                         .surfaceContainerLowest,
        //                   ),
        //                   const SizedBox(width: 6),
        //                 ],
        //               )),
        //             ),
        //           ),
        //         );
        //       },
        //     ),
        //   ),
        // ),
        const SizedBox(height: 10),
        Padding(
          padding: AppPadding.scaffold,
          child: TripSearchCommonWithADD(
            onChanged: (p0) {
              debounce.run(() {
                if (p0.isNotEmpty) {
                  mapStoreProvider().searchPlace(p0);
                } else {
                  mapStoreProvider().setSearchPlacesModel(null);
                }
                mapStoreProvider().setCurrentController(true);
              });
            },
            designationController: mapStoreProvider().designationController,
            onChangedSecond: (p0) {
              debounce.run(() {
                if (p0.isNotEmpty) {
                  mapStoreProvider().searchPlace(p0);
                } else {
                  mapStoreProvider().setSearchPlacesModel(null);
                }
                mapStoreProvider().setCurrentController(false);
              });
            },
            currentLocationController:
                mapStoreProvider().currentLocationController,
            onTapNow: () {},
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.only(left: 10, right: 10),
        //   child: Padding(
        //     padding: AppPadding.scaffold,
        //     child: buildSavedPlaceItem(
        //       fullAddress: '',
        //       placeName: AppStrings.savedPlaces,
        //       context: context,
        //       iconPath: Assets.icForward,
        //       onTap: () {},
        //     ),
        //   ),
        // ),
        const SizedBox(height: 14),

        Divider(
          height: 1,
          color: Theme.of(context).colorScheme.onTertiary.withValues(alpha: .8),
        ),
        Observer(
            builder: (_) => Expanded(
                  child: Padding(
                    padding: AppPadding.scaffold,
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        bottom: 10,
                      ),
                      itemCount: mapStoreProvider()
                              .searchPlaceModel
                              ?.features
                              ?.length ??
                          0,
                      itemBuilder: (context, index) {
                        final feature = mapStoreProvider()
                            .searchPlaceModel
                            ?.features?[index];
                        return Column(
                          children: [
                            buildSavedPlaceItem(
                              fullAddress:
                                  feature?.properties?.fullAddress ?? '',
                              placeName: feature?.properties?.name ?? '',
                              context: context,
                              onTap: () {
                                if (!mapStoreProvider().isCurrentController) {
                                  mapStoreProvider()
                                      .designationController
                                      .text = feature?.properties?.name ?? '';
                                  mapStoreProvider().selectedSuggestionsFrom =
                                      feature;
                                } else {
                                  mapStoreProvider()
                                      .currentLocationController
                                      .text = feature?.properties?.name ?? '';

                                  mapStoreProvider().selectedSuggestionsTo =
                                      feature;
                                }
                              },
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Divider(
                              height: 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onTertiary
                                  .withValues(alpha: .8),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                )),
        const Spacer(),
        Observer(builder: (context) {
          return Padding(
            padding: AppPadding.scaffold,
            child: CustomButton(
              isLoading: mapStoreProvider().isDirectionLoading,
              onTap: () async {
                await mapStoreProvider().getDirection(
                  '${mapStoreProvider().selectedSuggestionsFrom?.properties?.coordinates?.latitude ?? ''}',
                  '${mapStoreProvider().selectedSuggestionsFrom?.properties?.coordinates?.longitude ?? ''}',
                  '${mapStoreProvider().selectedSuggestionsTo?.properties?.coordinates?.latitude ?? ''}',
                  '${mapStoreProvider().selectedSuggestionsTo?.properties?.coordinates?.longitude ?? ''}',
                );

                NavigationService().pop();

                middleBottomSheetService(
                  ChooseTrip(),
                  backgroundColor: Colors.transparent,
                  height: 0.9,
                  applyTheme: false,
                );
              },
              text: AppStrings.next,
            ),
          );
        }),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget buildSavedPlaceItem(
      {required String placeName,
      required String fullAddress,
      String? iconPath,
      required BuildContext context,
      void Function()? onTap}) {
    log("object == $fullAddress");
    // return ListTile(
    //   leading: CustomImageView(
    //     imagePath: Assets.icLocation,
    //     height: 22,
    //     width: 22,
    //   ),
    //   title: Text(placeName, style: AppTextStyles.style15white.copyWith(color: Theme.of(context).colorScheme.onTertiary)),
    //   subtitle:  Text("2000, Airport Rd NE, Calgary, AB T2E 6W5",
    //       style: AppTextStyles.style12W500.copyWith(color: Theme.of(context).colorScheme.onTertiary)),
    //   trailing: const Icon(Icons.star_border, color: Colors.white),
    // );
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leading Icon
          CustomImageView(
              imagePath: Assets.icLocation,
              height: 18,
              width: 18,
              color: Theme.of(context).colorScheme.tertiary),
          const SizedBox(width: 10), // Space between the icon and text

          // Title and Subtitle Text
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    placeName,
                    style: AppTextStyles.style15white.copyWith(
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Space between the title and subtitle
                  Text(
                    fullAddress,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.style12W500.copyWith(
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Trailing Icon (Star Icon)
          iconPath == null
              ? Icon(Icons.star_border,
                  color: Theme.of(context).colorScheme.tertiary)
              : Center(
                  child: CustomImageView(
                    imagePath: Assets.icForward,
                    height: 13,
                    width: 8,
                  ),
                ),
        ],
      ),
    );
  }
}
