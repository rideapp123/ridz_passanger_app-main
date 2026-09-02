import 'package:intl/intl.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/core/services/toast_service.dart';
import 'package:ridzs_passenger_app/models/ride/get_ride_response.dart'
    as ride_model;
import 'package:ridzs_passenger_app/services/ride_service.dart';
import 'package:ridzs_passenger_app/view/faq_screen.dart';

class PaymentRecoveryScreen extends HookWidget {
  static const String routeNamed = 'PaymentRecovery';

  final ride_model.Ride ride;

  const PaymentRecoveryScreen({
    super.key,
    required this.ride,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;
    final rideService = useMemoized(() => RideService());
    final currentRide = useState(ride);
    final isRetrying = useState(false);
    final payment = currentRide.value.payment;

    Future<void> retryPayment() async {
      if (isRetrying.value || !payment.isRetryPending) return;
      isRetrying.value = true;
      try {
        currentRide.value = await rideService.retryRidePayment(ride.id);
        ToastService.show('Payment retry completed');
      } catch (e) {
        ToastService.show(e.toString());
      } finally {
        isRetrying.value = false;
      }
    }

    return Scaffold(
      backgroundColor: themeColor.secondary,
      body: SafeArea(
        child: Column(
          children: [
            const TitleRowWidget(text: 'Payment Recovery'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.screenWidth * 0.04,
                  vertical: SizeConfig.screenHeight * 0.015,
                ),
                children: [
                  _StatusPanel(payment: payment),
                  const SizedBox(height: 16),
                  _RidePanel(ride: currentRide.value),
                  const SizedBox(height: 16),
                  _AmountPanel(payment: payment),
                  const SizedBox(height: 22),
                  if (payment.isRetryPending)
                    CustomButton(
                      text: 'Retry payment',
                      isLoading: isRetrying.value,
                      onTap: retryPayment,
                    )
                  else if (payment.needsSupportReview)
                    CustomButton(
                      text: 'Contact support',
                      onTap: () {
                        NavigationService().navigateTo(FAQScreen.routeNamed);
                      },
                    )
                  else
                    CustomButton(
                      text: 'Done',
                      onTap: () {
                        NavigationService().pop(currentRide.value);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  final ride_model.Payment payment;

  const _StatusPanel({required this.payment});

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;
    final isRetryPending = payment.isRetryPending;
    final needsSupport = payment.needsSupportReview;
    final title = isRetryPending
        ? 'Payment retry pending'
        : needsSupport
            ? 'Support review'
            : 'Payment settled';
    final subtitle = isRetryPending
        ? 'Only part of this ride was captured. You can retry the remaining fare now.'
        : needsSupport
            ? 'Automatic retries did not settle the remaining fare. Support can review this ride.'
            : 'This ride payment has been settled.';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColor.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isRetryPending
                ? Icons.sync
                : needsSupport
                    ? Icons.support_agent
                    : Icons.check_circle,
            color: themeColor.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.style18W500.copyWith(
                    color: themeColor.tertiary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: AppTextStyles.style12W500.copyWith(
                    color: themeColor.surfaceContainer,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RidePanel extends StatelessWidget {
  final ride_model.Ride ride;

  const _RidePanel({required this.ride});

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
          Text(
            'Ride ${ride.id}',
            style: AppTextStyles.style12W500.copyWith(
              color: themeColor.tertiary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _LocationLine(
            icon: Icons.radio_button_checked,
            text: ride.pickup.address.isEmpty ? 'Pickup' : ride.pickup.address,
          ),
          const SizedBox(height: 8),
          _LocationLine(
            icon: Icons.location_on,
            text: ride.destination.address.isEmpty
                ? 'Dropoff'
                : ride.destination.address,
          ),
        ],
      ),
    );
  }
}

class _LocationLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _LocationLine({
    required this.icon,
    required this.text,
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
            text,
            style: AppTextStyles.style12W500.copyWith(
              color: themeColor.surface,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _AmountPanel extends StatelessWidget {
  final ride_model.Payment payment;

  const _AmountPanel({required this.payment});

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
        children: [
          _AmountRow(
            label: 'Captured',
            value: _money(payment.capturedAmount),
          ),
          const Divider(height: 20),
          _AmountRow(
            label: 'Remaining',
            value: _money(payment.adjustmentRemaining),
          ),
          const Divider(height: 20),
          _AmountRow(
            label: 'Attempts',
            value: '${payment.adjustmentAttempts ?? 0}',
          ),
          if (payment.nextRetryAt.isNotEmpty) ...[
            const Divider(height: 20),
            _AmountRow(
              label: 'Next automatic retry',
              value: _formatRetryAt(payment.nextRetryAt),
            ),
          ],
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final String value;

  const _AmountRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.style12W500.copyWith(
              color: themeColor.surfaceContainer,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.style12W500.copyWith(
            color: themeColor.surface,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

String _money(double? amount) => '\$${(amount ?? 0).toStringAsFixed(2)}';

String _formatRetryAt(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  return DateFormat('dd MMM, hh:mm a').format(date.toLocal());
}
