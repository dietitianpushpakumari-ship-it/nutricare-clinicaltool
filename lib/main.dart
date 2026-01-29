import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:promotional_app/screens/gate_screen.dart';
import 'config/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Try to Initialize Firebase
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyACeCXP-fQ5chNLdaWdlKr0cPdrTwgN86U", // <--- DOUBLE CHECK THIS!
        authDomain: "nutricarewellness-live.firebaseapp.com",
        projectId: "nutricarewellness-live",
        storageBucket: "nutricarewellness-live.firebasestorage.app",
        messagingSenderId: "867334529574",
        appId: "1:867334529574:web:a7a4f2a33a87d088913ce7",
        measurementId: "G-F3X5Z1DMNN",
      ),
    );

    // Apply Settings
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    // If Firebase fails, PRINT the error and run the app anyway so it's not white
    print("FATAL ERROR: Firebase failed to start: $e");
    runApp(ErrorApp(errorMessage: e.toString()));
    return;
  }

  // If successful, run the real app
  runApp(const UltraPremiumApp());
}

// --- MAIN APP ---
class UltraPremiumApp extends StatelessWidget {
  const UltraPremiumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutricare Wellness',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.creamBg,
        primaryColor: AppColors.primaryDark,
        useMaterial3: true,
        textTheme: TextTheme(
          displayLarge: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textMain),
          bodyLarge: GoogleFonts.lato(fontSize: 16, color: AppColors.textMain),
        ),
      ),
      home: const ZeroReadGate(),
    );
  }
}

// --- FALLBACK ERROR SCREEN (Shows instead of White Screen) ---
class ErrorApp extends StatelessWidget {
  final String errorMessage;
  const ErrorApp({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red.shade50,
        body: Padding(
          padding: const EdgeInsets.all(30),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 20),
                const Text(
                  "App Startup Failed",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(height: 10),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}