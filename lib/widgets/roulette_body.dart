import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

class RouletteBody extends StatefulWidget {
  const RouletteBody({super.key});

  @override
  State<RouletteBody> createState() => _RouletteBodyState();
}

class _RouletteBodyState extends State<RouletteBody>
    with TickerProviderStateMixin {
  StreamController<int> selected = StreamController<int>();
  final TextEditingController _textController = TextEditingController();
  List<String> items = ['Tap', 'Here'];
  int count = 0;
  String? _lastWinner; // Store the last winning prize

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

    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6, left: 9, right: 9),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.grey[300],
          boxShadow: [BoxShadow(color: Colors.red, blurRadius: 50)],
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
                          (_) => _textController.text == ' ' ? {} : _addToken(),
                      decoration: InputDecoration(
                        labelText: 'Add item',
                        labelStyle: TextStyle(color: Colors.red[300]),
                        hintText: 'Enter item',
                        hintStyle: TextStyle(
                          color: Colors.black.withOpacity(.2),
                        ),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.red),
                          onPressed:
                              _textController.text == ' ' ? () {} : _addToken,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: paddingBetween + 10),
                SizedBox(
                  width: screenSize.width * .7,
                  height: screenSize.height * .5,
                  child: GestureDetector(
                    onTap: _spin,

                    child: Column(
                      children: [
                        Expanded(
                          child: FortuneWheel(
                            animateFirst: false,
                            alignment: Alignment.topCenter,
                            items: [
                              for (var it in items)
                                FortuneItem(child: Text(it)),
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

                            // onAnimationEnd: () {
                            //   // Show dialog with result
                            //   showDialog(
                            //     context: context,
                            //     builder:
                            //         (context) => AlertDialog(
                            //           title: Text('You won!'),
                            //           content: Text('Congratulations!'),
                            //         ),
                            //   );
                            // },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Positioned(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade300,
                        padding: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
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
                  });
                },
                child: Container(
                  width: screenSize.width / 9,
                  height: screenSize.height / 19,
                  decoration: BoxDecoration(
                    color: Colors.red.shade300,

                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.restart_alt, size: 30, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
