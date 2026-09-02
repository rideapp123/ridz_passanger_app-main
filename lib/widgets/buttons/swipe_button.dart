import '../../core/exports/common_exports.dart';

class SwipeButton extends StatefulWidget {
  final Function() onSwipeComplete;

  const SwipeButton({
    super.key,
    required this.onSwipeComplete,
  });

  @override
  State<SwipeButton> createState() => _SwipeButtonState();
}

class _SwipeButtonState extends State<SwipeButton>
    with SingleTickerProviderStateMixin {
  double _dragExtent = 0;
  // bool _isDragging = false;
  late AnimationController _arrowAnimationController;
  late Animation<double> _arrowAnimation;
  // late Animation<double> _textSlideAnimation;

  @override
  void initState() {
    super.initState();
    _arrowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    // Arrow animation that moves left to right
    _arrowAnimation = Tween<double>(
      begin: -3.0,
      end: 3.0,
    ).animate(CurvedAnimation(
      parent: _arrowAnimationController,
      curve: Curves.easeInOut,
    ));

    // Text slide animation
    // _textSlideAnimation = Tween<double>(
    //   begin: 0.0,
    //   end: 10.0,
    // ).animate(CurvedAnimation(
    //   parent: _arrowAnimationController,
    //   curve: Curves.easeInOut,
    // ));

    _arrowAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _arrowAnimationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _arrowAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _arrowAnimationController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      // _isDragging = true;
      _dragExtent += details.primaryDelta!;
      _dragExtent = _dragExtent.clamp(
        0.0,
        MediaQuery.of(context).size.width * 0.44,
      );
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final threshold = MediaQuery.of(context).size.width * 0.3;
    if (_dragExtent >= threshold) {
      widget.onSwipeComplete();
    }
    setState(() {
      // _isDragging = false;
      _dragExtent = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.screenHeight * 0.07,
      margin: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(50),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.9),
            Colors.black,
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.14),
              spreadRadius: -3,
              offset: const Offset(-1, -0.5),
              blurRadius: 3,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Animated arrows and text
            AnimatedBuilder(
              animation: _arrowAnimationController,
              builder: (context, child) {
                return Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: SizeConfig.screenWidth * 0.07),
                      // Animated arrows
                      Transform.translate(
                        offset: Offset(_arrowAnimation.value, 0),
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.7),
                                Colors.white.withValues(alpha: 0.3),
                              ],
                            ).createShader(bounds);
                          },
                          child: const Text(
                            '»',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: SizeConfig.screenWidth * 0.03),
                      // Animated text with splash effect
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.white.withValues(alpha: 1),
                              Colors.white.withValues(alpha: 0.7),
                              Colors.white.withValues(alpha: 1),
                            ],
                            stops: [
                              0.0,
                              _arrowAnimationController.value,
                              1.0,
                            ],
                          ).createShader(bounds);
                        },
                        child: const Text(
                          'Swipe to cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Draggable thumb with improved touch area
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              child: Transform.translate(
                offset: Offset(_dragExtent, 0),
                child: Container(
                  width: SizeConfig.screenHeight * 0.07,
                  padding: const EdgeInsets.all(7),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF96040a),
                          Color(0xFFA11318),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.3),
                          offset: const Offset(0, -1),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                        child: Image.asset(
                      'assets/png/cancel-icon.png',
                      height: 20,
                    )),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
