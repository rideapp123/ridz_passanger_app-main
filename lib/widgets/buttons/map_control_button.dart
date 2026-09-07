import 'package:flutter/material.dart';
import '../../core/theme/ridzs_theme.dart';

class MapControlButton extends StatelessWidget {
  const MapControlButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RidzsTheme.paper(context),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: .16),
      shape: RoundedRectangleBorder(
        borderRadius: RidzsTheme.radius,
        side: BorderSide(color: RidzsTheme.line(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        constraints: const BoxConstraints.tightFor(width: 48, height: 48),
        icon: Icon(icon, color: RidzsTheme.ink(context), size: 22),
      ),
    );
  }
}
