import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:promotional_app/config/constant.dart';

class ReportGenerator {

  static Future<void> generateFamilyReport(String contactNo, String userName) async {
    final pdf = pw.Document();
    final date = DateFormat('dd MMM yyyy').format(DateTime.now());

    // 1. FETCH DATA
    final profiles = ['Dad', 'Mom', 'Me', 'Spouse', 'Kid'];
    Map<String, List<Map<String, dynamic>>> familyHistory = {};

    int memberCount = 0;
    int totalLatestScore = 0;

    for (String profile in profiles) {
      try {
        // [FIX] Changed collection to 'promo_logs' to match your Dashboard
        var snapshot = await FirebaseFirestore.instance
            .collection('lead_logs')
            .where('tenant_id', isEqualTo: tenant_id)
            .where('contact', isEqualTo: contactNo)
            .where('profile', isEqualTo: profile)
            .orderBy('timestamp', descending: true)
            .limit(5)
            .get();

        if (snapshot.docs.isNotEmpty) {
          List<Map<String, dynamic>> logs = snapshot.docs.map((d) => d.data()).toList();
          familyHistory[profile] = logs;

          // Handle String or Int score safely
          var rawScore = logs.first['health_score'];
          int score = (rawScore is int)
              ? rawScore
              : (double.tryParse(rawScore.toString()) ?? 0).toInt();

          totalLatestScore += score;
          memberCount++;
        }
      } catch (e) {
        print("Error fetching $profile: $e");
      }
    }

    if (memberCount == 0) {
      // Optional: Handle empty state if needed, or just let it generate an empty report
    }

    int avgFamilyScore = memberCount > 0 ? (totalLatestScore / memberCount).round() : 0;

    // 2. BUILD PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            _buildHeader(userName, date),
            pw.SizedBox(height: 20),

            // Family Scorecard
            if (memberCount > 0)
              _buildFamilyRiskCard(avgFamilyScore, memberCount)
            else
              pw.Text("No health logs found. Please log vitals first.", style: pw.TextStyle(color: PdfColors.red)),

            pw.SizedBox(height: 30),

            // Detailed Analysis
            if (memberCount > 0) ...[
              pw.Text("DETAILED CLINICAL ANALYSIS", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 10),

              ...familyHistory.entries.map((entry) {
                return _buildMemberDeepAnalysis(entry.key, entry.value);
              }).toList(),

              pw.SizedBox(height: 20),
              _buildFinalWarning(),
            ]
          ];
        },
      ),
    );

    // 3. SHARE / DOWNLOAD
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'Nutricare_Family_Audit.pdf');
  }

  // --- HEADER ---
  static pw.Widget _buildHeader(String name, String date) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("NUTRICARE WELLNESS", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
            pw.Text("CLINICAL NUTRITION CENTER", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text("FAMILY HEALTH AUDIT", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
            pw.Text("Report for: $name", style: pw.TextStyle(fontSize: 10)),
            pw.Text("Date: $date", style: pw.TextStyle(fontSize: 10)),
          ],
        )
      ],
    );
  }

  // --- FAMILY RISK CARD ---
  static pw.Widget _buildFamilyRiskCard(int score, int members) {
    PdfColor color = score > 80 ? PdfColors.green : (score > 50 ? PdfColors.orange : PdfColors.red);
    String status = score > 80 ? "OPTIMAL" : (score > 50 ? "WARNING" : "CRITICAL FAILURE");

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 2),
        borderRadius: pw.BorderRadius.circular(8),
        color: color == PdfColors.red ? PdfColors.red50 : PdfColors.white,
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 60, height: 60,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: color),
            child: pw.Text("$score", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
          ),
          pw.SizedBox(width: 15),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("FAMILY METABOLIC STATUS", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                pw.Text(status, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: color)),
                pw.Text("$members members audited. Immediate attention required for those in Red zone.", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- MEMBER ANALYSIS ---
  static pw.Widget _buildMemberDeepAnalysis(String name, List<Map<String, dynamic>> history) {
    final latest = history.first;

    // SCORE PARSING
    int currentScore = (latest['health_score'] is int)
        ? latest['health_score']
        : (double.tryParse(latest['health_score'].toString()) ?? 0).toInt();

    // TREND LOGIC (Compare First vs Last of the 5 logs)
    int oldestScore = currentScore;
    if (history.length > 1) {
      oldestScore = (history.last['health_score'] is int)
          ? history.last['health_score']
          : (double.tryParse(history.last['health_score'].toString()) ?? 0).toInt();
    }

    bool isDeclining = currentScore < oldestScore;

    // VITALS PARSING (With Defaults)
    double sugar = double.tryParse(latest['sugar']?.toString() ?? '0') ?? 0;
    double bp = double.tryParse(latest['bp_sys']?.toString() ?? '0') ?? 0;
    List<dynamic> symptoms = latest['symptoms'] ?? [];

    // PROGNOSIS GENERATION
    List<String> prognosis = [];
    if (sugar > 140) prognosis.add("PRE-DIABETIC RISK: Uncontrolled sugar damages retina and kidney filters.");
    if (bp > 130) prognosis.add("CARDIAC STRAIN: High pressure hardens arteries, increasing stroke risk.");
    if (currentScore < 50) prognosis.add("METABOLIC CRASH: Body is aging faster than biological age.");
    if (symptoms.isNotEmpty) prognosis.add("ACTIVE INFLAMMATION: ${symptoms.join(', ')} reported.");
    if (isDeclining) prognosis.add("RAPID DECLINE: Health has worsened by ${oldestScore - currentScore} points recently.");

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      decoration: pw.BoxDecoration(
        border: pw.Border(left: pw.BorderSide(color: currentScore < 60 ? PdfColors.red : PdfColors.green, width: 4)),
        color: PdfColors.grey50,
      ),
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(name.toUpperCase(), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text("Score: $currentScore/100", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: currentScore < 60 ? PdfColors.red : PdfColors.green)),
            ],
          ),
          pw.SizedBox(height: 5),

          // Trend Warning Box
          if (isDeclining)
            pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 8),
                padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                color: PdfColors.red100,
                child: pw.Text("[!] ALERT: Score dropped from $oldestScore to $currentScore in recent logs.", style: pw.TextStyle(color: PdfColors.red900, fontSize: 9, fontWeight: pw.FontWeight.bold))
            ),

          // Vitals Grid
          pw.Row(
            children: [
              // Only show Sugar/BP if they exist (non-zero), otherwise show "N/A"
              _buildVitalBox("SUGAR", sugar > 0 ? "${sugar.toInt()}" : "N/A", sugar > 140),
              pw.SizedBox(width: 10),
              _buildVitalBox("BP (Sys)", bp > 0 ? "${bp.toInt()}" : "N/A", bp > 130),
              pw.SizedBox(width: 10),
              _buildVitalBox("STATUS", currentScore < 60 ? "CRITICAL" : "STABLE", currentScore < 60),
            ],
          ),

          pw.SizedBox(height: 10),

          // Prognosis Section
          if (prognosis.isNotEmpty)
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(8),
              color: PdfColors.grey200,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("FUTURE PROGNOSIS (IF IGNORED):", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
                  ...prognosis.map((p) => pw.Text("- $p", style: pw.TextStyle(fontSize: 9, color: PdfColors.grey800))),
                ],
              ),
            )
          else
            pw.Text("Current markers are stable. Maintain MNT diet.", style: pw.TextStyle(fontSize: 9, color: PdfColors.green900)),
        ],
      ),
    );
  }

  static pw.Widget _buildVitalBox(String label, String value, bool isDanger) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(5),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: isDanger ? PdfColors.red : PdfColors.grey400),
          borderRadius: pw.BorderRadius.circular(4),
          color: isDanger ? PdfColors.red50 : PdfColors.white,
        ),
        child: pw.Column(
          children: [
            pw.Text(label, style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
            pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: isDanger ? PdfColors.red : PdfColors.black)),
          ],
        ),
      ),
    );
  }

  // --- FINAL CTA ---
  static pw.Widget _buildFinalWarning() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      color: PdfColors.black,
      child: pw.Column(
        children: [
          pw.Text("MEDICAL DISCLAIMER & ACTION PLAN", style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          pw.Text(
              "This report highlights metabolic risks based on your inputs. A declining score indicates that current lifestyle/medication is NOT working.",
              style: pw.TextStyle(color: PdfColors.grey300, fontSize: 9),
              textAlign: pw.TextAlign.center
          ),
          pw.SizedBox(height: 10),
          pw.Text("STOP SELF-MEDICATION. START CLINICAL NUTRITION.", style: pw.TextStyle(color: PdfColors.yellow, fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          pw.Text("Consult Dt. Pushpa Kumari | +91 79787 55097", style: pw.TextStyle(color: PdfColors.white, fontSize: 14, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}