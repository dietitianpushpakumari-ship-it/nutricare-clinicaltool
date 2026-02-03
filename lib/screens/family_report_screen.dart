import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../config/constant.dart';
import '../service/report_generator.dart'; // Import for the download button

class FamilyReportScreen extends StatefulWidget {
  final String contactNo;
  final String userName;

  const FamilyReportScreen({super.key, required this.contactNo, required this.userName});

  @override
  State<FamilyReportScreen> createState() => _FamilyReportScreenState();
}

class _FamilyReportScreenState extends State<FamilyReportScreen> {
  bool _isLoading = true;
  Map<String, Map<String, dynamic>> _familyData = {};
  int _avgFamilyScore = 0;
  int _memberCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchFamilyData();
  }

  Future<void> _fetchFamilyData() async {
    final profiles = ['Dad', 'Mom', 'Me', 'Spouse', 'Kid'];
    int totalScore = 0;
    int count = 0;
    Map<String, Map<String, dynamic>> temp = {};

    try {
      for (String profile in profiles) {
        var snapshot = await FirebaseFirestore.instance
            .collection('lead_logs')
            .where('tenant_id', isEqualTo: tenant_id)
            .where('contact', isEqualTo: widget.contactNo)
            .where('profile', isEqualTo: profile)
            .orderBy('timestamp', descending: true)
            .limit(5)
            .get();

        if (snapshot.docs.isNotEmpty) {
          var logs = snapshot.docs.map((d) => d.data()).toList();
          var latest = logs.first;

          // Score Parsing
          int score = (latest['health_score'] is int)
              ? latest['health_score']
              : (double.tryParse(latest['health_score'].toString()) ?? 0).toInt();

          // Trend
          int oldScore = score;
          if (logs.length > 1) {
            var lastLog = logs.last;
            oldScore = (lastLog['health_score'] is int) ? lastLog['health_score'] : (double.tryParse(lastLog['health_score'].toString()) ?? 0).toInt();
          }

          temp[profile] = {
            'score': score,
            'trend': score - oldScore,
            'sugar': double.tryParse(latest['sugar']?.toString() ?? '0') ?? 0,
            'bp': double.tryParse(latest['bp_sys']?.toString() ?? '0') ?? 0,
            'symptoms': latest['symptoms'] ?? [],
            'date': (latest['timestamp'] as Timestamp).toDate(),
          };

          totalScore += score;
          count++;
        }
      }
    } catch (e) {
      debugPrint("Error fetching family data: $e");
    }

    if (mounted) {
      setState(() {
        _familyData = temp;
        _memberCount = count;
        _avgFamilyScore = count > 0 ? (totalScore / count).round() : 0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("FAMILY HEALTH AUDIT", style: GoogleFonts.oswald(color: Colors.white, letterSpacing: 1)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.accentGold),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: "Download PDF",
            onPressed: () => ReportGenerator.generateFamilyReport( widget.contactNo, widget.userName),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accentGold))
          : _memberCount == 0
          ? _buildEmptyState()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 25),
            Text("DETAILED BREAKDOWN", style: GoogleFonts.lato(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            ..._familyData.entries.map((e) => _buildMemberCard(e.key, e.value)),
            const SizedBox(height: 30),
            _buildFooterAdvice(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildSummaryCard() {
    Color statusColor = _avgFamilyScore > 80 ? Colors.greenAccent : (_avgFamilyScore > 50 ? Colors.orangeAccent : Colors.redAccent);
    String statusText = _avgFamilyScore > 80 ? "OPTIMAL" : (_avgFamilyScore > 50 ? "WARNING" : "CRITICAL");

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            height: 70, width: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor.withOpacity(0.2), border: Border.all(color: statusColor)),
            child: Text("$_avgFamilyScore", style: GoogleFonts.oswald(fontSize: 32, color: statusColor, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("FAMILY METABOLIC STATUS", style: GoogleFonts.lato(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                Text(statusText, style: GoogleFonts.oswald(color: Colors.white, fontSize: 28, height: 1.1)),
                const SizedBox(height: 5),
                Text("Based on $_memberCount active profiles.", style: GoogleFonts.lato(color: Colors.white54, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMemberCard(String name, Map<String, dynamic> data) {
    int score = data['score'];
    int trend = data['trend'];
    double sugar = data['sugar'];
    double bp = data['bp'];
    List symptoms = data['symptoms'];
    Color color = score > 80 ? Colors.greenAccent : (score > 50 ? Colors.orangeAccent : Colors.redAccent);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name.toUpperCase(), style: GoogleFonts.oswald(color: Colors.white, fontSize: 18)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                child: Text("Score: $score", style: GoogleFonts.lato(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              )
            ],
          ),
          const SizedBox(height: 10),
          // Vitals Row
          Row(
            children: [
              _vitalChip("Sugar", "${sugar.toInt()}", sugar > 140),
              const SizedBox(width: 10),
              _vitalChip("BP", "${bp.toInt()}", bp > 130),
              const SizedBox(width: 10),
              if(trend < 0) _vitalChip("Trend", "$trend", true), // Negative trend is bad
            ],
          ),
          if(symptoms.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 5, runSpacing: 5,
              children: symptoms.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                child: Text(s.toString(), style: GoogleFonts.lato(color: Colors.white70, fontSize: 10)),
              )).toList(),
            )
          ]
        ],
      ),
    );
  }

  Widget _vitalChip(String label, String value, bool isDanger) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDanger ? Colors.redAccent.withOpacity(0.1) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDanger ? Colors.redAccent.withOpacity(0.5) : Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.lato(color: Colors.white38, fontSize: 8)),
          Text(value, style: GoogleFonts.lato(color: isDanger ? Colors.redAccent : Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFooterAdvice() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.accentGold.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.medical_services_outlined, color: AppColors.accentGold, size: 30),
          const SizedBox(height: 10),
          Text("CLINICAL ACTION PLAN", style: GoogleFonts.oswald(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 5),
          Text(
            "Low scores indicate metabolic dysfunction. Please consult for a Clinical Nutrition Plan immediately.",
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(color: Colors.white70, fontSize: 12),
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
          const Icon(Icons.analytics_outlined, size: 60, color: Colors.white24),
          const SizedBox(height: 20),
          Text("No Logs Found", style: GoogleFonts.oswald(color: Colors.white, fontSize: 22)),
          Text("Please log vitals for your family members first.", style: GoogleFonts.lato(color: Colors.white54)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGold, foregroundColor: Colors.black),
            child: const Text("GO BACK & LOG"),
          )
        ],
      ),
    );
  }
}