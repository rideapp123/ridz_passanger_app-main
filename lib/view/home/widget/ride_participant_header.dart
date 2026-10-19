import 'package:flutter/material.dart';
import '../../../models/ride_participant.dart';
import '../../../models/common/ride_response/ride_response.dart';
import '../../../models/passenger_driver_credentials.dart';
import 'passenger_driver_credentials_screen.dart';
import '../../legal/ride_documents_screen.dart';

class RideParticipantHeader extends StatelessWidget {
  const RideParticipantHeader(
      {super.key,
      required this.name,
      this.photoUrl,
      this.vehicle,
      this.rideRequest});
  final String name;
  final String? photoUrl;
  final RideVehicle? vehicle;
  final RideRequest? rideRequest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = vehicle?.description ?? '';
    final plate = vehicle?.licensePlate ?? '';
    final binding = CredentialRideBinding.fromRide(rideRequest);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: 48,
        height: 48,
        child: ClipOval(
            child: (photoUrl?.startsWith('https://') ?? false)
                ? Image.network(photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.person_outline))
                : const Icon(Icons.person_outline, size: 32)),
      ),
      const SizedBox(width: 12),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name,
            style: theme.textTheme.titleMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(description.isEmpty ? 'Vehicle details unavailable' : description,
            style: theme.textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis),
        if (plate.isNotEmpty) Text(plate, style: theme.textTheme.titleSmall),
        if (rideRequest?.ride?.sId?.isNotEmpty == true)
          RideDocumentsButton(rideId: rideRequest!.ride!.sId!, active: true),
        if (binding != null)
          TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) =>
                          PassengerDriverCredentialsScreen(binding: binding))),
              icon: const Icon(Icons.badge_outlined),
              label: const Text('Credentials')),
      ])),
    ]);
  }
}
