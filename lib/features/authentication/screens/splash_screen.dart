import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart'; // Using GetX for navigation
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:travel_minds/binding/firebase_options.dart';
import 'package:travel_minds/common/screens/onboarding_screen.dart';
import 'package:travel_minds/data/repositories/mongo_repository.dart';
import 'package:travel_minds/features/authentication/screens/mail_verification.dart';
import 'package:travel_minds/features/dashboard/screens/home_screen.dart';
import 'package:travel_minds/features/dashboard/screens/main/bottom_navigation.dart';
import 'package:travel_minds/localization/select_language_screen.dart';
import 'package:travel_minds/utils/constants/colors.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  // Initialize Firebase
  Future<void> initializeApp() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await MongoDb.connect();
  }

  // Timer for splash screen
  timer() {
    Timer(const Duration(seconds: 3), () async {
      // Check Firebase user status after SplashScreen
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // If user is not logged in, navigate to Onboarding and SignIn Screen
        Get.offAll(() => const SelectLang());
      } else if (user.emailVerified) {
        // If logged in and email is verified, navigate to the Home Screen
        Get.offAll(() => const BottomNavigationScreen());
      } else {
        // If logged in but email is not verified, navigate to MailVerificationScreen
        Get.offAll(() => MailVerificationScreen(email: user.email!));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initializeApp();  // Initialize Firebase
    timer();  // Start the timer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.darkBg, // You can customize the background color
      body: Center(
        child: Image.asset("assets/logos/logo.png"), // Your logo here
      ),
    );
  }
}
