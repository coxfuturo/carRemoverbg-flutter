import 'package:carbgremover/Routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // optional splash delay

    final user = FirebaseAuth.instance.currentUser;

    if (user != null && mounted) {
      // ✅ USER IS LOGGED IN → DASHBOARD
      Navigator.pushReplacementNamed(context, Routes.dashboard);
    }

  }
  @override
  Widget build(BuildContext context) {
    return
      AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // 🔥 important
          statusBarIconBrightness: Brightness.light, // Android icons
          statusBarBrightness: Brightness.dark, // iOS text
        ),
        child: _splashScreen(context),
      );
  }

  Widget _splashScreen(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B1C2D), Color(0xFF07121E)],
          ),
        ),

        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              /// ICON
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', height: 100),
                  /// TITLE
                  const Text(
                    "Snap Your Car",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              /// SUBTITLE
              Text(
                "Make your car photos showroom-\nready in one tap",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Colors.white70),
              ),

              const SizedBox(height: 40),
              /// GET STARTED BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.login);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF29B6F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Get Started",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward,color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// TRY DEMO BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.dashboard);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1BB6A5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Try Demo",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              /// FOOTER
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  "Professional AI enhancement • Lifetime access",
                  style: TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
