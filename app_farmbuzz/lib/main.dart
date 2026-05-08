import 'package:flutter/material.dart';
import 'package:farmbuzz/features/landing/presentation/landing_screen.dart';

void main() {
  runApp(const FarmBuzzApp());
}

class FarmBuzzApp extends StatelessWidget {
  const FarmBuzzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FarmBuzz',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF08180F),
      ),
      home: const LandingScreen(),
    );
  }
}
