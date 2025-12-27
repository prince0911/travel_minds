import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:lottie/lottie.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:travel_minds/data/repositories/mongo_repository.dart';
import 'package:travel_minds/features/dashboard/controllers/booking_controller.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class BookingScreen extends StatefulWidget {
  final mongo.ObjectId uid;
  final String email;
  final String fullName;
  final String contactNo;
  final String packageName;
  final String packageDuration;
  final String budgetPrice;
  final String premiumPrice;
  final String imageUrl;

  const BookingScreen(
      {super.key,
      required this.budgetPrice,
      required this.premiumPrice,
      required this.uid,
      required this.email,
      required this.contactNo,
      required this.packageName,
      required this.packageDuration,
      required this.fullName, required this.imageUrl});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late List<DateTime> allMonths; // Stores all months from Jan to Dec
  late List<DateTime> upcomingMonths; // Stores only next 3 months
  late DateTime selectedMonth;
  late Razorpay _razorPay;
  late String selectedPackage;
  late String selectedPayment;
  var tripPoints;
  var packageType = 'Economy';
  int tripPointsForUpdate = 0;
  int adultCount = 0;
  int childCount = 0;
  TextEditingController pointsController = TextEditingController();
  TextEditingController adultController = TextEditingController();
  TextEditingController childController = TextEditingController();
  int discount = 0;
  var newAmount = 0.obs;

  // Predefined available dates for multiple months

  DateTime? selectedDay;

  // Predefined available dates for multiple months
  final Map<DateTime, List<int>> allAvailableDates = {
    DateTime(2025, 1): [2, 5, 8, 12], // January
    DateTime(2025, 2): [3, 6, 9, 14], // February
    DateTime(2025, 3): [5, 10, 15, 20], // March
    DateTime(2025, 4): [3, 8, 12, 18, 24], // April
    DateTime(2025, 5): [7, 14, 21, 28], // May
    DateTime(2025, 6): [2, 6, 10, 15], // June
    DateTime(2025, 7): [1, 5, 10, 20], // July
    DateTime(2025, 8): [4, 9, 15, 22], // August
    DateTime(2025, 9): [7, 12, 18, 25], // September
    DateTime(2025, 10): [3, 8, 14, 19], // October
    DateTime(2025, 11): [5, 10, 15, 20], // November
    DateTime(2025, 12): [2, 6, 12, 18], // December
  };

  @override
  void initState() {
    super.initState();
    selectedDay = null;
    selectedPackage = '';
    selectedPayment = '';
    _generateMonths();
    _filterUpcomingMonths();
    bookingController.totalAmount.value = int.parse(widget.budgetPrice);
    newAmount.value = int.parse(widget.budgetPrice);

    fetchUserData(widget.email).then((data) {
      setState(() {
        tripPoints = (data["travelPoints"] ?? 0).toInt();
      });
      tripPointsForUpdate = int.parse(tripPoints.toString());
    });
    _razorPay = Razorpay();
    _razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<Map<String, dynamic>> fetchUserData(String email) async {
    var data = await MongoDb.getDataOfUserByEmail(email) ?? {};
    return {
      "travelPoints": (data["travelPoints"] ?? 0).toInt(),
    };
  }

  _createBookDetails(
      String packageType, double packagePrice, String paymentMode) async {
    String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDay!);
    int discountPoints = discount ~/ 2;
    tripPointsForUpdate = tripPointsForUpdate - discountPoints;
    bool success = await MongoDb.bookUser(
        widget.uid,
        widget.fullName,
        widget.email,
        widget.contactNo,
        getCurrentDate(),
        adultCount,
        childCount,
        widget.packageName,
        widget.packageDuration,
        packageType,
        formattedDate,
        packagePrice,
        discountPoints * 2,
        paymentMode);

    if (success) {
      await MongoDb.updateByEmail(widget.email, tripPointsForUpdate);
      sendBookingSMS(widget.contactNo, widget.packageName);

    } else {
      print("Error on booking. ");
    }
  }

  void _handlePaymentSuccess(
    PaymentSuccessResponse response,
  ) async {
    int points = getRandomMultipleOfTen();
    print(widget.contactNo);
    await _createBookDetails(packageType,
        double.parse(bookingController.totalAmount.value.toString()), "ONLINE");
    await processAndSendPdf(widget.contactNo,"ONLINE");
    await MongoDb.updateByEmail(widget.email, tripPointsForUpdate+points);
    // _saveInvoice("Online Payment", widget.package.pricing.budget, paymentId: response.paymentId!);
    _showLottieDialog(context, points);
    showSnackBar(context," Payement Succesful " , Icons.done_all_rounded ,Colors.green);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    showSnackBar(context, "Payment Failed: ${response.message}", Icons.error_outline, Colors.red);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //       content: Text("External Wallet Selected: ${response.walletName}")),
    // );
    showSnackBar(context, "External Wallet Selected: ${response.walletName}", Icons.account_balance_wallet_outlined, Colors.green);
  }

  int getRandomMultipleOfTen() {
    Random random = Random();
    int min = 500;
    int max = 1000;

    // Generate a random multiple of 10 in range [500, 1000]
    int randomValue = (random.nextInt((max - min) ~/ 10 + 1) * 10) + min;

    return randomValue;
  }

  Future<void> _showLottieDialog(BuildContext context ,int points) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing until animation completes
      builder: (context) {
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
              SizedBox(height: 5),
              Center(
                child: Text.rich(
                  TextSpan(
                    text: "You Got ", // Normal text
                    style: TextStyle(color: Colors.green, fontSize: 17, fontWeight: FontWeight.w400),
                    children: [
                      TextSpan(
                        text: "$points Points", // Bold text
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
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);

                  showSnackBar(context, "Congratulations! Your tour is successfully booked.", Icons.done_all_rounded, Colors.green);
                },
                child: Container(
                  height: 4.7.h,
                  width: 70.w,
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
                    child: Text("Done",
                      style: TextStyle(color: Colors.white, fontSize: 3.2.w),textAlign: TextAlign.center,),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void startPayment(int amount) {
    var options = {
      'key': 'rzp_test_dZElgg9nNyp4Vw',
      'amount': (amount * 100).toInt(),
      'name': 'TravelMinds',
      'description': 'Payment For Booking',
      'prefill': {'contact': widget.contactNo, 'email': widget.email},
    };
    try {
      _razorPay.open(options);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> placeCODOrder(int amount) async {
    Future.delayed(Duration(milliseconds: 500), () async {
      int points = getRandomMultipleOfTen();
      _showLottieDialog(context,points);
      print(widget.contactNo);
      await processAndSendPdf(widget.contactNo,"COD");
      await MongoDb.updateByEmail(widget.email, tripPointsForUpdate+points);
    });
  }

  void sendBookingSMS(String toPhone, String packageName) async {
    String accountSid = "ACe1b844aab908ec133812b3fbbaeaea3b";
    String authToken = "a21dad78f2855a34d238eddf582bf561";
    String twilioNumber = "+16195360862";

    String apiUrl =
        "https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json";

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Authorization":
            "Basic " + base64Encode(utf8.encode('$accountSid:$authToken')),
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "To": toPhone,
        "From": twilioNumber,
        "Body":
            "Your booking for $packageName is confirmed! Thank you for choosing us."
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print("SMS sent successfully");
    } else {
      print("Failed to send SMS: ${response.body}");
    }
  }

  String getCurrentDate() {
    DateTime now = DateTime.now();
    return DateFormat('dd-MM-yyyy').format(now);
  }

  void _generateMonths() {
    allMonths = List.generate(
      12,
      (index) => DateTime(DateTime.now().year, index + 1),
    );
  }

  void _filterUpcomingMonths() {
    DateTime now = DateTime.now();

    upcomingMonths = [
      DateTime(now.year, now.month + 1),
      DateTime(now.year, now.month + 2),
      DateTime(now.year, now.month + 3),
    ];

    // Set default selection to first available month
    selectedMonth = upcomingMonths.first;
  }

  int currentIndex = 0;
  int isselect = 0;
  int payment = 0;
  final BookingController bookingController = Get.put(BookingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(8, 9, 11, 1),
      appBar: AppBar(
        title:  Text(
          "paymentCheckout".tr,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(28, 32, 37, 1.0),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 2.h,
              ),
              Text(
                widget.packageName,
                style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 5),
              Text(widget.packageDuration,
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
              SizedBox(
                height: 4.h,
              ),
              Text(
                "datesavailable".tr,
                style: TextStyle(
                    color: const Color.fromARGB(255, 179, 226, 255),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 1.h,
              ),
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.sp),
                      color: const Color.fromARGB(255, 185, 232, 255)
                          .withAlpha(20),
                    ),
                    child: DropdownButton<DateTime>(
                      alignment: Alignment.topRight,
                      borderRadius: BorderRadius.circular(10.sp),
                      dropdownColor: const Color.fromARGB(255, 32, 39, 42),
                      value: selectedMonth,
                      items: allMonths.map((DateTime month) {
                        return DropdownMenuItem<DateTime>(
                          value: month,
                          enabled: upcomingMonths.contains(month),
                          child: Text(
                            DateFormat.yMMM().format(month),
                            style: TextStyle(
                              color: upcomingMonths.contains(month)
                                  ? const Color.fromARGB(255, 179, 226, 255)
                                  : Colors.grey,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (DateTime? newMonth) {
                        if (newMonth != null &&
                            upcomingMonths.contains(newMonth)) {
                          setState(() {
                            selectedMonth = newMonth;
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 2.w), // Add spacing between dropdown and grid
                  Expanded(
                    child: SizedBox(
                      height: 8.h,
                      child: GridView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount:
                            allAvailableDates[selectedMonth]?.length ?? 0,
                        itemBuilder: (context, index) {
                          int day = allAvailableDates[selectedMonth]![index];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDay = DateTime(selectedMonth.year,
                                    selectedMonth.month, day);
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(13.sp),
                                gradient: selectedDay != null &&
                                        selectedDay!.day == day &&
                                        selectedDay!.month ==
                                            selectedMonth.month &&
                                        selectedDay!.year == selectedMonth.year
                                    ? LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 86, 142, 177),
                                          Color.fromARGB(255, 131, 192, 228),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null, // Gradient when selected
                                color: selectedDay != null &&
                                        selectedDay!.day == day &&
                                        selectedDay!.month ==
                                            selectedMonth.month &&
                                        selectedDay!.year == selectedMonth.year
                                    ? null
                                    : Colors.grey[
                                        900], // Default color when not selected
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "$day",
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  color: Colors.white,
                                  fontWeight: selectedDay != null &&
                                          selectedDay!.day == day &&
                                          selectedDay!.month ==
                                              selectedMonth.month &&
                                          selectedDay!.year ==
                                              selectedMonth.year
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 1.h,
              ),

              SizedBox(
                height: 2.h,
              ),
              Text("selectPackageType".tr,
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 179, 226, 255))),
              SizedBox(height: 1.h),
              Column(
                children: [
                  packageTile("economyPrice".tr, "₹${widget.budgetPrice}",
                      "Economy"),
                  packageTile("premiumPrice".tr,
                      "₹${widget.premiumPrice}", "Premium"),
                ],
              ),
              SizedBox(
                height: 2.h,
              ),
              Text("howManyPeople".tr,
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 179, 226, 255))),
              SizedBox(
                height: 2.h,
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 4),
                        child: Text("adults".tr,
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.normal,
                                color: Colors.white)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                        child: SizedBox(
                          height: 5.h,
                          width: 30.w,
                          child: TextField(
                            controller: adultController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            // Allows decimal input
                            style:
                                TextStyle(color: Colors.white, fontSize: 14.sp),

                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[900],
                              hintText: "adultNo".tr,
                              hintStyle: TextStyle(
                                  color: Colors.white54, fontSize: 14.sp),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.white30),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.white30),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.white60),
                              ),
                            ),
                            onChanged: (value) {},
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 4),
                        child: Text("child".tr,
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.normal,
                                color: Colors.white)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                        child: SizedBox(
                          height: 5.h,
                          width: 30.w,
                          child: TextField(
                            controller: childController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            // Allows decimal input
                            style:
                                TextStyle(color: Colors.white, fontSize: 14.sp),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[900],
                              // Background color
                              hintText: "childNo".tr,
                              hintStyle: TextStyle(
                                  color: Colors.white54, fontSize: 14.sp),

                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.white30),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.white30),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.white60),
                              ),
                            ),
                            onChanged: (value) {},
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 2.w),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: GestureDetector(
                      onTap: () {
                        try {
                          // Check if both fields are empty or zero
                          if (adultController.text.trim().isEmpty &&
                              childController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).removeCurrentSnackBar();
                            showSnackBar(context, "Please enter at least one adult or child.", Icons.error_outline_rounded, Colors.red);
                            return; // Stop execution
                          }

                          // Parse package price safely
                          int basePrice = (selectedPackage == "Economy")
                              ? int.tryParse(widget.budgetPrice) ?? 0
                              : int.tryParse(widget.premiumPrice) ?? 0;

                          print("Base Price: $basePrice");

                          // Ensure base price is valid
                          if (basePrice < 0) basePrice = 0;

                          // Parse adult and child counts safely
                          adultCount = int.tryParse(adultController.text.trim()) ?? 0;
                          childCount = int.tryParse(childController.text.trim()) ?? 0;

                          print("Adults: $adultCount, Children: $childCount");

                          // If both values are zero, show error
                          if (adultCount == 0 && childCount == 0) {
                            ScaffoldMessenger.of(context).removeCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Please select at least one adult or child."),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                              ),
                            );
                            return; // Stop execution
                          }

                          // Calculate total cost
                          int adultAmount = basePrice * adultCount;
                          int childAmount = ((basePrice / 2) + 3000).toInt() * childCount;

                          // Ensure child amount doesn't go negative
                          if (childAmount < 0) childAmount = 0;

                          int totalAmount = adultAmount + childAmount;
                          print("Total Amount: $totalAmount");

                          // Update
                          // total amount
                          newAmount.value = totalAmount;
                          bookingController.totalAmount.value = totalAmount;
                        } catch (e) {
                          print("Error calculating amount: $e");
                        }
                      },
                      child: Container(
                        height: 5.h,
                        width: 27.w,
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
                          child: Text(
                            'confirm'.tr,
                            style: TextStyle(color: Colors.white, fontSize: 15.5.sp),
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
              Text("redeemPoints".tr,
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 179, 226, 255))),
              SizedBox(height: 2.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                        child: SizedBox(
                          height: 5.h,
                          width: 70.w,
                          child: TextField(
                            controller: pointsController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            // Allows decimal input
                            style:
                                TextStyle(color: Colors.white, fontSize: 14.sp),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[900],
                              // Background color
                              hintText: "enterTripPoints".tr,
                              hintStyle: TextStyle(
                                  color: Colors.white54, fontSize: 14.sp),
                              prefixIcon: Icon(Icons.card_giftcard,
                                  color: Colors.white, size: 20.sp),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.white30),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.white30),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.white60),
                              ),
                            ),
                            onChanged: (value) {
                              double? points = double.tryParse(value);
                              if (points != null && points > tripPoints) {
                                // Show a message if points exceed the available limit
                                ScaffoldMessenger.of(context).removeCurrentSnackBar(); // Remove previous SnackBar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("You can only redeem up to $tripPoints points."),
                                    backgroundColor: Colors.red,
                                    duration: Duration(days: 1), // Keeps it until dismissed manually
                                    action: SnackBarAction(
                                      label: "OK",
                                      textColor: Colors.white,
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Dismiss manually
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      GestureDetector(
                        onTap: () {
                          int redeempoints = bookingController.totalAmount.value.toInt();
                          double? points = double.tryParse(pointsController.text);

                          // Check if points are entered and within the redeemable limit
                          if (points == null || points <= 0) {
                            ScaffoldMessenger.of(context).removeCurrentSnackBar();
                            showSnackBar(context, "Please enter a valid number of points to redeem.", Icons.error_outline_rounded, Colors.red);
                            return; // Exit early if no valid points
                          }

                          if (points != null && points <= tripPoints) {
                            discount = points.toInt() * 2;
                            newAmount.value = redeempoints - discount;

                            // Ensure newAmount doesn't go negative
                            if (newAmount.value < 0) newAmount.value = 0;


                            print("Updating total amount to: $newAmount"); // Debugging

                            // ✅ Explicitly call the update method


                            ScaffoldMessenger.of(context).removeCurrentSnackBar(); // Remove previous SnackBar

                            showSnackBar(context, "Redeemed ${points * 2} points!", Icons.done_all_rounded, Colors.green);
                          } else {
                            ScaffoldMessenger.of(context).removeCurrentSnackBar(); // Remove previous SnackBar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                action: SnackBarAction(
                                  label: "OK",
                                  textColor: Colors.white,
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Dismiss manually
                                  },
                                ),
                                content: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded,
                                          color: Colors.white), // ⚠ Icon
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "You can only redeem up to $tripPoints points.",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                backgroundColor: Colors.transparent,
                                // Transparent to apply gradient
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 3),
                                margin: EdgeInsets.only(
                                    bottom: 5.h, left: 10, right: 10),
                                elevation: 0,
                              ),
                            );
                          }
                        },
                        child: Container(
                          height: 5.h,
                          width: 20.w,
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
                            child: Text(
                              'redeem'.tr,
                              style: TextStyle(color: Colors.white, fontSize: 15.sp),
                            ),
                          ),
                        ),
                      ),


                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Text.rich(
                      TextSpan(
                        text: "available_trip_points".tr,
                        style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                        children: [
                          TextSpan(
                            text: "${tripPoints}",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text("selectPaymentMethod".tr,
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 179, 226, 255))),
                  SizedBox(height: 1.h),
                  paymentTile(
                      Icons.payment, "payOnline".tr, "Online"),
                  paymentTile(Icons.money, "cash".tr, "COD"),
                ],
              ),

              SizedBox(height: 2.h),

              // Total Price
              Obx(() => Container(
                    margin: EdgeInsets.all(5),
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "totalAmount".tr+"                                 :  ₹${newAmount.value}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )),
              SizedBox(
                height: 1.h,
              ),
              GestureDetector(
                onTap: () async {
                  if (selectedDay != null) {
                    if (selectedPackage != '') {
                      if (adultCount != 0 || childCount != 0) {
                        if (selectedPayment != '') {
                          if (selectedPayment == "Online") {
                            startPayment(int.parse(bookingController
                                .totalAmount.value
                                .toString()));
                          } else {

                            await _createBookDetails(
                                packageType,
                                double.parse(bookingController.totalAmount.value
                                    .toString()),
                                "CASH");
                            bookingController.updateTotalAmount(newAmount.value);
                            placeCODOrder(bookingController.totalAmount.value);

                          }
                        } else {
                          showSnackBar(context,"Please select a payment method!", Icons.cancel_outlined,Colors.red);
                        }
                      } else {
                        showSnackBar(context,"Please enter how many people you are going?",Icons.cancel_outlined,Colors.red);
                      }
                    } else {
                      showSnackBar(context,"Please select a package type!",Icons.cancel_outlined,Colors.red);
                    }
                  } else {
                    showSnackBar(context,"Please select trip date!",Icons.cancel_outlined,Colors.red);
                  }
                  // _showPaymentOptions(int.parse(amount));
                },
                child: Container(
                  margin: EdgeInsets.all(7),
                  width: 100.w,
                  height: 5.8.h,
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
                    borderRadius: BorderRadius.circular(10),
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
                          "reserveTrip".tr,
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
              SizedBox(
                height: 5.h,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget packageTile(String title, String price, String value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPackage = value;
          packageType = value;
          // ✅ Update totalAmount based on selected package
          adultController.text="";
          adultCount=0;
          childCount=0;
          childController.text="";
          pointsController.text="";


         newAmount.value = int.parse(price.replaceAll('₹', '').trim());
         bookingController.totalAmount.value = int.parse(price.replaceAll('₹', '').trim());
        });
      },
      child: Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: selectedPackage == value
              ? Colors.transparent
              : Colors.grey[900], // Transparent when selected
          borderRadius: BorderRadius.circular(10), // Rounded corners
          border: Border.all(
            color: selectedPackage == value
                ? Color.fromARGB(
                    255, 131, 192, 228) // Light blue border when selected
                : Colors.grey[900]!, // Default border color
            width: 1.5, // Border thickness
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: selectedPackage == value
                    ? Color.fromARGB(255, 131, 192,
                        228) // Light blue text color when selected
                    : Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600, // Slightly bold text
              ),
            ),
            Text(
              price,
              style: TextStyle(
                color: selectedPackage == value
                    ? Color.fromARGB(255, 131, 192,
                        228) // Light blue price text when selected
                    : Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

// Widget for Payment Selection
  Widget paymentTile(IconData icon, String title, String value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPayment = value;
        });
      },
      child: Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: selectedPayment == value
              ? Colors.transparent
              : Colors.grey[900], // Transparent background
          borderRadius: BorderRadius.circular(10), // Rounded corners
          border: Border.all(
            color: selectedPayment == value
                ? Color.fromARGB(
                    255, 131, 192, 228) // Light blue border when selected
                : Colors.grey[900]!, // Default border color
            width: 1.5, // Border thickness
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: selectedPayment == value
                      ? Color.fromARGB(
                          255, 131, 192, 228) // Light blue icon color
                      : Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: TextStyle(
                    color: selectedPayment == value
                        ? Color.fromARGB(
                            255, 131, 192, 228) // Light blue text color
                        : Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600, // Slightly bold text
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: selectedPayment == value
                  ? Color.fromARGB(255, 131, 192, 228) // Light blue arrow color
                  : Colors.white,
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> generateAndUploadPdf({
    required String fullName,
    required String email,
    required String date,
    required String packageName,
    required String duration,
    required int adults,
    required int children,
    required String imageUrl,
    required String packageType,
    required double totalPrice,
    required double discount,
    required String paymentMode,
  }) async {
    final pdf = pw.Document();

    final imageProvider = await networkImage(imageUrl); // For package image

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  "Travel Package Summary",
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text("📅 Date: $date", style: pw.TextStyle(fontSize: 14)),
              pw.Divider(),

              pw.Text("👤 Full Name: $fullName", style: pw.TextStyle(fontSize: 14)),
              pw.Text("📧 Email: $email", style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 12),

              pw.Text("🌍 Package Details", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text("• Package Name: $packageName", style: pw.TextStyle(fontSize: 14)),
              pw.Text("• Duration: $duration", style: pw.TextStyle(fontSize: 14)),
              pw.Text("• Package Type: $packageType", style: pw.TextStyle(fontSize: 14)),
              pw.Text("• Adults: $adults", style: pw.TextStyle(fontSize: 14)),
              pw.Text("• Children: $children", style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 8),

              pw.Container(
                height: 180,
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                ),
                child: pw.Image(imageProvider, fit: pw.BoxFit.cover),
              ),
              pw.SizedBox(height: 16),

              pw.Text("💰 Payment Details", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text("• Total Price: ₹${totalPrice.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 14)),
              pw.Text("• Discount: ₹${discount.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 14)),
              pw.Text("• Payment Mode: $paymentMode", style: pw.TextStyle(fontSize: 14)),

              pw.Spacer(),
              pw.Divider(),
              pw.Center(
                child: pw.Text(
                  "Thank you for choosing TravelMinds!",
                  style: pw.TextStyle(fontSize: 14, fontStyle: pw.FontStyle.italic),
                ),
              )
            ],
          );
        },
      ),
    );

    final directory = await getTemporaryDirectory();
    final filePath = "${directory.path}/package_summary.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return await uploadToCloudinary(file); // Cloudinary function you already have
  }


  Future<String?> uploadToCloudinary(File file) async {
    const cloudinaryUrl = "https://api.cloudinary.com/v1_1/dmnr30d83/upload";
    const uploadPreset = "pdfupload";

    var request = http.MultipartRequest("POST", Uri.parse(cloudinaryUrl))
      ..fields["upload_preset"] = uploadPreset
      ..fields["resource_type"] = "raw" // Ensure it's a public upload
      ..files.add(await http.MultipartFile.fromPath("file", file.path,
          contentType: MediaType('application', 'pdf')));

    var response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(responseData)["secure_url"];
    } else {
      print("Upload failed: $responseData");
      return null;
    }
  }

  Future<void> sendWhatsAppMessage(String phoneNumber, String pdfUrl) async {
    final String accountSid = "ACe1b844aab908ec133812b3fbbaeaea3b";
    final String authToken = "a21dad78f2855a34d238eddf582bf561";
    final String fromWhatsAppNumber = "whatsapp:+14155238886";
    final String toWhatsAppNumber = "whatsapp:$phoneNumber";
    final String message = "Here is your PDF: $pdfUrl";

    final Uri twilioUrl = Uri.parse(
        "https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json");

    final response = await http.post(
      twilioUrl,
      headers: {
        "Authorization":
            "Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "From": fromWhatsAppNumber,
        "To": toWhatsAppNumber,
        "Body": message,
      },
    );

    if (response.statusCode == 201) {
      print("Message sent successfully");
    } else {
      print("Failed to send message: ${response.body}");
    }
  }

  Future<void> processAndSendPdf(String userPhoneNumber, String paymentMode) async {
    String? pdfUrl = await generateAndUploadPdf(fullName: widget.fullName, email: widget.email, date: selectedDay.toString(), packageName: widget.packageName, duration: widget.packageDuration, adults: adultCount, children: childCount, packageType: packageType, totalPrice: double.parse(bookingController.totalAmount.value.toString()), discount: discount.toDouble(), paymentMode: paymentMode, imageUrl: widget.imageUrl);
    if (pdfUrl != null) {
      await sendWhatsAppMessage(userPhoneNumber, pdfUrl);
    } else {
      print("Failed to upload PDF");
    }
  }

  void showSnackBar(BuildContext context , String message, IconData icon ,Color color) {
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
                      fontSize: 11,
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
