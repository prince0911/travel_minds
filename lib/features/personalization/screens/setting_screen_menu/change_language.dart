// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import 'package:travel_minds/features/dashboard/screens/main/bottom_navigation.dart';
import 'package:travel_minds/utils/constants/colors.dart';
import 'package:travel_minds/utils/theme/custom_themes/text_theme.dart';

class SelectLanguage extends StatefulWidget {
  const SelectLanguage({super.key});

  @override
  State<SelectLanguage> createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
  final List<Map<String, dynamic>> locale = [
    {'name': 'ENGLISH', 'locale': const Locale('en', 'US'), 'country': 'USA', 'flag': 'assets/images/flags/usa.png'},
    {'name': 'ಕನ್ನಡ', 'locale': const Locale('kn', 'IN'), 'country': 'India', 'flag': 'assets/images/flags/india.png'},
    {'name': 'हिंदी', 'locale': const Locale('hi', 'IN'), 'country': 'India', 'flag': 'assets/images/flags/india.png'},
    {'name': 'French', 'locale': const Locale('fr', 'FR'), 'country': 'France', 'flag': 'assets/images/flags/france.png'}
  ];

  List<Map<String, dynamic>> filteredLocale = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredLocale = locale;
  }

  void updateLanguage(Locale locale) {// Closes the dialog
    Get.updateLocale(locale);
  }

  void filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredLocale = locale;
      } else {
        filteredLocale = locale.where((item) =>
        item['country'].toString().toLowerCase().contains(query.toLowerCase()) ||
            item['name'].toString().toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.darkBg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.only(left: 3.w),
              child: Text('selectlanguage'.tr, style: TTextTheme.darkTextTheme.headlineLarge),
            ),
            SizedBox(height: 3.h),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 5.w),
              height: 6.5.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.sp),
                color: const Color.fromARGB(255, 110, 127, 223).withAlpha(40),
              ),
              child: TextFormField(
                controller: searchController,
                onChanged: filterSearch,
                cursorColor: Colors.white,
                style: TTextTheme.darkTextTheme.titleSmall,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, size: 20.sp, color: Colors.white),
                  border: InputBorder.none,
                  hintText: 'searchlanguage'.tr,
                  hintStyle: TTextTheme.darkTextTheme.titleSmall,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 5.w),
              height: 60.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.sp),
                color: TColors.dark.withOpacity(0.8),
              ),
              child: ListView.separated(
                padding: EdgeInsets.only(bottom: 2.h),
                itemCount: filteredLocale.length,
                itemBuilder: (context, index) {
                  var lang = filteredLocale[index];
                  return GestureDetector(
                      onTap: () async {
                        updateLanguage(lang['locale']);

                        // Show loading animation
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => Center(
                            child: SizedBox(
                              height: 150,
                              width: 150,
                              child: Lottie.asset('assets/images/loading.json'),
                            ),
                          ),
                        );

                        // Simulate loading
                        await Future.delayed(const Duration(seconds: 2));

                        if (mounted) {
                          Navigator.of(context).pop(); // Close the loading dialog

                          // Navigate to BottomNavigationScreen
                          Get.offAll(() => const BottomNavigationScreen(selectedIndex: 2));

                        }
                      },

                      child: ListTile(
                      title: Text(lang['country'], style: TextStyle(color: Colors.white, fontSize: 18.sp)),
                      subtitle: Text(lang['name'], style: TextStyle(color: Colors.white70, fontSize: 15.sp)),
                      trailing: CircleAvatar(
                        backgroundImage: AssetImage(lang['flag']),
                        backgroundColor: Colors.transparent,
                        radius: 18,
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(color: Color.fromARGB(255, 128, 136, 138)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
