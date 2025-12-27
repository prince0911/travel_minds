import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import 'package:travel_minds/data/repositories/mongo_repository.dart';

class Historyscreen extends StatefulWidget {
  final String userEmail;

  const Historyscreen({super.key, required this.userEmail});

  @override
  State<Historyscreen> createState() => _HistoryscreenState();
}

class _HistoryscreenState extends State<Historyscreen> {
  List<Map<String, dynamic>> bookingHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookingHistory();
  }

  Future<void> fetchBookingHistory() async {
    final startTime = DateTime.now();

    var history = await MongoDb.getUserBookingHistory(widget.userEmail);

    final elapsed = DateTime.now().difference(startTime);
    final minDuration = Duration(seconds: 2);

    if (elapsed < minDuration) {
      await Future.delayed(minDuration - elapsed);
    }

    setState(() {
      bookingHistory = history;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(8, 9, 11, 1),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("tripHistory".tr, style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(28, 32, 37, 1.0),
      ),
      body: isLoading
          ? Center(
        child: Lottie.asset(
          'assets/images/loading.json',
          width: 150,
          height: 150,
          fit: BoxFit.contain,
        ),
      )
          : Column(
        children: [
          SizedBox(height: 1.h),
          if (bookingHistory.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/empty_history.png",
                      height: 20.h,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "No Trips Found",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      "Plan your first trip now!",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: bookingHistory.length,
                itemBuilder: (context, index) {
                  var booking = bookingHistory[bookingHistory.length - 1 - index];
                  return Container(
                    margin: EdgeInsets.only(left: 16, right: 16, bottom: 14),
                    height: 14.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: const Color.fromARGB(255, 28, 54, 75).withAlpha(100),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 2.w,
                          top: 1.5.h,
                          right: 13.w,
                          child: Text(
                            booking['packageName'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 1.6.h,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 2.w,
                          top: 4.h,
                          child: Text(
                            booking['duration'],
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 1.4.h,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 2.w,
                          top: 6.h,
                          child: Text(
                            "Adult : ${booking['people']['adult']}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 1.5.h,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20.w,
                          top: 6.h,
                          child: Text(
                            "Child : ${booking['people']['child']}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 1.5.h,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 3.w,
                          bottom: 1.6.h,
                          child: Text(
                            "Total Amount = ₹${booking['packagePrice']}",
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 1.6.h,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 2.w,
                          top: 4.h,
                          child: Text(
                            "${booking['packageType']} Package",
                            style: TextStyle(
                              color: Color.fromRGBO(141, 223, 244, 1.0),
                              fontSize: 1.5.h,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 2.w,
                          top: 1.7.h,
                          child: Container(
                            height: 2.h,
                            width: 13.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                "${booking['paymentMode']} ",
                                style: TextStyle(
                                  color: Color.fromRGBO(16, 55, 98, 1.0),
                                  fontSize: 1.3.h,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 3.w,
                          bottom: 1.5.h,
                          child: Row(
                            children: [
                              Icon(
                                Icons.date_range,
                                color: const Color.fromARGB(255, 179, 226, 255),
                                size: 16.sp,
                              ),
                              SizedBox(width: 5),
                              Text(
                                booking['tripDate'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

