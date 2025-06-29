import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:byluck/screens/main_screen.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // simulate app startup
  Future.delayed(const Duration(seconds: 1), () {
    FlutterNativeSplash.remove();
    runApp(const ByLuck());
  });
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
