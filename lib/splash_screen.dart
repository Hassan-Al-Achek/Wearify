import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _opacityController;
  late AnimationController _sizeController;

  @override
  void initState() {
    super.initState();

    _opacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _sizeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/auth_gate');
    });
  }

  @override
  void dispose() {
    _opacityController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _opacityController,
              builder: (context, child) {
                return AnimatedBuilder(
                  animation: _sizeController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_sizeController.value * 0.05),
                      child: Opacity(
                        opacity: 0.5 + (_opacityController.value * 0.5),
                        child: child,
                      ),
                    );
                  },
                  child: child,
                );
              },
              child: const Text(
                'Welcome to Wearify',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
