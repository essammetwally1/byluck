import 'package:byluck/providers/sound_provider.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:provider/provider.dart';

class DiceItem extends StatefulWidget {
  const DiceItem({super.key});

  @override
  State<DiceItem> createState() => _DiceItemState();
}

class _DiceItemState extends State<DiceItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _bounceAnimation;
  int _dice1Value = 1;
  int _dice2Value = 1;
  int _sum = 0;
  final Random _random = Random();
  bool _isRolling = false;
  int _rotationDirection = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
      ),
    );

    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.elasticOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _rollDice() async {
    if (_isRolling) return;

    Provider.of<SoundProvider>(context, listen: false).playSound('dice_roll');
    _rotationDirection *= -1;

    setState(() => _isRolling = true);
    _controller.forward(from: 0);

    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      _dice1Value = _random.nextInt(6) + 1;
      _dice2Value = _random.nextInt(6) + 1;
      _sum = _dice1Value + _dice2Value;
    });

    await _controller.forward().whenComplete(() {
      setState(() => _isRolling = false);
    });
  }

  Widget _buildDiceFace(int value, double size) {
    final dotSize = size * 0.15;
    final padding = size * 0.1;
    final centerOffset = size * 0.5 - dotSize * 0.5;

    final dot = Container(
      width: dotSize,
      height: dotSize,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 2, spreadRadius: 1),
        ],
      ),
    );

    switch (value) {
      case 1:
        return Center(child: dot);
      case 2:
        return Stack(
          children: [
            Positioned(top: padding, left: padding, child: dot),
            Positioned(bottom: padding, right: padding, child: dot),
          ],
        );
      case 3:
        return Stack(
          children: [
            Positioned(top: padding, left: padding, child: dot),
            Center(child: dot),
            Positioned(bottom: padding, right: padding, child: dot),
          ],
        );
      case 4:
        return Stack(
          children: [
            Positioned(top: padding, left: padding, child: dot),
            Positioned(top: padding, right: padding, child: dot),
            Positioned(bottom: padding, left: padding, child: dot),
            Positioned(bottom: padding, right: padding, child: dot),
          ],
        );
      case 5:
        return Stack(
          children: [
            Positioned(top: padding, left: padding, child: dot),
            Positioned(top: padding, right: padding, child: dot),
            Center(child: dot),
            Positioned(bottom: padding, left: padding, child: dot),
            Positioned(bottom: padding, right: padding, child: dot),
          ],
        );
      case 6:
        return Stack(
          children: [
            Positioned(top: padding, left: padding, child: dot),
            Positioned(top: padding, right: padding, child: dot),
            Positioned(top: centerOffset - 8, left: padding, child: dot),
            Positioned(top: centerOffset - 8, right: padding, child: dot),
            Positioned(bottom: padding, left: padding, child: dot),
            Positioned(bottom: padding, right: padding, child: dot),
          ],
        );

      default:
        return Center(child: Text(value.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Colors.grey[200],
          boxShadow: [
            BoxShadow(color: Colors.red, blurRadius: 20, spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: 100),
            _sum > 0
                ? Container(
                  width: size.width * .4,
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.5),
                        blurRadius: 1,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.4),
                        blurRadius: 2,
                        spreadRadius: 5,
                      ),
                    ],
                    border: Border.all(color: Colors.red[200]!, width: 3),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.celebration_outlined,
                        size: 32,
                        color: Colors.red[200],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_sum',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.red[800],
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                )
                : SizedBox(height: 100),
            Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AnimatedDice(
                  controller: _controller,
                  rotationAnimation: _rotationAnimation,
                  bounceAnimation: _bounceAnimation,
                  direction: _rotationDirection,
                  size: size.width * .3,
                  child: _buildDiceFace(_dice1Value, size.width * .3),
                ),
                _AnimatedDice(
                  controller: _controller,
                  rotationAnimation: _rotationAnimation,
                  bounceAnimation: _bounceAnimation,
                  direction: -_rotationDirection,
                  size: size.width * .3,
                  child: _buildDiceFace(_dice2Value, size.width * .3),
                ),
              ],
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _rollDice,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[500],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 35,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                shadowColor: Colors.red.withValues(alpha: .3),
              ),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child:
                    _sum == 0
                        ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.casino, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Roll Dice',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                        : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Roll Again',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
            SizedBox(height: size.width * .3),
          ],
        ),
      ),
    );
  }
}

class _AnimatedDice extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> rotationAnimation;
  final Animation<double> bounceAnimation;
  final int direction;
  final double size;
  final Widget child;

  const _AnimatedDice({
    required this.controller,
    required this.rotationAnimation,
    required this.bounceAnimation,
    required this.direction,
    required this.size,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final double progress = controller.value;
        final bool isSpinning = progress < 0.7;
        final bool isSettling = progress >= 0.7 && progress < 1.0;
        final bool isComplete = progress == 1.0;

        // Natural rotation with easing
        final double rotation = rotationAnimation.value * direction;
        final double easedRotation =
            isSpinning
                ? rotation
                : rotation + (0 - rotation) * ((progress - 0.7) / 0.3);

        // Enhanced bounce with physics
        final double bounceHeight = -30.0 * bounceAnimation.value;
        final double settleBounce =
            isSettling ? 5.0 * sin((progress - 0.7) * 10 * pi) : 0.0;

        // Visual effects based on animation phase
        final double shadowBlur = isSpinning ? 20.0 : 15.0;
        final double shadowSpread = isSpinning ? 3.0 : 2.0;
        final double glowIntensity = isSettling ? (progress - 0.7) * 3 : 0.0;
        final double scale = isComplete ? 1.05 : 1.0;

        return Transform.translate(
          offset: Offset(0.0, bounceHeight + settleBounce),
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.0).animate(
              CurvedAnimation(
                parent: controller,
                curve: const Interval(0.8, 1.0, curve: Curves.elasticOut),
              ),
            ),
            child: Transform.rotate(
              angle: easedRotation,
              alignment: Alignment.center,
              child: Container(
                width: size * scale,
                height: size * scale,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    // Main shadow
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: shadowBlur,
                      spreadRadius: shadowSpread,
                      offset: const Offset(0, 6),
                    ),
                    // Inner highlight
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.6),
                      blurRadius: 4,
                      spreadRadius: -2,
                      offset: const Offset(0, -3),
                    ),
                    // Settling glow effect
                    if (isSettling)
                      BoxShadow(
                        color: Colors.amber,
                        blurRadius: 30 * glowIntensity,
                        spreadRadius: 8 * glowIntensity,
                      ),
                    // Final highlight
                    if (isComplete)
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.8),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, -2),
                      ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.grey.shade100,
                      if (isComplete) Colors.amber.shade50,
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.all(isSpinning ? 6 : 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.red[300]!,
                          Colors.red[500]!,
                          if (isSettling) Colors.amber[400]!,
                          if (isComplete) Colors.red[600]!,
                        ],
                      ),
                      boxShadow: [
                        if (isComplete)
                          BoxShadow(
                            color: Colors.red[300]!.withValues(alpha: 0.6),
                            blurRadius: 20,
                            spreadRadius: 3,
                          ),
                      ],
                    ),
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 200),
                      scale: isComplete ? 1.15 : 1.0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isSpinning ? 0.9 : 1.0,
                        child: Center(child: child),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
