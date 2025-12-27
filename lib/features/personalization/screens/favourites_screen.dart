import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:travel_minds/data/repositories/mongo_repository.dart';
import 'package:travel_minds/features/dashboard/screens/main/bottom_navigation.dart';
import 'package:travel_minds/features/dashboard/models/package_model.dart';
import 'package:travel_minds/features/dashboard/screens/main/detail_package_screen.dart';


class FavouritesScreen extends StatefulWidget {
  final String userEmail;
  const FavouritesScreen({super.key, required this.userEmail});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  List<Map<String, dynamic>> wishlist = [];
  bool isLoading = true;
  var uid;
  Set<String> favoritePackages = {};



  @override
  void initState() {
    super.initState();
    fetchUserData(widget.userEmail);

    // Listen to focus changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var focus = FocusScope.of(context);
      focus.addListener(() {
        if (focus.hasPrimaryFocus) {
          fetchWishlist(); // Refresh when returning
        }
      });
    });
  }


  Future<void> fetchUserData(String user) async {
    var userData = await MongoDb.getDataOfUserByEmail(user);
    if (userData != null) {
      setState(() {
        uid = userData['id'];
      });
      fetchWishlist();
    } else {
      print("🚨 User not found");
      setState(() {
        uid = null;
      });
    }
  }

  Future<void> fetchWishlist() async {
    if (uid == null) return;

    setState(() {
      isLoading = true; // Show shimmer
    });

    await Future.delayed(Duration(seconds: 1)); // ⏳ Add 1-second delay

    var favourites = await MongoDb.getFavourite(uid);

    setState(() {
      wishlist = favourites;
      favoritePackages = favourites.map((fav) => fav['packageName'] as String).toSet();
      isLoading = false; // Hide shimmer & show data
    });
  }


  Future<void> toggleFavorite(String packageName) async {
    bool confirmDelete = await _showConfirmationDialog();
    if (!confirmDelete) return;

    setState(() {
      favoritePackages.remove(packageName);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.cancel_outlined, color: Colors.white), // ⚠ Icon
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  " Remove From wishlist ",
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent, // Transparent to apply gradient
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
        margin: EdgeInsets.only(bottom: 5.h, left: 10, right: 10),
        elevation: 0,
      ),);
    });

    try {
      print("🚀 Removing $packageName from Wishlist...");
      await MongoDb.removeFromWishlist(uid, packageName);
      print("✅ Removed from Wishlist");
      setState(() {
        wishlist.removeWhere((pkg) => pkg['packageName'] == packageName);
      });
    } catch (e) {
      print("❌ Error updating wishlist: $e");
      setState(() {
        favoritePackages.add(packageName);
      });
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 28, 54, 75),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 1.h),
            Text(
              "Remove From Favourites",
              style: TextStyle(
                  fontSize: 4.5.w,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 1.5.h),
            Text(
              "Are you sure you want to remove this package from your wishlist?",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 3.w,
                  color: Color.fromRGBO(141, 223, 244, 1.0)),
            ),
            SizedBox(height: 2.5.h),

            // Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
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

                // Remove Button (Gradient)
                InkWell(
                  onTap: () => Navigator.of(context).pop(true),
                  child: Container(
                    height: 4.7.h,
                    width: 22.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 255, 91, 91),
                          Color.fromARGB(255, 255, 0, 0),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Center(
                      child: Text(
                        "Remove",
                        style: TextStyle(color: Colors.white, fontSize: 3.2.w),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ) ?? false;
  }


  /// ✅ Fetch full package details from MongoDB before navigating
  Future<void> navigateToPackageDetails(String packageName) async {
    var packageData = await MongoDb.getPackageByName(packageName);
    if (packageData != null) {
      PackageModel package = PackageModel.fromJson(packageData['package']);
      String state = packageData['state'];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailedPackageScreen(package: package,state: state),
        ),
      );
    } else {
      print("❌ Package details not found!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Package details not available")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(8, 9, 11, 1),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("wishlist".tr, style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(28, 32, 37, 1.0),
      ),
      body: Column(
        children: [
          SizedBox(height: 1.h),
          Expanded(
            child: isLoading
                ?  Center(
              child: Lottie.asset('assets/images/loading.json', // path to your Lottie file
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            )
                : wishlist.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  Image.asset(
                    'assets/images/empty_wishlist.png',
                    width: 35.w,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    "Your wishlist is empty",
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                  SizedBox(height: 2.h),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BottomNavigationScreen(
                                selectedIndex: 1,
                              )));
                    },
                    child: Container(
                      height: 5.h,
                      width: 40.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color.fromARGB(255, 28, 54, 75).withAlpha(200),
                      ),
                      child: Center(
                        child: Text(
                          ' Explore Now ',
                          style: TextStyle(fontSize: 18.sp,color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                var favourites = wishlist[index];
                String packageName = favourites['packageName'];
                return GestureDetector(
                  onTap: () => navigateToPackageDetails(packageName),
                  child: Container(
                    margin: EdgeInsets.all(10),
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      image: DecorationImage(
                        image: NetworkImage(favourites['packageImage']),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            gradient: LinearGradient(
                              colors: [Colors.black54, Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 2.h,
                          right: 3.w,
                          child: GestureDetector(
                            onTap: () => toggleFavorite(packageName),
                            child: Icon(
                              favoritePackages.contains(packageName)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: favoritePackages.contains(packageName)
                                  ? Colors.red
                                  : Colors.grey,
                              size: 30,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 3.w,
                          bottom: 4.2.h,
                          child: Text(
                            favourites['packageName'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 1.8.h,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 3.w,
                          bottom: 2.h,
                          child: Text(
                            favourites['packageDuration'],
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 3.w,
                          bottom: 1.5.h,
                          child: Text(
                            favourites['packagePrice'],
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 4, // Show 5 shimmer items while loading
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[800]!,
            highlightColor: Colors.grey[600]!,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[900], // Placeholder color
              ),
            ),
          ),
        );
      },
    );
  }
}

