import 'package:byluck/widgets/chooser_appbar_widget.dart';
import 'package:flutter/material.dart';

class ChooserAppBar extends StatefulWidget {
  const ChooserAppBar({super.key});

  @override
  State<ChooserAppBar> createState() => _ChooserAppBarState();
}

class _ChooserAppBarState extends State<ChooserAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _spacing;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Unique "pulse and return" motion
    _spacing = Tween<double>(begin: 20, end: 40).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
        reverseCurve: const Interval(0.4, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    // Scaling breath animation with a light bounce
    _scale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOutBack),
        reverseCurve: const Interval(0.0, 0.6, curve: Curves.decelerate),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChooserAppBarWidget(
      controller: _controller,
      scale: _scale,
      spacing: _spacing,
    );
  }
}
