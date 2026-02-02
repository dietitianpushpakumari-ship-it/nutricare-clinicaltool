import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class ClinicalReportGenerator {

  /// Generates a "Fear-Inducing" Clinical Audit PDF
  static Future<void> generate(
      String userName,
      String pathName,
      int redFlags,
      Map<String, dynamic> answers
      ) async {

    final pdf = pw.Document();
    final date = DateFormat('dd MMM yyyy').format(DateTime.now());

    // --- 1. RISK LOGIC (DETERMINES COLORS) ---
    String riskLevel = redFlags > 3 ? "CRITICAL FAILURE" : (redFlags > 1 ? "MODERATE RISK" : "STABLE");
    PdfColor riskColor = redFlags > 3 ? PdfColors.red : (redFlags > 1 ? PdfColors.orange : PdfColors.green);
    String riskMessage = redFlags > 3
        ? "URGENT: Your symptoms indicate multiple system failures. Immediate metabolic intervention is required to prevent chronic disease progression."
        : "WARNING: Early signs of metabolic stress detected. Corrective lifestyle measures are recommended.";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // --- HEADER ---
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("NUTRICARE DIAGNOSTICS", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
                    pw.Text("Clinical Assessment Engine v2.0", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.red),
                      borderRadius: pw.BorderRadius.circular(4)
                  ),
                  child: pw.Text("CONFIDENTIAL AUDIT", style: pw.TextStyle(color: PdfColors.red, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                )
              ],
            ),
            pw.Divider(thickness: 1, color: PdfColors.grey300),
            pw.SizedBox(height: 20),

            // --- PATIENT DETAILS ---
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("PATIENT NAME", style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                    pw.Text(userName.toUpperCase(), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("AUDIT TYPE", style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                    pw.Text(pathName.toUpperCase(), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("DATE", style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                    pw.Text(date, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // --- THE SCORE CARD (THE SCARY PART) ---
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: riskColor == PdfColors.red ? PdfColors.red50 : PdfColors.orange50,
                border: pw.Border.all(color: riskColor, width: 2),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                children: [
                  // Circle Score
                  pw.Container(
                    width: 60, height: 60,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      color: riskColor,
                    ),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                        redFlags.toString(),
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 28, fontWeight: pw.FontWeight.bold)
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  // Text
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("CLINICAL RISK LEVEL: $riskLevel", style: pw.TextStyle(color: riskColor, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 5),
                        pw.Text(riskMessage, style: pw.TextStyle(color: PdfColors.black, fontSize: 10)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // --- SYMPTOM BREAKDOWN ---
            pw.Text("DETAILED SYMPTOM ANALYSIS", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 10),

            ...answers.entries.map((e) {
              String key = e.key;
              String val = e.value.toString();

              // Skip slider values (like 160.0) for the simple list, focus on Yes/No for red flags
              // Or format them nicely.
              bool isRedFlag = (val == 'true' || val == 'Yes' || val == 'High');

              return pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                margin: const pw.EdgeInsets.only(bottom: 5),
                decoration: pw.BoxDecoration(
                  color: isRedFlag ? PdfColors.red50 : PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(_formatQuestionKey(key), style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                    pw.Text(
                        val.toString().toUpperCase(),
                        style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: isRedFlag ? PdfColors.red : PdfColors.black
                        )
                    ),
                  ],
                ),
              );
            }).toList(),

            pw.Spacer(),

            // --- CALL TO ACTION (FOOTER) ---
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                  color: PdfColors.black,
                  borderRadius: pw.BorderRadius.circular(8)
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("DO NOT IGNORE THIS REPORT.", style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Text("Schedule a clinical review with Dr. Pushpa immediately.", style: pw.TextStyle(color: PdfColors.grey400, fontSize: 8)),
                    ],
                  ),
                  pw.Text("CALL: +91 79787 55097", style: pw.TextStyle(color: PdfColors.yellow, fontWeight: pw.FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ];
        },
      ),
    );

    // Trigger Print/Share
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'Clinical_Audit_${pathName.replaceAll(' ', '_')}.pdf');
  }

  // Helper to make ID readable (e.g., "morning_headache" -> "Morning Headache")
  static String _formatQuestionKey(String key) {
    if (key.length < 3) return key.toUpperCase();
    return key.split('_').map((str) => str[0].toUpperCase() + str.substring(1)).join(' ');
  }
}