import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RandomBody extends StatefulWidget {
  const RandomBody({super.key});

  @override
  State<RandomBody> createState() => _RandomBodyState();
}

class _RandomBodyState extends State<RandomBody> {
  int randomNumber = 0;
  bool isGenerating = false;
  double progressValue = 0.0;

  void generateRandomNumber() async {
    setState(() {
      isGenerating = true;
      progressValue = 0.0;
      randomNumber = 0;
    });

    const totalDuration = Duration(seconds: 1);
    const interval = Duration(milliseconds: 50);
    final steps = totalDuration.inMilliseconds ~/ interval.inMilliseconds;
    final increment = 1.0 / steps;

    for (int i = 0; i < steps; i++) {
      await Future.delayed(interval);
      setState(() {
        progressValue = (i + 1) * increment;
      });
    }

    setState(() {
      randomNumber = Random().nextInt(101); // 0 to 100
      isGenerating = false;
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        // Background container
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02,
              vertical: screenHeight * 0.01,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.grey[300],
                boxShadow: [
                  BoxShadow(
                    color: Colors.red,
                    blurRadius: 50,
                    spreadRadius: -10,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Main content with fixed positioning
        Positioned(
          top: screenHeight * 0.3,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title text
              Text(
                'Generation Number 0 : 100',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),

              SizedBox(height: screenHeight * 0.05),

              // Generate button with fixed size
              SizedBox(
                width: screenWidth * 0.6,
                child: ElevatedButton(
                  onPressed: isGenerating ? null : generateRandomNumber,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    shadowColor: Colors.red.withOpacity(0.4),
                  ),
                  child: Text(
                    'Generate Number',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.05),

              // Progress indicator with fixed width
              if (isGenerating)
                SizedBox(
                  width: screenWidth * 0.6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: Colors.grey.shade400,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.red.shade400,
                      ),
                      minHeight: screenHeight * 0.015,
                    ),
                  ),
                ),

              SizedBox(height: screenHeight * 0.05),

              // Generated number display
              if (randomNumber > 0 || isGenerating)
                AnimatedScale(
                  scale: randomNumber > 0 ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    randomNumber > 0 ? '$randomNumber' : '...',
                    style: TextStyle(
                      fontSize: screenWidth * 0.15,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.red.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
