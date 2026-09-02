import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/models/ride/get_ride_response.dart'
    as ride_model;
import 'package:ridzs_passenger_app/models/ride/ride_trace_response.dart';
import 'package:ridzs_passenger_app/services/ride_service.dart';

class RideTraceScreen extends HookWidget {
  static const String routeNamed = 'RideTrace';

  final ride_model.Ride ride;

  const RideTraceScreen({
    super.key,
    required this.ride,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;
    final rideService = useMemoized(() => RideService());
    final refreshKey = useState(0);
    final traceFuture = useMemoized(
      () => rideService.getRideTrace(ride.id),
      [ride.id, refreshKey.value],
    );
    final snapshot = useFuture(traceFuture);

    return Scaffold(
      backgroundColor: themeColor.secondary,
      body: SafeArea(
        child: Column(
          children: [
            const TitleRowWidget(text: 'Ride Route'),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Center(
                      child:
                          CircularProgressIndicator(color: themeColor.primary),
                    );
                  }

                  if (snapshot.hasError) {
                    return _TraceError(
                      message: snapshot.error.toString(),
                      onRetry: () => refreshKey.value++,
                    );
                  }

                  final samples = snapshot.data ?? <RideTraceSample>[];
                  final validSamples = samples
                      .where((sample) => sample.hasValidCoordinate)
                      .toList();
                  return _TraceContent(ride: ride, samples: validSamples);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TraceContent extends StatelessWidget {
  final ride_model.Ride ride;
  final List<RideTraceSample> samples;

  const _TraceContent({
    required this.ride,
    required this.samples,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;
    final pickup = _validRidePoint(ride.pickup.latitude, ride.pickup.longitude);
    final destination =
        _validRidePoint(ride.destination.latitude, ride.destination.longitude);

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.screenWidth * 0.04,
        vertical: SizeConfig.screenHeight * 0.01,
      ),
      children: [
        _TraceMap(
          samples: samples,
          pickup: pickup,
          destination: destination,
        ),
        const SizedBox(height: 18),
        _TripSummary(ride: ride, sampleCount: samples.length),
        const SizedBox(height: 18),
        if (samples.isEmpty)
          const _EmptyTrace()
        else
          Text(
            'Trace samples',
            style: AppTextStyles.style18W500.copyWith(
              color: themeColor.tertiary,
              fontSize: 16,
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
          ),
        if (samples.isNotEmpty) const SizedBox(height: 10),
        if (samples.isNotEmpty)
          ...samples.asMap().entries.map(
                (entry) => _TraceSampleRow(
                  sample: entry.value,
                  isFirst: entry.key == 0,
                  isLast: entry.key == samples.length - 1,
                ),
              ),
      ],
    );
  }
}

class _TraceMap extends StatelessWidget {
  final List<RideTraceSample> samples;
  final LatLng? pickup;
  final LatLng? destination;

  const _TraceMap({
    required this.samples,
    this.pickup,
    this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;
    final tracePoints = samples.map((sample) => sample.latLng).toList();
    final framePoints = <LatLng>[
      if (pickup != null) pickup!,
      ...tracePoints,
      if (destination != null) destination!,
    ];

    if (framePoints.isEmpty) {
      return const _MapPlaceholder(
        icon: Icons.route,
        title: 'Route map unavailable',
        subtitle: 'No coordinates were saved for this ride yet.',
      );
    }

    final initialTarget = tracePoints.isNotEmpty
        ? tracePoints.first
        : pickup ?? destination ?? const LatLng(51.0447, -114.0719);
    final bounds = _boundsFor(framePoints);
    final markers = <Marker>{
      if (pickup != null)
        Marker(
          markerId: const MarkerId('pickup'),
          position: pickup!,
          infoWindow: const InfoWindow(title: 'Pickup'),
        ),
      if (destination != null)
        Marker(
          markerId: const MarkerId('destination'),
          position: destination!,
          infoWindow: const InfoWindow(title: 'Dropoff'),
        ),
      if (tracePoints.isNotEmpty)
        Marker(
          markerId: const MarkerId('trace_start'),
          position: tracePoints.first,
          infoWindow: const InfoWindow(title: 'Trace start'),
        ),
      if (tracePoints.length > 1)
        Marker(
          markerId: const MarkerId('trace_end'),
          position: tracePoints.last,
          infoWindow: const InfoWindow(title: 'Trace end'),
        ),
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 320,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialTarget,
            zoom: framePoints.length > 1 ? 13 : 15,
          ),
          markers: markers,
          polylines: {
            if (tracePoints.length > 1)
              Polyline(
                polylineId: const PolylineId('ride_trace'),
                points: tracePoints,
                color: themeColor.primary,
                width: 5,
              ),
          },
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: true,
          onMapCreated: (controller) {
            if (bounds == null) return;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              try {
                await controller.animateCamera(
                  CameraUpdate.newLatLngBounds(bounds, 56),
                );
              } catch (_) {}
            });
          },
        ),
      ),
    );
  }
}

class _TripSummary extends StatelessWidget {
  final ride_model.Ride ride;
  final int sampleCount;

  const _TripSummary({
    required this.ride,
    required this.sampleCount,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: themeColor.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ride.driverInfo != null && ride.driverInfo!.name.isNotEmpty
                      ? ride.driverInfo!.name
                      : 'Driver',
                  style: AppTextStyles.style12W500.copyWith(
                    color: themeColor.surface,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$sampleCount samples',
                style: AppTextStyles.style12W500.copyWith(
                  color: themeColor.surfaceContainer,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SummaryLocation(
            icon: Icons.radio_button_checked,
            title: ride.pickup.address.isEmpty ? 'Pickup' : ride.pickup.address,
          ),
          const SizedBox(height: 8),
          _SummaryLocation(
            icon: Icons.location_on,
            title: ride.destination.address.isEmpty
                ? 'Dropoff'
                : ride.destination.address,
          ),
        ],
      ),
    );
  }
}

class _SummaryLocation extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SummaryLocation({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: themeColor.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.style12W500.copyWith(
              color: themeColor.surface,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _TraceSampleRow extends StatelessWidget {
  final RideTraceSample sample;
  final bool isFirst;
  final bool isLast;

  const _TraceSampleRow({
    required this.sample,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;
    final timestamp = sample.recordedAt == null
        ? 'Time unavailable'
        : DateFormat('dd MMM, hh:mm a').format(sample.recordedAt!.toLocal());

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeColor.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeColor.primary.withValues(alpha: 0.12),
            ),
            child: Icon(
              isFirst
                  ? Icons.play_arrow
                  : isLast
                      ? Icons.flag
                      : Icons.navigation,
              color: themeColor.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timestamp,
                  style: AppTextStyles.style12W500.copyWith(
                    color: themeColor.surface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${sample.latitude.toStringAsFixed(5)}, ${sample.longitude.toStringAsFixed(5)}',
                  style: AppTextStyles.style12W500.copyWith(
                    color: themeColor.surfaceContainer,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (sample.speed != null)
            Text(
              '${sample.speed!.toStringAsFixed(0)} km/h',
              style: AppTextStyles.style12W500.copyWith(
                color: themeColor.surfaceContainer,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyTrace extends StatelessWidget {
  const _EmptyTrace();

  @override
  Widget build(BuildContext context) {
    return const _MapPlaceholder(
      icon: Icons.timeline,
      title: 'No trace samples yet',
      subtitle:
          'The ride route will appear after driver location samples are saved.',
    );
  }
}

class _TraceError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _TraceError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 42, color: themeColor.primary),
          const SizedBox(height: 14),
          Text(
            'Route unavailable',
            textAlign: TextAlign.center,
            style: AppTextStyles.style18W500.copyWith(
              color: themeColor.tertiary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.style12W500.copyWith(
              color: themeColor.surfaceContainer,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 140,
            child: CustomButton(
              text: 'Retry',
              onTap: onRetry,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MapPlaceholder({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;
    return Container(
      height: 220,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeColor.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: themeColor.primary),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.style18W500.copyWith(
              color: themeColor.tertiary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.style12W500.copyWith(
              color: themeColor.surfaceContainer,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

LatLng? _validRidePoint(double latitude, double longitude) {
  if (latitude < -90 ||
      latitude > 90 ||
      longitude < -180 ||
      longitude > 180 ||
      (latitude == 0 && longitude == 0)) {
    return null;
  }
  return LatLng(latitude, longitude);
}

LatLngBounds? _boundsFor(List<LatLng> points) {
  if (points.length < 2) return null;
  var south = points.first.latitude;
  var north = points.first.latitude;
  var west = points.first.longitude;
  var east = points.first.longitude;

  for (final point in points.skip(1)) {
    if (point.latitude < south) south = point.latitude;
    if (point.latitude > north) north = point.latitude;
    if (point.longitude < west) west = point.longitude;
    if (point.longitude > east) east = point.longitude;
  }

  if (south == north && west == east) return null;
  return LatLngBounds(
    southwest: LatLng(south, west),
    northeast: LatLng(north, east),
  );
}
