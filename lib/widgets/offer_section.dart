import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart'; // NEW: You might need to add carousel_slider to pubspec.yaml
import '../config/theme.dart';

// --- DATA MODELS ---
class PackageTier {
  final String name;
  final String price;
  final String? mktPrice;
  final String features;
  final Color color;
  final bool isRecommended;

  PackageTier({
    required this.name,
    required this.price,
    this.mktPrice,
    required this.features,
    required this.color,
    this.isRecommended = false,
  });
}

class PackageData {
  final String title;
  final String subtitle;
  final String duration;
  final String badge;
  final Color baseColor;
  final List<PackageTier> tiers;

  PackageData({
    required this.title,
    this.subtitle = "",
    required this.duration,
    required this.badge,
    required this.baseColor,
    required this.tiers,
  });
}

class OfferSection extends StatefulWidget {
  final Function(String package, String price) onBook;

  const OfferSection({super.key, required this.onBook});

  @override
  State<OfferSection> createState() => _OfferSectionState();
}

class _OfferSectionState extends State<OfferSection> {
  int _expandedIndex = -1;
  int _currentPhilosophyIndex = 0; // Track carousel page

  // --- WEBSITE LAUNCHER ---
  Future<void> _launchWebsite() async {
    final Uri url = Uri.parse("https://www.nutricarewellness.com");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch website");
    }
  }

  // --- DATA FOR CAROUSEL ---
  final List<Map<String, dynamic>> _philosophySlides = [
    {
      "title": "Food is NOT the Enemy",
      "desc": "We don't believe in starvation. Enjoy your favorite home-cooked meals while healing your metabolism.",
      "icon": Icons.restaurant_menu,
      "color": Colors.orangeAccent,
    },
    {
      "title": "Root Cause Resolution",
      "desc": "Pills only manage symptoms. We fix the hormonal imbalance (Insulin, Cortisol, Thyroid) that causes the disease.",
      "icon": FontAwesomeIcons.tree,
      "color": Colors.greenAccent,
    },
    {
      "title": "Sustainable Lifestyle",
      "desc": "No crash diets. We build habits that stick for a lifetime, so the weight never comes back.",
      "icon": FontAwesomeIcons.infinity,
      "color": Colors.blueAccent,
    },
  ];

  static List<PackageData> packages = [
    PackageData(
      title: "SINGLE SERVICES",
      duration: "A LA CARTE",
      badge: "STARTER",
      baseColor: Colors.tealAccent,
      tiers: [
        PackageTier(
            name: "CONSULT + DIET",
            price: "₹1,000",
            mktPrice: "2300",
            features: "45min Call + 1 Month Plan",
            color: Colors.white
        ),
        PackageTier(
            name: "LAB TEST ONLY",
            price: "20% OFF",
            mktPrice: null,
            features: "72 Thyrocare Tests (Home Collection)",
            color: Colors.white
        ),
      ],
    ),
    PackageData(
      title: "GUT & WEIGHT RESET",
      duration: "3 MONTHS",
      badge: "QUARTERLY",
      baseColor: Colors.orangeAccent,
      tiers: [
        PackageTier(
            name: "BASIC",
            price: "₹7,000",
            mktPrice: "15k",
            features: "Weekly Monitoring • Weight Loss",
            color: Colors.white70
        ),
        PackageTier(
            name: "STANDARD",
            price: "₹10,500",
            mktPrice: "23k",
            features: "Bi-Weekly Tweaks • Gut Cleaning",
            color: Colors.blueAccent
        ),
        PackageTier(
            name: "PREMIUM",
            price: "₹15,100",
            mktPrice: "33k",
            features: "Daily Monitoring • Priority Access",
            color: AppColors.accentGold,
            isRecommended: true
        ),
      ],
    ),
    PackageData(
      title: "METABOLIC REVERSAL",
      subtitle: "DIABETES • BP • THYROID • LIVER",
      duration: "6 MONTHS",
      badge: "BEST VALUE",
      baseColor: Colors.lightBlueAccent,
      tiers: [
        PackageTier(
            name: "BASIC",
            price: "₹13,000",
            mktPrice: "28k",
            features: "App Access • Standard Reversal Protocol",
            color: Colors.white70
        ),
        PackageTier(
            name: "STANDARD",
            price: "₹19,500",
            mktPrice: "42k",
            features: "Root Cause Fix • WhatsApp Support",
            color: Colors.blueAccent
        ),
        PackageTier(
            name: "PREMIUM",
            price: "₹28,000",
            mktPrice: "61k",
            features: "Full Disease Reversal • Senior Expert",
            color: AppColors.accentGold,
            isRecommended: true
        ),
      ],
    ),
    PackageData(
      title: "LIFESTYLE OVERHAUL",
      duration: "12 MONTHS",
      badge: "YEARLY",
      baseColor: Colors.purpleAccent,
      tiers: [
        PackageTier(
            name: "BASIC",
            price: "₹26,000",
            mktPrice: "57k",
            features: "Yearly Support • Maintenance Mode",
            color: Colors.white70
        ),
        PackageTier(
            name: "STANDARD",
            price: "₹39,000",
            mktPrice: "85k",
            features: "Lifestyle Lock • WhatsApp Support",
            color: Colors.blueAccent
        ),
        PackageTier(
            name: "PREMIUM",
            price: "₹55,900",
            mktPrice: "1.2L",
            features: "Family Add-On • Daily Monitoring",
            color: AppColors.accentGold,
            isRecommended: true
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double collapsedHeight = (screenHeight * 0.38).clamp(320.0, 380.0);
    double expandedHeight = (screenHeight * 0.75).clamp(600.0, 800.0);
    double listHeight = _expandedIndex == -1 ? collapsedHeight : expandedHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // --- 1. NEW PHILOSOPHY CAROUSEL ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Text("WHY CHOOSE US?", style: GoogleFonts.lato(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
        ),
        _buildPhilosophyCarousel(),
        const SizedBox(height: 10),
        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _philosophySlides.asMap().entries.map((entry) {
            return Container(
              width: 6.0,
              height: 6.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black)
                    .withOpacity(_currentPhilosophyIndex == entry.key ? 0.9 : 0.2),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // --- 2. EXPERTISE GRID ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("OUR CLINICAL EXPERTISE", style: GoogleFonts.lato(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text("What We Treat", style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildExpertiseGrid(),
            ],
          ),
        ),

        const SizedBox(height: 25),

        // --- 3. PACKAGES HEADER ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Select Your Protocol",
                style: GoogleFonts.playfairDisplay(color: Colors.white70, fontSize: 18, letterSpacing: 1),
              ),
              if (_expandedIndex != -1)
                InkWell(
                  onTap: () => setState(() => _expandedIndex = -1),
                  child: const Text("Collapse All", style: TextStyle(color: Colors.white38, fontSize: 12)),
                )
            ],
          ),
        ),
        const SizedBox(height: 15),

        // --- 4. HORIZONTAL LIST ---
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: listHeight,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              // Thyrocare Card
              Align(
                alignment: Alignment.topCenter,
                child: _buildThyrocareCard(context),
              ),

              const SizedBox(width: 15),

              // Dynamic Packages
              ...packages.asMap().entries.map((entry) {
                int index = entry.key;
                PackageData pkg = entry.value;
                bool isExpanded = _expandedIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: _buildExpandableCard(context, pkg, index, isExpanded),
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // --- 5. TRUST & WEBSITE SECTION ---
        _buildTrustSection(),

        const SizedBox(height: 20),
      ],
    );
  }

  // --- WIDGET: PHILOSOPHY CAROUSEL ---
  Widget _buildPhilosophyCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 140.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        viewportFraction: 0.9,
        enlargeCenterPage: true,
        onPageChanged: (index, reason) {
          setState(() {
            _currentPhilosophyIndex = index;
          });
        },
      ),
      items: _philosophySlides.map((slide) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: slide['color'].withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(slide['icon'], color: slide['color'], size: 28),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slide['title'],
                          style: GoogleFonts.oswald(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          slide['desc'],
                          style: GoogleFonts.lato(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.3
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }

  // --- NEW TRUST FOOTER WIDGET ---
  Widget _buildTrustSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_box_outlined, color: AppColors.accentGold, size: 16),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            "STANDARD INCLUSIONS",
                            style: GoogleFonts.lato(color: AppColors.accentGold, fontSize: 10, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _checkListItem("Plan Updates every 7-10 days"),
                    _checkListItem("Recipe & Grocery Guide"),
                    _checkListItem("App & WhatsApp Support"),
                    _checkListItem("Lab Report Reviews"),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_user_outlined, color: Colors.greenAccent, size: 16),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            "OUR PROMISE",
                            style: GoogleFonts.lato(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _checkListItem("100% Natural"),
                    _checkListItem("No Fad Diets"),
                    _checkListItem("Doctor Aligned"),
                    _checkListItem("Sustainable Healing"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          const Divider(color: Colors.white10),
          const SizedBox(height: 20),
          InkWell(
            onTap: _launchWebsite,
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 5,
              runSpacing: 5,
              children: [
                const Icon(Icons.language, color: Colors.white54, size: 18),
                Text("Visit Official Website:", style: GoogleFonts.lato(color: Colors.white70, fontSize: 14)),
                Text(
                    "www.nutricarewellness.com",
                    style: GoogleFonts.lato(
                        color: AppColors.accentGold,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline
                    )
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _checkListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        "• $text",
        style: GoogleFonts.lato(color: Colors.white60, fontSize: 11, height: 1.3),
      ),
    );
  }

  // --- EXPERTISE GRID WIDGET ---
  Widget _buildExpertiseGrid() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _expertiseItem(FontAwesomeIcons.droplet, "Diabetes\n(Type 2)", Colors.blueAccent),
              _expertiseItem(FontAwesomeIcons.heartPulse, "High BP\n(Hypertension)", Colors.redAccent),
              _expertiseItem(FontAwesomeIcons.martiniGlassEmpty, "Fatty Liver\n(Gr 1-3)", Colors.orangeAccent),
              _expertiseItem(FontAwesomeIcons.weightScale, "Weight Loss\n(Obesity)", Colors.tealAccent),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _expertiseItem(FontAwesomeIcons.leaf, "Thyroid\n(Hypo/Hashi)", Colors.greenAccent),
              _expertiseItem(FontAwesomeIcons.personDress, "PCOS\n(Hormonal)", Colors.pinkAccent),
              _expertiseItem(FontAwesomeIcons.bacteria, "Gut Health\n(IBS/Gas)", Colors.brown),
              _expertiseItem(FontAwesomeIcons.flask, "Kidney\n(Uric Acid)", Colors.purpleAccent),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _expertiseItem(FontAwesomeIcons.shieldVirus, "Auto-Immune\n(RA/Lupus)", Colors.indigoAccent),
              _expertiseItem(FontAwesomeIcons.spa, "Skin & Hair\n(Aesthetic)", Colors.cyanAccent),
              _expertiseItem(FontAwesomeIcons.personPregnant, "Pregnancy\n(Natal Care)", Colors.pink.shade200),
              _expertiseItem(FontAwesomeIcons.personCane, "Geriatric\n(Old Age)", Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _expertiseItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(color: Colors.white70, fontSize: 10, height: 1.2),
        )
      ],
    );
  }

  // --- THYROCARE CARD ---
  Widget _buildThyrocareCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.accentGold.withOpacity(0.6), width: 2),
            gradient: LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.02)]),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.accentGold, borderRadius: BorderRadius.circular(20)),
                  child: const Text("LIMITED TIME COMBO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
                const SizedBox(height: 10),
                Text("FULL BODY CHECKUP", style: GoogleFonts.oswald(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                Text("72 TESTS + DIET CONSULT", style: GoogleFonts.lato(fontSize: 12, color: Colors.white70)),

                const SizedBox(height: 15),
                _buildBreakdownRow("72 Thyrocare Tests", "₹2,200"),
                const SizedBox(height: 5),
                _buildBreakdownRow("Diet Consult (45min)", "₹1,200"),
                const SizedBox(height: 5),
                _buildBreakdownRow("Diet Plan", "₹1,100"),

                const SizedBox(height: 10),
                const Divider(color: Colors.white10),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Value", style: TextStyle(color: Colors.white38, fontSize: 10)),
                        Text("₹4,500", style: GoogleFonts.lato(fontSize: 16, color: Colors.white38, decoration: TextDecoration.lineThrough)),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("Offer Price", style: TextStyle(color: AppColors.accentGold, fontSize: 10, fontWeight: FontWeight.bold)),
                        Text("₹2,499", style: GoogleFonts.lato(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.accentGold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => widget.onBook("Thyrocare Combo Offer", "₹2,499"),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: AppColors.accentGold, borderRadius: BorderRadius.circular(12)),
                    alignment: Alignment.center,
                    child: Text("BOOK COMBO", style: GoogleFonts.lato(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- EXPANDABLE CARD ---
  Widget _buildExpandableCard(BuildContext context, PackageData pkg, int index, bool isExpanded) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: pkg.baseColor.withOpacity(0.3)),
        gradient: LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.02)]),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: pkg.baseColor.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: Text(pkg.badge, style: GoogleFonts.lato(fontSize: 10, fontWeight: FontWeight.bold, color: pkg.baseColor)),
                ),
                Text(pkg.duration, style: GoogleFonts.lato(fontSize: 12, color: Colors.white54)),
              ],
            ),
            const SizedBox(height: 10),
            Text(pkg.title, style: GoogleFonts.oswald(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1)),
            if(pkg.subtitle.isNotEmpty)
              Text(pkg.subtitle, style: GoogleFonts.lato(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 1)),

            const SizedBox(height: 15),
            const Divider(color: Colors.white10),
            const SizedBox(height: 10),

            // 1. BASIC TIER (Always Visible)
            _buildDetailedTierRow(pkg.tiers[0], pkg.baseColor),

            // 2. EXPANDED TIERS
            if (isExpanded) ...[
              const SizedBox(height: 10),
              ...pkg.tiers.skip(1).map((tier) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildDetailedTierRow(tier, pkg.baseColor),
              )),
            ],

            // 3. TOGGLE BUTTON
            if (pkg.tiers.length > 1)
              InkWell(
                onTap: () {
                  setState(() {
                    if (_expandedIndex == index) {
                      _expandedIndex = -1;
                    } else {
                      _expandedIndex = index;
                    }
                  });
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 5),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isExpanded ? "Show Less" : "Compare Variants",
                        style: GoogleFonts.lato(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.white70,
                          size: 16
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedTierRow(PackageTier tier, Color baseColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tier.isRecommended ? AppColors.accentGold.withOpacity(0.1) : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: tier.isRecommended ? Border.all(color: AppColors.accentGold.withOpacity(0.5)) : Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (tier.isRecommended)
                    const Padding(padding: EdgeInsets.only(right: 6), child: Icon(Icons.star, size: 14, color: AppColors.accentGold)),
                  Text(
                      tier.name,
                      style: GoogleFonts.lato(
                          color: tier.isRecommended ? AppColors.accentGold : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                      )
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(tier.price, style: GoogleFonts.oswald(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  if (tier.mktPrice != null)
                    Text(tier.mktPrice!, style: GoogleFonts.lato(color: Colors.white38, fontSize: 10, decoration: TextDecoration.lineThrough)),
                ],
              )
            ],
          ),
          const SizedBox(height: 5),
          Text(tier.features, style: GoogleFonts.lato(color: Colors.white60, fontSize: 11)),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => widget.onBook(tier.name, tier.price),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: tier.isRecommended ? AppColors.accentGold : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                "BOOK NOW",
                style: GoogleFonts.lato(
                    color: tier.isRecommended ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white54, size: 14),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.lato(color: Colors.white70, fontSize: 13)),
          ],
        ),
        Text(price, style: GoogleFonts.lato(color: Colors.white30, decoration: TextDecoration.lineThrough, fontSize: 12)),
      ],
    );
  }
}