import 'dart:async';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isSecondSplash = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          isSecondSplash = true;
        });
      }

      Timer(const Duration(seconds: 5), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const figmaGreen = Color(0xFF3F8A7D);

    return Scaffold(
      backgroundColor: figmaGreen,
      body: Stack(
        children: [
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          SizedBox.expand(
            child: isSecondSplash
                ? _buildSplash2()
                : Center(child: _buildSplash1()),
          ),
        ],
      ),
    );
  }

  Widget _buildSplash1() {
    return const Text(
      'AI Study Assistant',
      style: TextStyle(
        color: Colors.white70,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildSplash2() {
    return Column(
      children: [
        const Spacer(flex: 3),
        const Icon(Icons.book_outlined, size: 90, color: Colors.white),
        const SizedBox(height: 25),
        const Text(
          'LEKSIKA',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'AI Study Assistant',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const Spacer(flex: 3),
        const Padding(
          padding: EdgeInsets.only(bottom: 30),
          child: Text(
            'Belajar lebih cerdas, Bukan lebih keras.',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
