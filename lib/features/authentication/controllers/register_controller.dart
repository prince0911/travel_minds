
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_minds/features/authentication/controllers/authentication_file.dart';
import 'package:travel_minds/features/authentication/screens/mail_verification.dart';

class RegisterController extends GetxController {
  static RegisterController get instance => Get.find();




  final email = TextEditingController();

  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final fullName = TextEditingController();
  final contactNumber = TextEditingController();
  late final dateOfBirth = TextEditingController();



  registerUser(String email,String password,context)  {
    try {
      final auth = AuthenticationFile.instance;
      auth.createUserWithEmailPassword(email, password);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MailVerificationScreen(email: email)),
      );
    } catch (e) {
      Get.snackbar("Error", e.toString(),snackPosition: SnackPosition.BOTTOM,duration: Duration(seconds: 5));
    }
  }

}
