import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:promotional_app/model/assesment_model.dart';
import 'package:promotional_app/service/assessment_engine.dart';
import '../config/theme.dart';

import '../widgets/clinical_assessment.dart';

class AssessmentHubScreen extends StatelessWidget {
  final String contactNo;
  final String userName;
  final String lang;

  const AssessmentHubScreen({
    super.key,
    required this.contactNo,
    required this.userName,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    // Get all paths
    List<HealthPath> paths = AssessmentEngine.getAvailablePaths(30, 'Female');

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F2C23), Colors.black],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Clinical Diagnostics", style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 24)),
                          Text("Select a system to audit", style: GoogleFonts.lato(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Grid of Tests
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      // FIX 1: Make cards taller (smaller ratio = taller card)
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: paths.length,
                    itemBuilder: (context, index) {
                      return _buildAssessmentCard(context, paths[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard(BuildContext context, HealthPath path) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenAssessment(
              path: path,
              contactNo: contactNo,
              userName: userName,
              lang: lang,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.accentGold.withOpacity(0.2), shape: BoxShape.circle),
                  child: Icon(path.icon, color: AppColors.accentGold, size: 24),
                ),

                const SizedBox(height: 15),

                // FIX 2: Use Expanded here to handle content spacing dynamically
                // This prevents the "RenderFlex overflow" if text is too long
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end, // Push text to bottom of this section
                    children: [
                      Text(
                          path.title,
                          style: GoogleFonts.oswald(color: Colors.white, fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis
                      ),
                      const SizedBox(height: 5),
                      Text(
                        path.description,
                        style: GoogleFonts.lato(color: Colors.white54, fontSize: 10),
                        maxLines: 3, // Allowed 3 lines since we made card taller
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Button
                Row(
                  children: [
                    Text("START AUDIT", style: GoogleFonts.lato(color: AppColors.accentGold, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 5),
                    const Icon(Icons.arrow_forward, color: AppColors.accentGold, size: 12),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- FULL SCREEN WRAPPER ---
class FullScreenAssessment extends StatelessWidget {
  final HealthPath path;
  final String contactNo;
  final String userName;
  final String lang;

  const FullScreenAssessment({super.key, required this.path, required this.contactNo, required this.userName, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ClinicalAssessmentWidget(
            contactNo: contactNo,
            userName: userName,
            lang: lang,
            initialPath: path,
          ),
        ),
      ),
    );
  }
}