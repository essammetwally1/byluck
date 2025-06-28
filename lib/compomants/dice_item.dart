import 'package:flutter/material.dart';
import 'dart:math';

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
    final diceSize = MediaQuery.of(context).size.width * 0.3;

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[200],
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _sum == 0 ? 'Tap to Roll' : 'Sum: $_sum',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AnimatedDice(
                  controller: _controller,
                  rotationAnimation: _rotationAnimation,
                  bounceAnimation: _bounceAnimation,
                  direction: _rotationDirection,
                  size: diceSize,
                  child: _buildDiceFace(_dice1Value, diceSize),
                ),
                _AnimatedDice(
                  controller: _controller,
                  rotationAnimation: _rotationAnimation,
                  bounceAnimation: _bounceAnimation,
                  direction: -_rotationDirection,
                  size: diceSize,
                  child: _buildDiceFace(_dice2Value, diceSize),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _rollDice,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                shadowColor: Colors.red.withOpacity(0.4),
              ),
              child: const Text(
                'ROLL DICE',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
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
        return Transform(
          transform:
              Matrix4.identity()
                ..rotateY(rotationAnimation.value * direction)
                ..translate(0.0, -20.0 * bounceAnimation.value),
          alignment: Alignment.center,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
