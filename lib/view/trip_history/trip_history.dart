import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ridzs_passenger_app/core/constants/extension.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/stores/map/map_store.dart';
import 'package:ridzs_passenger_app/view/payments/payment_recovery_screen.dart';
import 'package:ridzs_passenger_app/view/trip_history/ride_trace_screen.dart';

class TripHistory extends HookWidget {
  static const String routeNamed = 'RideHistory';

  const TripHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;
    final mapStore = mapStoreProvider();
    final options = [
      'Today',
      'Last Seven Days',
      'This Month',
      'Date Range',
    ];

    return Scaffold(
      backgroundColor: themeColor.secondary,
      body: SafeArea(
        child: Column(
          children: [
            //
            TitleRowWidget(
              text: 'Trip History',
              trailingWidget: PopupMenuButton(
                color: themeColor.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                itemBuilder: (_) {
                  return List.generate(options.length, (index) {
                    return PopupMenuItem(
                      value: options[index],
                      child: Text(
                        options[index],
                        style: AppTextStyles.style12W500.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: GoogleFonts.poppins().fontFamily),
                      ),
                    );
                  }).toList().addVWidget(
                        const PopupMenuDivider(
                          height: 1,
                        ),
                      );
                },
                child: const Icon(
                  Icons.filter_alt,
                ),
              ),
            ),

            //
            Observer(builder: (context) {
              if (mapStore.isRideHistoryLoading) {
                return Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: themeColor.primary,
                    ),
                  ),
                );
              }

              return Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.screenWidth * 0.04,
                  ),
                  child: ListView.builder(
                    itemCount: mapStore.rideHistory.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final ride = mapStore.rideHistory[index];
                      return Container(
                        margin: const EdgeInsets.only(
                          bottom: 7,
                          top: 7,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: themeColor.surfaceContainerHigh,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: .3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      //
                                      Text(
                                        DateFormat('dd MMM, yyyy hh:mm a')
                                            .format(ride.timestamps.requested!),
                                        style:
                                            AppTextStyles.style12W500.copyWith(
                                          color: themeColor.surface,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      SizedBox(
                                          height:
                                              SizeConfig.screenHeight * 0.01),

                                      Row(
                                        children: [
                                          //
                                          if (ride.driverInfo?.photo.isEmpty ??
                                              true)
                                            Container(
                                              height: SizeConfig.screenHeight *
                                                  0.05,
                                              width: SizeConfig.screenHeight *
                                                  0.05,
                                              decoration: BoxDecoration(
                                                color: themeColor.primary,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                              ),
                                            )
                                          else
                                            ClipOval(
                                              child: CustomImageView(
                                                url: ride.driverInfo?.photo,
                                                height:
                                                    SizeConfig.screenHeight *
                                                        0.05,
                                                width: SizeConfig.screenHeight *
                                                    0.05,
                                                fit: BoxFit.cover,
                                              ),
                                            ),

                                          SizedBox(
                                            width:
                                                SizeConfig.screenWidth * 0.02,
                                          ),

                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              //
                                              Text(
                                                ride.driverInfo?.name ?? 'N/A',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .surface,
                                                ),
                                              ),

                                              Text(
                                                'N/A',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .surfaceContainer,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                //
                                const Padding(
                                  padding: EdgeInsets.only(
                                    top: 6,
                                  ),
                                  child: Icon(
                                    Icons.more_vert,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(
                              height: SizeConfig.screenHeight * 0.02,
                            ),

                            buildLocationDetails(
                              context: context,
                              pickup: ride.pickup.address,
                              dropOff: ride.destination.address,
                            ),

                            SizedBox(
                              height: SizeConfig.screenHeight * 0.02,
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        'Paid ',
                                        style:
                                            AppTextStyles.style12W500.copyWith(
                                          color: themeColor.surfaceContainer,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        ' \$${ride.fare.total.toStringAsFixed(2)}',
                                        style:
                                            AppTextStyles.style12W500.copyWith(
                                          color: themeColor.surface,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (ride.status.isNotEmpty)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: SizeConfig.screenWidth * 0.03,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40),
                                      color: const Color(0xff3378FF),
                                    ),
                                    child: Text(
                                      ride.status.isEmpty
                                          ? ''
                                          : '${ride.status[0].toUpperCase()}${ride.status.substring(1)}',
                                      style: AppTextStyles.style12W500.copyWith(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              alignment: WrapAlignment.end,
                              spacing: 6,
                              runSpacing: 2,
                              children: [
                                if (ride.payment.needsRecovery)
                                  TextButton.icon(
                                    onPressed: () {
                                      NavigationService().navigateTo(
                                        PaymentRecoveryScreen.routeNamed,
                                        arguments: {'ride': ride},
                                      );
                                    },
                                    icon: Icon(
                                      Icons.payment,
                                      color: themeColor.primary,
                                      size: 18,
                                    ),
                                    label: Text(
                                      'Payment help',
                                      style: AppTextStyles.style12W500.copyWith(
                                        color: themeColor.primary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                TextButton.icon(
                                  onPressed: () {
                                    NavigationService().navigateTo(
                                      RideTraceScreen.routeNamed,
                                      arguments: {'ride': ride},
                                    );
                                  },
                                  icon: Icon(
                                    Icons.route,
                                    color: themeColor.primary,
                                    size: 18,
                                  ),
                                  label: Text(
                                    'View route',
                                    style: AppTextStyles.style12W500.copyWith(
                                      color: themeColor.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget buildDashedLine(BuildContext context) {
    return Column(
      children: List.generate(18, (index) {
        return Container(
          width: 1,
          height: index % 2 == 0 ? 4 : 2,
          color: index % 2 == 0
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent, // Dashed effect
        );
      }),
    );
  }

  // Widget to build location details
  Widget buildLocationDetails({
    required String pickup,
    required String dropOff,
    String? distance,
    required BuildContext context,
  }) {
    return Row(
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
              decoration: const BoxDecoration(
                color: Color(0xff38C274),
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
              child: const VerticalDivider(
                color: Color(0xff38C274),
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
                  color: const Color(0xff38C274),
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.circle,
                color: Color(0xff38C274),
                size: 14,
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
                pickup,
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
                    .onSecondary
                    .withValues(alpha: .1),
                height: 0,
              ),

              const SizedBox(height: 8),

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
                dropOff,
                style: AppTextStyles.style15w400.copyWith(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
