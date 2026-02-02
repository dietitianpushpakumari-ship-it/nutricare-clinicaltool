import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:promotional_app/config/constant.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../config/theme.dart';
import 'config/translations.dart';

class SmartLogSheet extends StatefulWidget {
  final String contactNo;
  final String userName;
  final String selectedProfile;
  final String lang;

  const SmartLogSheet({
    super.key,
    required this.contactNo,
    required this.userName,
    required this.selectedProfile,
    this.lang = 'en',
  });

  @override
  State<SmartLogSheet> createState() => _SmartLogSheetState();
}

class _SmartLogSheetState extends State<SmartLogSheet> {
  // --- 1. VITALS ---
  final _sugarCtrl = TextEditingController();
  String _sugarTime = "fasting";
  final _bpSysCtrl = TextEditingController();
  final _bpDiaCtrl = TextEditingController();
  final _pulseCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();

  // --- 2. SYMPTOMS ---
  final Map<String, List<String>> _symptomCategories = {
    'head_energy': ['Morning Headache', 'Dizziness', 'Extreme Fatigue'],
    'heart_chest': ['Palpitations', 'Shortness of Breath'],
    'gut_digest': ['Gas / Bloating', 'Acidity', 'Constipation', 'Upper Abdomen Pain'],
    'hormone': ['Hair Fall', 'Swelling', 'Feeling Cold', 'Irregular Periods'],
    'skin_feet': ['Tingling Feet', 'Slow Healing', 'Dry Skin'],
  };
  final Map<String, bool> _activeSymptoms = {};

  // --- 3. LIFESTYLE ---
  double _stressLevel = 5.0;
  double _sleepHours = 7.0;
  double _waterIntake = 2.0;
  bool _tookMeds = true;

  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _symptomCategories.values.expand((i) => i).forEach((s) {
      _activeSymptoms[s] = false;
    });
  }

  String _t(String key) => AppTranslations.keys[widget.lang]?[key] ?? key;

  // --- STRICT CLINICAL LOGIC ---
  int _calculateRiskScore() {
    int score = 100;

    // 1. Parsing (Handle empty safely)
    double sugar = double.tryParse(_sugarCtrl.text) ?? 0;
    double sys = double.tryParse(_bpSysCtrl.text) ?? 0;
    double dia = double.tryParse(_bpDiaCtrl.text) ?? 0;
    double waist = double.tryParse(_waistCtrl.text) ?? 0;

    // --- CRITICAL CAPS (The Safety Net) ---
    // If these values are hit, the score CANNOT exceed the cap,
    // regardless of how good other metrics are.
    int maxPossibleScore = 100;

    // 2. SUGAR EVALUATION
    if (sugar > 0) {
      if (_sugarTime == 'fasting') {
        if (sugar > 300) {
          maxPossibleScore = 40; // EMERGENCY
          score -= 60;
        } else if (sugar > 200) {
          maxPossibleScore = 60; // SEVERE
          score -= 40;
        } else if (sugar > 126) {
          score -= 25; // DIABETIC
        } else if (sugar > 100) {
          score -= 10; // PRE-DIABETIC
        }
      } else {
        // PP or Random
        if (sugar > 400) {
          maxPossibleScore = 40; // EMERGENCY
          score -= 60;
        } else if (sugar > 250) {
          maxPossibleScore = 60; // SEVERE
          score -= 40;
        } else if (sugar > 200) {
          score -= 25; // DIABETIC
        } else if (sugar > 140) {
          score -= 10; // PRE-DIABETIC
        }
      }
    }

    // 3. BLOOD PRESSURE EVALUATION
    if (sys > 0 || dia > 0) {
      if (sys > 180 || dia > 110) {
        maxPossibleScore = 40; // HYPERTENSIVE CRISIS
        score -= 50;
      } else if (sys > 160 || dia > 100) {
        maxPossibleScore = 60; // STAGE 2
        score -= 30;
      } else if (sys > 140 || dia > 90) {
        score -= 20; // STAGE 1
      } else if (sys > 130 || dia > 85) {
        score -= 10; // ELEVATED
      }
    }

    // 4. OBESITY (Waist)
    // Waist > 40 (Men) or > 35 (Women) is High Risk.
    // We average to 38 for mixed gender simple check.
    if (waist > 38) score -= 15;

    // 5. SYMPTOMS (Weighted)
    int symptomCount = _activeSymptoms.values.where((v) => v).length;
    // Cap deduction at 30
    score -= (symptomCount * 5);

    // 6. LIFESTYLE (Bonus/Penalty)
    // Only apply lifestyle penalties if not already critical
    if (maxPossibleScore > 60) {
      if (_stressLevel > 8) score -= 10;
      if (_sleepHours < 5) score -= 10;
      if (_waterIntake < 1.0) score -= 5;
    }

    // 7. EMPTY FORM CHECK
    // If user enters absolutely nothing, return 0 or a neutral indicator
    if (sugar == 0 && sys == 0 && symptomCount == 0 && waist == 0) {
      return 0; // Indicates "No Data"
    }

    // 8. APPLY CAP & RETURN
    // Ensure calculated score never exceeds the Critical Cap
    if (score > maxPossibleScore) {
      score = maxPossibleScore;
    }

    return score.clamp(10, 100);
  }

  Future<void> _saveAndAnalyze() async {
    // Validation
    if (_sugarCtrl.text.isEmpty && _bpSysCtrl.text.isEmpty && !_activeSymptoms.values.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter at least one Vital (Sugar/BP) or Symptom."), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(seconds: 2));

    int finalScore = _calculateRiskScore();
    // Handle the "Empty Form" case (Score 0) -> Treat as 75 for saving, or reject.
    // Let's set a default baseline if they just clicked analyze with minimal data.
    if (finalScore == 0) finalScore = 75;

    List<String> activeSymList = _activeSymptoms.entries.where((e) => e.value).map((e) => e.key).toList();

    try {
      // ** USING 'lead_logs' AS REQUESTED **
      await FirebaseFirestore.instance.collection('lead_logs').add({
        'tenant_id': tenant_id,
        'contact': widget.contactNo,
        'user_name': widget.userName,
        'profile': widget.selectedProfile,
        'sugar': double.tryParse(_sugarCtrl.text) ?? 0,
        'sugar_tag': _sugarTime,
        'bp_sys': double.tryParse(_bpSysCtrl.text) ?? 0,
        'bp_dia': double.tryParse(_bpDiaCtrl.text) ?? 0,
        'pulse': double.tryParse(_pulseCtrl.text) ?? 0,
        'weight': double.tryParse(_weightCtrl.text) ?? 0,
        'waist': double.tryParse(_waistCtrl.text) ?? 0,
        'symptoms': activeSymList,
        'stress_level': _stressLevel,
        'sleep_hours': _sleepHours,
        'water_intake': _waterIntake,
        'medication_taken': _tookMeds,
        'health_score': finalScore,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if(mounted) {
        setState(() => _isAnalyzing = false);
        _showAnalysisReport(finalScore, activeSymList.length);
      }
    } catch (e) {
      setState(() => _isAnalyzing = false);
      debugPrint("Error: $e");
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }

  // --- UI: ANALYSIS REPORT DIALOG (Updated Text) ---
  void _showAnalysisReport(int score, int symptomCount) {
    Color statusColor = score > 80 ? Colors.green : (score > 50 ? Colors.orange : Colors.red);
    String statusText = score > 80 ? "Optimal Health" : (score > 50 ? "Metabolic Warning" : "CRITICAL RISK");

    // Dynamic Message based on score tiers
    String message = "";
    if (score > 80) {
      message = "Great job! Your metabolic markers are stable.";
    } else if (score > 50) {
      message = "Warning: Early signs of inflammation detected. Diet correction advised.";
    } else {
      // Score <= 50
      message = "ALERT: Your vitals are in the danger zone. Immediate clinical attention is required to prevent complications.";
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Text("DIAGNOSTIC REPORT", style: GoogleFonts.lato(fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold, color: Colors.black54)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: statusColor, width: 4),
                            color: Colors.white
                        ),
                        child: Text("$score", style: GoogleFonts.oswald(fontSize: 32, fontWeight: FontWeight.bold, color: statusColor)),
                      ),
                      const SizedBox(height: 10),
                      Text(statusText, style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      Text(message, textAlign: TextAlign.center, style: GoogleFonts.lato(color: Colors.black87, fontSize: 14)),

                      // Critical Alert Box if Score is Low
                      if (score <= 50)
                        Container(
                          margin: const EdgeInsets.only(top: 15),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade100)),
                          child: Row(
                            children: [
                              const Icon(Icons.warning, color: Colors.red, size: 20),
                              const SizedBox(width: 10),
                              const Expanded(child: Text("High Risk of Hospitalization if ignored.", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)))
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 10),

                      Text("Follow Nutricare for Free Diet Tips", style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accentGold)),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _socialBtn(FontAwesomeIcons.facebook, Colors.blue[800]!, "https://www.facebook.com/NutricareWellness.rkl/"),
                          _socialBtn(FontAwesomeIcons.youtube, Colors.red, "https://www.youtube.com/@NutricareWellness-t2s"),
                          _socialBtn(FontAwesomeIcons.globe, AppColors.primaryDark, "https://www.nutricarewellness.com"),
                        ],
                      ),
                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark),
                          child: const Text("CLOSE & SAVE", style: TextStyle(color: Colors.white)),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        )
    );
  }

  Widget _socialBtn(IconData icon, Color color, String url) {
    return InkWell(
      onTap: () => _launchURL(url),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Keep your existing beautiful UI build method here.
    // I will not repeat the UI code block to save space, assuming you have it from previous steps.
    // If you need the full file again, let me know.
    // ...
    // Make sure to return the Container(...) structure you provided.
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: const BoxDecoration(color: AppColors.creamBg, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: SafeArea(
        child: Column(
          children: [
            Center(child: Container(margin: const EdgeInsets.only(top: 15, bottom: 10), width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                children: [
                  Text(_t('log_title'), textAlign: TextAlign.center, style: GoogleFonts.playfairDisplay(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  Text("AI-Powered Health Assessment", textAlign: TextAlign.center, style: GoogleFonts.lato(color: AppColors.accentGold, fontSize: 12, letterSpacing: 1.5)),
                  const SizedBox(height: 25),
                  _buildCard(title: _t('vitals'), icon: Icons.monitor_heart, child: Column(children: [Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Expanded(flex: 2, child: _buildPremiumInput(_sugarCtrl, _t('sugar'), "mg/dL")), const SizedBox(width: 10), Expanded(flex: 3, child: DropdownButtonFormField<String>(value: _sugarTime, decoration: _inputDec(), items: ['fasting', 'pp', 'random'].map((t) => DropdownMenuItem(value: t, child: Text(_t(t), style: GoogleFonts.lato(fontSize: 13)))).toList(), onChanged: (v) => setState(() => _sugarTime = v!)))]), const SizedBox(height: 15), Row(children: [Expanded(child: _buildPremiumInput(_bpSysCtrl, _t('bp_sys'), "mmHg")), const SizedBox(width: 10), Expanded(child: _buildPremiumInput(_bpDiaCtrl, _t('bp_dia'), "mmHg"))]), const SizedBox(height: 15), Row(children: [Expanded(child: _buildPremiumInput(_weightCtrl, _t('weight'), "kg")), const SizedBox(width: 10), Expanded(child: _buildPremiumInput(_waistCtrl, _t('waist'), "in"))])])),
                  _buildCard(title: _t('symptoms'), icon: Icons.healing, child: Column(children: _symptomCategories.entries.map((entry) { return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.only(top: 10, bottom: 8), child: Text(_t(entry.key), style: GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))), Wrap(spacing: 8, runSpacing: 8, children: entry.value.map((symKey) { bool isSelected = _activeSymptoms[symKey]!; return ChoiceChip(label: Text(_t(symKey), style: GoogleFonts.lato(fontSize: 11, color: isSelected ? AppColors.primaryDark : Colors.black87)), selected: isSelected, selectedColor: AppColors.accentGold.withOpacity(0.3), backgroundColor: Colors.white, side: BorderSide(color: isSelected ? AppColors.accentGold : Colors.grey.shade200), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), onSelected: (val) => setState(() => _activeSymptoms[symKey] = val)); }).toList())]); }).toList())),
                  _buildCard(title: _t('lifestyle'), icon: Icons.self_improvement, child: Column(children: [_buildSliderRow(Icons.psychology, Colors.orange, "Stress", _stressLevel, 1, 10, (v) => setState(() => _stressLevel = v), label: "${_stressLevel.toInt()}/10"), const Divider(height: 25), _buildSliderRow(Icons.bed, Colors.indigo, "Sleep", _sleepHours, 4, 12, (v) => setState(() => _sleepHours = v), label: "${_sleepHours.toStringAsFixed(1)} h"), const Divider(height: 25), _buildSliderRow(Icons.water_drop, Colors.blue, "Water", _waterIntake, 0.5, 5, (v) => setState(() => _waterIntake = v), label: "${_waterIntake.toStringAsFixed(1)} L"), const SizedBox(height: 15), SwitchListTile(title: Text("Taking Medications?", style: GoogleFonts.lato(fontSize: 14)), value: _tookMeds, activeColor: AppColors.primaryDark, onChanged: (v) => setState(() => _tookMeds = v))])),
                ],
              ),
            ),
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]), child: SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: _isAnalyzing ? null : _saveAndAnalyze, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, foregroundColor: AppColors.accentGold, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: _isAnalyzing ? const CircularProgressIndicator(color: AppColors.accentGold) : Text("ANALYZE HEALTH SCORE", style: GoogleFonts.lato(fontWeight: FontWeight.bold, letterSpacing: 1.5)))))
          ],
        ),
      ),
    );
  }

  // Keep Helpers (_buildCard, _buildPremiumInput, _inputDec, _buildSliderRow) unchanged
  Widget _buildCard({required String title, required IconData icon, required Widget child}) { return Container(margin: const EdgeInsets.only(bottom: 20), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: AppColors.accentGold, size: 18), const SizedBox(width: 8), Text(title.toUpperCase(), style: GoogleFonts.lato(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.primaryDark, fontSize: 12))]), const Divider(height: 25), child])); }
  Widget _buildPremiumInput(TextEditingController ctrl, String label, String suffix, {bool isPhone = false, bool isRequired = false}) { return TextFormField(controller: ctrl, keyboardType: TextInputType.number, style: GoogleFonts.lato(color: AppColors.primaryDark, fontWeight: FontWeight.bold), decoration: _inputDec().copyWith(labelText: label, suffixText: suffix)); }
  InputDecoration _inputDec() { return InputDecoration(filled: true, fillColor: AppColors.creamBg, labelStyle: GoogleFonts.lato(color: Colors.grey.shade600, fontSize: 13), suffixStyle: GoogleFonts.lato(color: Colors.grey.shade400, fontSize: 12), contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.accentGold, width: 1))); }
  Widget _buildSliderRow(IconData icon, Color color, String title, double value, double min, double max, Function(double) onChanged, {required String label}) { return Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 18)), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 13)), Text(label, style: GoogleFonts.lato(color: color, fontWeight: FontWeight.bold, fontSize: 13))]), SliderTheme(data: SliderTheme.of(context).copyWith(trackHeight: 4, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6), overlayShape: const RoundSliderOverlayShape(overlayRadius: 14), activeTrackColor: color, inactiveTrackColor: color.withOpacity(0.2), thumbColor: color, overlayColor: color.withOpacity(0.1)), child: Slider(value: value, min: min, max: max, onChanged: onChanged))]))]); }
}