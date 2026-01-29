import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:promotional_app/log_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../config/translations.dart';
import 'gate_screen.dart';

class PremiumDashboard extends StatefulWidget {
  final String tenantId;
  final String userName;
  const PremiumDashboard({super.key, required this.tenantId, required this.userName});

  @override
  State<PremiumDashboard> createState() => _PremiumDashboardState();
}

class _PremiumDashboardState extends State<PremiumDashboard> {
  String _selectedProfile = "Dad";
  final List<String> _profiles = ["Dad", "Mom", "Me", "Spouse"];

  // Language State
  String _lang = 'en';

  // --- NEW: FIREBASE INQUIRY SUBMISSION ---
  Future<void> _submitClinicalInquiry(int score, List<dynamic> symptoms) async {
   // ScaffoldMessenger.of(context).showSnackBar(
     //   const SnackBar(content: Text("Requesting callback..."))
   // );

    // Using the exact structure provided
    final inquiry = {
      'source': 'clinical_tool',
      'name': widget.userName, // Logged in user name
      'contact': {
        'phone': widget.tenantId, // Logged in phone number
        'email': null,
        'wa': true
      },
      'clinical': {
        'notes': 'Risk Score: $score/100. Symptoms: ${symptoms.join(", ")}',
        'tier': null,
        'goal': null
      },
      'meta': {
        'time': DateTime.now().toIso8601String(),
        'status': 'New'
      },
    };

    try {
      await FirebaseFirestore.instance.collection('enquiries').add(inquiry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Request sent! Dt. Pushpa Kumari's team will contact you shortly."),
              backgroundColor: Colors.green,
            )
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, ${widget.userName}", style: GoogleFonts.playfairDisplay(fontSize: 20, color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
            Text(_selectedProfile, style: GoogleFonts.lato(fontSize: 12, color: AppColors.accentGold, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          // LANGUAGE SWITCHER
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _lang,
              icon: const Icon(Icons.language, color: AppColors.primaryDark),
              items: const [
                DropdownMenuItem(value: 'en', child: Text("Eng")),
                DropdownMenuItem(value: 'hi', child: Text("हिंदी")),
                DropdownMenuItem(value: 'or', child: Text("ଓଡ଼ିଆ")),
              ],
              onChanged: (v) => setState(() => _lang = v!),
            ),
          ),
          const SizedBox(width: 15),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textLight),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if(mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ZeroReadGate()));
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSmartLogSheet(context),
        backgroundColor: AppColors.primaryDark,
        icon: const Icon(Icons.add, color: AppColors.accentGold),
        label: Text(AppTranslations.keys[_lang]!['analyze_btn']!, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ),

      // ✅ FIX: Column layout ensures Tabs are always visible, even if Stream is empty
      body: Column(
        children: [
          // --- 1. PROFILE TABS (Fixed at Top) ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _profiles.map((p) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(p),
                    selected: _selectedProfile == p,
                    selectedColor: AppColors.primaryDark,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(color: _selectedProfile == p ? Colors.white : AppColors.textLight),
                    onSelected: (val) => setState(() => _selectedProfile = p),
                  ),
                )).toList(),
              ),
            ),
          ),

          // --- 2. DYNAMIC CONTENT AREA ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('promo_logs')
                    .where('tenant_id', isEqualTo: widget.tenantId)
                    .where('profile', isEqualTo: _selectedProfile)
                    .orderBy('timestamp', descending: true)
                    .limit(7) // Get last 7 days for trend
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                  List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) return _buildEmptyState();

                  // LATEST DATA
                  var latest = docs.first.data() as Map<String, dynamic>;
                  int score = (latest['health_score'] ?? 0).toInt();
                  List<dynamic> symptoms = latest['symptoms'] ?? [];

                  // TREND DATA (Reversed for Graph: Oldest -> Newest)
                  List<FlSpot> trendPoints = [];
                  for (int i = 0; i < docs.length; i++) {
                    int s = (docs[i]['health_score'] ?? 0).toInt();
                    trendPoints.add(FlSpot((docs.length - 1 - i).toDouble(), s.toDouble()));
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        // --- TREND GRAPH ---
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Metabolic Trend (7 Days)", style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                                  Text("$score/100", style: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold, color: _scoreColor(score))),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 150,
                                child: LineChart(
                                  LineChartData(
                                    gridData: FlGridData(show: false),
                                    titlesData: FlTitlesData(show: false),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: trendPoints,
                                        isCurved: true,
                                        color: AppColors.primaryDark,
                                        barWidth: 3,
                                        dotData: FlDotData(show: true),
                                        belowBarData: BarAreaData(show: true, color: AppColors.primaryDark.withOpacity(0.1)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // --- SYMPTOM CORRELATION ---
                        if (symptoms.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.rubyRed.withOpacity(0.05),
                              border: Border.all(color: AppColors.rubyRed.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  const Icon(Icons.warning_amber, color: AppColors.rubyRed),
                                  const SizedBox(width: 10),
                                  Text("${symptoms.length} Critical Signals Detected", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.rubyRed.withOpacity(0.8))),
                                ]),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  children: symptoms.map((s) => Chip(
                                    label: Text(AppTranslations.keys[_lang]?[s.toString()] ?? s.toString(), style: const TextStyle(fontSize: 10)),
                                    backgroundColor: Colors.white,
                                    side: BorderSide(color: AppColors.rubyRed.withOpacity(0.2)),
                                  )).toList(),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  "These symptoms combined with your score suggest metabolic distress. A diet correction is highly recommended.",
                                  style: GoogleFonts.lato(fontSize: 12, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 20),

                        // --- EXPERT CTA (Updated Name & Action) ---
                        if (score < 80)
                          InkWell(
                            onTap: () => _submitClinicalInquiry(score, symptoms), // ✅ New Action
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [AppColors.primaryDark, Color(0xFF1A4D3E)]),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: AppColors.primaryDark.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Clinical Action Needed", style: TextStyle(color: AppColors.accentGold, fontSize: 12, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 5),
                                        // ✅ Updated Name
                                        const Text("Consult Dt. Pushpa Kumari", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                        const Text("Fix your root cause before it worsens.", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    child: const Icon(Icons.arrow_forward, color: AppColors.primaryDark),
                                  )
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.monitor_heart_outlined, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text("No logs for $_selectedProfile", style: GoogleFonts.lato(color: Colors.grey)),
          Text("Tap '+ LOG VITALS' to start", style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _scoreColor(int s) => s > 80 ? Colors.green : (s > 50 ? Colors.orange : Colors.red);

  void _showSmartLogSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SmartLogSheet(
        tenantId: widget.tenantId,
        userName: widget.userName,
        selectedProfile: _selectedProfile,
        lang: _lang,
      ),
    );
  }
}