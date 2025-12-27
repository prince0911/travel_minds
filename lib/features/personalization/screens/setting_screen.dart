import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:travel_minds/features/authentication/controllers/authentication_file.dart';
import 'package:travel_minds/features/personalization/screens/setting_screen_menu/about_us_screen.dart';
import 'package:travel_minds/features/personalization/screens/setting_screen_menu/change_language.dart';
import 'package:travel_minds/features/personalization/screens/setting_screen_menu/faqs_screen.dart';
import 'package:travel_minds/features/personalization/screens/setting_screen_menu/rate_us_screen.dart';
import 'package:travel_minds/localization/select_language_screen.dart';

class NavigationDrawerScreen extends StatefulWidget {
  final String? profilePhoto;
  final String fullName;
  final String emailAddress;

  NavigationDrawerScreen({
    required this.profilePhoto,
    required this.fullName,
    required this.emailAddress,
    super.key,
  });

  @override
  State<NavigationDrawerScreen> createState() => _NavigationDrawerScreenState();
}

class _NavigationDrawerScreenState extends State<NavigationDrawerScreen> {
  String? profilePhoto;
  String fullName = "Loading...";
  String emailAddress = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  void _fetchUserProfile() async {
    setState(() {
      profilePhoto =
          widget.profilePhoto ?? "https://example.com/default_profile.jpg";
      fullName = widget.fullName.isNotEmpty ? widget.fullName : "John Doe";
      emailAddress = widget.emailAddress.isNotEmpty
          ? widget.emailAddress
          : "johndoe@example.com";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromRGBO(8, 9, 11, 1), // Black background
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h), // Responsive spacing from top

          // Profile Section
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: profilePhoto == null || profilePhoto!.isEmpty
                ? CircleAvatar(
                    radius: 11.w, // Responsive avatar size
                    backgroundColor: Colors.grey[800],
                    child: Icon(Icons.person, size: 10.w, color: Colors.white),
                  )
                : CircleAvatar(
                    radius: 11.w, // Responsive avatar size
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: Container(
                      height: 9.4.h,
                      width: 9.4.h,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(28.sp),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28.sp),
                        child: Image.network(
                          profilePhoto!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person,
                            size: 10.w,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
          SizedBox(height: 2.h),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              fullName,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 3.w,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              emailAddress,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 3.w,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 2.h),

          // Menu Items
          buildMenuButton(context, 'darkLightMode'.tr, Icons.dark_mode, () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Coming Soon...'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.blueGrey,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            );
          }),
          buildMenuButton(context, "changelan".tr, Icons.language, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SelectLanguage(),));
          }),
          buildMenuButton(context, "aboutus".tr, Icons.info, () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AboutUsScreen(),
                ));
          }),
          buildMenuButton(context, 'faqs'.tr, Icons.help, () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FAQSScreen(),
                ));
          }),
          buildMenuButton(context, "rateus".tr, Icons.star, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserReviewScreen(fullName: fullName,email: emailAddress,)),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(left: 20.0,top: 60),
            child: Text('version :  1.0.0+1', style: TextStyle(color: Colors.white, fontSize: 3.5.w)),
          ),

          const Spacer(),

          // Logout Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                    color: Color.fromRGBO(141, 223, 244, 1.0)), // Border color
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.w)),
              ),
              onPressed: () => _openDialog(context),
              child: Center(
                child: Text(
                  "logout".tr,
                  style: TextStyle(
                      color: Color.fromRGBO(141, 223, 244, 1.0),
                      fontSize: 3.5.w,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          SizedBox(height: 5.h),
        ],
      ),
    );
  }

  // Menu Button Widget
  Widget buildMenuButton(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900], // Dark background
          borderRadius: BorderRadius.circular(2.w),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
          leading: Icon(icon, color: Colors.white, size: 6.w),
          title: Text(title,
              style: TextStyle(color: Colors.white, fontSize: 3.5.w)),
          trailing:
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 4.w),
          onTap: onTap,
        ),
      ),
    );
  }
}

// Logout Confirmation Dialog
Future<void> _openDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color.fromARGB(255, 28, 54, 75),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 1.h),
            Text(
              'Are you sure you want to logout?',
              style: TextStyle(
                  fontSize: 3.w,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 2.h),

            // Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.w)),
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.2.h),
                  ),
                  child: Text("Cancel",
                      style: TextStyle(color: Colors.white, fontSize: 3.2.w)),
                ),

                // Logout Button
                InkWell(
                  onTap: () {
                    AuthenticationFile.instance.logout();

                  },
                  child: Container(
                    height: 4.7.h,
                    width: 22.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 86, 142, 177),
                          Color.fromARGB(255, 131, 192, 228),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Center(
                      child: Text("logout".tr,
                          style: TextStyle(color: Colors.white, fontSize: 3.2.w),textAlign: TextAlign.center,),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      );
    },
  );
}
