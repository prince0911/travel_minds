import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class FAQSScreen extends StatefulWidget {
  const FAQSScreen({super.key});

  @override
  State<FAQSScreen> createState() => _FAQSScreenState();
}

class _FAQSScreenState extends State<FAQSScreen> {
  final List<Map<String, String>> faqs = [
    {
      "question": "What is included in the travel package?",
      "answer":
      "Our packages include accommodation,sightseeing, and transportation."
    },
    {
      "question": "How can I cancel my booking?",
      "answer":
      "You can cancel your booking through our app or by contacting our support team."
    },
    {
      "question": "Do I need a visa for international trips?",
      "answer":
      "Yes, visa requirements vary based on your destination. Contact us for assistance."
    },
    {
      "question": "Can I see my booking history of the trip?",
      "answer":
      "Yes, rescheduling is possible based on availability and terms & conditions."
    },
    {
      "question": "Is travel insurance included?",
      "answer": "Travel insurance is not included."
    },
    {
      "question": "Can I change my app language after login?",
      "answer": "yes, in setting optio there is a option to change the language"
    },
    {
      "question": "How can I see my whistlist packages",
      "answer":
      "In the profile screen there is a option of whistlist by which you can see your respective packages"
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(8, 9, 11, 1),
      body: Column(
        children: [
          Container(
            height: 15.h,
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 28, 54, 75).withAlpha(100),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25.sp),
                    bottomRight: Radius.circular(25.sp))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 8.h,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 2.w,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 21.5.sp,
                      ),
                    ),
                    SizedBox(
                      width: 2.w,
                    ),
                    Text(
                      "faqs".tr,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 2.h,
          ),
          Container(
            height: 82.h,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.sp),
                color: Colors.transparent),
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 2.h),
              itemCount: faqs.length,
              itemBuilder: (context, index) {
                return Card(
                  color: const Color.fromARGB(255, 185, 232, 255).withAlpha(20),
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ExpansionTile(
                    backgroundColor:
                    const Color.fromARGB(255, 185, 232, 255).withAlpha(20),
                    title: Text(
                      faqs[index]["question"]!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 179, 226, 255),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          faqs[index]["answer"]!,
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      )
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
