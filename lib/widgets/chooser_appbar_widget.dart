import 'package:flutter/material.dart';

class ChooserAppBarWidget extends StatelessWidget {
  const ChooserAppBarWidget({
    super.key,
    required AnimationController controller,
    required Animation<double> scale,
    required Animation<double> spacing,
  }) : _controller = controller,
       _scale = scale,
       _spacing = spacing;

  final AnimationController _controller;
  final Animation<double> _scale;
  final Animation<double> _spacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red,
            Colors.black,
            Color.fromARGB(113, 255, 255, 255),
            Colors.black,
            Colors.red,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Fixed "Eng\Essam" in top-left corner
            Positioned(
              left: 20,
              top: 12,
              child: Text(
                'Eng\\Essam',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.white, blurRadius: 4)],
                ),
              ),
            ),
            // Original animated content centered
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, __) {
                  return Transform.scale(
                    scale: _scale.value,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 12),
                        TitleTextStyle(title: 'By'),
                        SizedBox(width: _spacing.value),
                        TitleTextStyle(title: 'Luck'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TitleTextStyle extends StatelessWidget {
  final String title;
  const TitleTextStyle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white, // Main text color
        shadows: [
          Shadow(color: Colors.red, offset: Offset(2, 2), blurRadius: 5),
          Shadow(color: Colors.black, offset: Offset(-2, -2), blurRadius: 5),
          Shadow(color: Colors.white, offset: Offset(0, 1), blurRadius: 3),
        ],
      ),
    );
  }
}
