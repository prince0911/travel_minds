import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:travel_minds/features/authentication/screens/signin_screen.dart';

class LogoutLoadingScreen extends StatefulWidget {
  const LogoutLoadingScreen({super.key});

  @override
  State<LogoutLoadingScreen> createState() => _LogoutLoadingScreenState();
}

class _LogoutLoadingScreenState extends State<LogoutLoadingScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    Get.offAll(() => const SignInScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // optional dark background
      body: Center(
        child: Lottie.asset(
          'assets/images/loading.json',
          width: 150,
          height: 150,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
