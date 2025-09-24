import 'package:byluck/providers/sound_provider.dart';
import 'package:flutter/material.dart';
import 'package:byluck/screens/main_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => SoundProvider(),
      child: const ByLuck(),
    ),
  );
}

class ByLuck extends StatelessWidget {
  const ByLuck({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF202020),
        primaryColor: Colors.blue,
        splashFactory: NoSplash.splashFactory,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          backgroundColor: Color(0xFF2C2C2C),
        ),
      ),

      home: const MainScreen(),
    );
  }
}
