import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:lottie/lottie.dart';
import 'package:mongo_dart/mongo_dart.dart' as M;
import 'package:sizer/sizer.dart';
import 'package:travel_minds/data/repositories/mongo_repository.dart';
import 'package:travel_minds/features/authentication/controllers/authentication_file.dart';
import 'package:travel_minds/features/authentication/controllers/register_controller.dart';
import 'package:travel_minds/features/authentication/screens/mail_verification.dart';
import 'package:travel_minds/features/authentication/screens/signin_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final controller = Get.put(RegisterController());
  final _auth = FirebaseAuth.instance;
  bool _isPassword = true;
  final authController = AuthenticationFile.instance;
  final _formKey = GlobalKey<FormState>();
  String? errorMessage;
  String completePhoneNumber = "";



  Future<void> createUserWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      var id = M.ObjectId();

      // Now, controller.contactNumber.text contains the full phone number
      String fullPhoneNumber = completePhoneNumber;
      print("📌 Storing phone number: $fullPhoneNumber");

      bool success = await MongoDb.registerUser(
          id,
          controller.email.text.trim(),
          fullPhoneNumber,  // Save the complete phone number with country code
          controller.password.text.trim(),
          controller.fullName.text.trim(),
          "",
          "",
          1000.0,
          0
      );

      if (success) {
        await userCredential.user?.sendEmailVerification();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MailVerificationScreen(email: email)),
        );
      } else {
        _showErrorDialog('Registration Failed', 'An error occurred while registering. Please try again.');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          errorMessage = 'email_already_registered'.tr
          ;
        });
      } else {
        setState(() {
          errorMessage = e.message;
        });
      }
      print('❌ FIREBASE_AUTH EXCEPTION - ${e.message}');
    } catch (e) {
      print('❌ FIREBASE_AUTH EXCEPTION - ${e.toString()}');
    }
  }


  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'email_required'.tr;
    }

    // Define the regular expression for a valid email
    final emailRegExp = RegExp( r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );

    if (!emailRegExp.hasMatch(value)) {
      return 'valid_email'.tr;
    }

    return null;
  }

  Future<void> registerUser (String email, String password) async {
    if (_formKey.currentState!.validate()) {
      authController.isLoading.value = true; // Start loading
      try {
        await createUserWithEmailPassword(email, password);
      } catch (e) {
        Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 5));
      } finally {
        authController.isLoading.value = false; // Stop loading
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    errorMessage="";
    controller.email.text="";
    controller.password.text="";
    controller.fullName.text="";
    controller.contactNumber.text="";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(11, 16, 24, 1),
      body: Obx((){
        return SingleChildScrollView(
          child: Stack(
            children : [ Visibility(child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4.h),
                  Padding(
                    padding: EdgeInsets.only(left: 65.w),
                    child: Image.asset("assets/images/shape.png"),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 5.w),
                    child: Text(
                      'create_account'.tr,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20,right: 20),
                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 2.0, bottom: 2, top: 15),
                            child: Text(
                              'fullname'.tr,
                              style:TextStyle(
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
                              controller: controller.fullName,
                              style: TextStyle(color: Colors.white),
                              cursorColor: const Color.fromARGB(255, 193, 238, 251),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(vertical: 14,horizontal: 10),
                                suffixIcon: Icon(Icons.person,size: 25,color: const Color.fromARGB(255, 193, 238, 251),),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: BorderSide(
                                        width: 1.5
                                    )
                                ),
                                disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)
                                ),
                                focusedErrorBorder:OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: const Color.fromARGB(255, 193, 238, 251)
                                    )
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: const Color.fromARGB(255, 193, 238, 251),
                                    width: 1.4,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                errorStyle: TextStyle(
                                  fontSize: 12,
                                  // Adjust font size for the error text
                                  height: 1.5,   // Reduce the line height to minimize padding
                                ),
                                errorMaxLines: 1,  // Limit error message to a single line
                                isDense: true,
                              ),

                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'enter_username'.tr;
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 2.0, bottom: 5, top: 0),
                            child: Text(
                              'contactNumber'.tr,
                              style:TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                // fontFamily: 'Open Sans',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          phoneNumberField(),
                          Padding(
                            padding: const EdgeInsets.only(left: 2.0, bottom: 5, top: 0),
                            child: Text(
                              'email'.tr,
                              style:TextStyle(
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
                              controller: controller.email,
                              style: TextStyle(color: Colors.white),
                              cursorColor: const Color.fromARGB(255, 193, 238, 251),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(vertical: 14,horizontal: 10),
                                suffixIcon: Icon(Icons.email,size: 25,color: const Color.fromARGB(255, 193, 238, 251),),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        width: 1.5
                                    )
                                ),
                                disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)
                                ),
                                focusedErrorBorder:OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: const Color.fromARGB(255, 193, 238, 251)
                                    )
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: const Color.fromARGB(255, 193, 238, 251),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                errorStyle: TextStyle(
                                  fontSize: 12,
                                  // Adjust font size for the error text
                                  height: 1.5,   // Reduce the line height to minimize padding
                                ),
                                errorMaxLines: 1,  // Limit error message to a single line
                                isDense: true,
                              ),
                              validator: emailValidator,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 2.0, bottom: 5, top: 0),
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
                              controller: controller.password,
                              style: TextStyle(color: Colors.white),
                              obscureText: _isPassword,
                              cursorColor: const Color.fromARGB(255, 193, 238, 251),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(vertical: 14,horizontal: 10),
                                suffixIcon: _isPassword
                                    ? IconButton(
                                  icon: Icon(
                                    _isPassword ? Icons.visibility_off : Icons.visibility,
                                    color: const Color.fromARGB(255, 193, 238, 251),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPassword= !_isPassword;
                                    });
                                  },
                                )
                                    : IconButton(
                                  icon: Icon(
                                    _isPassword ? Icons.visibility_off : Icons.visibility,
                                    color: const Color.fromARGB(255, 193, 238, 251),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPassword= !_isPassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        width: 1.5
                                    )
                                ),
                                focusedErrorBorder:OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: const Color.fromARGB(255, 193, 238, 251)
                                    )
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: const Color.fromARGB(255, 193, 238, 251),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:const Color.fromARGB(255, 193, 238, 251),
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
                                errorMaxLines: 2,  // Limit error message to a single line
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
                          SizedBox(height: 1.h,),
                          Center(child: signUpButton()),
                          SizedBox(height: 1.h),
                          Center(
                            child: Text(
                              "or".tr,
                              style: TextStyle(color: Colors.white, fontSize: 15.sp),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Center(
                            child: buttonItems("assets/logos/google.png", "googlesignin".tr, 2.9.h, () async {
                              await AuthenticationFile.instance.loginWithGoogle(context);
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "already_have_account".tr +"?",
                        style: TextStyle(color: Colors.white, fontSize: 15.sp),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (builder) => const SignInScreen()),
                                  (route) => false);
                        },
                        child: Text(
                          "signin".tr,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 6.h),
                ],
              ),
            )

            ),
              if (authController.isLoading.value)
                Positioned(
                  top: 45.h,
                  left: 30.w,
                  child: Center(
                    child: Lottie.asset(
                      'assets/images/loading.json',
                      height: 150,
                      width: 150,
                    ),
                  ),
                ),
              ]),
        );
      }),

    );
  }
   // Store full phone number separately
  // Store full phone number separately

  Widget phoneNumberField() {
    return SizedBox(
      height: 75,
      child: IntlPhoneField(
        controller: controller.contactNumber, // Do NOT modify this inside `onChanged`
        initialCountryCode: 'IN',
        keyboardType: TextInputType.phone,
        cursorColor: const Color.fromARGB(255, 193, 238, 251),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          suffixIcon: Icon(Icons.phone, size: 25, color: const Color.fromARGB(255, 193, 238, 251)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(255, 193, 238, 251),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          errorStyle: TextStyle(
            fontSize: 12,
            height: 0,
          ),
          errorMaxLines: 1,
          isDense: true,
        ),
        dropdownIcon: Icon(Icons.arrow_drop_down, color: Colors.white),
        dropdownTextStyle: TextStyle(color: Colors.white),
        style: TextStyle(color: Colors.white),

        // ✅ Correct way to handle full number
        onChanged: (phone) {
          completePhoneNumber = phone.completeNumber; // Store full number separately
          print("📌 Full phone number: $completePhoneNumber");
        },

        // ✅ Use onSaved to update the controller properly (only when form is submitted)
        onSaved: (phone) {
          controller.contactNumber.text = phone?.completeNumber ?? "";
        },

        validator: (phone) {
          if (phone == null || phone.number.isEmpty) {
            return 'enter_contact_number'.tr;
          }
          if (phone.number.length != 10) {
            return 'valid_mobile_number'.tr;
          }
          return null;
        },
      ),
    );
  }

  Widget signUpButton() {

      return InkWell(
        onTap: () async {
          if (_formKey.currentState!.validate()) { // Ensure validation runs
            registerUser(controller.email.text.trim(), controller.password.text.trim());
          } else {
            setState(() {
              errorMessage = 'fill_all_fields'.tr;
            });
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
           child:Text(
              "signup".tr,
              style: TextStyle(
                  color: const Color.fromARGB(255, 44, 66 , 77),
                  fontSize: 17.5.sp,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );

  }

  Widget buttonItems(String imagePath, String buttonName, double size, VoidCallback onTap) {
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
              SizedBox(
                width: 5.w,
              ),
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