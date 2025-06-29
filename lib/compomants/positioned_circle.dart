import 'package:flutter/material.dart';

class PositionedCircle extends StatelessWidget {
  const PositionedCircle({
    super.key,
    required this.pos,
    required this.containerSize,
    this.scale = 2,
    this.baseSizeFactor = 0.25,
    this.containerPadding = 30,
    this.isSelected = false,
  });

  final Offset pos;
  final Size containerSize;
  final double scale;
  final double baseSizeFactor;
  final double containerPadding;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final baseSize = containerSize.shortestSide * baseSizeFactor;
    final scaledSize = baseSize * scale; // Removed selection scaling

    final availableWidth = containerSize.width - 2 * containerPadding;
    final availableHeight = containerSize.height - 2 * containerPadding;

    final constrainedX = pos.dx.clamp(
      containerPadding + scaledSize / 2,
      containerPadding + availableWidth - scaledSize / 2,
    );

    final constrainedY = pos.dy.clamp(
      containerPadding + scaledSize / 2,
      containerPadding + availableHeight - scaledSize / 2,
    );

    return Positioned(
      left: constrainedX - scaledSize / 2,
      top: constrainedY - scaledSize / 2,
      child: Transform.scale(
        scale: isSelected ? scale * 1.2 : scale,
        child: Container(
          width: baseSize,
          height: baseSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white, // Always white
            boxShadow: [
              BoxShadow(
                color: Colors.red, // Always red shadow
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: Colors.white, // Always white border
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
