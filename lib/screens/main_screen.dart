import 'package:byluck/compomants/arrow_item.dart';
import 'package:byluck/compomants/chooser_item.dart';
import 'package:byluck/compomants/dice_item.dart';
import 'package:byluck/compomants/random_item.dart';
import 'package:byluck/compomants/roulette_item.dart';
import 'package:byluck/widgets/byluck_app_title.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _spacing;

  final List<Widget> _screens = const [
    ChooserItem(),
    ArrowItem(),
    RouletteItem(),
    RandomItem(),
    DiceItem(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scale = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _spacing = Tween<double>(
      begin: 0.0,
      end: 15.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: ByluckAppTitle(
            controller: _controller,
            scale: _scale,
            spacing: _spacing,
          ),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _screens[_currentIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          fixedColor: Colors.red,
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState(() => _currentIndex = index),

          selectedLabelStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),

          items: const [
            BottomNavigationBarItem(icon: SizedBox.shrink(), label: 'Chooser'),
            BottomNavigationBarItem(icon: SizedBox.shrink(), label: 'Arrow'),
            BottomNavigationBarItem(icon: SizedBox.shrink(), label: 'Roulette'),
            BottomNavigationBarItem(icon: SizedBox.shrink(), label: 'Random'),
            BottomNavigationBarItem(icon: SizedBox.shrink(), label: 'Dice'),
          ],
        ),
      ),
    );
  }
}
