import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:travel_minds/features/dashboard/screens/category_packagelist_screen.dart';
 // Import your CategoryWisePackagesScreen

class CategoriesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String userEmail;

  const CategoriesScreen({super.key, required this.categories, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('all_categories'.tr, style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(28, 32, 37, 1.0),
      ),
      backgroundColor: Color.fromRGBO(8, 9, 11, 1),
      body: Padding(
        padding: EdgeInsets.all(8.w),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // ✅ 3 items per row
            crossAxisSpacing: 3.w, // Space between columns
            mainAxisSpacing: 2.h, // Space between rows
            childAspectRatio: 0.8, // Adjust size of each card
          ),
          itemBuilder: (context, index) => GestureDetector(
            onTap: () {
              // ✅ Navigate to CategoryWisePackagesScreen with selected category
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryWisePackagesScreen(
                    category: categories[index]['name']!,
                    userEmail: userEmail,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.sp),
                  color: Colors.grey[900],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20.sp,
                    backgroundColor: Colors.blueGrey[200],
                    child: Image(image: NetworkImage(categories[index]['image']!)),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '${categories[index]['name']!}'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
