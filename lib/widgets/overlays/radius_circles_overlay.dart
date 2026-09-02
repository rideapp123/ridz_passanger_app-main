import '../../core/exports/common_exports.dart';
import '../painters/radius_circles_painter.dart';

class RadiusCirclesOverlay extends StatelessWidget {
  final List<double> radiusLevels;
  final Color color;

  const RadiusCirclesOverlay({
    super.key,
    this.radiusLevels = const [0.2, 0.4, 0.6],
    this.color = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RadiusCirclesPainter(
        radiusLevels: radiusLevels,
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Container(),
    );
  }
}