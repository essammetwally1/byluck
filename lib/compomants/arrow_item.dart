import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class ArrowItem extends StatefulWidget {
  final Color arrowColor;
  final Duration spinDuration;
  final double maxSpeed;
  final double deceleration;

  const ArrowItem({
    super.key,
    this.arrowColor = Colors.black,
    this.spinDuration = const Duration(seconds: 3),
    this.maxSpeed = 0.6,
    this.deceleration = 0.002,
  });

  @override
  State<ArrowItem> createState() => _ArrowItemState();
}

class _ArrowItemState extends State<ArrowItem> with TickerProviderStateMixin {
  late AnimationController _spinController;
  double _currentAngle = 0;
  double _velocity = 0;
  Timer? _decelerationTimer;
  bool _isSpinning = false;
  double _colorOpacity = 0.3;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateAngle);
  }

  void _updateAngle() {
    setState(() {
      _currentAngle += _velocity;
      _currentAngle %= (2 * pi);
    });
  }

  void _startSpin() {
    if (_isSpinning) return;
    _isSpinning = true;
    _colorOpacity = 0.3;

    _decelerationTimer?.cancel();
    setState(() => _velocity = widget.maxSpeed);
    _spinController.repeat();

    _decelerationTimer = Timer(
      Duration(
        milliseconds: (widget.spinDuration.inMilliseconds * 0.8).round(),
      ),
      _beginDeceleration,
    );
  }

  void _beginDeceleration() {
    const frameDuration = Duration(milliseconds: 16);
    _decelerationTimer = Timer.periodic(frameDuration, (timer) {
      setState(() {
        _colorOpacity = (_colorOpacity + 0.008).clamp(0.3, 1.0);
        _velocity *= 0.98;
        if (_velocity <= 0.01) {
          _velocity = 0;
          _isSpinning = false;
          _colorOpacity = 1.0;
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
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final containerSize = min(
            constraints.maxWidth,
            constraints.maxHeight,
          );
          final largeCircleSize = containerSize * 0.9;
          final smallCircleSize = containerSize * 0.15;
          final arrowLength = largeCircleSize * 0.9;

          return Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: Colors.grey[200],
              boxShadow: [
                BoxShadow(color: Colors.red, blurRadius: 20, spreadRadius: 2),
              ],
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
                    gradient: RadialGradient(
                      colors: [
                        Colors.red.withOpacity(0.2),
                        Colors.red.withOpacity(0.5),
                      ],
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.rotate(
                        angle: _currentAngle,
                        child: CustomPaint(
                          size: Size(arrowLength, 50),
                          painter: _ArrowPainter(
                            color: widget.arrowColor.withOpacity(_colorOpacity),
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
                      if (!_isSpinning && _velocity == 0)
                        Positioned(
                          bottom: 20,
                          child: Text(
                            'Tap to spin',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.red[400],
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(color: Colors.white, blurRadius: 20),
                              ],
                            ),
                          ),
                        ),
                    ],
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

  _ArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;
    final arrowBody =
        Path()
          ..moveTo(0, size.height * 0.3)
          ..lineTo(size.width - 25, size.height * 0.1)
          ..lineTo(size.width, size.height * 0.5)
          ..lineTo(size.width - 25, size.height * 0.9)
          ..lineTo(0, size.height * 0.7)
          ..close();
    canvas.drawPath(arrowBody, paint);
    canvas.drawCircle(Offset(size.width, size.height * 0.5), 8, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
