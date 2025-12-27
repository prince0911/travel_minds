import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:travel_minds/data/repositories/mongo_repository.dart';
import 'package:travel_minds/features/dashboard/models/package_model.dart';
import 'package:travel_minds/features/dashboard/models/top_packages_model.dart';
import 'package:travel_minds/features/dashboard/screens/categories_screen.dart';
import 'package:travel_minds/features/dashboard/screens/category_packagelist_screen.dart';
import 'package:travel_minds/features/dashboard/screens/main/chatbot_screen.dart';
import 'package:travel_minds/features/dashboard/screens/main/detail_package_screen.dart';
import 'package:travel_minds/utils/screens/translator_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String? userEmail;
  String fullName = "";
  int travelPoints = 0;
  List<TopPackagesModel> topPackages = [];
  List<String> imageSlider = [];
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;
  bool isUserLoaded = false;
  bool showLottie = true;

  String greetings() {
    final hour = TimeOfDay.now().hour;

    if (hour <= 11) {
      return "goodmorning".tr;
    } else if (hour <= 17) {
      return "goodafternoon".tr;
    } else {
      return "goodnight".tr;
    }
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 2), () async {
      if (!mounted) return;
      await fetchHomeData();

      if (!mounted) return;
      await getCurrentUserEmail();

      if (userEmail != null) {
        fetchUserData(userEmail!).then((data) {
          if (!mounted) return;
          setState(() {
            fullName = data["fullName"] ?? "Unknown";
            travelPoints = (data["travelPoints"] ?? 0).toInt();
            isUserLoaded = true; // ✅ Mark user as loaded
          });
        });
      } else {
        setState(() {
          isUserLoaded = true; // ✅ Even if user is null, mark as loaded
        });
      }

      if (!mounted) return;
      await _fetchTopPackages();

      Future.delayed(Duration(seconds: 2), () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) return; // Ensure user is logged in

        String userKey = 'showDialog_${currentUser.uid}'; // ✅ Unique key per user
        bool? showDialog = prefs.getBool(userKey) ?? false;

        debugPrint("📌 Dialog flag retrieved: $showDialog for user ${currentUser.email}");

        if (showDialog) {
          Future.delayed(Duration(seconds: 2), () async {
            if (!mounted) return;
            _showLottieDialog();

            // ✅ Reset flag so it doesn't show again for this user
            await prefs.setBool(userKey, false);
            debugPrint("✅ Dialog flag reset: ${prefs.getBool(userKey)}");
          });
        }
      });

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    });
  }


  void _showLottieDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(Duration(seconds: 3), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });

        return Dialog(
          backgroundColor: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 30.h,
                width: 30.h,
                child: Lottie.asset(
                  "assets/images/animation.json",
                  repeat: true, // Run once
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Welcome to Travel Minds!",
                style: TextStyle(color: Colors.grey[900], fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Center(
                child: Text.rich(
                  TextSpan(
                    text: "You Got ", // Normal text
                    style: TextStyle(color: Colors.green, fontSize: 17, fontWeight: FontWeight.w400),
                    children: [
                      TextSpan(
                        text: "1000 Points", // Bold text
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: " in your wallet!", // Normal text
                      ),
                    ],
                  ),
                ),

              ),
              SizedBox(height: 30),

            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> fetchUserData(String email) async {
    var data = await MongoDb.getDataOfUserByEmail(email) ?? {};
    return {
      "fullName": data["fullName"] ?? "Unknown",
      "travelPoints": (data["travelPoints"] ?? 0).toInt(),
    };
  }

  Future<void> fetchHomeData() async {
    var homeData = await MongoDb.getHomeData();

    if (homeData != null) {
      if (!mounted) return;
      setState(() {
        imageSlider = homeData["imageSlider"];
        categories = homeData["categories"];
        isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getCurrentUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser ;

    if (user != null) {
      if (!mounted) return;
      setState(() {
        userEmail = user.email;
      });
    } else {
      if (!mounted) return;
      setState(() {
        userEmail = 'No user logged in';
      });
    }
  }

  Future<void> _fetchTopPackages() async {
    try {
      var data = await MongoDb.fetchTopPackages();
      List<TopPackagesModel> states = data
          .map<TopPackagesModel>((json) => TopPackagesModel.fromJson(json))
          .toList();
      setState(() {
        if (!mounted) return;
        topPackages = states;
      });
    } catch (e) {
      debugPrint("Error fetching states: $e");
    }
  }

  Future<void> navigateToPackageDetails(String packageName) async {
    var packageData = await MongoDb.getPackageByName(packageName);
    if (packageData != null) {
      PackageModel package = PackageModel.fromJson(packageData['package']);
      String state = packageData['state'];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DetailedPackageScreen(package: package, state: state),
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
    String firstName = fullName.split(" ")[0];

    return Scaffold(
      backgroundColor: Color.fromRGBO(8, 9, 11, 1),
      body: isLoading || !isUserLoaded
          ? homeShimmer()// Show Loader
          : Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(
                  "Hey $firstName!!",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold),
                ),
                collapsedHeight: 10.h,
                actions: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => const TranslatorScreen()),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.all(3.w),
                      height: 4.h,
                      width: 9.5.w,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.sp),
                          color: const Color.fromARGB(255, 1, 52, 71)
                              .withAlpha(100)),
                      child: Icon(
                        Icons.translate_outlined,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                ],
                floating: true,
                excludeHeaderSemantics: true,
                centerTitle: false,
                forceElevated: true,
                backgroundColor: Color.fromRGBO(11, 16, 24, 1),
                stretch: true,
                pinned: true,
                expandedHeight: 17.h,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: [StretchMode.zoomBackground],
                  centerTitle: true,
                  collapseMode: CollapseMode.pin,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          "assets/images/mountain6.jpg",
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 10.h,
                        left: 3.5.w,
                        child: Text(
                          greetings(),
                          style: TextStyle(
                              fontSize: 21.sp,
                              color: Color.fromARGB(255, 198, 227, 243)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              // SliverToBoxAdapter(
              //   child: Padding(
              //     padding: EdgeInsets.all(10),
              //     child: Column(
              //       children: [
              //         showLottie
              //             ? Center(
              //           child: SizedBox(
              //             height: 15.h,
              //             width: 50.w,
              //             child: Lottie.asset(
              //               "assets/images/animation.json",
              //               repeat: false,
              //             ),
              //           ),
              //         )
              //             : SizedBox(), // Hide after 6 sec
              //       ],
              //     ),
              //   ),
              // ),
              SliverList(
                  delegate: SliverChildListDelegate([
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 2.w),
                          height: 3.5.h,
                          width: 80.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9.sp),
                          ),
                          child: Text(
                            "trendingpackages".tr,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15.sp),
                          ),
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        CarouselSlider.builder(
                          itemCount: imageSlider.length,
                          itemBuilder: (BuildContext context, int itemIndex,
                              int pageViewIndex) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 1.w),
                              height: 25.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.sp),
                                image: DecorationImage(
                                  image: NetworkImage(imageSlider[itemIndex]),
                                  fit: BoxFit
                                      .cover, // Ensures the image fills the container
                                ),
                              ),
                            );
                          },
                          options: CarouselOptions(
                            enlargeCenterPage: true,
                            autoPlay: true,
                            autoPlayInterval: Duration(seconds: 3),
                            autoPlayAnimationDuration:
                            Duration(milliseconds: 800),
                            autoPlayCurve: Curves.fastOutSlowIn,
                          ),
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 1.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "categories".tr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CategoriesScreen(
                                            categories: categories,
                                            userEmail:
                                            userEmail!, // Pass only category names
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "viewall".tr,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 2.h),
                            // Show only the first four categories
                            SizedBox(
                              height: 13.h,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                categories.length > 4 ? 4 : categories.length,
                                itemBuilder: (context, index) => GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CategoryWisePackagesScreen(
                                              category: categories[index]["name"]!,
                                              userEmail:
                                              userEmail!, // Pass only the category name
                                            ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding:
                                    EdgeInsets.only(right: 0.5.w, left: 3.w),
                                    child: Container(
                                      height: 13.h,
                                      width: 21.w,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(14.sp),
                                        color: Colors.grey[900],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                              radius: 20.sp,
                                              backgroundColor:
                                              Colors.blueGrey[200],
                                              child: Image(
                                                  image: NetworkImage(
                                                      categories[index]
                                                      ['image']!))),
                                          SizedBox(height: 1.h),
                                          Text(
                                            '${categories[index]["name"]!}'.tr,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 4.w,
                            ),
                            Text(
                              'topPackages'.tr,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                            Spacer(),
                            SizedBox(
                              width: 1.w,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        SizedBox(
                          height: 18.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: topPackages.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => navigateToPackageDetails(
                                    topPackages[index].packageName),
                                child: Padding(
                                  padding: EdgeInsets.only(right: 2.w, left: 3.w),
                                  child: Container(
                                      height: 13.h,
                                      width: 60.w,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12.0),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              topPackages[index].packageImage),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(12.0),
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.black54,
                                                  Colors.transparent
                                                ],
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 3.w,
                                            bottom: 3.5.h,
                                            child: Text(
                                              topPackages[index].packageName,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 3.w,
                                            bottom: 1.5.h,
                                            child: Text(
                                              topPackages[index].packageDuration,
                                              style: TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            right: 3.w,
                                            bottom: 1.7.h,
                                            child: Text(
                                              topPackages[index].packagePrice,
                                              style: TextStyle(
                                                color: Colors.greenAccent,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),

                      ],
                    )
                  ])),

            ],
          ),
        ],

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(),));
        },
        child: Icon(Icons.chat_outlined,color: Colors.white,), // Default Icon
        backgroundColor: Colors.grey[900], // Default Color
      ),
    );
  }

  homeShimmer() {
    return Shimmer.fromColors(
        baseColor: Colors.grey[400]!,
        highlightColor: Colors.white,
        child: Stack(
          children: [
            Positioned(
              top: 1.h,
              child: Container(
                height: 22.h,
                width: 100.w,
                color: Colors.grey.withOpacity(0.8),
              ),
            ),
            Positioned(
              top: 28.h,
              left: 10.w,
              child: Center(
                child: Container(
                  height: 25.h,
                  width: 80.w,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            Positioned(
              top: 57.h,
              left: 3.w,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.sp),
                    color: Colors.white.withOpacity(0.7)),
                height: 2.5.h,
                width: 32.w,
              ),
            ),
            Positioned(
              top: 57.h,
              right: 3.w,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.sp),
                    color: Colors.white.withOpacity(0.7)),
                height: 2.5.h,
                width: 20.w,
              ),
            ),
            Positioned(
                top: 62.h,
                left: 3.w,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 13.h,
                          width: 21.w,
                          color: Colors.grey.withOpacity(0.8),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 13.h,
                          width: 21.w,
                          color: Colors.grey.withOpacity(0.8),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 13.h,
                          width: 21.w,
                          color: Colors.grey.withOpacity(0.8),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 13.h,
                          width: 21.w,
                          color: Colors.grey.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                )),
            Positioned(
              top: 78.h,
              left: 3.w,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.sp),
                    color: Colors.white.withOpacity(0.7)),
                height: 3.h,
                width: 38.w,
              ),
            ),
            Positioned(
                top: 83.h,
                left: 3.w,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 13.h,
                          width: 60.w,
                          color: Colors.grey.withOpacity(0.8),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 13.h,
                          width: 60.w,
                          color: Colors.grey.withOpacity(0.8),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 13.h,
                          width: 60.w,
                          color: Colors.grey.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        ));
  }


}