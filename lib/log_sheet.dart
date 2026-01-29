import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../config/translations.dart';

class SmartLogSheet extends StatefulWidget {
  final String tenantId;
  final String userName;
  final String selectedProfile;
  final String lang; // 'en', 'hi', 'or'

  const SmartLogSheet({
    super.key,
    required this.tenantId,
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
  String _sugarTime = "fasting"; // fasting, pp, random
  final _bpSysCtrl = TextEditingController();
  final _bpDiaCtrl = TextEditingController();
  final _pulseCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();

  // --- 2. SYMPTOMS (Categorized) ---
  final Map<String, List<String>> _symptomCategories = {
    'head_energy': ['Morning Headache', 'Dizziness', 'Extreme Fatigue'],
    'heart_chest': ['Palpitations', 'Shortness of Breath'],
    'gut_digest': ['Gas / Bloating', 'Acidity', 'Constipation', 'Upper Abdomen Pain'],
    'hormone': ['Hair Fall', 'Swelling', 'Feeling Cold', 'Irregular Periods'],
    'skin_feet': ['Tingling Feet', 'Slow Healing', 'Dry Skin'],
  };

  // Stores active symptoms
  final Map<String, bool> _activeSymptoms = {};

  // --- 3. LIFESTYLE ---
  double _stressLevel = 5.0; // 1-10
  double _sleepHours = 7.0;
  double _waterIntake = 1.5;
  bool _tookMeds = true;

  @override
  void initState() {
    super.initState();
    // Initialize all symptoms to false
    _symptomCategories.values.expand((i) => i).forEach((s) {
      _activeSymptoms[s] = false;
    });
  }

  String _t(String key) => AppTranslations.keys[widget.lang]?[key] ?? key;

  int _calculateRiskScore() {
    int score = 100;
    // Vitals Penalty
    double sugar = double.tryParse(_sugarCtrl.text) ?? 0;
    double sys = double.tryParse(_bpSysCtrl.text) ?? 0;

    if (sugar > 140) score -= 15;
    if (sys > 140) score -= 15;

    // Symptom Penalty
    int symptomCount = _activeSymptoms.values.where((v) => v).length;
    score -= (symptomCount * 4); // 4 points per symptom

    // Stress Penalty
    if (_stressLevel > 7) score -= 10;

    return score.clamp(10, 100);
  }

  Future<void> _saveLog() async {
    int finalScore = _calculateRiskScore();
    List<String> activeSymList = _activeSymptoms.entries.where((e) => e.value).map((e) => e.key).toList();

    try {
      await FirebaseFirestore.instance.collection('promo_logs').add({
        'tenant_id': widget.tenantId,
        'user_name': widget.userName,
        'profile': widget.selectedProfile,
        // New Vitals
        'sugar': double.tryParse(_sugarCtrl.text) ?? 0,
        'sugar_tag': _sugarTime,
        'bp_sys': double.tryParse(_bpSysCtrl.text) ?? 0,
        'bp_dia': double.tryParse(_bpDiaCtrl.text) ?? 0,
        'pulse': double.tryParse(_pulseCtrl.text) ?? 0,
        'weight': double.tryParse(_weightCtrl.text) ?? 0,
        'waist': double.tryParse(_waistCtrl.text) ?? 0,
        // Lists
        'symptoms': activeSymList,
        // Lifestyle
        'stress_level': _stressLevel,
        'sleep_hours': _sleepHours,
        'water_intake': _waterIntake,
        'medication_taken': _tookMeds,
        // Metadata
        'health_score': finalScore,
        'timestamp': FieldValue.serverTimestamp(),
      });
      if(mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        children: [
          Text(_t('log_title'), style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
          Text(_t('log_subtitle'), style: GoogleFonts.lato(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. VITALS SECTION ---
                  _buildSectionHeader(_t('vitals')),

                  // Sugar Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(flex: 2, child: _buildMiniInput(_sugarCtrl, _t('sugar'), "mg/dL")),
                      const SizedBox(width: 10),
                      Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            value: _sugarTime,
                            decoration: _inputDec(),
                            items: ['fasting', 'pp', 'random'].map((t) => DropdownMenuItem(value: t, child: Text(_t(t), style: const TextStyle(fontSize: 12)))).toList(),
                            onChanged: (v) => setState(() => _sugarTime = v!),
                          )
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // BP & Pulse Row
                  Row(children: [
                    Expanded(child: _buildMiniInput(_bpSysCtrl, _t('bp_sys'), "")),
                    const SizedBox(width: 8),
                    Expanded(child: _buildMiniInput(_bpDiaCtrl, _t('bp_dia'), "")),
                    const SizedBox(width: 8),
                    Expanded(child: _buildMiniInput(_pulseCtrl, _t('pulse'), "bpm")),
                  ]),
                  const SizedBox(height: 10),

                  // Weight & Waist
                  Row(children: [
                    Expanded(child: _buildMiniInput(_weightCtrl, _t('weight'), "kg")),
                    const SizedBox(width: 10),
                    Expanded(child: _buildMiniInput(_waistCtrl, _t('waist'), "in")),
                  ]),

                  const SizedBox(height: 30),

                  // --- 2. SYMPTOMS SECTION (Categorized) ---
                  _buildSectionHeader(_t('symptoms')),
                  ..._symptomCategories.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(_t(entry.key), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accentGold)),
                        ),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: entry.value.map((symKey) {
                            bool isSelected = _activeSymptoms[symKey]!;
                            return FilterChip(
                              label: Text(_t(symKey)),
                              selected: isSelected,
                              selectedColor: AppColors.rubyRed.withOpacity(0.1),
                              checkmarkColor: AppColors.rubyRed,
                              labelStyle: TextStyle(fontSize: 11, color: isSelected ? AppColors.rubyRed : Colors.black87),
                              onSelected: (val) => setState(() => _activeSymptoms[symKey] = val),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  }).toList(),

                  const SizedBox(height: 30),

                  // --- 3. LIFESTYLE SECTION ---
                  _buildSectionHeader(_t('lifestyle')),

                  // Stress Slider
                  Row(children: [
                    const Icon(Icons.psychology, color: Colors.orange, size: 20),
                    const SizedBox(width: 10),
                    Text("${_t('stress')}: ${_stressLevel.toInt()}/10"),
                  ]),
                  Slider(value: _stressLevel, min: 1, max: 10, divisions: 9, activeColor: Colors.orange, onChanged: (v) => setState(() => _stressLevel = v)),

                  // Sleep & Water
                  Row(
                    children: [
                      Expanded(
                        child: Column(children: [
                          Icon(Icons.bed, color: Colors.indigo.shade300),
                          Slider(value: _sleepHours, min: 4, max: 12, divisions: 16, activeColor: Colors.indigo, onChanged: (v) => setState(() => _sleepHours = v)),
                          Text("${_t('sleep')}: ${_sleepHours}h"),
                        ]),
                      ),
                      Expanded(
                        child: Column(children: [
                          const Icon(Icons.water_drop, color: Colors.blue),
                          Slider(value: _waterIntake, min: 0.5, max: 5, divisions: 9, activeColor: Colors.blue, onChanged: (v) => setState(() => _waterIntake = v)),
                          Text("${_t('water')}: ${_waterIntake}L"),
                        ]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  CheckboxListTile(
                    title: Text(_t('meds')),
                    value: _tookMeds,
                    activeColor: Colors.green,
                    onChanged: (v) => setState(() => _tookMeds = v!),
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Container(
              padding: const EdgeInsets.only(bottom: 20),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveLog,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
                child: Text(_t('analyze_btn'), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(title, style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)));
  }

  Widget _buildMiniInput(TextEditingController ctrl, String label, String suffix) {
    return TextField(
      controller: ctrl, keyboardType: TextInputType.number,
      decoration: _inputDec().copyWith(labelText: label, suffixText: suffix),
    );
  }

  // ✅ FIXED: Now returns InputDecoration directly
  InputDecoration _inputDec() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }
}