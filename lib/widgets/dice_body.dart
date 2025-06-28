import 'package:flutter/material.dart';
import 'dart:math';

class DiceBody extends StatefulWidget {
  const DiceBody({super.key});

  @override
  State<DiceBody> createState() => _DiceBodyState();
}

class _DiceBodyState extends State<DiceBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _animation;
  int _dice1Value = 1;
  int _dice2Value = 1;
  int _sum = 0;
  final Random _random = Random();
  bool _isRolling = false;
  int reverseRotate = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Rotation animation (0 to 2π)
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1, curve: Curves.easeInBack),
      ),
    );

    // Bounce animation (for return to position)
    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.elasticOut),
      ),
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.bounceOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _rollDice() async {
    if (_isRolling) return;
    reverseRotate *= -1;

    setState(() => _isRolling = true);
    _controller.forward(from: 0);

    // Generate new values at peak of rotation
    await Future.delayed(const Duration(milliseconds: 350));
    setState(() {
      _dice1Value = _random.nextInt(6) + 1;
      _dice2Value = _random.nextInt(6) + 1;
      _sum = _dice1Value + _dice2Value;
    });

    // Fix: Proper use of whenComplete()
    await _controller.forward().whenComplete(() {
      setState(() => _isRolling = false);
    });
  }

  Widget _buildDiceFace(int value) {
    const dotStyle = BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: Colors.black, blurRadius: 2)],
    );
    Widget dot = Container(width: 20, height: 20, decoration: dotStyle);

    switch (value) {
      case 1:
        return Center(child: dot);
      case 2:
        return Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(alignment: Alignment.topLeft, child: dot),
              Align(alignment: Alignment.bottomRight, child: dot),
            ],
          ),
        );
      case 3:
        return Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(alignment: Alignment.topLeft, child: dot),
              Center(child: dot),
              Align(alignment: Alignment.bottomRight, child: dot),
            ],
          ),
        );
      case 4:
        return Padding(
          padding: const EdgeInsets.all(45),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [dot, dot],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [dot, dot],
              ),
            ],
          ),
        );
      case 5:
        return Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [dot, dot],
              ),
              Center(child: dot),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [dot, dot],
              ),
            ],
          ),
        );
      case 6:
        return Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              3,
              (_) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [dot, dot],
              ),
            ),
          ),
        );
      default:
        return Center(
          child: Text(
            value.toString(),
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6, left: 9, right: 9),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.grey[300],
          boxShadow: [BoxShadow(color: Colors.red, blurRadius: 50)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(top: screenSize.height / 10),
              child: Container(
                width: screenSize.width / 3,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(29, 0, 0, 0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _sum == 0 ? 'Press ROLL' : 'Sum : $_sum',
                    style: TextStyle(
                      fontSize: _sum > 9 ? 15 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Two dice display with combined rotation and bounce
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // First dice
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final rotationValue = _rotationAnimation.value;
                      final bounceValue = _bounceAnimation.value;

                      return Transform(
                        transform:
                            Matrix4.identity()
                              ..rotateY(rotationValue)
                              ..translate(0.0, -20.0 * bounceValue),
                        alignment: Alignment.center,
                        child: Container(
                          width: screenSize.width * 0.4,
                          height: screenSize.height * 0.2,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.shade200,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: _buildDiceFace(_dice1Value),
                          ),
                        ),
                      );
                    },
                  ),

                  // Second dice
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final rotationValue = _rotationAnimation.value;
                      final bounceValue = _bounceAnimation.value;

                      return Transform(
                        transform:
                            Matrix4.identity()
                              ..rotateY(rotationValue)
                              ..translate(0.0, -20.0 * bounceValue),
                        alignment: Alignment.center,
                        child: Container(
                          width: screenSize.width * 0.4,
                          height: screenSize.height * 0.2,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.shade200,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: _buildDiceFace(_dice2Value),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Roll button
            Padding(
              padding: EdgeInsets.only(bottom: screenSize.height / 6),

              child: GestureDetector(
                onTap: _rollDice,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform(
                      transform:
                          Matrix4.identity()..rotateZ(
                            _isRolling
                                ? _animation.value / 5 * reverseRotate
                                : 0,
                          ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 100,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'ROLL',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
