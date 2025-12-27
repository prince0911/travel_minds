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
import 'package:travel_minds/features/dashboard/screens/main/bottom_navigation.dart';

class RegistrationFormScreen extends StatefulWidget {
  final String email;
  const RegistrationFormScreen({super.key, required this.email});

  @override
  State<RegistrationFormScreen> createState() => _RegistrationFormScreenState();
}

class _RegistrationFormScreenState extends State<RegistrationFormScreen> {
  final controller = Get.put(RegisterController());
  final _auth = FirebaseAuth.instance;
  final authController = AuthenticationFile.instance;
  String? errorMessage;
  bool _isPassword = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.fullName.text="";
    controller.contactNumber.text="";
    controller.password.text="";
  }

  Future<void> linkEmailAndPassword(String email, String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No user is signed in.");
        return;
      }

      AuthCredential emailCredential = EmailAuthProvider.credential(email: email, password: password);
      await user.linkWithCredential(emailCredential);
      var id = M.ObjectId();
      bool success = await MongoDb.registerUser (
          id,
          email,
          controller.contactNumber.text.trim(),
          password,
          controller.fullName.text.trim(),
          "",
          "",
          1000,
          0

      );

      if (success) {
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => BottomNavigationScreen()),
        );

      } else {
        _showErrorDialog('Registration Failed', 'An error occurred while registering. Please try again.');
      }
      print("Google and Email/Password accounts linked successfully!");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          errorMessage = 'This email is already registered. Please try logging in.';
        });
      } else {
        setState(() {
          errorMessage = e.message; // Display general error message
        });
      }
      print('FIREBASE_AUTH EXCEPTION - ${e.message}');
    } catch (e) {
      print('FIREBASE_AUTH EXCEPTION - ${e.toString()}');
    }
  }


  Future<void> registerUser (String email, String password) async {
    if (_formKey.currentState!.validate()) {
      authController.isLoading.value = true; // Start loading
      try {
        await linkEmailAndPassword(email, password);
      } catch (e) {
        Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 5));
      } finally {
        authController.isLoading.value = false; // Stop loading
      }
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(11, 16, 24, 1),
      body: Obx((){
        return  Stack(
            children:[
              Visibility(child: SingleChildScrollView(
                child: Padding(
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
                          "Complete Details",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22.sp,
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
                                      return "Please enter your username";
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
                                  obscureText: _isPassword,
                                  style: TextStyle(color: Colors.white),
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
                                      return "Please enter a password with at least 8 characters";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(height: 1.h,),
                              Center(child: signUpButton()),
                              SizedBox(height: 1.h),
                              SizedBox(height: 1.h),

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

            ]);
      })
    );
  }
  Widget signUpButton() {

      return InkWell(
        onTap: () async {
          if (_formKey.currentState!.validate()) { // Ensure validation runs
            registerUser(widget.email.trim(), controller.password.text.trim());
          } else {
            setState(() {
              errorMessage = "Please fill in all fields correctly.";
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
            child: Text(
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
  Widget phoneNumberField() {
    return SizedBox(
      height: 75,
      child: IntlPhoneField(
        controller: controller.contactNumber, // Ensure controller is initialized
        initialCountryCode: 'IN',
        keyboardType: TextInputType.phone,
        cursorColor: const Color.fromARGB(255, 193, 238, 251),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          suffixIcon: Icon(Icons.phone, size: 25, color:const Color.fromARGB(255, 193, 238, 251)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(255, 193, 238, 251),
              width: 1.5,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(255, 193, 238, 251),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
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
        onChanged: (phone) {
          // No need to manually assign phone.completeNumber
        },
        validator: (phone) {
          if (phone == null || phone.number.isEmpty) {
            return 'Please enter your contact number';
          }
          if (phone.number.length != 10) {
            return 'Enter a valid 10-digit mobile number';
          }
          return null;
        },
      ),
    );
  }


  bool validatePassword(String password) {
    String pattern = r'^(?=.*?[A-Za-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{6,}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(password);
  }
}
