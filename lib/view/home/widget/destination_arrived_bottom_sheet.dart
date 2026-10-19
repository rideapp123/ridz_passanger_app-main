import 'package:flutter/material.dart';
import 'package:ridzs_passenger_app/stores/map/map_store.dart';
import 'package:ridzs_passenger_app/models/common/ride_response/ride_response.dart';
import 'ride_rating_form.dart';

class DestinationArrivedBottomSheet extends StatelessWidget {
  const DestinationArrivedBottomSheet({super.key, required this.rideRequest});
  final RideRequest rideRequest;

  @override
  Widget build(BuildContext context) {
    final store = mapStoreProvider();
    return RideRatingForm(
      key: ValueKey(rideRequest.ride!.sId),
      rideId: rideRequest.ride!.sId!,
      participant: rideRequest.participantLabel,
      photoUrl: rideRequest.driverPhoto,
      service: store.ratings,
      foreground: Theme.of(context).colorScheme.onPrimary,
      background: Theme.of(context).colorScheme.secondary,
      submit: (stars, feedback) => store.submitFeedback(
          rideId: rideRequest.ride!.sId!, rating: stars, feedback: feedback),
    );
  }
}
