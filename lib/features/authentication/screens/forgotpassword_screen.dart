import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import 'package:travel_minds/features/authentication/screens/signin_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController reset_email_controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool circular = false;
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(11, 16, 24, 1),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.only(left: 15,right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5.h),
                  IconButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => const SignInScreen()),
                              (route) => false);
                    },
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20.sp),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.w),
                    height: 40.h,
                    width: 90.w,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/forgotimg.png"),
                          fit: BoxFit.fill),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 2.0, bottom: 5, top: 0),
                    child: Text(
                      'Email',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        // fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Email field
                  SizedBox(
                    height: 75,
                    child: TextFormField(
                      controller: reset_email_controller,
                      cursorColor:
                      const Color.fromARGB(255, 193, 238, 251),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 14, horizontal: 10),
                        suffixIcon: Icon(
                          Icons.email,
                          size: 25,
                          color:
                          const Color.fromARGB(255, 193, 238, 251),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(width: 1.5)),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: const Color.fromARGB(
                                    255, 193, 238, 251))),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color.fromARGB(
                                255, 193, 238, 251),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorStyle: TextStyle(
                          fontSize: 12,

                          // Adjust font size for the error text
                          height:
                          1.5, // Reduce the line height to minimize padding
                        ),
                        errorMaxLines: 1,
                        // Limit error message to a single line
                        isDense: true,
                      ),
                      validator: emailValidator,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Padding(
                    padding: EdgeInsets.only(left: 45.w),
                    child: reset(),
                  ),
                  SizedBox(height: 5.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget textitem(String labelname, TextEditingController controller) {
    return Container(
      height: 6.h,
      width: 80.w,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 17, 110, 142).withAlpha(20),
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        cursorColor: const Color.fromARGB(255, 193, 251, 233),
        decoration: InputDecoration(
          labelText: labelname,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelStyle: TextStyle(fontSize: 15.sp, color: Colors.white),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 193, 251, 233),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(9.sp),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 232, 232, 232),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(9.sp),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Email is required';
          }
          if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value.trim())) {
            return 'Enter a valid email';
          }
          return null;
        },
      ),
    );
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Define the regular expression for a valid email
    final emailRegExp = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );

    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }
  Widget reset() {
    return InkWell(
      onTap: () {
        if (_formKey.currentState!.validate()) {
          resetPassword();
        }
      },
      child: Container(
        height: 5.h,
        width: 35.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.sp),
          gradient: const LinearGradient(colors: [
            Color.fromARGB(255, 123, 192, 215),
            Color.fromARGB(255, 82, 200, 232),
            Color.fromARGB(255, 22, 89, 112)
          ]),
        ),
        child: circular
            ? Center(
          child: Lottie.asset(
            'assets/images/loading.json',
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
        )
            : Center(
          child: Text(
            "Reset",
            style: TextStyle(
              color: const Color.fromARGB(255, 44, 66, 77),
              fontSize: 19.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future resetPassword() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Lottie.asset(
          'assets/images/loading.json',
          width: 150,
          height: 150,
          fit: BoxFit.contain,
        ),
      ),
    );

    try {
      await auth.sendPasswordResetEmail(
        email: reset_email_controller.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password Reset Link Sent to Your Email'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop(); // close loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "An error occurred"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
