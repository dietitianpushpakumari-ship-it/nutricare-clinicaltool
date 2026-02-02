import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:promotional_app/config/constant.dart';
import 'package:promotional_app/screens/knowledge_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// --- WIDGETS & SERVICES ---
import 'package:promotional_app/screens/assessment_hub_screen.dart';
import 'package:promotional_app/service/report_generator.dart';
import 'package:promotional_app/widgets/offer_section.dart';
import 'package:promotional_app/log_sheet.dart';
import 'package:promotional_app/config/health_content.dart';
import 'package:promotional_app/screens/gate_screen.dart';
import '../config/theme.dart';

class PremiumDashboard extends StatefulWidget {
  final String contactNo;
  final String userName;
  const PremiumDashboard({super.key, required this.contactNo, required this.userName});

  @override
  State<PremiumDashboard> createState() => _PremiumDashboardState();
}

class _PremiumDashboardState extends State<PremiumDashboard> {
  String _selectedProfile = "Dad";
  final List<String> _profiles = ["Dad", "Mom", "Me", "Spouse", "Kid"];
  String _lang = 'en';

  // --- LOGIC SECTION (Keep as is) ---
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not launch link")));
    }
  }

  String _generateTrendReport(List<int> scores) {
    if (scores.isEmpty) return "Awaiting data...";
    if (scores.length < 2) return "Log daily.";
    int current = scores.first;
    int past = scores.last;
    int diff = current - past;
    if (diff > 5) return "Improving! (+${diff})";
    if (diff < -5) return "Declining (-${diff.abs()})";
    return "Stable.";
  }

  Future<void> _submitClinicalInquiry(int score, List<dynamic> symptoms) async {
    final inquiry = {
      'source': 'dashboard_glass',
      'name': widget.userName,
      'contact': {'phone': widget.contactNo, 'wa': true},
      'clinical': {'notes': 'Score: $score. Symptoms: $symptoms', 'tier': 'Premium'},
      'meta': {'time': DateTime.now().toIso8601String(), 'status': 'New'},
    };
    try {
      await FirebaseFirestore.instance.collection('enquiries').add(inquiry);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Request sent."), backgroundColor: AppColors.accentGold));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // --- LOGIC: Handle Booking (Fixed) ---
  Future<void> _handleBooking(String planName, String price) async {
    // 1. Show immediate feedback (so user knows they clicked it)
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Processing your booking request..."),
          backgroundColor: AppColors.primaryDark,
          duration: Duration(milliseconds: 1000),
        )
    );

    try {
      // 2. Prepare Data
      final bookingData = {
        'tenant_id': tenant_id, // Ensure this is imported from config/constant.dart
        'user_name': widget.userName,
        'phone_number': widget.contactNo,
        'plan_selection': planName,
        'price_quoted': price,
        'status': 'NEW_LEAD',
        'source': 'app_package_section',
        'created_at': FieldValue.serverTimestamp(),
      };

      // 3. Write to Firestore (Collection: lead_bookings)
      await FirebaseFirestore.instance.collection('lead_bookings').add(bookingData);

      // 4. Show Success Dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.accentGold, width: 1)
            ),
            title: const Icon(Icons.check_circle, color: AppColors.accentGold, size: 40),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Booking Confirmed!", style: GoogleFonts.oswald(color: Colors.white, fontSize: 22)),
                const SizedBox(height: 10),
                Text(
                  "We have received your interest for:\n$planName",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone_in_talk, color: Colors.green, size: 16),
                      const SizedBox(width: 10),
                      Text("Expect a call within 24hrs", style: GoogleFonts.lato(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("CLOSE", style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint("Booking Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red)
        );
      }
    }
  }

  // --- UI SECTION ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: _buildGlassAppBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSmartLogSheet(context),
        backgroundColor: AppColors.accentGold,
        foregroundColor: AppColors.primaryDark,
        elevation: 10,
        // 1. More descriptive Icon
        icon: const Icon(Icons.monitor_heart_outlined, size: 24),
        // 2. Explicit Label
        label: Text(
            "LOG VITALS",
            style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1
            )
        ),
      ),
      body: Stack(
        children: [
          // 1. BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF0F2C23), Color(0xFF000000), Color(0xFF1A3C34)],
              ),
            ),
          ),
          Positioned(top: -100, left: -50, child: _buildGlowOrb(AppColors.accentGold.withOpacity(0.15))),

          // 2. SCROLLABLE CONTENT
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // A. PROFILES
                  _buildProfileSelector(),

                  const SizedBox(height: 15),

                  // B. METABOLIC CHART (Promoted to Top for Visibility)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildMetabolicGlassCard(),
                  ),

                  const SizedBox(height: 20),

                  // C. SWIPE DECK (Content)
                  SizedBox(height: 300, child: GlassSwipeDeck(lang: _lang)),

                  const SizedBox(height: 25),

                  // D. 2x2 GRID MENU (Efficient Space Usage)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("CLINICAL TOOLS", style: GoogleFonts.lato(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        _buildGridMenu(),
                        const SizedBox(height: 15),

// Small Text Link for Family Report
                        Center(
                          child: TextButton.icon(
                            onPressed: () async {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Generating Family Report...")));
                              await ReportGenerator.generateFamilyReport(widget.contactNo, widget.userName);
                            },
                            icon: const Icon(Icons.download, size: 14, color: Colors.white30),
                            label: Text("Download Family Audit Report", style: GoogleFonts.lato(color: Colors.white30, fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  OfferSection(
                    onBook: (plan, price) {
                      print("Booking clicked: $plan @ $price"); // Debug print
                      _handleBooking(plan, price);
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- NEW COMPACT GRID LAYOUT ---
  Widget _buildGridMenu() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- LEFT COLUMN ---
        Expanded(
          child: Column(
            children: [
              // 1. RISK ASSESSMENT (Main Tool)
              _buildGlassTile(
                title: "CHECK RISK",
                subtitle: "Body Audit",
                icon: Icons.health_and_safety,
                color: Colors.redAccent,
                height: 140,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AssessmentHubScreen(contactNo: widget.contactNo, userName: widget.userName, lang: _lang))),
              ),

              const SizedBox(height: 15),

              // 3. YOUTUBE (Education)
              _buildGlassTile(
                title: "YOUTUBE",
                subtitle: "Health Videos",
                icon: Icons.play_circle_fill,
                color: Colors.red,
                height: 100,
                onTap: () => _launchURL("https://www.youtube.com/@NutricareWellness-t2s"),
              ),
            ],
          ),
        ),

        const SizedBox(width: 15),

        // --- RIGHT COLUMN ---
        Expanded(
          child: Column(
            children: [
              // 2. TRUTH SERIES (Knowledge)
              _buildGlassTile(
                title: "TRUTH SERIES",
                subtitle: "Med vs Food",
                icon: Icons.menu_book,
                color: Colors.greenAccent,
                height: 140,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KnowledgeScreen())),
              ),

              const SizedBox(height: 15),

              // 4. FACEBOOK (Community Support) - REPLACED FAMILY AUDIT
              _buildGlassTile(
                title: "FACEBOOK",
                subtitle: "Join Group",
                icon: Icons.facebook,
                color: Colors.blueAccent,
                height: 100,
                onTap: () => _launchURL("https://www.facebook.com/NutricareWellness.rkl/"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlassTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double height,
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: height,
        width: double.infinity,
        // REDUCED PADDING to save those 4 pixels
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)],
            )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Using Spacer allows dynamic distribution instead of forced 'spaceBetween'
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),

            const Spacer(), // Pushes text to bottom dynamically

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.oswald(color: Colors.white, fontSize: 14, letterSpacing: 0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.lato(color: Colors.white38, fontSize: 10),
                  maxLines: 1, // Limit subtitle to 1 line to prevent overflow
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Center(
          child: TextButton.icon(
            onPressed: () => _launchURL("https://www.facebook.com/NutricareWellness.rkl/"),
            icon: const Icon(Icons.facebook, size: 16, color: Colors.blueAccent),
            label: Text("Join Facebook Group", style: GoogleFonts.lato(color: Colors.white54, fontSize: 12)),
          ),
        ),
        const SizedBox(height: 20),
        Text("v1.0.5 Beta", style: GoogleFonts.lato(color: Colors.white10, fontSize: 10)),
      ],
    );
  }

  // --- REUSED WIDGETS (Slightly Optimized) ---

  Widget _buildProfileSelector() {
    return SizedBox(
      height: 50, // Reduced height
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: _profiles.length,
        itemBuilder: (ctx, i) {
          String p = _profiles[i];
          bool isSelected = _selectedProfile == p;
          return GestureDetector(
            onTap: () => setState(() => _selectedProfile = p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentGold : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: isSelected ? AppColors.accentGold : Colors.white12),
              ),
              alignment: Alignment.center,
              child: Text(p, style: GoogleFonts.lato(color: isSelected ? AppColors.primaryDark : Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetabolicGlassCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('lead_logs')
          .where('tenant_id', isEqualTo: tenant_id).where('contact', isEqualTo: widget.contactNo)
          .where('profile', isEqualTo: _selectedProfile).orderBy('timestamp', descending: true).limit(7).snapshots(),
      builder: (context, snapshot) {

        // --- LOADING STATE ---
        if (!snapshot.hasData) {
          return _glassContainer(
              child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: AppColors.accentGold),
                  )
              )
          );
        }

        // --- EMPTY STATE ---
        List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return _glassContainer(
              child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Text("No Logs for $_selectedProfile", style: GoogleFonts.lato(color: Colors.white38)),
                  )
              )
          );
        }

        // --- DATA PROCESSING ---
        var latest = docs.first.data() as Map<String, dynamic>;
        int score = (latest['health_score'] ?? 0).toInt();
        List<dynamic> symptoms = latest['symptoms'] ?? [];
        List<FlSpot> spots = [];
        List<int> scores = [];
        for (int i = 0; i < docs.length; i++) {
          int s = (docs[i]['health_score'] ?? 0).toInt();
          scores.add(s);
          spots.add(FlSpot((docs.length - 1 - i).toDouble(), s.toDouble()));
        }

        return Column(
          mainAxisSize: MainAxisSize.min, // <--- CRITICAL: Prevents stretching
          children: [
            // THE GLASS CARD
            _glassContainer(
              child: Column(
                mainAxisSize: MainAxisSize.min, // <--- CRITICAL
                children: [
                  // HEADER ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("METABOLIC SCORE", style: GoogleFonts.lato(color: Colors.white38, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                          Text(_generateTrendReport(scores), style: GoogleFonts.lato(color: AppColors.accentGold, fontSize: 12))
                        ],
                      ),
                      Text("$score", style: GoogleFonts.oswald(fontSize: 24, color: _getScoreColor(score)))
                    ],
                  ),

                  const SizedBox(height: 15),

                  // CHART (Fixed height wrapper)
                  SizedBox(
                      height: 100, // Fixed height prevents overflow
                      width: double.infinity,
                      child: LineChart(
                          LineChartData(
                              gridData: FlGridData(show: false),
                              titlesData: FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              minY: 0, maxY: 100,
                              lineBarsData: [
                                LineChartBarData(
                                    spots: spots,
                                    isCurved: true,
                                    color: AppColors.accentGold,
                                    barWidth: 2,
                                    dotData: FlDotData(show: true),
                                    belowBarData: BarAreaData(show: true, color: AppColors.accentGold.withOpacity(0.1))
                                )
                              ]
                          )
                      )
                  )
                ],
              ),
            ),

            // WARNING BANNER
            if (score < 80)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: InkWell(
                  onTap: () => _submitClinicalInquiry(score, symptoms),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.redAccent.withOpacity(0.3))),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 16),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                                "Low Score. Request Clinical Callback",
                                style: GoogleFonts.lato(color: Colors.white, fontSize: 12),
                                overflow: TextOverflow.ellipsis
                            ),
                          )
                        ]
                    ),
                  ),
                ),
              )
          ],
        );
      },
    );
  }

  // --- SAFE GLASS CONTAINER ---
  // (Removed fixed 'height' parameter from build method to let it grow)
  Widget _glassContainer({required Widget child, double? height}) {
    return Container(
      height: height, // Can be null (auto-grow)
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: child,
    );
  }


  // Keep _buildGlassAppBar, _buildGlowOrb, _getScoreColor, _showSmartLogSheet, GlassSwipeDeck as is
  // (They are fine, just make sure to include them in the file)
  Widget _buildGlowOrb(Color color) => Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)]));
  Color _getScoreColor(int s) => s > 80 ? Colors.greenAccent : (s > 50 ? Colors.orangeAccent : Colors.redAccent);

  PreferredSizeWidget _buildGlassAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent, elevation: 0,
      flexibleSpace: ClipRRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Container(color: Colors.black.withOpacity(0.2)))),
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Hello, ${widget.userName}", style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), Text("Nutricare Member", style: GoogleFonts.lato(color: AppColors.accentGold, fontSize: 10, letterSpacing: 1.5))]),
      actions: [
        DropdownButtonHideUnderline(child: DropdownButton<String>(dropdownColor: const Color(0xFF1A3C34), value: _lang, icon: const Icon(Icons.language, color: Colors.white54, size: 16), style: GoogleFonts.lato(color: Colors.white, fontSize: 12), items: const [DropdownMenuItem(value: 'en', child: Text("En")), DropdownMenuItem(value: 'hi', child: Text("Hi")), DropdownMenuItem(value: 'or', child: Text("Or"))], onChanged: (v) => setState(() => _lang = v!))),
        IconButton(icon: const Icon(Icons.logout, color: Colors.white54, size: 20), onPressed: () async { final prefs = await SharedPreferences.getInstance(); await prefs.clear(); if(mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const ZeroReadGate())); })
      ],
    );
  }

  void _showSmartLogSheet(BuildContext context) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => SmartLogSheet(contactNo: widget.contactNo, userName: widget.userName, selectedProfile: _selectedProfile, lang: _lang));
  }
}

class GlassSwipeDeck extends StatefulWidget {
  final String lang;
  const GlassSwipeDeck({super.key, required this.lang});

  @override
  State<GlassSwipeDeck> createState() => _GlassSwipeDeckState();
}

class _GlassSwipeDeckState extends State<GlassSwipeDeck> {
  List<HealthTip> _shuffledTips = [];
  int _currentTipIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load and shuffle tips once
    _shuffledTips = List.from(masterHealthTips)..shuffle(Random());
  }

  // --- SHARE LOGIC ---
  Future<void> _shareTip(HealthTip tip) async {
    String title = tip.title[widget.lang] ?? tip.title['en']!;
    String body = tip.body[widget.lang] ?? tip.body['en']!;
    String message = "🚨 *HEALTH ALERT: $title* 🚨\n\n$body\n\n👉 Check your Health Score on the *Nutricare Wellness App*.";
    try {
      await Share.share(message);
    } catch (e) {
      debugPrint("Error sharing: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Handle Empty/Finished Deck
    if (_shuffledTips.isEmpty) return const SizedBox();

    if (_currentTipIndex >= _shuffledTips.length) {
      return Center(
        child: InkWell(
          onTap: () => setState(() {
            _currentTipIndex = 0;
            _shuffledTips.shuffle();
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.accentGold),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh, color: AppColors.accentGold),
                const SizedBox(width: 10),
                Text("Refresh Health Tips", style: GoogleFonts.lato(color: Colors.white)),
              ],
            ),
          ),
        ),
      );
    }

    HealthTip currentTip = _shuffledTips[_currentTipIndex];

    // 2. The Stack (Back Card + Front Card)
    return Stack(
      alignment: Alignment.center,
      children: [
        // --- BACKGROUND CARD (Next Tip) ---
        if (_currentTipIndex + 1 < _shuffledTips.length)
          Transform.scale(
            scale: 0.92,
            child: Transform.translate(
              offset: const Offset(0, 15), // Push it down slightly
              child: Opacity(
                opacity: 0.6,
                child: _buildCardUI(_shuffledTips[_currentTipIndex + 1], isFront: false),
              ),
            ),
          ),

        // --- FRONT CARD (Swipeable) ---
        Dismissible(
          key: ValueKey(currentTip), // Unique key for animation
          direction: DismissDirection.horizontal, // Only swipe Left/Right
          onDismissed: (direction) {
            setState(() {
              _currentTipIndex++;
            });
          },
          child: _buildCardUI(currentTip, isFront: true),
        ),
      ],
    );
  }

  Widget _buildCardUI(HealthTip tip, {required bool isFront}) {
    String title = tip.title[widget.lang] ?? tip.title['en']!;
    String body = tip.body[widget.lang] ?? tip.body['en']!;

    return Container(
      width: double.infinity,
      // Removed fixed height here; let parent SizedBox control it
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.95), // Darker background for readability
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: isFront
            ? [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.accentGold, borderRadius: BorderRadius.circular(6)),
                child: Text(
                    tip.category.toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)
                ),
              ),
              if (isFront)
                InkWell(
                  onTap: () => _shareTip(tip),
                  child: const Icon(Icons.share, color: Colors.white54, size: 20),
                )
            ],
          ),

          const SizedBox(height: 15),

          // SCROLLABLE CONTENT (Fixes hidden text issue)
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    body,
                    style: GoogleFonts.lato(fontSize: 15, color: Colors.white70, height: 1.5),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // FOOTER HINT
          if (isFront)
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.swipe, color: Colors.white24, size: 14),
                  const SizedBox(width: 5),
                  Text("Swipe left or right", style: GoogleFonts.lato(fontSize: 10, color: Colors.white24)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}