import 'package:flutter/material.dart';
import 'screens/fatigue_tracker_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fatigue Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 4,
          ),
        ),
      ),
      home: const FatigueTrackerScreen(),
    );
  }
}
