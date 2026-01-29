import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:promotional_app/main.dart' show ZeroReadGate;
import 'package:promotional_app/screens/gate_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';


class PremiumLoginScreen extends StatefulWidget {
  const PremiumLoginScreen({super.key});

  @override
  State<PremiumLoginScreen> createState() => _PremiumLoginScreenState();
}

class _PremiumLoginScreenState extends State<PremiumLoginScreen> {
  final _phoneCtrl = TextEditingController();
  bool _isProcessing = false;

  Future<void> _loginWithPhone() async {
    String phoneInput = _phoneCtrl.text.trim();

    if (phoneInput.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter a valid mobile number")));
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 1. SEARCH FOR ANY KEY ASSIGNED TO THIS PHONE
      final QuerySnapshot query = await FirebaseFirestore.instance
          .collection('promo_keys')
          .where('assigned_to', isEqualTo: phoneInput)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw "No plan found for this number. Please register first.";
      }

      var doc = query.docs.first;
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // 2. CHECK EXPIRY
      Timestamp? validTo = data['valid_to'];
      if (validTo != null && DateTime.now().isAfter(validTo.toDate())) {
        throw "Your plan has expired.";
      }

      // 3. GET USER DETAILS FROM KEY (Or Default)
      String userName = data['user_name'] ?? "Member";
      String code = data['code'];

      // 4. ACTIVATE SESSION (If not already)
      if (data['is_used'] == false) {
        await doc.reference.update({
          'is_used': true,
          'claimed_at': FieldValue.serverTimestamp(),
        });
      }

      // 5. SAVE LOCALLY
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('promo_phone', phoneInput);
      await prefs.setString('promo_name', userName);
      await prefs.setString('active_coupon', code);

      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ZeroReadGate()));
      }

    } catch(e) {
      setState(() => _isProcessing = false);
      String errorMsg = e.toString().replaceAll("Exception: ", "");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const Icon(Icons.diamond_outlined, color: AppColors.accentGold, size: 50),
              const SizedBox(height: 30),
              Text("Member Access", style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 32)),
              Text("Enter registered number to login.", style: GoogleFonts.lato(color: Colors.white54)),
              const SizedBox(height: 40),

              // ONLY PHONE NUMBER FIELD
              TextField(
                controller: _phoneCtrl,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Mobile Number",
                  labelStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.phone_android, color: AppColors.accentGold),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.accentGold)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                ),
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _loginWithPhone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(_isProcessing ? "Checking..." : "SECURE LOGIN", style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}