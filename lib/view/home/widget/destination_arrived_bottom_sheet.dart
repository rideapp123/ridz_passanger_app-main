import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/core/services/toast_service.dart';
import 'package:ridzs_passenger_app/models/common/ride_response/ride_response.dart';

import '../../../stores/map/map_store.dart';

// import '../../../widgets/dialogs/app_dialog.dart';

class DestinationArrivedBottomSheet extends HookWidget {
  final RideRequest rideRequest;
  const DestinationArrivedBottomSheet({
    super.key,
    required this.rideRequest,
  });

  @override
  Widget build(BuildContext context) {
    final mapStore = mapStoreProvider();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final tips = ['\$5', '\$10', '\$15', '\$20'];
    final commentController = useTextEditingController();
    final rating = useState(0);
    const additionalInfo = [
      _AdditionalInfo(
        image: Assets.reportIc,
        title: 'Report issue',
      ),
      _AdditionalInfo(
        image: Assets.searchIc2,
        title: 'Lost items',
      ),
      _AdditionalInfo(
        image: Assets.supportIc,
        title: 'Support',
      ),
    ];

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

          //
          Text(
            'You’ve Arrived at your destination',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),

          SizedBox(height: SizeConfig.screenHeight * 0.01),

          Text(
            'Rate the trip and leave feedback for the driver',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onTertiary,
            ),
          ),

          SizedBox(height: SizeConfig.screenHeight * 0.01),

          Divider(
            color:
                !isDarkMode ? const Color(0xffF1F5F9) : const Color(0xff3F3F3F),
          ),

          SizedBox(height: SizeConfig.screenHeight * 0.01),

          Row(
            children: [
              //
              if ((rideRequest.driverPhoto ?? '').isEmpty)
                Container(
                  height: SizeConfig.screenHeight * 0.1,
                  width: SizeConfig.screenHeight * 0.1,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Icon(
                    Icons.person,
                    size: SizeConfig.screenHeight * 0.05,
                    color: Colors.white,
                  ),
                )
              else
                ClipOval(
                  child: CustomImageView(
                    url: rideRequest.driverPhoto,
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
                          'Rate your driver',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.onTertiary,
                          ),
                        ),

                        Text(
                          rideRequest.driverName ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),

                        SizedBox(height: SizeConfig.screenHeight * 0.01),

                        RatingBar.builder(
                          glow: false,
                          glowRadius: 0,
                          initialRating: rating.value.toDouble(),
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemSize: 32,
                          itemPadding: const EdgeInsets.symmetric(
                            horizontal: 2,
                          ),
                          itemBuilder: (context, _) => CustomImageView(
                            svgPath: Assets.starIc,
                            color: const Color(0xffF4C700),
                          ),
                          onRatingUpdate: (rate) {
                            rating.value = rate.toInt();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: SizeConfig.screenHeight * 0.02),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: tips.map((e) {
              return Container(
                alignment: Alignment.center,
                height: SizeConfig.screenHeight * 0.065,
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.screenWidth * 0.06,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceDim
                        .withValues(alpha: .6),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  e,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: SizeConfig.screenHeight * 0.02),

          customTextFormField(
            hintText: 'Write your comment here',
            controller: commentController,
            maxLines: 3,
            contentPadding: EdgeInsets.all(
              SizeConfig.screenHeight * 0.015,
            ),
            focusedBorderColor: Theme.of(context).colorScheme.primaryFixedDim,
            inputBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primaryFixedDim,
                width: 1,
              ),
            ),
            borderWidth: 1,
          ),

          SizedBox(height: SizeConfig.screenHeight * 0.02),

          Divider(
            color:
                !isDarkMode ? const Color(0xffF1F5F9) : const Color(0xff3F3F3F),
          ),

          SizedBox(height: SizeConfig.screenHeight * 0.02),

          Row(
            children: additionalInfo.map((e) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: SizeConfig.screenWidth * 0.02,
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.screenHeight * 0.02,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceDim
                          .withValues(alpha: .6),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //
                      CustomImageView(
                        svgPath: e.image,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),

                      SizedBox(height: SizeConfig.screenHeight * 0.01),

                      Text(
                        e.title,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: SizeConfig.screenHeight * 0.02),

          CustomButton(
            onTap: () async {
              if (rating.value == 0) {
                ToastService.show('Please select a rating');
                return;
              }

              await mapStore.submitFeedback(
                rideId: rideRequest.ride!.sId!,
                feedback: commentController.text,
                rating: rating.value,
              );

              ToastService.show('Feedback submitted successfully');
            },
            text: 'Continue',
          ),
        ],
      ),
    );
  }
}

@immutable
class _AdditionalInfo {
  final String image;
  final String title;

  const _AdditionalInfo({required this.image, required this.title});
}
