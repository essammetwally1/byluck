import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

class RouletteItem extends StatefulWidget {
  const RouletteItem({super.key});

  @override
  State<RouletteItem> createState() => _RouletteItemState();
}

class _RouletteItemState extends State<RouletteItem>
    with TickerProviderStateMixin {
  StreamController<int> selected = StreamController<int>();
  final TextEditingController _textController = TextEditingController();
  List<String> items = ['Tap', 'Here'];
  int count = 0;
  String? _lastWinner; // Store the last winning prize

  // Add this color generator method
  Color _getSegmentColor(int index) {
    final colors = [
      Colors.red[700]!,
      Colors.orange[700]!,

      Colors.red[500]!,
      Colors.orange[500]!,

      Colors.red[300]!,
      Colors.orange[300]!,
      Colors.red,
      Colors.orange,
      Colors.purpleAccent,

      Colors.greenAccent,
    ];
    return colors[index % colors.length];
  }

  void _addToken() {
    final input = _textController.text.trim();
    if (count < 2) {
      items.removeAt(0);
      count++;
    }

    if (input.isNotEmpty) {
      setState(() {
        items.add(input);
        _textController.clear();
      });
      FocusScope.of(context).unfocus();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Congratulations!',
              style: TextStyle(color: Colors.black),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.celebration, color: Colors.red.shade300, size: 50),
                SizedBox(height: 20),
                Text(
                  count < 2 ? 'Add' : 'You get :',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                SizedBox(height: 10),
                Text(
                  count == 0
                      ? '2+ Items'
                      : count == 1
                      ? '1+ Items'
                      : (_lastWinner ?? 'Unknown Prize'),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('OK', style: TextStyle(color: Colors.red.shade300)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
    );
  }

  void _spin() {
    final randomIndex = Random().nextInt(items.length);
    selected.add(randomIndex);
    setState(() {
      _lastWinner = items[randomIndex]; // Store the winning prize
    });
  }

  @override
  void dispose() {
    selected.close();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;
    final paddingBetween =
        isPortrait ? screenSize.height * 0.02 : screenSize.width * 0.02;

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(color: Colors.red, blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(
              top: 6,
              bottom: 6,
              left: 9,
              right: 9,
            ),
            children: [
              SizedBox(height: screenSize.height / 50),
              // Input Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _textController,
                    onSubmitted:
                        (_) =>
                            _textController.text.trim().isEmpty
                                ? null
                                : _addToken(),
                    style: TextStyle(color: Colors.black, fontSize: 20),
                    decoration: InputDecoration(
                      labelText: 'Add item',
                      labelStyle: TextStyle(color: Colors.red[300]),
                      hintText: 'Enter item',
                      hintStyle: TextStyle(color: Colors.black.withOpacity(.2)),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.red),
                        onPressed: () {
                          if (_textController.text.trim().isNotEmpty) {
                            _addToken();
                            FocusScope.of(context).unfocus();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: paddingBetween + 10),
              SizedBox(
                width: screenSize.width * .7,
                height: screenSize.height * .5,
                child: Column(
                  children: [
                    Expanded(
                      child: FortuneWheel(
                        animateFirst: false,
                        alignment: Alignment.topCenter,
                        items: [
                          for (var it in items)
                            FortuneItem(
                              child: Text(it),
                              // Modified only this part for wheel colors:
                              style: FortuneItemStyle(
                                color: _getSegmentColor(items.indexOf(it)),
                                textStyle: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                        selected: selected.stream,
                        indicators: [
                          FortuneIndicator(
                            alignment: Alignment.topCenter,
                            child: Stack(
                              children: [
                                TriangleIndicator(
                                  color: Colors.red,
                                  width: 40,
                                  height: 50,
                                ),
                                Positioned(
                                  top: 10,
                                  left: 0,
                                  right: 0,
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.red.shade100,
                                    size: 30,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        duration: Duration(seconds: 5),
                        curve: Curves.decelerate,
                        rotationCount: 5,
                        hapticImpact: HapticImpact.medium,
                        onAnimationEnd: _showResultDialog,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _spin,
                  child: Text(
                    'SPIN',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: screenSize.height / 8,
            left: screenSize.width - (screenSize.width - 18),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  items = ['Tap', 'Here'];
                  count = 0;
                  _lastWinner = null;
                });
              },
              child: Container(
                width: screenSize.width / 9,
                height: screenSize.height / 19,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.restart_alt, size: 30, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
