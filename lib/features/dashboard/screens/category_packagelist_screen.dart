import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:travel_minds/data/repositories/mongo_repository.dart';
import 'package:travel_minds/features/dashboard/models/package_model.dart';
import 'package:travel_minds/features/dashboard/models/wishlist_model.dart';
import 'package:travel_minds/features/dashboard/screens/main/detail_package_screen.dart';

class CategoryWisePackagesScreen extends StatefulWidget {
  final String category;
  final String userEmail;
   // Add user ID to manage favorites

  const CategoryWisePackagesScreen({
    super.key,
    required this.category,
    required this.userEmail,
  });

  @override
  _CategoryWisePackagesScreenState createState() =>
      _CategoryWisePackagesScreenState();
}

class _CategoryWisePackagesScreenState extends State<CategoryWisePackagesScreen> {
  List<Map<String, dynamic>> packages = [];
  Set<String> favoritePackages = {};
  var uid;// Store favorite package names
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData(widget.userEmail);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      var focus = FocusScope.of(context);
      focus.addListener(() {
        if (focus.hasPrimaryFocus) {
         _fetchFavorites(); // Refresh when returning
        }
      });
    });
  }



  Future<void> _fetchPackages() async {
    try {
      List<Map<String, dynamic>> allPackages = await MongoDb.fetchAllPackages();
      if (mounted) {  // ✅ Check before updating state
        setState(() {
          packages = _filterPackagesByCategory(allPackages, widget.category);
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error fetching packages: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> fetchUserData(String user) async {
    var userData = await MongoDb.getDataOfUserByEmail(user);
    if (userData != null) {
      if (mounted) {  // ✅ Check before updating state
        setState(() {
          uid = userData['id'];
        });
      }
      _fetchPackages();
      _fetchFavorites();
    } else {
      print("🚨 User not found");
      if (mounted) {
        setState(() {
          uid = null;
        });
      }
    }
  }

  Future<void> _fetchFavorites() async {
    try {
      List<Map<String, dynamic>> favorites = await MongoDb.getFavourite(uid);
      if (mounted) {  // ✅ Check before updating state
        setState(() {
          favoritePackages = favorites.map((fav) => fav['packageName'] as String).toSet();
        });
      }
    } catch (e) {
      print("❌ Error fetching favorites: $e");
    }
  }


  List<Map<String, dynamic>> _filterPackagesByCategory(
      List<Map<String, dynamic>> allPackages, String category) {
    List<Map<String, dynamic>> filteredPackages = [];
    for (var state in allPackages) {
      String stateName = state['state'] ?? "Unknown";
      List<dynamic> statePackages = state['packages'] ?? [];
      for (var package in statePackages) {
        if (package['categories'].contains(category)) {
          package['stateName'] = stateName;
          filteredPackages.add(package);
        }
      }
    }
    return filteredPackages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(8, 9, 11, 1),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          '${widget.category} Packages',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(28, 32, 37, 1.0),
      ),
      body: isLoading
          ? ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => ShimmerEffect(),
      )
          : packages.isEmpty
          ? Center(
        child: Text(
          "No packages available for ${widget.category}",
          style: TextStyle(color: Colors.white),
        ),
      )
          : ListView.builder(
        itemCount: packages.length,
        itemBuilder: (context, index) {
          var package = packages[index];
          String stateName = package['stateName'];
          String packageName = package['name'];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailedPackageScreen(
                    package: PackageModel.fromJson(package),
                    state: stateName,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  image: DecorationImage(
                    image: NetworkImage(
                        package['images'].isNotEmpty ? package['images'][0] : ''),
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
                        onTap: () async{
                          bool isFavorite = favoritePackages.contains(packageName);
                          setState(() {
                            if (isFavorite) {
                              showSnackBar(" Remove From wishlist ", Colors.red, Icons.cancel_outlined);
                              favoritePackages.remove(packageName);
                            } else {
                              showSnackBar(" Added into the wishlist ", Colors.green,Icons.book_outlined);
                              favoritePackages.add(packageName);
                            }
                          });

                          try {
                            if (isFavorite) {
                              await MongoDb.removeFromWishlist(uid, packageName);
                            } else {
                              String packagePrice = package['pricing']['budget'];
                              String packageImage = package['images'][0];
                              String packageDuration = package['duration'];
                              print(packageImage + packagePrice + packageDuration);
                              await MongoDb.addToWishlist( WishlistModel(
                                userId: uid,
                                packageName: packageName,
                                packageImage: packageImage,
                                packagePrice: packagePrice,
                                packageDuration: packageDuration,
                              ));
                            }
                          } catch (e) {
                            print("❌ Error updating wishlist: $e");
                            setState(() {
                              if (isFavorite) {
                                favoritePackages.add(packageName);
                              } else {
                                favoritePackages.remove(packageName);
                              }
                            });
                          }
                        },
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
                        package['name'],
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
                        package['duration'],
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
                        package['pricing']['budget'],
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
            ),
          );
        },
      ),
    );
  }
  void showSnackBar(String message, Color color,IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(
              horizontal: 5, vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: Colors.white), // ⚠ Icon
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        // Transparent to apply gradient
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
        margin: EdgeInsets.only(
            bottom: 5.h, left: 10, right: 10),
        elevation: 0,
      ),
    );
  }
}

class ShimmerEffect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.6),
      highlightColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
