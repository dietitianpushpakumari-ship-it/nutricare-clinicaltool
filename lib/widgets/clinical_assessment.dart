import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:promotional_app/config/constant.dart';
import 'package:promotional_app/model/assesment_model.dart';
import 'package:promotional_app/service/clinical_report_generator.dart';
import '../config/theme.dart';
import '../service/assessment_engine.dart';
// Import the new PDF Generator

class ClinicalAssessmentWidget extends StatefulWidget {
  final String contactNo;
  final String userName;
  final String lang; // 'en', 'hi', or 'or'
  final HealthPath? initialPath; // Optional: If passed, starts audit immediately

  const ClinicalAssessmentWidget({
    super.key,
    required this.contactNo,
    required this.userName,
    required this.lang,
    this.initialPath,
  });

  @override
  State<ClinicalAssessmentWidget> createState() => _ClinicalAssessmentWidgetState();
}

class _ClinicalAssessmentWidgetState extends State<ClinicalAssessmentWidget> {
  // --- STATE ---
  HealthPath? _selectedPath;
  List<ScreeningQuestion> _activeQuestions = [];
  int _currentQuestionIndex = 0;
  bool _isCompleted = false;

  // Data Store
  final Map<String, dynamic> _answers = {};
  int _redFlagsCount = 0;

  @override
  void initState() {
    super.initState();
    // If the Hub passed a specific path, start it immediately
    if (widget.initialPath != null) {
      _startAssessment(widget.initialPath!);
    }
  }

  // --- TRANSLATION HELPER ---
  String _t(String key) {
    // 1. Check UI Labels
    if (AppTranslations.uiLabels[widget.lang]?.containsKey(key) ?? false) {
      return AppTranslations.uiLabels[widget.lang]![key]!;
    }
    // 2. Check Question Dictionary
    if (AppTranslations.questions.containsKey(key)) {
      var qData = AppTranslations.questions[key];
      if (qData != null && qData.containsKey(widget.lang)) {
        return qData[widget.lang]['q'];
      }
    }
    // 3. Fallback
    return key;
  }

  // --- LOGIC ---
  void _startAssessment(HealthPath path) {
    setState(() {
      _selectedPath = path;
      _activeQuestions = AssessmentEngine.getFullQuestionSet(path);
      _currentQuestionIndex = 0;
      _isCompleted = false;
      _answers.clear();
      _redFlagsCount = 0;
    });
  }

  void _submitAnswer(String questionId, dynamic value, bool isRedFlag) {
    setState(() {
      _answers[questionId] = value;

      // Calculate Risk in Real-time (Simple Logic: Yes/True = Bad for red flag questions)
      if (isRedFlag) {
        if (value == true || value == "Yes") {
          _redFlagsCount++;
        }
      }

      // Move Next
      if (_currentQuestionIndex < _activeQuestions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _finishAssessment();
      }
    });
  }

  Future<void> _finishAssessment() async {
    setState(() => _isCompleted = true);

    String riskLevel = _redFlagsCount > 3 ? "CRITICAL" : (_redFlagsCount > 1 ? "MODERATE" : "LOW");

    try {
      // SAVE TO 'lead_health_assessments'
      await FirebaseFirestore.instance.collection('lead_health_assessments').add({
        // 1. STANDARD ID FIELDS
        'tenantid': tenant_id,      // Exact match for Admin Panel
        'contact': widget.contactNo,       // Explicit contact number

        // 2. USER DETAILS
        'user_name': widget.userName,
        'created_at': FieldValue.serverTimestamp(), // Standard timestamp

        // 3. CLINICAL DATA
        'audit_type': _selectedPath!.title,
        'risk_level': riskLevel,
        'red_flags_count': _redFlagsCount,
        'answers': _answers,

        // 4. LEAD STATUS
        'status': 'NEW', // Easy to filter in Admin
        'source': 'app_clinical_hub',
      });

      debugPrint("Lead saved successfully to lead_health_assessments");

    } catch (e) {
      debugPrint("Error saving assessment: $e");
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error saving data: $e"), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.accentGold.withOpacity(0.3)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.02)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER ROW
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                          _isCompleted ? Icons.analytics_outlined : Icons.medical_services_outlined,
                          color: AppColors.accentGold
                      ),
                      const SizedBox(width: 10),
                      Text(
                          _selectedPath == null ? _t('select_path') : _selectedPath!.title,
                          style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18)
                      ),
                    ],
                  ),
                  if (_selectedPath != null && !_isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                      child: Text(
                          "${_currentQuestionIndex + 1}/${_activeQuestions.length}",
                          style: GoogleFonts.lato(color: Colors.white70, fontSize: 10)
                      ),
                    )
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.white10),
              const SizedBox(height: 20),

              // DYNAMIC BODY
              if (_isCompleted)
                _buildCompletionScreen()
              else if (_selectedPath == null)
                _buildPathSelector()
              else
                _buildQuestionCard(_activeQuestions[_currentQuestionIndex]),
            ],
          ),
        ),
      ),
    );
  }

  // --- 1. PATH SELECTOR (If accessed directly) ---
  Widget _buildPathSelector() {
    List<HealthPath> available = AssessmentEngine.getAvailablePaths(30, 'Female');

    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: available.length,
        itemBuilder: (context, index) {
          HealthPath path = available[index];
          return InkWell(
            onTap: () => _startAssessment(path),
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(path.icon, color: Colors.white70, size: 30),
                  const SizedBox(height: 10),
                  Text(
                      path.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- 2. QUESTION CARD ---
  Widget _buildQuestionCard(ScreeningQuestion q) {
    // Translation Logic
    String displayText = widget.lang == 'en' ? q.text : _t(q.id);
    if (displayText == q.id) displayText = q.text; // Safety Fallback

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question Text
        Text(
          displayText,
          style: GoogleFonts.lato(color: Colors.white, fontSize: 18, height: 1.3),
        ),
        const SizedBox(height: 25),

        // Input Type Logic
        if (q.type == QuestionType.yesNo) ...[
          _buildOptionButton("Yes", true, q),
          const SizedBox(height: 10),
          _buildOptionButton("No", false, q),
        ]
        else if (q.type == QuestionType.singleChoice) ...[
          ...?q.options?.map((opt) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildOptionButton(opt, opt, q),
          )),
        ]
        else if (q.type == QuestionType.slider) ...[
            _buildSlider(q),
          ]
      ],
    );
  }

  Widget _buildOptionButton(String label, dynamic value, ScreeningQuestion q) {
    return InkWell(
      onTap: () => _submitAnswer(q.id, value, q.isRedFlag),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.lato(color: Colors.white70, fontSize: 16)),
            const Icon(Icons.arrow_forward_ios, color: Colors.white12, size: 14)
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(ScreeningQuestion q) {
    double min = q.min ?? 0;
    double max = q.max ?? 100;
    double current = _answers[q.id] ?? min;

    return Column(
      children: [
        Text(
            "${current.round()} ${q.unit ?? ''}",
            style: GoogleFonts.oswald(color: AppColors.accentGold, fontSize: 40)
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.accentGold,
            thumbColor: Colors.white,
            overlayColor: AppColors.accentGold.withOpacity(0.2),
          ),
          child: Slider(
            value: current,
            min: min,
            max: max,
            onChanged: (val) {
              setState(() => _answers[q.id] = val);
            },
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _submitAnswer(q.id, current, q.isRedFlag),
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGold,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
          ),
          child: const Text("NEXT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  // --- 3. CRITICAL COMPLETION SCREEN (THE FEAR FACTOR) ---
  Widget _buildCompletionScreen() {
    Color statusColor = _redFlagsCount > 3 ? Colors.red : (_redFlagsCount > 1 ? Colors.orange : Colors.green);
    String statusText = _redFlagsCount > 3 ? "CRITICAL RISK" : (_redFlagsCount > 1 ? "MODERATE RISK" : "STABLE");

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Score Circle
        Container(
          width: 100,
          height: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: statusColor, width: 4),
              color: statusColor.withOpacity(0.1)
          ),
          child: Text("$_redFlagsCount", style: GoogleFonts.oswald(fontSize: 45, color: statusColor, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 15),

        Text(statusText, style: GoogleFonts.oswald(color: statusColor, fontSize: 28, letterSpacing: 1)),
        const SizedBox(height: 10),

        Text(
          "We detected $_redFlagsCount major metabolic red flags in your profile.",
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(color: Colors.white70, fontSize: 14),
        ),

        const SizedBox(height: 30),

        // DOWNLOAD REPORT BUTTON
        InkWell(
          onTap: () {
            // Trigger PDF Generation
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Generating Clinical Report...")));
            ClinicalReportGenerator.generate(widget.userName, _selectedPath!.title, _redFlagsCount, _answers);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.redAccent.shade700, Colors.redAccent]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 15, spreadRadius: 1)]
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.white),
                const SizedBox(width: 10),
                Text("DOWNLOAD FULL REPORT", style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 15),

        TextButton(
          onPressed: () {
            // Reset to allow another test or close
            if(widget.initialPath != null) {
              Navigator.pop(context); // Close if in fullscreen mode
            } else {
              setState(() {
                _selectedPath = null;
                _isCompleted = false;
              });
            }
          },
          child: Text(widget.initialPath != null ? "Close" : "Start New Audit", style: const TextStyle(color: Colors.white30)),
        )
      ],
    );
  }
}