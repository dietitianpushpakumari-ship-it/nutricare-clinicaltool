import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../config/knowledge_content.dart'; // Ensure this points to the file we just updated

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _currentLang = 'en'; // Default Language

  @override
  void initState() {
    super.initState();
    // Two Tabs: 1. Diseases (Clinical), 2. Food (Kitchen/Myths)
    _tabController = TabController(length: 2, vsync: this);
  }

  // --- HELPER TO GET TRANSLATED TEXT ---
  String _getText(Map<String, String> map) {
    return map[_currentLang] ?? map['en'] ?? "Content unavailable";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. BACKGROUND GRADIENT
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0F2C23), Colors.black],
                ),
              ),
            ),
        
            SafeArea(
              child: Column(
                children: [
                  // --- HEADER & LANGUAGE TOGGLE ---
                  _buildHeader(),
        
                  // --- TAB BAR ---
                  TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.accentGold,
                    labelColor: AppColors.accentGold,
                    unselectedLabelColor: Colors.white38,
                    indicatorWeight: 3,
                    labelStyle: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
                    tabs: const [
                      Tab(text: "CHRONIC DISEASES"),
                      Tab(text: "LIFESTYLE & CURES"),
                    ],
                  ),
        
                  const SizedBox(height: 10),
        
                  // --- LIST CONTENT ---
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildList('disease'), // Tab 1
                        _buildList('food'),    // Tab 2
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 20, 15), // Reduced left padding for Back Button alignment
      child: Row(
        children: [
          // 1. BACK BUTTON
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),

          // 2. TITLE (Wrapped in Expanded to push Language Switcher to the right)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Body Intelligence", style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text("Understand Your Symptoms", style: GoogleFonts.lato(color: Colors.white54, fontSize: 10)),
              ],
            ),
          ),

          // 3. LANGUAGE PILLS
          Container(
            height: 35,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
            child: Row(
              children: [
                _langBtn('en', "Eng"),
                _langBtn('hi', "हिंदी"),
                _langBtn('or', "ଓଡ଼ିଆ"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _langBtn(String code, String label) {
    bool isActive = _currentLang == code;
    return GestureDetector(
      onTap: () => setState(() => _currentLang = code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentGold : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(label, style: GoogleFonts.lato(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? Colors.black : Colors.white54)),
      ),
    );
  }

  Widget _buildList(String category) {
    // Filter master list by category
    final items = masterKnowledge.where((i) => i.category == category).toList();

    if (items.isEmpty) {
      return Center(child: Text("Coming Soon...", style: GoogleFonts.lato(color: Colors.white30)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => _showDetailSheet(context, item),
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                // Icon Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppColors.accentGold.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accentGold.withOpacity(0.3))
                  ),
                  child: Icon(item.icon, color: AppColors.accentGold, size: 26),
                ),
                const SizedBox(width: 15),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getText(item.title), style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.white30, size: 12),
                          const SizedBox(width: 5),
                          Text("Tap to reveal the truth", style: GoogleFonts.lato(color: Colors.white30, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white12, size: 14),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- THE DETAILED BOTTOM SHEET ---
  void _showDetailSheet(BuildContext context, KnowledgeItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.90, // Tall Sheet
        decoration: const BoxDecoration(
          color: Color(0xFF151515), // Deep dark background
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.fromLTRB(25, 10, 25, 25),
        child: Column(
          children: [
            // Handle
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),

            // Header
            Row(
              children: [
                Icon(item.icon, color: AppColors.accentGold, size: 28),
                const SizedBox(width: 15),
                Expanded(child: Text(_getText(item.title), style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
                IconButton(icon: const Icon(Icons.close, color: Colors.white38), onPressed: () => Navigator.pop(context))
              ],
            ),
            const Divider(color: Colors.white10, height: 30),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. SYMPTOMS (Awareness)
                    _buildSectionHeader("⚠️ SYMPTOMS / LAKSHAN", Colors.orangeAccent),
                    _buildContentBox(_getText(item.symptoms), Colors.orangeAccent.withOpacity(0.05), Colors.orangeAccent),

                    const SizedBox(height: 25),

                    // 2. REALITY (Fear/Education)
                    _buildSectionHeader("🚫 THE DARK REALITY", Colors.redAccent),
                    _buildContentBox(_getText(item.reality), Colors.redAccent.withOpacity(0.05), Colors.redAccent),

                    const SizedBox(height: 25),

                    // 3. SOLUTION (Science/Hope)
                    _buildSectionHeader("✅ THE NUTRICARE SCIENCE", Colors.greenAccent),
                    _buildContentBox(_getText(item.solution), Colors.greenAccent.withOpacity(0.05), Colors.greenAccent),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Call to Action
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Redirecting to Dr. Pushpa's WhatsApp...")));
                  // Add WhatsApp Launch Logic here later
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: Text("CONSULT DR. PUSHPA", style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(title, style: GoogleFonts.lato(color: color, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5)),
    );
  }

  Widget _buildContentBox(String text, Color bgColor, Color borderColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: GoogleFonts.lato(color: Colors.white.withOpacity(0.9), fontSize: 15, height: 1.6),
      ),
    );
  }
}