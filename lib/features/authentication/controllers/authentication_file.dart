import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_minds/data/repositories/mongo_repository.dart';
import 'package:travel_minds/features/authentication/controllers/register_controller.dart';
import 'package:travel_minds/features/authentication/models/register_exception.dart';
import 'package:travel_minds/features/authentication/screens/addition_register_screen.dart';
import 'package:travel_minds/features/authentication/screens/mail_verification.dart';
import 'package:travel_minds/features/authentication/screens/signin_screen.dart';
import 'package:travel_minds/features/dashboard/screens/main/bottom_navigation.dart';
import 'package:travel_minds/features/personalization/screens/setting_screen_menu/logout_loading_screen.dart';

class AuthenticationFile extends GetxController {
  static AuthenticationFile get instance => Get.find();

  final _auth = FirebaseAuth.instance;
  late final Rx<User?> firebaseUser;
  var isLoading = false.obs;
  var isCheckingMongoDB = false.obs;
  var isLoggingOut = false.obs;
// Nullable to prevent late initialization errors
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final controller = Get.put(RegisterController());

  @override
  void onInit() {
    super.onInit();
    firebaseUser = Rx<User?>(_auth.currentUser);
    firebaseUser.bindStream(_auth.userChanges());
    firebaseUser.listen((user) {
      if (!isCheckingMongoDB.value && !isLoggingOut.value) {
        setInitialScreen(user);
      }
    });
  }

  // Set the initial screen based on the user's authentication state
  void setInitialScreen(User? user) async {
    if (user == null) {
      if (Get.currentRoute != '/SignInScreen') {
        Get.offAll(() => const SignInScreen());
      }
    } else {
      if (user.emailVerified) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // ✅ Use UID-based preference key
        String userKey = 'showDialog_${user.uid}';
        bool? showDialog = prefs.getBool(userKey);
        if (showDialog == null) {
          await prefs.setBool(userKey, true);
        }

        debugPrint("📌 Dialog flag retrieved: ${prefs.getBool(userKey)}");

        if (Get.currentRoute != '/BottomNavigationScreen') {
          Get.offAll(() => const BottomNavigationScreen());
        }
      } else {
        if (Get.currentRoute != '/MailVerificationScreen') {
          Get.offAll(() => MailVerificationScreen(email: user.email ?? ''));
        }
      }
    }
  }



  // Register user with email and password
  Future<void> createUserWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Send email verification
      await userCredential.user?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuthException
      final ex = SignUpWithEmailAndPasswordFailure.code(e.code);
      print('FIREBASE_AUTH EXCEPTION - ${ex.message}');
      // Handle navigation based on user state
      if (firebaseUser.value != null) {

        // ✅ Check if this is the first time login

        Get.offAll(() =>  BottomNavigationScreen());
      } else {
        Get.to(() => const SignInScreen());
      }
      throw ex;
    } catch (_) {
      const ex = SignUpWithEmailAndPasswordFailure();
      print('FIREBASE_AUTH EXCEPTION - ${ex.message}');
      throw ex;
    }
  }

  // Google Sign-In
  Future<UserCredential?> loginWithGoogle(BuildContext context) async {
    try {
      isLoading.value = true;
      isCheckingMongoDB.value = true; // 🔴 Prevent setInitialScreen from interfering

      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isCheckingMongoDB.value = false; // Reset if user cancels
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      String email = userCredential.user?.email ?? "";

      if (email.isNotEmpty) {
        bool userExists = await MongoDb.checkUserInMongoDB(email);

        if (!userExists) {
          // Navigate to registration form and stop execution
          Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationFormScreen(email: email)));
          return null;
        } else {
          // Navigate to main app screen after login

          // ✅ Check if this is the first time login

          Get.offAll(() =>  BottomNavigationScreen());
        }
      }

      return userCredential;
    } catch (e) {
      print('GOOGLE_AUTH EXCEPTION - ${e.toString()}');
      Get.snackbar('Login Failed', 'Error: ${e.toString()}');
      return null;
    } finally {
      isCheckingMongoDB.value = false; // 🔵 Re-enable setInitialScreen after processing
      isLoading.value = false;
    }
  }




  // Logout the user
  Future<void> logout() async {
    try {
      isLoggingOut.value = true;

      await _googleSignIn.signOut();
      await _auth.signOut();

      // Show logout animation
      await Future.delayed(const Duration(milliseconds: 100)); // Give time to trigger stream
      Get.offAll(() => const LogoutLoadingScreen());
    } catch (e) {
      Get.snackbar('Logout Failed', 'Error: ${e.toString()}');
    } finally {
      isLoggingOut.value = false;
    }
  }




}