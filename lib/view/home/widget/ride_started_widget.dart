import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/models/common/ride_response/ride_response.dart';
import 'package:ridzs_passenger_app/stores/map/map_store.dart';
import 'package:ridzs_passenger_app/view/home/widget/cancel_ride_bottom_sheet.dart';
import 'package:ridzs_passenger_app/widgets/dialogs/app_dialog.dart';

class RideStartedWidget extends HookWidget {
  final RideRequest? rideRequest;
  const RideStartedWidget({
    super.key,
    required this.rideRequest,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        right: SizeConfig.screenWidth * 0.04,
        left: SizeConfig.screenWidth * 0.04,
        bottom: Platform.isIOS
            ? SizeConfig.screenHeight * 0.03
            : SizeConfig.screenHeight * 0.01,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.screenWidth * 0.04,
        vertical: SizeConfig.screenHeight * 0.02,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          //
          Container(
            height: 4,
            width: SizeConfig.screenWidth * 0.1,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .onTertiary
                  .withValues(alpha: .2),
              borderRadius: BorderRadius.circular(24),
            ),
          ),

          SizedBox(height: SizeConfig.screenHeight * 0.02),

          Row(
            children: [
              //
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //
                    Text(
                      'Ride started',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),

                    Text(
                      'You’ll reach at your location in',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '${rideRequest?.ride!.estimatedTimeInMinutes} mins',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.surfaceContainer,
                ),
              ),
            ],
          ),

          SizedBox(height: SizeConfig.screenHeight * 0.01),

          Divider(
            color:
                !isDarkMode ? const Color(0xffF1F5F9) : const Color(0xff3F3F3F),
          ),

          SizedBox(height: SizeConfig.screenHeight * 0.02),

          Row(
            children: [
              //
              if ((rideRequest?.driverPhoto ?? '').isEmpty)
                Container(
                  height: SizeConfig.screenHeight * 0.1,
                  width: SizeConfig.screenHeight * 0.1,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 52,
                  ),
                )
              else
                ClipOval(
                  child: CustomImageView(
                    url: rideRequest?.driverPhoto,
                    height: SizeConfig.screenHeight * 0.1,
                    width: SizeConfig.screenHeight * 0.1,
                    fit: BoxFit.cover,
                  ),
                ),

              SizedBox(width: SizeConfig.screenWidth * 0.02),

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //
                        Text(
                          rideRequest!.driverName!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),

                        Text(
                          'Kia Soul LX',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color:
                                Theme.of(context).colorScheme.tertiaryContainer,
                          ),
                        ),

                        SizedBox(height: SizeConfig.screenHeight * 0.01),

                        Text(
                          'HSW 4736 XK',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),

                    //
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //
                        SizedBox(
                          height: SizeConfig.screenHeight * 0.07,
                          width: SizeConfig.screenHeight * 0.07,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              //
                              CustomImageView(
                                svgPath: Assets.starIc,
                                height: SizeConfig.screenHeight * 0.07,
                                width: SizeConfig.screenHeight * 0.07,
                              ),

                              Text(
                                '4.8',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          'Overall rating',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onTertiary,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: SizeConfig.screenHeight * 0.02),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.screenWidth * 0.05,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _iconWithTextWidget(
                  context: context,
                  value: '${rideRequest?.ride?.distanceInKm} Km',
                  icon: Assets.distanceIc,
                ),
                _iconWithTextWidget(
                  context: context,
                  value: '${rideRequest?.ride?.estimatedTimeInMinutes} min',
                  icon: Assets.timelineIc2,
                ),
                _iconWithTextWidget(
                  context: context,
                  value: '\$${rideRequest?.ride?.fare?.baseFare ?? '-'}',
                  icon: Assets.dollarIc,
                ),
              ],
            ),
          ),

          SizedBox(height: SizeConfig.screenHeight * 0.01),

          Divider(
            color:
                !isDarkMode ? const Color(0xffF1F5F9) : const Color(0xff3F3F3F),
          ),

          SizedBox(height: SizeConfig.screenHeight * 0.02),

          SizedBox(
            height: SizeConfig.screenHeight * 0.08,
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

                    Expanded(
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
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.screenHeight * 0.002,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${rideRequest?.ride?.pickup?.address}',
                          style: AppTextStyles.style15w400.copyWith(
                            color: Theme.of(context).colorScheme.tertiary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${rideRequest?.ride?.destination?.address}',
                          style: AppTextStyles.style15w400.copyWith(
                            color: Theme.of(context).colorScheme.tertiary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: SizeConfig.screenHeight * 0.02),

          CustomButton(
            imageIcon: true,
            iconPath: Assets.locationIc,
            iconColor: Theme.of(context).colorScheme.surfaceContainer,
            onTap: () {
              // NavigationService().pop();
              // showModalBottomSheet(
              //   context: context,
              //   backgroundColor: Colors.transparent,
              //   isScrollControlled: true,
              //   builder: (_) {
              //     return const DestinationArrivedBottomSheet();
              //   },
              // );
            },
            text: 'Edit Destination',
            shadowColor:
                Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: .1),
            showShadow: false,
            textColor: Theme.of(context).colorScheme.onPrimary,
          ),

          SizedBox(height: SizeConfig.screenHeight * 0.02),

          Divider(
            color: Theme.of(context).colorScheme.surfaceBright,
          ),

          SizedBox(height: SizeConfig.screenHeight * 0.02),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Payment option',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
              ),

              //
              Text(
                'Visa card',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Total price',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
              ),

              //
              Text(
                '\$ ${rideRequest?.ride?.fare?.baseFare}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: SizeConfig.screenHeight * 0.01),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Change payment mode',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xff2378D8),
              ),
            ),
          ),

          SizedBox(height: SizeConfig.screenHeight * 0.03),

          CustomButton(
            hasIcon: true,
            iconData: Icons.cancel_outlined,
            iconColor: Colors.white,
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AppDialog(
                    isDelete: true,
                    onYesPressed: () async {
                      NavigationService().pop();

                      final reason = await showModalBottomSheet<String>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) {
                          return const CancelRideBottomSheet();
                        },
                      );

                      if (reason == null) {
                        NavigationService().pop();
                        return;
                      }

                      await mapStoreProvider().cancelRide(reason);
                    },
                    title: ' Cancellation fee - \$2',
                    subTitle:
                        'Your driver is already on their way! A small cancellation fee will apply to fairly compensate their time and effort.',
                    actionButtonTitle: 'Cancel Anyway',
                    color: Theme.of(context).colorScheme.onError,
                    icon: Assets.cancelIc,
                    cancelTitle: 'Continue with ride',
                  );
                },
              );
            },
            text: 'Cancel ride',
            shadowColor: Theme.of(context).colorScheme.onError,
            showShadow: false,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _iconWithTextWidget({
    required BuildContext context,
    required String value,
    required String icon,
  }) {
    return Row(
      children: [
        CustomImageView(
          svgPath: icon,
          height: SizeConfig.screenHeight * 0.025,
          width: SizeConfig.screenHeight * 0.025,
        ),
        SizedBox(width: SizeConfig.screenWidth * 0.02),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }
}
