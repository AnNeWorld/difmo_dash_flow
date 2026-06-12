// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:dashflow/company/services/api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dashflow/core/setup/onboarding_screen.dart';
import 'package:dashflow/shared/components/bottom_bar.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _jumpAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    // Scale (spring effect)
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticInOut));
    _jumpAnimation = Tween<double>(
      begin: 0,
      end: -15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    try {
      print("========== SPLASH SCREEN: FETCHING FCM TOKEN ==========");
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        print("========== SPLASH SCREEN FCM TOKEN ==========");
        print(fcmToken);
        print("=============================================");
        String platform = Platform.operatingSystem;
        String deviceId = "device-flutter";
        await ApiService().registerFcmToken(
          token: fcmToken,
          platform: platform,
          deviceId: deviceId,
        );
        print("========== FCM TOKEN API SUCCESS ==========");
      } else {
        print("========== SPLASH SCREEN FCM TOKEN IS NULL ==========");
      }
    } catch (e) {
      print("========== Failed to register FCM token in splash: $e ==========");
    }

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => widget.nextScreen),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _jumpAnimation.value),
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                'assets/images/logo.png',
                width: 90,
                height: 110,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Dashflow",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: Color(0xFF1F2937),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Manage your business smarter",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
