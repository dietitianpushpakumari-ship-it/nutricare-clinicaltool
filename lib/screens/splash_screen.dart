import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- IMPORTS ---
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Entrance Animation (Fade In & Scale Up)
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOut),
    );

    // 2. Glow Animation (Breathing Gold Shadow)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1, milliseconds: 500),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Start Animations
    _mainController.forward();
    _glowController.repeat(reverse: true);

    // 3. RUN LOGIC CHECK
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Wait 4 seconds for animation to play out
    await Future.delayed(const Duration(seconds: 4));

    final prefs = await SharedPreferences.getInstance();

    // A. Check Logic
    String? userPhone = prefs.getString('promo_phone');
    String? userName = prefs.getString('promo_name');
    bool seenOnboarding = prefs.getBool('seen_onboarding') ?? false;

    Widget nextScreen;

    if (userPhone != null && userName != null) {
      // User is logged in -> Dashboard
      nextScreen = PremiumDashboard(contactNo: userPhone, userName: userName);
    } else if (!seenOnboarding) {
      // New User -> Onboarding
      nextScreen = const OnboardingScreen();
    } else {
      // Returning User -> Login
      nextScreen = const PremiumLoginScreen();
    }

    // B. Navigate Smoothly
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1000),
          pageBuilder: (_, __, ___) => nextScreen,
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2C23), Colors.black],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_mainController, _glowController]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- THE GLOWING BRAND NAME ---
                      Text(
                        "Nutricare Wellness",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD4AF37), // Gold Text
                          shadows: [
                            // The Magic Glow
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withOpacity(0.6),
                              blurRadius: _glowAnimation.value,
                              spreadRadius: _glowAnimation.value / 2,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // SUBTITLE
                      Text(
                        "CLINICAL NUTRITION EXPERTS",
                        style: GoogleFonts.lato(
                          color: Colors.white54,
                          fontSize: 10,
                          letterSpacing: 5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}