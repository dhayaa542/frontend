import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/registration_screen.dart';
import 'screens/roadmap_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isRegistered = prefs.getBool('is_registered') ?? false;
  runApp(FinLitApp(isRegistered: isRegistered));
}

class FinLitApp extends StatelessWidget {
  final bool isRegistered;

  const FinLitApp({super.key, required this.isRegistered});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinLit India',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF58CC02),
          primary: const Color(0xFF58CC02),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: isRegistered ? const RoadmapScreen() : const RegistrationScreen(),
    );
  }
}
