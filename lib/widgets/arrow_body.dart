import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class ArrowBody extends StatefulWidget {
  final Color smallCircleColor;
  final Color largeCircleColor;
  final Duration spinDuration;
  final double maxSpeed; // radians per frame
  final double deceleration; // slow down rate

  const ArrowBody({
    super.key,
    this.smallCircleColor = Colors.black,
    this.largeCircleColor = Colors.red,
    this.spinDuration = const Duration(seconds: 2),
    this.maxSpeed = 0.4, // Faster default speed
    this.deceleration = 0.003, // Stronger deceleration
  });

  @override
  State<ArrowBody> createState() => _ArrowBodyState();
}

class _ArrowBodyState extends State<ArrowBody> with TickerProviderStateMixin {
  late AnimationController _spinController;
  double _currentAngle = 0;
  double _velocity = 0;
  Timer? _decelerationTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // ~60fps
    )..addListener(_updateAngle);
  }

  void _updateAngle() {
    setState(() {
      _currentAngle += _velocity;
      _currentAngle %= (2 * pi); // Keep angle normalized
    });
  }

  void _startSpin() {
    // Cancel any existing timers
    _decelerationTimer?.cancel();

    // Start spinning at max speed
    setState(() => _velocity = widget.maxSpeed);
    _spinController.repeat();

    // Begin deceleration after 70% of spin duration
    _decelerationTimer = Timer(
      Duration(
        milliseconds: (widget.spinDuration.inMilliseconds * 0.7).round(),
      ),
      _beginDeceleration,
    );
  }

  void _beginDeceleration() {
    const frameDuration = Duration(milliseconds: 16);
    _decelerationTimer = Timer.periodic(frameDuration, (timer) {
      setState(() {
        _velocity -= widget.deceleration;
        if (_velocity <= 0) {
          _velocity = 0;
          _spinController.stop();
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    _decelerationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final containerSize = min(
            constraints.maxWidth,
            constraints.maxHeight,
          );
          final largeCircleSize = containerSize * 0.9;
          final smallCircleSize = containerSize * 0.15;
          final arrowLength = largeCircleSize * .9;

          return Padding(
            padding: const EdgeInsets.only(
              top: 6,
              bottom: 6,
              left: 9,
              right: 9,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.grey[300],
                boxShadow: [BoxShadow(color: Colors.red, blurRadius: 50)],
              ),
              child: Center(
                child: GestureDetector(
                  onTap: _startSpin,
                  child: Container(
                    width: largeCircleSize,
                    height: largeCircleSize,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(.2),
                          blurRadius: 10,
                        ),
                      ],
                      shape: BoxShape.circle,
                      color: const Color.fromARGB(50, 218, 111, 111),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.rotate(
                          angle: _currentAngle,
                          child: CustomPaint(
                            size: Size(arrowLength, 50),
                            painter: _ArrowPainter(
                              color: Colors.white,
                              velocity: _velocity,
                              maxSpeed: widget.maxSpeed,
                            ),
                          ),
                        ),
                        Container(
                          width: smallCircleSize,
                          height: smallCircleSize,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(color: Colors.white, blurRadius: 3),
                            ],
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(.5),
                          ),
                        ),
                        Container(
                          width: smallCircleSize / 3,
                          height: smallCircleSize / 3,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(color: Colors.black, blurRadius: 1),
                            ],
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final Color color;
  final double velocity;
  final double maxSpeed;

  _ArrowPainter({
    required this.color,
    required this.velocity,
    required this.maxSpeed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate opacity based on speed

    // Shadow paint (drawn first)
    final shadowPaint =
        Paint()
          ..color = Colors.white
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 5.0);

    // Main arrow paint
    final paint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;

    // Create arrow path
    final arrowBody =
        Path()
          ..moveTo(0, size.height * 0.3)
          ..lineTo(size.width - 25, size.height * 0.1)
          ..lineTo(size.width, size.height * 0.5)
          ..lineTo(size.width - 25, size.height * 0.9)
          ..lineTo(0, size.height * 0.7)
          ..close();

    // Draw shadow (offset slightly)
    canvas.save();
    canvas.drawPath(arrowBody, shadowPaint);
    canvas.restore();

    // Draw main arrow
    canvas.drawPath(arrowBody, paint);

    // Draw arrow tip (with shadow)
    final tipShadowPaint =
        Paint()
          ..color = Colors.white
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    final tipPaint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;

    // Draw tip shadow
    canvas.drawCircle(
      Offset(size.width + 2, size.height * 0.5 + 2),
      8,
      tipShadowPaint,
    );

    // Draw tip
    canvas.drawCircle(Offset(size.width, size.height * 0.5), 8, tipPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
