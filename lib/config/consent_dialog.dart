import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

class ConsentDialog extends StatelessWidget {
  final VoidCallback onAccepted;

  const ConsentDialog({super.key, required this.onAccepted});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.accentGold, width: 1)),
        title: Row(
          children: [
            const Icon(Icons.privacy_tip_outlined, color: AppColors.accentGold),
            const SizedBox(width: 10),
            Text("Medical Disclaimer", style: GoogleFonts.oswald(color: Colors.white, fontSize: 20)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBullet("This tool is for **screening purposes only** and does not provide a medical diagnosis."),
            const SizedBox(height: 10),
            _buildBullet("Your data (symptoms & risk score) will be securely analyzed by **Dt. Pushpa** to generate your health report."),
            const SizedBox(height: 10),
            _buildBullet("By continuing, you consent to being contacted via **WhatsApp/Phone** to discuss your report findings."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            child: const Text("CANCEL", style: TextStyle(color: Colors.white30)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              onAccepted(); // Trigger the actual action
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGold),
            child: const Text("I AGREE & START", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    // Simple bold parser
    List<TextSpan> spans = [];
    text.split("**").asMap().forEach((index, part) {
      spans.add(TextSpan(
          text: part,
          style: TextStyle(
              //color: Colors.white70,
              fontSize: 13,
              fontWeight: index % 2 == 1 ? FontWeight.bold : FontWeight.normal, // Odd indexes are bold
              color: index % 2 == 1 ? Colors.white : Colors.white70
          )));
    });

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("• ", style: TextStyle(color: AppColors.accentGold, fontSize: 16)),
        Expanded(child: RichText(text: TextSpan(children: spans))),
      ],
    );
  }
}