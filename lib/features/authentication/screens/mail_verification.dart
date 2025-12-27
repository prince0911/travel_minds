import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:travel_minds/features/authentication/screens/signin_screen.dart';
import 'package:travel_minds/features/dashboard/screens/main/bottom_navigation.dart';
import 'package:travel_minds/utils/constants/colors.dart';

class MailVerificationScreen extends StatefulWidget {
  const MailVerificationScreen({super.key, required this.email});
  final String email;

  @override
  State<MailVerificationScreen> createState() => _MailVerificationScreenState();
}

class _MailVerificationScreenState extends State<MailVerificationScreen> {
  final _auth = FirebaseAuth.instance;
  bool isEmailVerified = false;
  bool isLoading = false;
  String errorMessage = '';
  Timer? timer;
  bool hasNavigated = false;

  @override
  void initState() {
    super.initState();
    checkEmailVerified();
    timer = Timer.periodic(Duration(seconds: 2), (timer) {
      checkEmailVerified();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    User? user = _auth.currentUser;
    await user?.reload();
    bool emailVerified = user?.emailVerified ?? false;

    if (emailVerified) {
      if (mounted) {
        setState(() {
          isEmailVerified = true;
        });
      }
      timer?.cancel();

      // ✅ Set SharedPreferences flag BEFORE navigating
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // ✅ Only set 'showDialog' if it is not already set
      bool? showDialog = prefs.getBool('showDialog');
      if (showDialog == null) {
        await prefs.setBool('showDialog', true);
      }

      debugPrint("📌 Dialog flag retrieved: ${prefs.getBool('showDialog')}");

      if (!hasNavigated) {
        hasNavigated = true;
        Get.offAll(() => BottomNavigationScreen()); // ✅ Navigate after setting flag
      }
    }
  }



  Future<void> resendVerification() async {
    try {
      setState(() => isLoading = true);
      User? user = _auth.currentUser;
      await user?.sendEmailVerification();
      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: 100.h,
          width: double.infinity,
          color: TColors.darkBg,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: Image.asset('assets/images/email_envolope.png'),
              ),
              SizedBox(height: 40),
              Text(
                'Verify your email address',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                child: Text(
                  'We have just sent a verification link to your email. Please check your email and click on the link to verify your address.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'If not auto-redirected after verification, click on the Continue button.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 200),
              InkWell(
                onTap: () => resendVerification(),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh, color: Colors.blue),
                      Text(
                        'Resend email verification',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignInScreen()),
                  );
                },
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back, color: Colors.blue),
                      Text(
                        'Back to login',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
