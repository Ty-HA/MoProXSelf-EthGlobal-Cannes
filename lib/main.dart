import 'package:flutter/material.dart';
import 'core/constants/blockchain_constants.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MoproZKAgeApp());
}

class MoproZKAgeApp extends StatelessWidget {
  const MoproZKAgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mopro ZK Age Verification',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
