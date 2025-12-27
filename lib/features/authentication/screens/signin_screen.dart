import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import 'package:travel_minds/features/authentication/controllers/authentication_file.dart';
import 'package:travel_minds/features/authentication/controllers/register_controller.dart';
import 'package:travel_minds/features/authentication/screens/forgotpassword_screen.dart';
import 'package:travel_minds/features/authentication/screens/signup_screen.dart';
import 'package:travel_minds/features/dashboard/screens/main/bottom_navigation.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final controller = Get.put(RegisterController());
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isPassword = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'email_required'.tr;
    }

    // Define the regular expression for a valid email
    final emailRegExp = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );

    if (!emailRegExp.hasMatch(value)) {
      return 'valid_email'.tr;
    }

    return null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _errorMessage="";
    controller.email.text="";
    controller.password.text="";
  }

  @override
  Widget build(BuildContext context) {
    final authController = AuthenticationFile.instance;

    return Scaffold(
      backgroundColor: Color.fromRGBO(11, 16, 24, 1),
      body: Obx((){
        return Stack(
          children: [
            Visibility(child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.h),
                    Padding(
                      padding: EdgeInsets.only(left: 65.w),
                      child: Image.asset("assets/images/shape.png"),
                    ),
                    SizedBox(height: 2.h),
                    Padding(
                      padding: EdgeInsets.only(left: 5.w),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'login'.tr, // 'ಲಾಗಿನ್ ಮಾಡಿ'
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: '\n'),
                            TextSpan(
                              text: 'please_sign_in'.tr, // '\nದಯವಿಟ್ಟು ಮುಂದುವರಿಯಲು ಸೈನ್ ಇನ್ ಮಾಡಿ'
                              style: TextStyle(
                                color: const Color.fromARGB(255, 188, 186, 186),
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    ),
                    SizedBox(height: 8.h),
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 2.0, bottom: 5, top: 0),
                              child: Text(
                                'email'.tr,
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
                                controller: emailController,
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
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 2.0, bottom: 5, top: 0),
                              child: Text(
                                'password'.tr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  // fontFamily: 'Open Sans',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 75,
                              child: TextFormField(
                                controller: passwordController,
                                obscureText: _isPassword,
                                style: TextStyle(color: Colors.white),
                                cursorColor:
                                const Color.fromARGB(255, 193, 238, 251),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 10),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: const Color.fromARGB(
                                          255, 193, 238, 251),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPassword = !_isPassword;
                                      });
                                    },
                                  ),

                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(width: 1.5)),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: const Color.fromARGB(
                                              255, 193, 238, 251))),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: const Color.fromARGB(
                                          255, 193, 238, 251),
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: const Color.fromARGB(
                                          255, 193, 238, 251),
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  errorStyle: TextStyle(
                                    fontSize: 11,
                                    // Adjust font size for the error text
                                    height: 1.5,
                                    // Reduce the line height to minimize padding
                                  ),
                                  errorMaxLines: 2,
                                  // Limit error message to a single line
                                  isDense: false,
                                ),
                                validator: (value) {
                                  if (value!.length < 8) {
                                    return 'enter_password_8_char'.tr;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 48.w),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) =>
                                        const ForgotPasswordScreen()),
                                  );
                                },
                                child: Text(
                                  "forgotpassword".tr,
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.white,
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            if (_errorMessage != null) ...[
                              SizedBox(height: 10),
                              Center(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              SizedBox(height: 16),
                            ],
                            SizedBox(height: 4.h),
                            Center(
                              child: InkWell(
                                onTap: () async {
                                  if (_formKey.currentState!.validate()) {
                                    String email = emailController.text.trim();
                                    String password =
                                    passwordController.text.trim();

                                    if (email.isEmpty || password.isEmpty) {
                                      setState(() {
                                        _errorMessage =
                                        'Email and password cannot be empty.';
                                      });
                                      return;
                                    }

                                    setState(() {
                                      _errorMessage = null;
                                      _isLoading = true;
                                    });

                                    try {
                                      print(email +"\n" +password);
                                      UserCredential userCredential =
                                      await _auth.signInWithEmailAndPassword(
                                        email: email.trim(),
                                        password: password.trim(),
                                      );

                                      authController.setInitialScreen(
                                          authController.firebaseUser.value);
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                BottomNavigationScreen()),
                                      );
                                    } on FirebaseAuthException catch (e) {
                                      setState(() {
                                        _errorMessage = "Invalid EmailAddress Or Password " ??
                                            'An error occurred. Please try again.';
                                      });
                                    } finally {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  }
                                },
                                child: Container(
                                  height: 5.h,
                                  width: 80.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.sp),
                                    gradient: const LinearGradient(colors: [
                                      Color.fromARGB(255, 123, 192, 215),
                                      Color.fromARGB(255, 82, 200, 232),
                                      Color.fromARGB(255, 22, 89, 112)
                                    ]),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "signin".tr,
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 44, 66, 77),
                                          fontSize: 17.5.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Center(
                              child: Text(
                                "or".tr,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15.sp),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Center(
                              child: buttonItems(
                                "assets/logos/google.png",
                                "googlesignin".tr,
                                2.9.h,
                                    ()  {
                                  authController.loginWithGoogle(context);
                                },
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "donthaveaccount".tr,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16.sp),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) =>
                                          const SignUpScreen()),
                                          (route) => false,
                                    );
                                  },
                                  child: Text(
                                    "signup".tr,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 6.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),),
            if (authController.isLoading.value)
              Center(
                child: Lottie.asset(
                  'assets/images/loading.json',
                  height: 150,
                  width: 150,
                ),
              ),
            if (_isLoading) // Show loading indicator if loading
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Lottie.asset(
                    'assets/images/loading.json', // path to your Lottie file
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

          ],
        );
      })

    );
  }

  Widget textItem(
      String labelName, TextEditingController controller, bool obscureText) {
    return Container(
      height: 6.h,
      width: 80.w,
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 17, 110, 142).withAlpha(20)),
      child: TextFormField(
        obscureText: obscureText,
        cursorColor: const Color.fromARGB(255, 193, 241, 251),
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: labelName,
          labelStyle: TextStyle(
            fontSize: 16.sp,
            color: Colors.white,
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                  color: Color.fromARGB(255, 193, 238, 251), width: 1.5),
              borderRadius: BorderRadius.circular(9.sp)),
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                  color: Color.fromARGB(255, 193, 238, 251), width: 1),
              borderRadius: BorderRadius.circular(9.sp)),
        ),
      ),
    );
  }

  Widget buttonItems(
      String imagePath, String buttonName, double size, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 6.5.h,
        width: 82.w,
        child: Card(
          color: Colors.white.withAlpha(20),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.sp)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: size,
                width: size,
              ),
              SizedBox(width: 5.w),
              Text(
                buttonName,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
