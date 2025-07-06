import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Fade-in animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    // Scale animation (subtle bounce effect)
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    // Start animation
    _animationController.forward();

    // Navigate to HomeScreen after delay
    Timer(
      const Duration(seconds: 3),
      () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Custom purple color matching the app's theme
  final Color customPurple = const Color.fromRGBO(187, 181, 247, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo image with pulsing effect
                    Container(
                      height: 200,
                      width: 200,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade800,
                        boxShadow: [
                          BoxShadow(
                            color: customPurple.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/img/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // App title
                    Text(
                      'ZKAge Proof',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: customPurple,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Tagline
                    Text(
                      'Private Age Verification',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 50),
                    // Loading indicator
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(customPurple),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Hackathon mention
                    Text(
                      'EthGlobal Cannes 2025',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
