import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

// --- APP IMPORTS ---
import '../config/theme.dart';
import '../config/constant.dart'; // Must contain 'tenant_id'
import 'dashboard_screen.dart';

class PremiumLoginScreen extends StatefulWidget {
  const PremiumLoginScreen({super.key});

  @override
  State<PremiumLoginScreen> createState() => _PremiumLoginScreenState();
}

class _PremiumLoginScreenState extends State<PremiumLoginScreen> {
  // Controllers
  final _mobileCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _secretCtrl = TextEditingController(); // For Password/Recovery

  // State
  bool _isLoading = false;
  bool _isChecking = false;
  bool _numberChecked = false; // "True" means we know if they are New/Old
  bool _isNewUser = false;     // "True" = Register Mode, "False" = Login Mode
  bool _obscurePin = true;

  // ====================================================
  // 1. SMART CHECK (Detects Login vs Register)
  // ====================================================
  Future<void> _handlePrimaryAction() async {
    String mobile = _mobileCtrl.text.trim();

    // A. Simple Format Check
    if (mobile.length != 10) {
      _showMessage("Enter valid 10-digit mobile", isError: true);
      return;
    }

    // B. FIRST CLICK: Check if User Exists
    if (!_numberChecked) {
      setState(() => _isChecking = true);
      try {
        final QuerySnapshot result = await FirebaseFirestore.instance
            .collection('lead_health_assessments')
            .where('tenant_id', isEqualTo: tenant_id)
            .where('contact', isEqualTo: mobile)
            .limit(1)
            .get();

        setState(() {
          _isChecking = false;
          _numberChecked = true;
          _isNewUser = result.docs.isEmpty; // If empty, they are NEW
        });

        if (_isNewUser) {
          _showMessage("Welcome! Create your account.");
        } else {
          _showMessage("Welcome back! Enter PIN.");
        }
      } catch (e) {
        setState(() => _isChecking = false);
        _showMessage("Network Error", isError: true);
      }
      return;
    }

    // C. SECOND CLICK: Login or Register
    if (_isNewUser) {
      _registerUser(mobile);
    } else {
      _loginUser(mobile);
    }
  }

  // ====================================================
  // 2. REGISTER (New User)
  // ====================================================
  Future<void> _registerUser(String mobile) async {
    String name = _nameCtrl.text.trim();
    String pin = _pinCtrl.text.trim();
    String secret = _secretCtrl.text.trim().toLowerCase();

    if (name.isEmpty || pin.length != 4 || secret.isEmpty) {
      _showMessage("Please fill all fields", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('lead_health_assessments').doc(mobile).set({
        'tenant_id': tenant_id,
        'contact': mobile,
        'user_name': name,
        'pin': pin,
        'security_code': secret, // Saved for recovery
        'created_at': FieldValue.serverTimestamp(),
        'valid_to': DateTime.now().add(const Duration(days: 60)), // 60 Days Promo
        'source': 'app_fast_login',
        'is_verified': true, // Auto-verified since we compromised security
      });

      await _saveSessionAndRedirect(mobile, name);

    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage("Error: $e", isError: true);
    }
  }

  // ====================================================
  // 3. LOGIN (Existing User)
  // ====================================================
  Future<void> _loginUser(String mobile) async {
    String pin = _pinCtrl.text.trim();
    if (pin.isEmpty) {
      _showMessage("Enter PIN", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Fetch User Data
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('lead_health_assessments')
          .doc(mobile)
          .get();

      if (!doc.exists) {
        // Fallback: search by query if doc ID isn't mobile
        final QuerySnapshot qs = await FirebaseFirestore.instance
            .collection('lead_health_assessments')
            .where('contact', isEqualTo: mobile)
            .limit(1)
            .get();
        if (qs.docs.isNotEmpty) doc = qs.docs.first;
        else throw "User not found. Reset app.";
      }

      var data = doc.data() as Map<String, dynamic>;

      // A. Check PIN
      if ((data['pin'] ?? "").toString() != pin) {
        throw "Wrong PIN";
      }

      // B. Check Validity (60 Days)
      Timestamp? validTo = data['valid_to'];
      if (validTo != null && DateTime.now().isAfter(validTo.toDate())) {
        _showRenewalSheet(mobile);
        setState(() => _isLoading = false);
        return;
      }

      // C. Success
      await _saveSessionAndRedirect(
          mobile,
          data['user_name'] ?? "Member"
      );

    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage(e.toString().replaceAll("Exception: ", ""), isError: true);
    }
  }

  // ====================================================
  // 4. HELPERS (Redirect, Reset, Renewal)
  // ====================================================
  Future<void> _saveSessionAndRedirect(String mobile, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('promo_phone', mobile);
    await prefs.setString('promo_name', name);

    if (mounted) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PremiumDashboard(contactNo: mobile, userName: name))
      );
    }
  }
  void _showResetPinSheet() async {
    // 1. Wait for sheet to close
    final bool? success = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ResetPinSimpleSheet(initialMobile: _mobileCtrl.text),
    );

    // 2. Add a tiny delay (CRITICAL FIX)
    // This gives the keyboard time to close and the sheet time to disappear
    if (success == true) {
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        _showMessage("PIN Reset Successful! Please Login.", isError: false);
      }
    }
  }

  void _showRenewalSheet(String mobile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RenewalSheet(mobile: mobile),
    );
  }

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: isError ? Colors.red : Colors.green)
    );
  }

  void _resetFlow() {
    setState(() {
      _numberChecked = false;
      _isNewUser = false;
      _pinCtrl.clear();
      _nameCtrl.clear();
      _secretCtrl.clear();
    });
  }

  // ====================================================
  // UI BUILD
  // ====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F2C23), Colors.black],
              ),
            ),
          ),

          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // HEADER
                  Text(
                      "Nutricare Wellness",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 8),
                  Text(
                      "CLINICAL NUTRITION PLATFORM",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(color: Colors.white54, fontSize: 10, letterSpacing: 3, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 50),

                  // GLASS FORM
                  _buildGlassForm(),

                  const SizedBox(height: 20),

                  // Footer Links
                  if (_numberChecked && !_isNewUser)
                    TextButton(
                        onPressed: _showResetPinSheet,
                        child: Text("Forgot PIN?", style: GoogleFonts.lato(color: Colors.white54))
                    ),

                  if (_numberChecked)
                    TextButton(
                        onPressed: _resetFlow,
                        child: Text("Change Number", style: GoogleFonts.lato(color: AppColors.accentGold))
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassForm() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. MOBILE NUMBER (Always Visible)
              _buildInputLabel("Mobile Number"),
              TextField(
                controller: _mobileCtrl,
                keyboardType: TextInputType.number,
                maxLength: 10,
                enabled: !_numberChecked,
                style: TextStyle(color: _numberChecked ? Colors.white54 : Colors.white, fontSize: 18, letterSpacing: 2),
                decoration: _inputDecoration("98765 XXXXX", Icons.phone_android),
              ),

              // 2. DYNAMIC FIELDS
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: Column(
                  children: [
                    if (_numberChecked) ...[
                      const SizedBox(height: 15),

                      // NEW USER FIELDS
                      if (_isNewUser) ...[
                        _buildInputLabel("Your Name"),
                        TextField(
                          controller: _nameCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Enter full name", Icons.person),
                        ),
                        const SizedBox(height: 15),
                        _buildInputLabel("Secret Code (For PIN Reset)"),
                        TextField(
                          controller: _secretCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("e.g. Pet Name, City", Icons.security),
                        ),
                        const SizedBox(height: 15),
                      ],

                      // PIN FIELD (For Both)
                      _buildInputLabel(_isNewUser ? "Create 4-Digit PIN" : "Enter PIN"),
                      TextField(
                        controller: _pinCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        obscureText: _obscurePin,
                        style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 5),
                        decoration: _inputDecoration("****", Icons.lock).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePin ? Icons.visibility_off : Icons.visibility, color: Colors.white24),
                              onPressed: () => setState(() => _obscurePin = !_obscurePin),
                            )
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // 3. MAIN BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: (_isLoading || _isChecking) ? null : _handlePrimaryAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: (_isLoading || _isChecking)
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : Text(
                    _getButtonText(),
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getButtonText() {
    if (!_numberChecked) return "CONTINUE";
    if (_isNewUser) return "REGISTER & START";
    return "LOGIN";
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white12),
      counterText: "",
      prefixIcon: Icon(icon, color: AppColors.accentGold, size: 20),
      border: InputBorder.none,
      filled: true,
      fillColor: Colors.black26,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.accentGold)),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(label, style: GoogleFonts.lato(color: Colors.white54, fontSize: 12)),
    );
  }
}
// ====================================================
// 5. SIMPLE RESET SHEET (Bulletproof In-Line Errors)
// ====================================================
class ResetPinSimpleSheet extends StatefulWidget {
  final String initialMobile;
  const ResetPinSimpleSheet({super.key, required this.initialMobile});

  @override
  State<ResetPinSimpleSheet> createState() => _ResetPinSimpleSheetState();
}

class _ResetPinSimpleSheetState extends State<ResetPinSimpleSheet> {
  final _mobileCtrl = TextEditingController();
  final _secretCtrl = TextEditingController();
  final _newPinCtrl = TextEditingController();

  bool _loading = false;

  // --- NEW: State variables for showing messages directly ---
  String _statusMessage = "";
  Color _statusColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _mobileCtrl.text = widget.initialMobile;
  }

  Future<void> _reset() async {
    // 1. Clear previous errors & Hide Keyboard
    FocusScope.of(context).unfocus();
    setState(() {
      _statusMessage = "";
      _loading = true;
    });

    try {
      String mobile = _mobileCtrl.text.trim();

      // 2. Validate Inputs locally first
      if (mobile.length != 10) throw "Invalid Mobile Number";
      if (_secretCtrl.text.isEmpty) throw "Enter Secret Code";
      if (_newPinCtrl.text.length != 4) throw "PIN must be 4 digits";

      // 3. Search User in Firestore
      DocumentReference? userRef;
      var docSnap = await FirebaseFirestore.instance.collection('lead_health_assessments').doc(mobile).get();

      if (docSnap.exists) {
        userRef = docSnap.reference;
      } else {
        // Fallback search
        var querySnap = await FirebaseFirestore.instance
            .collection('lead_health_assessments')
            .where('contact', isEqualTo: mobile)
            .limit(1)
            .get();
        if (querySnap.docs.isNotEmpty) {
          userRef = querySnap.docs.first.reference;
          docSnap = querySnap.docs.first;
        }
      }

      if (userRef == null) throw "Mobile number not found.";

      // 4. Verify Secret
      String storedSecret = (docSnap.data()?['security_code'] ?? "").toString().toLowerCase();
      String inputSecret = _secretCtrl.text.trim().toLowerCase();

      if (storedSecret.isEmpty) throw "Recovery not set up for this user.";
      if (storedSecret != inputSecret) throw "Wrong Secret Code.";

      // 5. Update PIN
      await userRef.update({'pin': _newPinCtrl.text.trim()});

      // 6. SUCCESS
      if (mounted) {
        setState(() {
          _statusMessage = "✅ Success! PIN Reset. Closing...";
          _statusColor = Colors.greenAccent;
          _loading = false;
        });

        // Wait 1.5 seconds so user sees the green message, then close
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) Navigator.pop(context);
      }

    } catch (e) {
      // 7. FAILURE - Show Red Text
      if (mounted) {
        setState(() {
          _statusMessage = "❌ ${e.toString().replaceAll("Exception: ", "")}";
          _statusColor = Colors.redAccent;
          _loading = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
            top: 30, left: 30, right: 30,
            // Calculate bottom padding dynamically for keyboard
            bottom: MediaQuery.of(context).viewInsets.bottom + 30
        ),
        decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25))
        ),
        // ERROR WAS HERE: Removed 'mainAxisSize' from Container
      
        child: Column(
          mainAxisSize: MainAxisSize.min, // <--- MOVED IT HERE (Correct)
          children: [
            Text("Reset PIN", style: GoogleFonts.playfairDisplay(color: AppColors.accentGold, fontSize: 24)),
            const SizedBox(height: 20),
      
            _field(_mobileCtrl, "Mobile Number"),
            _field(_secretCtrl, "Enter Secret Code"),
            _field(_newPinCtrl, "New PIN", isPin: true),
      
            const SizedBox(height: 10),
      
            // --- ERROR MESSAGE AREA ---
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _statusColor.withOpacity(0.3))
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _statusMessage,
                        style: TextStyle(color: _statusColor, fontSize: 13, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
      
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGold),
                onPressed: _loading ? null : _reset,
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text("RESET", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String h, {bool isPin = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: c,
        keyboardType: isPin || h.contains("Mobile") ? TextInputType.number : TextInputType.text,
        maxLength: isPin ? 4 : 20,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
            labelText: h, labelStyle: const TextStyle(color: Colors.white54),
            filled: true, fillColor: Colors.white10,
            counterText: "",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
        ),
      ),
    );
  }
}
// ====================================================
// 6. RENEWAL SHEET (Reuse from before)
// ====================================================
class RenewalSheet extends StatefulWidget {
  final String mobile;
  const RenewalSheet({super.key, required this.mobile});

  @override
  State<RenewalSheet> createState() => _RenewalSheetState();
}

class _RenewalSheetState extends State<RenewalSheet> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;
  String _message = "";

  final Map<String, int> _validCodes = {
    "NUTRI30": 30, "GOLD90": 90, "VIP365": 365, "PROMO7": 7,
  };

  Future<void> _redeemCode() async {
    String input = _codeCtrl.text.trim().toUpperCase();
    if (!_validCodes.containsKey(input)) {
      setState(() => _message = "Invalid Activation Code");
      return;
    }
    setState(() { _loading = true; _message = ""; });

    try {
      var snapshot = await FirebaseFirestore.instance.collection('lead_health_assessments').doc(widget.mobile).get();
      if (snapshot.exists) {
        await snapshot.reference.update({
          'valid_to': DateTime.now().add(Duration(days: _validCodes[input]!)),
          'plan_type': 'RENEWED',
        });
        if (mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _message = "Error");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30), height: 400,
      decoration: const BoxDecoration(color: Color(0xFF1A1A1A), borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      child: Column(
        children: [
          const Icon(Icons.lock_clock, color: Colors.orange, size: 50),
          const SizedBox(height: 15),
          Text("Plan Expired", style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 22)),
          const SizedBox(height: 20),
          TextField(controller: _codeCtrl, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center, decoration: const InputDecoration(hintText: "ENTER CODE", filled: true, fillColor: Colors.white10)),
          if (_message.isNotEmpty) Text(_message, style: const TextStyle(color: Colors.red)),
          const Spacer(),
          ElevatedButton(onPressed: _loading ? null : _redeemCode, style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGold), child: const Text("RENEW"))
        ],
      ),
    );
  }
}