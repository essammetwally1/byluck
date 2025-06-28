import 'package:byluck/screens/chooser_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ByLuck());
}

class ByLuck extends StatelessWidget {
  const ByLuck({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChooserScreen(),
    );
  }
}
