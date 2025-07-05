import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MoProXSelfApp());
}

class MoProXSelfApp extends StatelessWidget {
  const MoProXSelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoPro x Self - ZK Age Verification',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
