import 'package:byluck/widgets/chooser_appbar.dart';
import 'package:byluck/widgets/chooser_back_bodies.dart';
import 'package:byluck/widgets/chooser_body.dart';
import 'package:byluck/widgets/dice_body.dart';
import 'package:byluck/widgets/random_body.dart';
import 'package:byluck/widgets/arrow_body.dart';
import 'package:byluck/widgets/roulette_body.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Updated enum to include roulette
enum SelectionMode { chooser, arrow, random, roulette, dice }

class ChooserScreen extends StatefulWidget {
  const ChooserScreen({super.key});

  @override
  State<ChooserScreen> createState() => _ChooserScreenState();
}

class _ChooserScreenState extends State<ChooserScreen> {
  SelectionMode selectedMode = SelectionMode.chooser;
  int randomNumber = 0;
  bool isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: ChooserAppBar(),
      ),
      body: Stack(
        children: [
          // Background elements
          const ChooserBackBody1(),
          const ChooserBackBody2(),

          // Main content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildSelectedBody(),
          ),

          // Bottom selector with 4 options
          Positioned(
            bottom: 24,
            left: 12,
            right: 12,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12, // Further reduced for 4 buttons
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IntrinsicWidth(
                  child: Row(
                    children: [
                      _buildModeButton('Chooser', SelectionMode.chooser),
                      _buildDivider(),
                      _buildModeButton('Arrow', SelectionMode.arrow),
                      _buildDivider(),
                      _buildModeButton('Roulette', SelectionMode.roulette),
                      _buildDivider(),
                      _buildModeButton('Random', SelectionMode.random),
                      _buildDivider(),
                      _buildModeButton('Dice', SelectionMode.dice),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedBody() {
    switch (selectedMode) {
      case SelectionMode.chooser:
        return const ChooserBody();
      case SelectionMode.arrow:
        return const ArrowBody();
      case SelectionMode.random:
        return const RandomBody();
      case SelectionMode.roulette:
        return const RouletteBody();
      case SelectionMode.dice:
        return const DiceBody(); // Add your RouletteBody widget here
    }
  }

  Widget _buildModeButton(String text, SelectionMode mode) {
    final isSelected = selectedMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => selectedMode = mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 2,
          ), // Adjusted padding
          decoration: BoxDecoration(
            color:
                isSelected ? Colors.red.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                style: TextStyle(fontSize: 15), // This will scale down
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 20, // Smaller divider
      margin: const EdgeInsets.symmetric(horizontal: 6), // Reduced margin
      color: Colors.grey.withOpacity(0.3),
    );
  }
}
