import 'package:flutter/material.dart';

class ChooserBackBody1 extends StatelessWidget {
  const ChooserBackBody1({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3, bottom: 3, left: 5, right: 5),

      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [BoxShadow(color: Colors.black, blurRadius: 20)],
        ),
      ),
    );
  }
}

class ChooserBackBody2 extends StatelessWidget {
  const ChooserBackBody2({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 7, right: 7),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [BoxShadow(color: Colors.white, blurRadius: 20)],
        ),
      ),
    );
  }
}
