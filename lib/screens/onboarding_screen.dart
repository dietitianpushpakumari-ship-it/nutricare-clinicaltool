import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      "title": "Clinical Diagnostics",
      "desc": "Don't guess your health. Use our AI-powered clinical audit to check risks for Diabetes, Thyroid, and Heart issues in minutes.",
      "icon": Icons.health_and_safety_outlined,
    },
    {
      "title": "Family Health Guard",
      "desc": "One app for your entire family. Monitor the vitals of your parents, spouse, and kids. Generate instant PDF health reports.",
      "icon": Icons.family_restroom,
    },
    {
      "title": "Medical Nutrition",
      "desc": "Direct access to Dt. Pushpa Kumari. We don't just give diet plans; we provide medical nutrition therapy to reverse diseases.",
      "icon": Icons.spa_outlined, // Branding Icon
    },
  ];

  Future<void> _finishOnboarding() async {
    // 1. Save flag so this screen doesn't show again
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);

    // 2. Navigate to Login
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PremiumLoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // --- 1. BACKGROUND GRADIENT ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0F2C23), Colors.black], // Deep Green to Black
              ),
            ),
          ),

          // --- 2. GLOW ORB (Visual Polish) ---
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentGold.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentGold.withOpacity(0.1),
                    blurRadius: 100,
                    spreadRadius: 50,
                  )
                ],
              ),
            ),
          ),

          // --- 3. PAGE VIEW (The Slides) ---
          SafeArea(
            child: Column(
              children: [
                // SKIP BUTTON
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _finishOnboarding,
                    child: Text("SKIP", style: GoogleFonts.lato(color: Colors.white30, fontSize: 12)),
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      return _buildSlide(_slides[index]);
                    },
                  ),
                ),

                // --- 4. BOTTOM CONTROLS ---
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      // Page Indicators (Dots)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                              (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: _currentPage == index ? 25 : 6,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? AppColors.accentGold : Colors.white24,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Next / Get Started Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage == _slides.length - 1) {
                              _finishOnboarding();
                            } else {
                              _pageCtrl.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentGold,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 10,
                          ),
                          child: Text(
                            _currentPage == _slides.length - 1 ? "GET STARTED" : "NEXT",
                            style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ICON CIRCLE
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: AppColors.accentGold.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Icon(data['icon'], size: 80, color: AppColors.accentGold),
          ),
          const SizedBox(height: 40),

          // TEXT CONTENT
          Text(
            data['title'],
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            data['desc'],
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 15,
              color: Colors.white60,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}