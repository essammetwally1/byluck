import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RandomItem extends StatefulWidget {
  const RandomItem({super.key});

  @override
  State<RandomItem> createState() => _RandomItemState();
}

class _RandomItemState extends State<RandomItem> {
  int _randomNumber = 0;
  bool _isGenerating = false;
  double _progressValue = 0.0;
  final Random _random = Random();

  Future<void> _generateRandomNumber() async {
    setState(() {
      _isGenerating = true;
      _progressValue = 0.0;
      _randomNumber = 0;
    });

    const totalDuration = Duration(seconds: 1);
    const interval = Duration(milliseconds: 50);
    final steps = totalDuration.inMilliseconds ~/ interval.inMilliseconds;
    final increment = 1.0 / steps;

    for (int i = 0; i < steps; i++) {
      await Future.delayed(interval);
      setState(() => _progressValue = (i + 1) * increment);
    }

    setState(() {
      _randomNumber = _random.nextInt(101);
      _isGenerating = false;
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait = size.height > size.width;

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          color: Colors.grey[200],
          boxShadow: [
            BoxShadow(color: Colors.red, blurRadius: 20, spreadRadius: 2),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Random Number 0-100',
                style: TextStyle(
                  fontSize: isPortrait ? size.width * 0.05 : size.height * 0.04,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: size.width * 0.6,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _generateRandomNumber,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    shadowColor: Colors.red.withOpacity(0.4),
                  ),
                  child: Text(
                    'Generate Number',
                    style: TextStyle(
                      fontSize:
                          isPortrait ? size.width * 0.04 : size.height * 0.03,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              if (_isGenerating)
                SizedBox(
                  width: size.width * 0.6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _progressValue,
                      backgroundColor: Colors.grey[400],
                      valueColor: AlwaysStoppedAnimation(Colors.red[400]!),
                      minHeight: 10,
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child:
                    _randomNumber > 0 || _isGenerating
                        ? Text(
                          _randomNumber > 0 ? '$_randomNumber' : '...',
                          key: ValueKey(_randomNumber),
                          style: TextStyle(
                            fontSize:
                                isPortrait
                                    ? size.width * 0.2
                                    : size.height * 0.15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.red.withOpacity(0.3),
                              ),
                            ],
                          ),
                        )
                        : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
