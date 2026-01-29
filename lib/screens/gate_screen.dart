import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class ZeroReadGate extends StatefulWidget {
  const ZeroReadGate({super.key});

  @override
  State<ZeroReadGate> createState() => _ZeroReadGateState();
}

class _ZeroReadGateState extends State<ZeroReadGate> {
  bool _isLoading = true;
  String? _tenantId;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      _tenantId = prefs.getString('promo_phone');
      _userName = prefs.getString('promo_name');
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.primaryDark,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.spa, color: AppColors.accentGold, size: 60),
              const SizedBox(height: 20),
              Text("NUTRICARE WELLNESS", style: GoogleFonts.playfairDisplay(color: Colors.white, letterSpacing: 4)),
            ],
          ),
        ),
      );
    }

    if (_tenantId != null) {
      return PremiumDashboard(tenantId: _tenantId!, userName: _userName ?? "Member");
    } else {
      return const PremiumLoginScreen();
    }
  }
}