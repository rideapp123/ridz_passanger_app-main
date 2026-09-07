import 'package:flutter/material.dart';
import '../../core/theme/ridzs_theme.dart';

class BalanceSummary extends StatelessWidget {
  const BalanceSummary({
    super.key,
    required this.label,
    required this.amount,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
  });

  final String label;
  final String amount;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final ink = RidzsTheme.ink(context);
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: ink.withValues(alpha: .65))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Semantics(
            label: '$label: $amount',
            excludeSemantics: true,
            child: SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(amount,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()])),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.icon(
              onPressed: onAction,
              icon: Icon(actionIcon, size: 20),
              label: Text(actionLabel, textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }
}
