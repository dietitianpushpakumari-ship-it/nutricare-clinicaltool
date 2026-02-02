import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

// --- IMPORTS FOR NAVIGATION ---
import '../config/theme.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart'; // Ensure you created this file from the previous step

class ZeroReadGate extends StatefulWidget {
  const ZeroReadGate({super.key});

  @override
  State<ZeroReadGate> createState() => _ZeroReadGateState();
}

class _ZeroReadGateState extends State<ZeroReadGate> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 1. SETUP ANIMATION (Breathing/Pulsing Effect)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Speed of the pulse
    )..repeat(reverse: true); // Makes it grow and shrink continuously

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    // 2. START LOGIC CHECK
    _checkSession();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkSession() async {
    // Wait at least 3 seconds so the user sees the beautiful animation
    // (Even if the phone is fast, we force this delay for branding)
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();

    // A. Check Onboarding
    bool seenOnboarding = prefs.getBool('seen_onboarding') ?? false;

    // B. Check Login
    final String? phone = prefs.getString('promo_phone');
    final String? name = prefs.getString('promo_name');

    if (mounted) {
      // --- NAVIGATION LOGIC ---
      if (phone != null && phone.isNotEmpty) {
        // 1. User Logged In -> Go to Dashboard
        Navigator.pushReplacement(
          context,
          _createRoute(PremiumDashboard(contactNo: phone, userName: name ?? "Member")),
        );
      } else if (!seenOnboarding) {
        // 2. New User -> Go to Onboarding
        Navigator.pushReplacement(
          context,
          _createRoute(const OnboardingScreen()),
        );
      } else {
        // 3. Seen Onboarding but Not Logged In -> Go to Login
        Navigator.pushReplacement(
          context,
          _createRoute(const PremiumLoginScreen()),
        );
      }
    }
  }

  // --- SMOOTH FADE TRANSITION FOR NAVIGATION ---
  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 800), // Slow, premium fade
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. PREMIUM BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0F2C23), Colors.black], // Deep Forest Green to Black
              ),
            ),
          ),

          // 2. CENTER ANIMATION
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // A. THE GLOWING LOGO
                    Transform.scale(
                      scale: _scaleAnimation.value, // Applies the breathing scale
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(
                            color: AppColors.accentGold.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            // THE GLOW EFFECT
                            BoxShadow(
                              color: AppColors.accentGold.withOpacity(0.3 * _controller.value), // Opacity pulses
                              blurRadius: 30 * _controller.value, // Blur expands
                              spreadRadius: 10 * _controller.value, // Glow spreads
                            ),
                          ],
                        ),
                        // Replace this Icon with Image.asset('assets/logo.png') if you have one
                        child: const Icon(
                          Icons.spa_outlined,
                          color: AppColors.accentGold,
                          size: 60,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // B. TEXT FADE IN
                    Opacity(
                      opacity: _fadeAnimation.value > 0.5 ? 1.0 : _fadeAnimation.value * 2,
                      child: Column(
                        children: [
                          Text(
                            "NUTRICARE WELLNESS",
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Clinical Nutrition & Lifestyle Medicine",
                            style: GoogleFonts.lato(
                              color: Colors.white54,
                              fontSize: 10,
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // 3. BOTTOM LOADER (Minimalist)
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accentGold.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}