import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobx/mobx.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/core/services/toast_service.dart';
import 'package:ridzs_passenger_app/models/response/payment/get_card_response.dart';
import 'package:ridzs_passenger_app/stores/map/map_store.dart';
import 'package:ridzs_passenger_app/view/home/widget/add_new_card.dart';
import 'package:ridzs_passenger_app/view/home/widget/choose_payment_bottom_sheet.dart';
import 'package:ridzs_passenger_app/view/my_rewards/ad_watch_screen.dart';

import '../../../core/enums/ride.dart';

class ChooseTrip extends HookWidget {
  ChooseTrip({
    super.key,
  });

  final currentLocationController = TextEditingController();
  final designationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final selected = useState(0);
    final userStore = userStoreProvider();
    final mapStore = mapStoreProvider();
    final isDiscountApplied = useState(false);
    final totalDiscountPercentage = useState(0.0);
    final maxDiscountAmount = useState(0.0);
    final isWalletSelected = useState(false);

    final selectedCard = useState<CardDetails?>(
      (userStoreProvider().cardList?.cards?.isNotEmpty ?? false)
          ? (userStoreProvider().cardList?.cards?[0])
          : null,
    );

    Future<void> showAdRewardPrompt() async {
      if (!context.mounted ||
          mapStore.currentRide?.ride?.sId?.isNotEmpty != true) {
        return;
      }

      final rideId = mapStore.currentRide?.ride?.sId;
      var keepWatching = true;
      while (keepWatching) {
        if (!context.mounted) {
          return;
        }

        final watchAd = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Save on next ride'),
              content: const Text(
                'Watch a short ad and add ride credit to your wallet.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false);
                  },
                  child: const Text('Not now'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const Text('Watch'),
                ),
              ],
            );
          },
        );

        if (watchAd != true) {
          return;
        }

        final rewardAmount = await NavigationService().navigateTo(
          AdWatchScreen.routeNamed,
          arguments: {'rideId': rideId},
        );

        if (rewardAmount is num) {
          await userStore.getWallet();
          ToastService.show(
            '\$${rewardAmount.toStringAsFixed(2)} added to wallet',
          );

          if (!context.mounted) {
            return;
          }

          final watchAnother = await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text('Reward added'),
                content: const Text(
                  'Watch another short ad to add more ride credit.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(false);
                    },
                    child: const Text('Done'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(true);
                    },
                    child: const Text('Watch another'),
                  ),
                ],
              );
            },
          );
          keepWatching = watchAnother == true;
        } else {
          return;
        }
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.circle,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 10,
                    ),
                  ),

                  SizedBox(
                    height: SizeConfig.screenHeight * 0.07,
                    child: VerticalDivider(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      thickness: 1,
                      width: 1,
                    ),
                  ),

                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.circle,
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      size: 10,
                    ),
                  ),
                ],
              ),

              //
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //
                    Text(
                      'Pick-up',
                      style: AppTextStyles.style10W400.copyWith(
                        color: Theme.of(context).colorScheme.primaryFixedDim,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mapStoreProvider()
                              .selectedSuggestionsFrom
                              ?.properties
                              ?.name ??
                          '',
                      style: AppTextStyles.style15w400.copyWith(
                        color: Theme.of(context).colorScheme.tertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Divider(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withValues(alpha: .1),
                    ),

                    //
                    Text(
                      'Drop off',
                      style: AppTextStyles.style10W400.copyWith(
                        color: Theme.of(context).colorScheme.primaryFixedDim,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mapStoreProvider()
                              .selectedSuggestionsTo
                              ?.properties
                              ?.name ??
                          '',
                      style: AppTextStyles.style15w400.copyWith(
                        color: Theme.of(context).colorScheme.tertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              //
              const SizedBox(width: 10),

              SvgPicture.asset(
                Assets.editPencilIc,
                height: 20,
                width: 20,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.surface,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: SizeConfig.screenHeight * 0.01,
        ),

        Container(
          margin: const EdgeInsets.only(
            right: 16,
            left: 16,
            bottom: 16,
          ),
          padding: AppPadding.scaffoldWithTop,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 10,
              ),

              Text(
                'Choose your ride',
                style: AppTextStyles.style18W500.copyWith(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              //
              SizedBox(
                height: SizeConfig.screenHeight * 0.4,
                child: Observer(builder: (context) {
                  final prices = mapStoreProvider().pricesList;

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: prices.length,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    itemBuilder: (context, index) {
                      final price = prices[index];

                      final distance = mapStoreProvider().getKilometer(
                          mapStoreProvider().directions?.routes?[0].distance ??
                              0.0);

                      double totalPrice = calculateTotalPrice(
                        distance: distance,
                        basePrice: price.basePrice,
                        perKm: price.perKilometer,
                        perMin: price.perMinute,
                        serviceCharge: price.taxes.serviceCharge,
                        gst: price.taxes.gst,
                      );

                      final originalPrice = calculateTotalPrice(
                        distance: distance,
                        basePrice: price.basePrice,
                        perKm: price.perKilometer,
                        perMin: price.perMinute,
                        serviceCharge: price.taxes.serviceCharge,
                        gst: price.taxes.gst,
                      );

                      if (isDiscountApplied.value) {
                        final discountedPrice = totalPrice -
                            (totalPrice * totalDiscountPercentage.value / 100);

                        if (discountedPrice > maxDiscountAmount.value) {
                          totalPrice -= maxDiscountAmount.value;
                        } else {
                          totalPrice = discountedPrice;
                        }
                      }

                      return buildSavedPlaceItem(
                        placeName: price.vehicleType,
                        price: totalPrice,
                        originalPrice: originalPrice,
                        context: context,
                        isSelected: index == selected.value,
                        onTap: () {
                          selected.value = index;
                          // Save selected price for ride creation
                          mapStoreProvider().setSelectedPrice(price);
                        },
                      );
                    },
                  );
                }),
              ),

              const SizedBox(
                height: 10,
              ),

              //
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose payment method',
                            style: AppTextStyles.style10W400.copyWith(
                              color: Theme.of(context).colorScheme.tertiary,
                              fontSize: 10,
                            ),
                          ),

                          const SizedBox(height: 8),

                          //
                          if (userStoreProvider().cardList?.cards?.isNotEmpty ??
                              false)
                            GestureDetector(
                              onTap: () async {
                                final distance = mapStore.getKilometer(
                                    mapStore.directions?.routes?[0].distance ??
                                        0.0);

                                double totalPrice = calculateTotalPrice(
                                  distance: distance,
                                  basePrice: mapStore.selectedPrice!.basePrice,
                                  perKm: mapStore.selectedPrice!.perKilometer,
                                  perMin: mapStore.selectedPrice!.perMinute,
                                  serviceCharge: mapStore
                                      .selectedPrice!.taxes.serviceCharge,
                                  gst: mapStore.selectedPrice!.taxes.gst,
                                );

                                if (isDiscountApplied.value) {
                                  final discountedPrice = totalPrice -
                                      (totalPrice *
                                          totalDiscountPercentage.value /
                                          100);

                                  if (discountedPrice >
                                      maxDiscountAmount.value) {
                                    totalPrice -= maxDiscountAmount.value;
                                  } else {
                                    totalPrice = discountedPrice;
                                  }
                                }

                                final result =
                                    await showModalBottomSheet<List<dynamic>>(
                                  context: context,
                                  builder: (_) {
                                    return ChoosePaymentBottomSheet(
                                      selectedCardId:
                                          selectedCard.value?.id ?? '',
                                      totalAmount: totalPrice,
                                    );
                                  },
                                );

                                if (result == null) return;
                                if (result.isEmpty) return;
                                isWalletSelected.value = result[0] as bool;
                                final card = result[1] as CardDetails?;

                                if (!isWalletSelected.value) {
                                  selectedCard.value = card;
                                }
                              },
                              child: Row(
                                children: [
                                  CustomImageView(
                                    svgPath: isWalletSelected.value
                                        ? Assets.walletIc
                                        : Assets.visaIc,
                                    width: 24,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    isWalletSelected.value
                                        ? 'Wallet'
                                        : 'XXXX ${userStoreProvider().cardList?.cards?[0].last4}',
                                    style: AppTextStyles.style15w400.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                ],
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: () async {
                                NavigationService()
                                    .navigateTo(AddNewCard.routeNamed);
                              },
                              child: Container(
                                height: 56,
                                padding: EdgeInsets.symmetric(
                                  horizontal: SizeConfig.screenWidth * 0.04,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xffF5F7FA),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  children: [
                                    //
                                    Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      size: 20,
                                    ),

                                    SizedBox(
                                        width: SizeConfig.screenWidth * 0.02),

                                    Text(
                                      'Add Payment Method',
                                      style: AppTextStyles.caption.copyWith(
                                        color: const Color(0xff475569),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (userStoreProvider().cardList?.cards?.isNotEmpty ??
                          false)
                        const SizedBox(
                          width: 10,
                        ),
                      if (userStoreProvider().cardList?.cards?.isNotEmpty ??
                          false)
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Theme.of(context).colorScheme.tertiary,
                          size: 18,
                        )
                    ],
                  ),

                  // GestureDetector(
                  //   onTap: () async {
                  //     final promocode = await showDialog<String>(
                  //       context: context,
                  //       builder: (BuildContext dialogContext) {
                  //         return const EnterPromoCodeDialog();
                  //       },
                  //     );

                  //     if (promocode != null) {
                  //       final distance = mapStore.getKilometer(
                  //           mapStore.directions?.routes?[0].distance ?? 0.0);

                  //       final totalPrice = calculateTotalPrice(
                  //         distance: distance,
                  //         basePrice: mapStore.selectedPrice!.basePrice,
                  //         perKm: mapStore.selectedPrice!.perKilometer,
                  //         perMin: mapStore.selectedPrice!.perMinute,
                  //         serviceCharge:
                  //             mapStore.selectedPrice!.taxes.serviceCharge,
                  //         gst: mapStore.selectedPrice!.taxes.gst,
                  //       );

                  //       final result = await mapStore.addPromoCode(
                  //         promocode,
                  //         totalPrice,
                  //       );

                  //       if (result != null) {
                  //         isDiscountApplied.value = true;
                  //         totalDiscountPercentage.value =
                  //             result.value?.toDouble() ?? 0.0;
                  //         maxDiscountAmount.value =
                  //             result.maxAmount?.toDouble() ?? 0.0;
                  //         ToastService.show(
                  //             'Promo code applied: ${result.code}, Value: ${result.value}');
                  //       } else {
                  //         ToastService.show('Failed to apply promo code');
                  //       }
                  //     }
                  //   },
                  //   child: Container(
                  //     height: 56,
                  //     padding: EdgeInsets.symmetric(
                  //       horizontal: SizeConfig.screenWidth * 0.04,
                  //     ),
                  //     decoration: BoxDecoration(
                  //       color: const Color(0xffF5F7FA),
                  //       borderRadius: BorderRadius.circular(30),
                  //     ),
                  //     child: Row(
                  //       children: [
                  //         //
                  //         Icon(
                  //           Icons.add_circle_outline_rounded,
                  //           color: Theme.of(context)
                  //               .colorScheme
                  //               .onPrimaryContainer,
                  //           size: 20,
                  //         ),

                  //         SizedBox(width: SizeConfig.screenWidth * 0.02),

                  //         Text(
                  //           'Apply promo code',
                  //           style: AppTextStyles.caption.copyWith(
                  //             color: const Color(0xff475569),
                  //             fontSize: 10,
                  //             fontWeight: FontWeight.w400,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              Row(
                children: [
                  // Container(
                  //   height: 50,
                  //   width: 50,
                  //   padding: const EdgeInsets.all(11),
                  //   decoration: BoxDecoration(
                  //     border: Border.all(
                  //       color:
                  //           Theme.of(context).colorScheme.onSecondaryContainer,
                  //     ),
                  //     shape: BoxShape.circle,
                  //   ),
                  //   child: SvgPicture.asset(
                  //     Assets.scheduleCalendarIc,
                  //     height: 24,
                  //     width: 24,
                  //   ),
                  // ),

                  // SizedBox(
                  //   width: SizeConfig.screenWidth * 0.04,
                  // ),

                  //
                  Observer(
                    builder: (_) {
                      return Expanded(
                        child: CustomButton(
                          onTap: () async {
                            if (mapStore.selectedPrice == null) {
                              ToastService.show('Please select a price');
                              return;
                            }

                            try {
                              final distance = mapStore.getKilometer(
                                  mapStore.directions?.routes?[0].distance ??
                                      0.0);

                              double totalPrice = calculateTotalPrice(
                                distance: distance,
                                basePrice: mapStore.selectedPrice!.basePrice,
                                perKm: mapStore.selectedPrice!.perKilometer,
                                perMin: mapStore.selectedPrice!.perMinute,
                                serviceCharge:
                                    mapStore.selectedPrice!.taxes.serviceCharge,
                                gst: mapStore.selectedPrice!.taxes.gst,
                              );

                              if (isDiscountApplied.value) {
                                final discountedPrice = totalPrice -
                                    (totalPrice *
                                        totalDiscountPercentage.value /
                                        100);

                                if (discountedPrice > maxDiscountAmount.value) {
                                  totalPrice -= maxDiscountAmount.value;
                                } else {
                                  totalPrice = discountedPrice;
                                }
                              }

                              final result = isWalletSelected.value
                                  ? true
                                  : await userStore
                                      .makeDirectPayment(totalPrice);

                              if (result) {
                                await mapStore.createRideRequest(
                                  isWalletSelected.value
                                      ? PaymentMethod.wallet
                                      : PaymentMethod.card,
                                );
                                await showAdRewardPrompt();

                                runInAction(() {
                                  mapStore.coordinatesList.clear();
                                });

                                for (var item in mapStore.tempCoordinatesList) {
                                  await Future.delayed(
                                    const Duration(milliseconds: 240),
                                  );
                                  runInAction(() {
                                    mapStore.coordinatesList.add(item);
                                  });
                                }

                                NavigationService().pop();
                              }
                            } catch (e) {
                              NavigationService().pop();
                              ToastService.show(
                                  'Error creating ride request: $e');
                            }
                          },
                          text: AppStrings.confirmRide,
                          isLoading: userStore.isPaymentLoading ||
                              mapStore.isCreatingRide ||
                              mapStore.isApplyingPromoCode,
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),

        //
        // Positioned(
        //   bottom: 0,
        //   width: MediaQuery.of(context).size.width,
        //   child: Container(
        //     color: Theme.of(context).colorScheme.secondary,
        //     child: Column(
        //       children: [
        //         Container(
        //           height: 1.5,
        //           color: Theme.of(context)
        //               .colorScheme
        //               .onTertiaryFixed
        //               .withValues(alpha: 0.3),
        //         ),
        //         Padding(
        //           padding: AppPadding.scaffold,
        //           child: Column(
        //             children: [
        //               const SizedBox(
        //                 height: 20,
        //               ),
        //               Row(
        //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                 children: [
        //                   Row(
        //                     children: [
        //                       CustomImageView(
        //                         imagePath: Assets.imgVisaWhite,
        //                         width: 45,
        //                       ),
        //                       const SizedBox(
        //                         width: 10,
        //                       ),
        //                       Text(
        //                         '**** **** **** ${userStoreProvider().getCardList?.cards?[0].last4}',
        //                         style: AppTextStyles.style15W600.copyWith(
        //                             color: Theme.of(context)
        //                                 .colorScheme
        //                                 .onTertiaryFixed),
        //                       )
        //                     ],
        //                   ),
        //                   CustomImageView(
        //                     imagePath: Assets.icRightArrow,
        //                     width: 24,
        //                   ),
        //                 ],
        //               ),
        //               const SizedBox(
        //                 height: 20,
        //               ),
        //               CustomButton(
        //                 onTap: () async {
        //                   // Check if price is selected
        //                   if (mapStoreProvider().selectedPrice == null) {
        //                     ToastService.show('Please select a price');
        //                     return;
        //                   }
        //                   // Show loading dialog
        //                   showDialog(
        //                     context: context,
        //                     barrierDismissible: false,
        //                     builder: (BuildContext context) {
        //                       return const LoadingIndicator();
        //                     },
        //                   );

        //                   try {
        //                     // Create ride request
        //                     await mapStoreProvider().createRideRequest();

        //                     // If successful, clear coordinates and animate
        //                     runInAction(() {
        //                       mapStoreProvider().coordinatesList.clear();
        //                     });

        //                     // Pop loading dialog and main screen
        //                     NavigationService().pop(); // Pop loading dialog
        //                     NavigationService()
        //                         .pop(); // Pop loading dialog// Pop choose trip screen

        //                     // Animate coordinates
        //                     for (var item
        //                         in mapStoreProvider().tempCoordinatesList) {
        //                       await Future.delayed(
        //                           const Duration(milliseconds: 240));
        //                       runInAction(() {
        //                         mapStoreProvider().coordinatesList.add(item);
        //                       });
        //                     }
        //                   } catch (e) {
        //                     // Pop loading dialog
        //                     Navigator.pop(context);

        //                     // Show error snackbar
        //                     ToastService.show(
        //                         'Error creating ride request: $e');
        //                   }
        //                 },
        //                 text: AppStrings.confirmRide,
        //               ),
        //               const SizedBox(
        //                 height: 20,
        //               ),
        //             ],
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // )
      ],
    );
  }

  Widget buildSavedPlaceItem({
    required CarType placeName,
    required double price,
    required double originalPrice,
    required BuildContext context,
    required bool isSelected,
    void Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
        ),
        margin: const EdgeInsets.only(
          bottom: 10,
        ),
        decoration: BoxDecoration(
          border: !isSelected
              ? Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceDim
                      .withValues(alpha: .1))
              : Border.all(color: Theme.of(context).colorScheme.primary),
          color: !isSelected
              ? Theme.of(context).colorScheme.surfaceDim.withValues(alpha: .1)
              : Theme.of(context).colorScheme.primary.withValues(alpha: .05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Vehicle icon based on type
              CustomImageView(
                imagePath: _getVehicleImage(placeName),
                width: 52,
                height: 52,
                fit: BoxFit.contain,
              ),

              //
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      toFirstUpperCase(placeName.toString().split('.').last),
                      style: AppTextStyles.style15w400.copyWith(
                        color: Theme.of(context).colorScheme.tertiary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Observer(
                      builder: (context) {
                        final estimatedTime = (mapStoreProvider()
                                .directions
                                ?.routes?[0]
                                .duration ??
                            0.0);
                        return Row(
                          children: [
                            Row(
                              children: [
                                CustomImageView(
                                  svgPath: Assets.timelineIc,
                                  width: 16,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "${(estimatedTime / 60).round()} min",
                                  style: AppTextStyles.style12w400.copyWith(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerLowest,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            //
                            const SizedBox(width: 10),

                            Row(
                              children: [
                                CustomImageView(
                                  svgPath: Assets.avatarIc,
                                  width: 16,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  _getNumberOfSeats(placeName),
                                  style: AppTextStyles.style12w400.copyWith(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerLowest,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: AppTextStyles.style18W500.copyWith(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (price != originalPrice)
                    Text(
                      '\$${originalPrice.toStringAsFixed(2)}',
                      style: AppTextStyles.style18W500.copyWith(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          decorationColor:
                              Theme.of(context).colorScheme.tertiary),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // bool _shouldShowFaster(CarType vehicleType) {
  //   return vehicleType == CarType.comfort || vehicleType == CarType.luxury;
  // }

  String _getVehicleImage(CarType vehicleType) {
    switch (vehicleType) {
      case CarType.standard:
        return Assets.economyCarIc;
      case CarType.comfort:
        return Assets.comfortCarIc;
      case CarType.xl:
        return Assets.comfortCarIc;
      case CarType.luxury:
        return Assets.premiumCarIc;
      case CarType.electric:
        return Assets.imgCar;
    }
  }

  String _getNumberOfSeats(CarType vehicleType) {
    switch (vehicleType) {
      case CarType.standard:
        return '4 seats';
      case CarType.comfort:
        return '4 seats';
      case CarType.xl:
        return '6 seats';
      case CarType.luxury:
        return '4 seats';
      case CarType.electric:
        return '4 seats';
    }
  }
}

class EnterPromoCodeDialog extends HookWidget {
  const EnterPromoCodeDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final promoCodeController = useTextEditingController();
    final mapStore = mapStoreProvider();

    return AlertDialog(
      title: Text(
        'Enter Promo Code',
        style: AppTextStyles.style18W500.copyWith(
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            autofocus: true,
            controller: promoCodeController,
            style: AppTextStyles.style15w400.copyWith(
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your promo code',
              hintStyle: AppTextStyles.style12w400.copyWith(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.surfaceDim,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        Observer(builder: (context) {
          if (mapStore.isApplyingPromoCode) {
            return const Center(child: CircularProgressIndicator());
          }

          return TextButton(
            onPressed: () async {
              if (promoCodeController.text.isEmpty) {
                ToastService.show('Please enter a promo code');
                return;
              }

              NavigationService().pop(promoCodeController.text);
            },
            child: Text(
              'Apply',
              style: AppTextStyles.style15w400.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }),
      ],
    );
  }
}

double calculateTotalPrice({
  required double distance,
  required double basePrice,
  required double perKm,
  required double perMin,
  required double serviceCharge,
  required double gst,
}) {
  // Base calculation
  double baseFare = basePrice;
  double distanceFare = distance * perKm;
  double estimatedTime = distance * 3; // Rough estimate: 3 minutes per km
  double timeFare = estimatedTime * perMin;

  // Subtotal
  double subtotal = baseFare + distanceFare + timeFare;

  // Add service charge
  double serviceChargeFee = (subtotal * serviceCharge) / 100;

  // Add GST
  double gstFee = (subtotal * gst) / 100;

  // Total
  return subtotal + serviceChargeFee + gstFee;
}

String toFirstUpperCase(String str) {
  if (str.isEmpty) return str;
  return str[0].toUpperCase() + str.substring(1).toLowerCase();
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 15),
          Text(
            'Creating your ride...',
            style: AppTextStyles.style15W600.copyWith(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}
