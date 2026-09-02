import 'package:ridzs_passenger_app/view/home/widget/ride_chat_bottom_sheet.dart';
import 'package:ridzs_passenger_app/view/home/widget/ride_arriving_bottom_sheet.dart';

import '../../../core/exports/common_exports.dart';
import '../../../models/common/ride_response/ride_response.dart';

class RideWaitingBottomSheet extends StatelessWidget {
  final RideRequest rideRequest;
  const RideWaitingBottomSheet({
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
              color: Theme.of(context).colorScheme.onTertiary.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(24),
            ),
          ),

          SizedBox(height: SizeConfig.screenHeight * 0.02),

          DriverInfoBoxWidget(
            driverName: rideRequest.driverName ?? '',
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
                        'Driver arrived ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),

                      Text(
                        'Waiting time after this charges applicable',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: SizeConfig.screenWidth * 0.02,
                ),

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
                    '${rideRequest.ride!.waitingTimeInMinutes} mins',
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
                        return Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).viewPadding.top,
                          ),
                          child: RideChatBottomSheet(
                            rideRequest: rideRequest,
                          ),
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
                onTap: () {
                  // NavigationService().pop();
                  // showModalBottomSheet(
                  //   context: context,
                  //   backgroundColor: Colors.transparent,
                  //   isScrollControlled: true,
                  //   builder: (_) {
                  //     return const RideStartedWidget();
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
