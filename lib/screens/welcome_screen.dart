import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../config/consent_dialog.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F2C23), Colors.black, Color(0xFF1A1A1A)],
              ),
            ),
          ),

          // 2. CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // PREMIUM ICON
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                        color: AppColors.accentGold.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accentGold.withOpacity(0.5), width: 2),
                        boxShadow: [
                          BoxShadow(color: AppColors.accentGold.withOpacity(0.2), blurRadius: 30, spreadRadius: 5)
                        ]
                    ),
                    child: const Icon(Icons.verified_user, size: 60, color: AppColors.accentGold),
                  ),

                  const SizedBox(height: 30),

                  // TEXT CONTENT
                  Text(
                    "PREMIUM UNLOCKED",
                    style: GoogleFonts.oswald(color: Colors.white, fontSize: 28, letterSpacing: 2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Complimentary Family License",
                    style: GoogleFonts.lato(color: AppColors.accentGold, fontSize: 14, letterSpacing: 1, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // DESCRIPTION BOX
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "You have been granted 60 days of full clinical access.",
                          style: GoogleFonts.lato(color: Colors.white, fontSize: 16, height: 1.4),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        const Divider(color: Colors.white10),
                        const SizedBox(height: 15),
                        _buildFeatureRow(Icons.family_restroom, "Audit Parents, Spouse & Kids"),
                        _buildFeatureRow(Icons.monitor_heart, "Log Vitals & Symptoms"),
                        _buildFeatureRow(Icons.description, "Generate Clinical Reports"),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ACTION BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => _showConsent(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 10,
                      ),
                      child: Text(
                        "ACTIVATE LICENSE",
                        style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context, false), // Dismiss without saving
                    child: Text("Skip for now", style: GoogleFonts.lato(color: Colors.white30, fontSize: 12)),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentGold, size: 18),
          const SizedBox(width: 15),
          Expanded(child: Text(text, style: GoogleFonts.lato(color: Colors.white70, fontSize: 14))),
        ],
      ),
    );
  }

  void _showConsent(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ConsentDialog(
        onAccepted: () {
          // Return TRUE to dashboard indicating onboarding is done
          Navigator.pop(context, true);
        },
      ),
    );
  }
}