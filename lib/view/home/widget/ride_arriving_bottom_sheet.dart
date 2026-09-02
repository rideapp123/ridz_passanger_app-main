import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/models/common/ride_response/ride_response.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ride_chat_bottom_sheet.dart';

class RideArrivingBottomSheet extends HookWidget {
  final RideRequest rideRequest;
  const RideArrivingBottomSheet({
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          //
          Container(
            height: 4,
            width: SizeConfig.screenWidth * 0.1,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onTertiary.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(24),
            ),
          ),

          SizedBox(height: SizeConfig.screenHeight * 0.02),

          DriverInfoBoxWidget(
            driverName: rideRequest.driverName ?? 'N/A',
            driverImage: rideRequest.driverPhoto ?? '',
          ),

          SizedBox(height: SizeConfig.screenHeight * 0.02),

          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: SizeConfig.screenWidth * 0.04,
              top: SizeConfig.screenHeight * 0.02,
              bottom: SizeConfig.screenHeight * 0.02,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.onTertiary.withValues(alpha: .2),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
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
                        'Arriving in next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),

                      Text(
                        'Please be ready at the location',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                    ],
                  ),
                ),

                //
                SizedBox(
                  height: SizeConfig.screenHeight * 0.04,
                  child: VerticalDivider(
                    color: Theme.of(context)
                        .colorScheme
                        .onTertiary
                        .withValues(alpha: .2),
                    thickness: 1,
                    width: 1,
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.screenWidth * 0.06,
                  ),
                  child: Text(
                    '${rideRequest.ride!.waitingTimeInMinutes} Mins',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.surfaceContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: SizeConfig.screenHeight * 0.02),

          Row(
            children: [
              //
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      builder: (_) {
                        return RideChatBottomSheet(
                          rideRequest: rideRequest,
                        );
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: SizeConfig.screenHeight * 0.052,
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.screenWidth * 0.03,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceDim
                          .withValues(alpha: .1),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceDim
                            .withValues(alpha: .8),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomImageView(
                          svgPath: Assets.messagesIc,
                          height: 24,
                          width: 24,
                          color: isDarkMode
                              ? const Color(0xffA6A6A6)
                              : Colors.black,
                        ),
                        SizedBox(width: SizeConfig.screenWidth * 0.02),

                        //
                        Text(
                          'Chat With Your Driver',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.onTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: SizeConfig.screenWidth * 0.02),

              GestureDetector(
                onTap: () async {
                  // Call the driver's phone number
                  if (rideRequest.driverNumber != null) {
                    final Uri phoneUri =
                        Uri.parse('tel:${rideRequest.driverNumber}');
                    try {
                      await launchUrl(phoneUri);
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Unable to make phone call'),
                        ),
                      );
                    }
                  } else {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Driver phone number not available'),
                      ),
                    );
                  }

                  // NavigationService().pop();
                  // showModalBottomSheet(
                  //   context: context,
                  //   backgroundColor: Colors.transparent,
                  //   isScrollControlled: true,
                  //   builder: (_) {
                  //     return const RideStartedWidget();
                  //   },
                  // );
                  // showModalBottomSheet(
                  //   context: context,
                  //   backgroundColor: Colors.transparent,
                  //   isScrollControlled: true,
                  //   builder: (_) {
                  //     return const RideWaitingBottomSheet();
                  //   },
                  // );
                },
                child: Container(
                  alignment: Alignment.center,
                  width: SizeConfig.screenWidth * 0.1,
                  height: SizeConfig.screenWidth * 0.1,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: CustomImageView(
                    svgPath: Assets.phoneIc2,
                    height: 24,
                    width: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DriverInfoBoxWidget extends StatelessWidget {
  final String driverName;
  final String driverImage;
  const DriverInfoBoxWidget({
    super.key,
    required this.driverName,
    required this.driverImage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        //
        if (driverImage.isEmpty)
          Container(
            height: SizeConfig.screenHeight * 0.06,
            width: SizeConfig.screenHeight * 0.06,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.secondary,
              size: 18,
            ),
          )
        else
          ClipOval(
            child: CustomImageView(
              url: driverImage,
              height: SizeConfig.screenHeight * 0.06,
              width: SizeConfig.screenHeight * 0.06,
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
                    driverName,
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
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //
                      CustomImageView(
                        svgPath: Assets.starIc,
                        height: 20,
                        width: 20,
                      ),

                      SizedBox(width: SizeConfig.screenWidth * 0.01),

                      Text(
                        '4.8',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'HSW 4736 XK',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
