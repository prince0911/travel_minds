import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart'
    show SegmentTab, SegmentedTabControl;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:lottie/lottie.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:sizer/sizer.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:travel_minds/data/repositories/mongo_repository.dart';
import 'package:travel_minds/features/dashboard/models/package_model.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:travel_minds/features/dashboard/models/wishlist_model.dart';
import 'package:travel_minds/features/dashboard/screens/booking_screen.dart';

class DetailedPackageScreen extends StatefulWidget {
  final PackageModel package;
  final String state;

  const DetailedPackageScreen(
      {Key? key, required this.package, required this.state})
      : super(key: key); // Update constructor

  @override
  State<DetailedPackageScreen> createState() => _DetailedPackageScreenState();
}

class Feesinclude {
  String? iconsname;
  Icon? icon;

  Feesinclude({
    this.icon,
    this.iconsname,
  });
}

List<Feesinclude> detaillist = [
  Feesinclude(
    icon: Icon(
      Icons.money,
      color: Color.fromARGB(255, 180, 191, 195),
      size: 22.sp,
    ),
    iconsname: "gst".tr,
  ),
  Feesinclude(
    icon: Icon(
      Icons.food_bank_outlined,
      color: Color.fromARGB(255, 180, 191, 195),
      size: 22.sp,
    ),
    iconsname: "food".tr,
  ),
  Feesinclude(
    icon: Icon(
      Icons.hotel,
      color: Color.fromARGB(255, 180, 191, 195),
      size: 22.sp,
    ),
    iconsname: "accommodation".tr,
  ),
  Feesinclude(
    icon: Icon(
      Icons.person,
      color: Color.fromARGB(255, 180, 191, 195),
      size: 22.sp,
    ),
    iconsname: "instructor".tr,
  ),
  Feesinclude(
    icon: Icon(
      Icons.medical_services_outlined,
      color: Color.fromARGB(255, 180, 191, 195),
      size: 22.sp,
    ),
    iconsname: "firstaid".tr,
  ),
  Feesinclude(
    icon: Icon(
      Icons.emoji_transportation_outlined,
      color: Color.fromARGB(255, 180, 191, 195),
      size: 22.sp,
    ),
    iconsname: "firstaid".tr,
  ),
];

class _DetailedPackageScreenState extends State<DetailedPackageScreen> {
  late Razorpay _razorPay;

  // late List<DateTime> allMonths; // Stores all months from Jan to Dec
  // late List<DateTime> upcomingMonths; // Stores only next 3 months
  // late DateTime selectedMonth;
  bool isDataLoaded = false;
  bool isFavorite = false;

  var uid;
  var email;
  var contactNo;
  var fullName;

  String? userEmail;
  late String currentDate;

  var packageType;
  var packagePrice;
  List<String> images = [];
  bool isLoading = true;

  // DateTime? selectedDay;

  // Predefined available dates for multiple months
  // final Map<DateTime, List<int>> allAvailableDates = {
  //   DateTime(2025, 1): [2, 5, 8, 12], // January
  //   DateTime(2025, 2): [3, 6, 9, 14], // February
  //   DateTime(2025, 3): [5, 10, 15, 20], // March
  //   DateTime(2025, 4): [3, 8, 12, 18, 24], // April
  //   DateTime(2025, 5): [7, 14, 21, 28], // May
  //   DateTime(2025, 6): [2, 6, 10, 15], // June
  //   DateTime(2025, 7): [1, 5, 10, 20], // July
  //   DateTime(2025, 8): [4, 9, 15, 22], // August
  //   DateTime(2025, 9): [7, 12, 18, 25], // September
  //   DateTime(2025, 10): [3, 8, 14, 19], // October
  //   DateTime(2025, 11): [5, 10, 15, 20], // November
  //   DateTime(2025, 12): [2, 6, 12, 18], // December
  // };

  @override
  void initState() {
    super.initState();
    // selectedDay = null;
    initialize(); // Call an async method to handle initialization properly
    currentDate = getCurrentDate();
    fetchImages();
    // _generateMonths();
    // _filterUpcomingMonths();
  }

  Future<void> initialize() async {
    await getCurrentUserEmail(); // Wait until email is retrieved
    if (userEmail != null && userEmail!.isNotEmpty) {
      await fetchUserData(userEmail!); // Now fetch user data safely
      checkIfInWishlist(); // Only call after `uid` is set
    } else {
      print("🚨 User email is null or empty");
    }
  }

  @override
  void dispose() {

    Navigator.pop(context, isFavorite);
    super.dispose();
  }

  Future<void> fetchImages() async {
    List<String> fetchedImages =
        await MongoDb.getPackageImages(widget.package.name);
    setState(() {
      images = fetchedImages;
      isLoading = false;
    });
  }

  Future<void> getCurrentUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
      });
    } else {
      setState(() {
        userEmail = null; // Keep it null instead of a placeholder string
      });
    }
  }

  Future<void> fetchUserData(String user) async {
    var userData = await MongoDb.getDataOfUserByEmail(user);
    if (userData != null) {
      setState(() {
        uid = userData['id'];
        email = userData['email'];
        contactNo = userData['contactNo'];
        fullName = userData['fullName'];
        isDataLoaded = true;
      });
    } else {
      print("🚨 User not found");
      setState(() {
        uid = null;
      });
    }
  }

  Future<void> checkIfInWishlist() async {
    try {
      print("🔍 UID: $uid");

      if (uid == null) {
        print("🚨 Cannot check wishlist: UID is null.");
        return;
      }

      bool exists =
          await MongoDb.isPackageInWishlist(uid!, widget.package.name);

      if (mounted) {
        setState(() {
          isFavorite = exists;
        });
      }
    } catch (e) {
      print("🚨 Error in checkIfInWishlist: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (uid != null) {
      checkIfInWishlist();
    }
  }

  // Method to get current date in dd-MM-yyyy format
  String getCurrentDate() {
    DateTime now = DateTime.now();
    return DateFormat('dd-MM-yyyy').format(now);
  }

  void _handlePaymentSuccess(
    PaymentSuccessResponse response,
  ) async {
    // _saveInvoice("Online Payment", widget.package.pricing.budget, paymentId: response.paymentId!);
    // await _createBookDetails(packageType, packagePrice, "ONLINE");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful: ${response.paymentId}")),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("External Wallet Selected: ${response.walletName}")),
    );
  }

  void startPayment(int amount) {
    var options = {
      'key': 'rzp_test_dZElgg9nNyp4Vw',
      'amount': (amount * 100).toInt(),
      'name': 'TravelMinds',
      'description': 'Payment for Order',
      'prefill': {'contact': '7778841643', 'email': 'travelminds@gmail.com'},
    };
    try {
      _razorPay.open(options);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void placeCODOrder(int amount) {
    // _saveInvoice("Cash on Delivery", amount);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Order Placed with Cash on Delivery")),
    );
  }

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    String budget = widget.package.pricing.budget;
    String premium = widget.package.pricing.premium;
    String budgetAmount = budget.substring(1); // Removes the first letter
    String premiumAmount = premium.substring(1); // Removes the first letter

    return DefaultTabController(
      length: 3,
      child: Scaffold(
          backgroundColor: Color.fromRGBO(8, 9, 11, 1),
          body: Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Stack(children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 2.25,
                    width: MediaQuery.of(context).size.width,
                    color: Color.fromRGBO(8, 9, 11, 1),
                  ),
                  Container(
                    height: 30.h,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(170))),
                    child: Container(
                        height: MediaQuery.of(context).size.height / 2.25,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(70))),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(70)),
                          child: Image.network(
                            widget.package.images[0],
                            fit: BoxFit.fill,
                          ),
                        )),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      gradient: LinearGradient(
                        colors: [Colors.black, Colors.black26],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 80.5.h,
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(8, 9, 11, 1),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(70),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 2.h,
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 2.w),
                              height: 5.h,
                              width: 90.w,
                              decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 8, 16, 20)
                                      .withAlpha(100),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(30.sp),
                                      topLeft: Radius.circular(15.sp),
                                      bottomLeft: Radius.circular(10.sp),
                                      bottomRight: Radius.circular(10.sp))),
                              child: SegmentedTabControl(
                                tabTextColor:
                                    const Color.fromARGB(255, 199, 200, 201),
                                selectedTabTextColor:
                                    const Color.fromARGB(255, 179, 226, 255),
                                barDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(30.sp),
                                        topLeft: Radius.circular(15.sp),
                                        bottomLeft: Radius.circular(10.sp),
                                        bottomRight: Radius.circular(10.sp))),
                                squeezeIntensity: 2,
                                height: 5.h,
                                tabPadding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                // indicatorDecoration: BoxDecoration(
                                //     borderRadius: BorderRadius.only(
                                //         topRight: Radius.circular(30.sp),
                                //         topLeft: Radius.circular(15.sp),
                                //         bottomLeft: Radius.circular(10.sp),
                                //         bottomRight: Radius.circular(10.sp))),
                                textStyle: TextStyle(
                                    color: const Color.fromARGB(
                                        255, 199, 200, 201),
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500),
                                selectedTextStyle: TextStyle(
                                    color: const Color.fromARGB(
                                        255, 179, 226, 255),
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold),
                                tabs: [
                                  SegmentTab(
                                    label: 'info'.tr,
                                    color: Colors.transparent,
                                    backgroundColor:
                                        Color.fromARGB(255, 163, 217, 253)
                                            .withAlpha(10),
                                  ),
                                  SegmentTab(
                                    label: 'schedule'.tr,
                                    backgroundColor:
                                        Color.fromARGB(255, 189, 227, 255)
                                            .withAlpha(10),
                                    color: Color.fromARGB(255, 82, 159, 232)
                                        .withAlpha(10),
                                  ),
                                  SegmentTab(
                                      label: 'gallery'.tr,
                                      backgroundColor:
                                          Color.fromARGB(255, 158, 210, 255)
                                              .withAlpha(10),
                                      color: Color.fromARGB(255, 33, 134, 223)
                                          .withAlpha(10)),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 3.h,
                            ),
                            Expanded(
                              child: TabBarView(
                                  physics: const BouncingScrollPhysics(),
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15.sp),
                                        color:
                                            Color.fromARGB(255, 163, 217, 253)
                                                .withAlpha(10),
                                      ),
                                      child: SingleChildScrollView(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 2.w),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 1.h,
                                              ),
                                              Text(
                                                "placecovered".tr,
                                                style: TextStyle(
                                                    color: const Color.fromARGB(
                                                        255, 179, 226, 255),
                                                    fontSize: 17.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                height: 1.h,
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 2.w,
                                                    vertical: 1.h),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.sp),
                                                  color: Colors.transparent,
                                                ),
                                                child: Text(
                                                  widget.package.destinations
                                                      .join(", "),
                                                  // Convert List<String> to a comma-separated String
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  softWrap:
                                                      true, // Ensures text wraps properly
                                                ),
                                              ),

                                              SizedBox(
                                                height: 2.h,
                                              ),
                                              Text(
                                                "highlights".tr,
                                                style: TextStyle(
                                                    color: const Color.fromARGB(
                                                        255, 179, 226, 255),
                                                    fontSize: 17.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                height: 1.h,
                                              ),
                                              Container(
                                                width: 100.w,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 2.w,),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.sp),
                                                  color: Colors.transparent,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: List.generate(
                                                    widget.package.highlights
                                                        .length,
                                                    (index) => Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 0.1.h),
                                                      child: Text(
                                                        "• ${widget.package.highlights[index]}",
                                                        // Display each highlight
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16.sp,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              SizedBox(
                                                height: 2.h,
                                              ),
                                              Text(
                                                "activities".tr,
                                                style: TextStyle(
                                                    color: const Color.fromARGB(
                                                        255, 179, 226, 255),
                                                    fontSize: 17.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                height: 1.h,
                                              ),
                                              Container(
                                                width: 100.w,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 2.w,),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.sp),
                                                  color: Colors.transparent,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: List.generate(
                                                    widget.package.allActivities
                                                        .length,
                                                    (index) => Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 0.1.h),
                                                      child: Text(
                                                        "• ${widget.package.allActivities[index]}",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16.sp,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              SizedBox(
                                                height: 2.h,
                                              ),
                                              Text(
                                                "duration".tr,
                                                style: TextStyle(
                                                    color: const Color.fromARGB(
                                                        255, 179, 226, 255),
                                                    fontSize: 17.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                height: 1.h,
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 2.w,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.sp),
                                                  color: Colors.transparent,
                                                ),
                                                child: Text(
                                                  widget.package.duration,
                                                  style: TextStyle(
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              255,
                                                              255,
                                                              255),
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 2.h,
                                              ),
                                              Text(
                                                "bestseason".tr,
                                                style: TextStyle(
                                                    color: const Color.fromARGB(
                                                        255, 179, 226, 255),
                                                    fontSize: 17.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                height: 1.h,
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 2.w,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.sp),
                                                  color: Colors.transparent,
                                                ),
                                                child: Text(
                                                  widget.package.bestSeason,
                                                  style: TextStyle(
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              255,
                                                              255,
                                                              255),
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 2.h,
                                              ),
                                              Text(
                                                "transportation".tr,
                                                style: TextStyle(
                                                    color: const Color.fromARGB(
                                                        255, 179, 226, 255),
                                                    fontSize: 17.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                height: 1.h,
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 2.w,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.sp),
                                                  color: Colors.transparent,
                                                ),
                                                child: Text(
                                                  "${widget.package.transportation}",
                                                  style: TextStyle(
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              255,
                                                              255,
                                                              255),
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 2.h,
                                              ),
                                              Text(
                                                "pricing".tr,
                                                style: TextStyle(
                                                    color: const Color.fromARGB(
                                                        255, 179, 226, 255),
                                                    fontSize: 17.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                height: 1.h,
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 2.w,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.sp),
                                                  color: Colors.transparent,
                                                ),
                                                child: Text(
                                                  "Budget     :   ${widget.package.pricing.budget}\nPremium :   ${widget.package.pricing.premium}",
                                                  style: TextStyle(
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              255,
                                                              255,
                                                              255),
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 2.h,
                                              ),
                                              Text(
                                                "feesinclude".tr,
                                                style: TextStyle(
                                                    color: const Color.fromARGB(
                                                        255, 179, 226, 255),
                                                    fontSize: 17.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                height: 1.h,
                                              ),
                                              Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 2.w,
                                                      vertical: 1.h),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.sp),
                                                    color: Colors.transparent,
                                                  ),
                                                  child: SizedBox(
                                                    height: 27.5.h,
                                                    child: GridView.builder(
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      padding: EdgeInsets.only(
                                                          bottom: 2.h),
                                                      itemCount:
                                                          detaillist.length,
                                                      gridDelegate:
                                                          SliverGridDelegateWithFixedCrossAxisCount(
                                                              childAspectRatio:
                                                                  0.13.h,
                                                              crossAxisCount: 3,
                                                              crossAxisSpacing:
                                                                  0.5.w,
                                                              mainAxisSpacing:
                                                                  3.h),
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return Column(
                                                          children: [
                                                            CircleAvatar(
                                                                backgroundColor:
                                                                    const Color
                                                                            .fromARGB(
                                                                            255,
                                                                            72,
                                                                            82,
                                                                            93)
                                                                        .withAlpha(
                                                                            70),
                                                                radius: 24.sp,
                                                                child: detaillist[
                                                                        index]
                                                                    .icon),
                                                            SizedBox(
                                                              height: 0.5.h,
                                                            ),
                                                            Text(
                                                              detaillist[index]
                                                                  .iconsname
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize:
                                                                      14.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  )),
                                              SizedBox(
                                                height: 10.h,
                                              ),

                                              // GestureDetector(
                                              //   onTap: () {
                                              //     Get.to(() => TourDatesScreen());
                                              //   },
                                              //   child: Container(
                                              //     padding: EdgeInsets.symmetric(
                                              //         horizontal: 2.w, vertical: 1.h),
                                              //     decoration: BoxDecoration(
                                              //       borderRadius:
                                              //           BorderRadius.circular(10.sp),
                                              //       color: const Color.fromARGB(
                                              //               255, 185, 232, 255)
                                              //           .withAlpha(20),
                                              //     ),
                                              //     child: Text(
                                              //       "1 April",
                                              //       style: TextStyle(
                                              //           color: const Color.fromARGB(
                                              //               255, 255, 255, 255),
                                              //           fontSize: 16.sp,
                                              //           fontWeight: FontWeight.w600),
                                              //     ),
                                              //   ),
                                              // ),
                                              SizedBox(
                                                height: 5.h,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    ListView.builder(
                                      itemCount: widget.package.schedule.length,
                                      // ✅ Use the actual list length
                                      padding: EdgeInsets.only(bottom: 12.h),
                                      itemBuilder: (context, index) {
                                        final scheduleDay = widget
                                                .package.schedule[
                                            index]; // ✅ Get the current schedule item

                                        return Container(
                                          margin: EdgeInsets.only(bottom: 2.h,left: 2.h,right: 2.h),
                                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(255, 163, 217, 253)
                                                .withAlpha(10), // Dark background
                                            borderRadius: BorderRadius.circular(10.sp),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Day Title
                                              Center(
                                                child: Text(
                                                  "Day ${index + 1}",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Divider(color: Colors.white.withOpacity(0.3)), // Subtle divider
                                              SizedBox(height: 1.h),

                                              // Places
                                              _buildDetailRow("places".tr, scheduleDay.places.join(", ")),
                                              SizedBox(height: 1.5.h),

                                              // Activities
                                              _buildDetailRow("activities".tr, scheduleDay.activities.join(", ")),
                                              SizedBox(height: 1.5.h),

                                              // Accommodation
                                              _buildDetailRow("accommodation".tr, scheduleDay.accommodations),


                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10,right: 10),
                                      child: Expanded(
                                        child: isLoading
                                            ?  Center(
                                          child: Lottie.asset('assets/images/loading.json', // path to your Lottie file
                                            width: 150,
                                            height: 150,
                                            fit: BoxFit.contain,
                                          ),
                                        )
                                            : GridView.builder(
                                                padding:
                                                    EdgeInsets.only(bottom: 2.h),
                                                itemCount: images.length,
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  childAspectRatio: 0.8,
                                                  crossAxisCount: 2,
                                                  crossAxisSpacing: 10,
                                                  mainAxisSpacing: 10,
                                                ),
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return GestureDetector(
                                                    onTap: () {},
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10.sp),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10.sp),
                                                        child: Image.network(
                                                          images[index],
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context,
                                                                  error,
                                                                  stackTrace) =>
                                                              Icon(Icons.error),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),

                                      ),
                                    ),
                                  ]),
                            ),
                            SizedBox(height: 10.h,)
                          ],
                        ),
                      )),
                  Positioned(
                    top: 12.h,
                    left: 5.w,
                    right: 6.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.package.name,
                          style: const TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 20,
                              color: Colors.white,
                            ),
                            Text(
                              widget.state,
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    top: 5.h,
                    left: 3.w,
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: const Icon(
                        Icons.arrow_back,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // for bookmark icon
                  Positioned(
                    top: 4.h,
                    right: 3.w,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          color: Colors.white38,
                          borderRadius: BorderRadius.circular(200)),
                      child: GestureDetector(
                        onTap: () async {
                          setState(() {
                            isFavorite = !isFavorite;
                          });

                          try {
                            if (isFavorite) {
                              await MongoDb.addToWishlist(WishlistModel(
                                userId: uid,
                                packageName: widget.package.name ?? "Unknown",
                                packageImage: widget.package.images[0] ??
                                    "default_image_url",
                                packagePrice:
                                    widget.package.pricing.budget.toString() ??
                                        "Price not available",
                                packageDuration: widget.package.duration ??
                                    "Duration not available",
                              ));
                              showSnackBar(" Added into the wishlist ", Colors.green,Icons.book_outlined);
                            } else {
                              await MongoDb.removeFromWishlist(
                                  uid, widget.package.name);
                              showSnackBar(" Remove From wishlist ", Colors.red, Icons.cancel_outlined);
                            }
                          } catch (e) {
                            setState(() {
                              isFavorite =
                                  !isFavorite; // Rollback UI if error occurs
                            });
                          }
                        },
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                                scale: animation, child: child);
                          },
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            key: ValueKey<bool>(isFavorite),
                            color: isFavorite ? Colors.red : Colors.grey,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
              Positioned(
                top: 90.h,
                child: GestureDetector(
                  onTap: () {
                    // if (selectedDay != null) {
                    //   _showPackageOptions(budgetAmount, premiumAmount);
                    // } else {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     SnackBar(
                    //       content: Text("Please select a Trip date first!"),
                    //       backgroundColor: Colors.red,
                    //       behavior: SnackBarBehavior.floating,
                    //       duration: Durations.medium3,
                    //     ),
                    //   );
                    // }
                    // _showPaymentOptions(int.parse(amount));
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingScreen(
                            budgetPrice: budgetAmount,
                            premiumPrice: premiumAmount,
                            uid: uid,
                            email: email,
                            contactNo: contactNo,
                            packageDuration: widget.package.duration,
                            packageName: widget.package.name,
                            fullName: fullName,
                            imageUrl: widget.package.images[0],
                          ),
                        ));
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 5.w),
                    width: 90.w,
                    height: 6.h,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 86, 142, 177),
                          Color.fromARGB(255, 131, 192, 228),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(255, 179, 226, 255),
                          blurRadius: 5,
                          spreadRadius: 1,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.book, color: Colors.white, size: 22),
                          SizedBox(width: 2),
                          Text(
                            "booknow".tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title :",
          style: TextStyle(
            color: const Color.fromARGB(
                255, 179, 226, 255),
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.sp,
          ),
        ),

      ],
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



  Widget _buildPaymentOption(
      {required IconData icon,
      required String title,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.5), blurRadius: 8, spreadRadius: 1),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
