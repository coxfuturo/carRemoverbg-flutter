import 'package:carbgremover/CameraCaptureScreen.dart';
import 'package:carbgremover/CarImage.dart';
import 'package:carbgremover/CarViewDetailScreen.dart';
import 'package:carbgremover/DashboardRoot.dart';
import 'package:carbgremover/Login.dart';
import 'package:carbgremover/OnboardingScreen.dart';
import 'package:carbgremover/PreviewScreen.dart';
import 'package:carbgremover/profile_page.dart';
import 'package:carbgremover/report_bug_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'AppSettings.dart';
import 'Register.dart';
import 'Routes.dart';
import 'billing_history_screen.dart';
import 'contact_support_screen.dart';
import 'edit_profile_screen.dart';
import 'help_faq_screen.dart';
import 'history_screen.dart';
import 'home_page.dart';
import 'manage_plan_screen.dart';
import 'splash_screen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppSettings(),
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Image bg Remover',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      // ✅ DO NOT use home
      initialRoute: Routes.splash,

      // ✅ ALL routes MUST be registered
      routes: {
        Routes.splash: (_) => const SplashScreen(),
        Routes.login: (_) => const LoginScreen(),
        Routes.onBoardingScreen: (_) => const OnboardingScreen(),
        Routes.register: (_) => const RegisterScreen(),
        Routes.home: (_) => const MyHomePage(),
        Routes.dashboard: (_) => const DashboardRoot(),
        Routes.history: (_) => const HistoryScreen(),
        Routes.profile: (_) => const ProfileScreen(),
        Routes.helpFaqScreen: (_) => const HelpFaqScreen(),
        Routes.reportBugScreen: (_) => const ReportBugScreen(),
        Routes.managePlanScreen: (_) => const ManagePlanScreen(),
        Routes.billingHistoryScreen: (_) => const BillingHistoryScreen(),
        Routes.editProfileScreen: (_) => const EditProfileScreen(),
        Routes.contactSupportScreen: (_) => const ContactSupportScreen(),
        Routes.carDetailScreen: (_) => const CarDetailScreen(),
        Routes.cameraCaptureScreen: (_) => const CameraCaptureScreen(),
      },
    );
  }
}

