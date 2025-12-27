import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(8, 9, 11, 1),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: 8.h,
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color.fromARGB(255, 179, 226, 255),
                    ),
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  Text(
                    "aboutus".tr,
                    style: TextStyle(
                        fontSize: 20.sp,
                        color: const Color.fromARGB(255, 179, 226, 255),
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 3.h,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5.w),
                height: 77.h,
                width: 90.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.sp),
                  color: const Color.fromARGB(255, 185, 232, 255).withAlpha(20),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 2.h,
                        ),
                        Text(
                          textAlign: TextAlign.left,
                          "Welcome to Travel Minds, your ultimate travel companion, designed to ignite your passion for exploration and simplify your journey around the globe. \n\nWe believe in the transformative power of travel, and we've created an intuitive platform to help you discover new destinations, plan unforgettable adventures, and connect with diverse cultures effortlessly. Our goal is to make the world accessible and enjoyable for every traveler.",
                          style:
                          TextStyle(fontSize: 17.sp, color: Colors.white),
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Text(
                          "At Travel Minds, we prioritize convenience and cultural immersion. Our robust trip planner empowers you to organize every aspect of your travel, from flights and accommodations to activities and local experiences. Multiple language support ensures you can navigate the app and your travels in your preferred language, while our translator booking system breaks down communication barriers, fostering deeper connections with local communities.",
                          textAlign: TextAlign.left,
                          style:
                          TextStyle(fontSize: 17.sp, color: Colors.white),
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Text(
                          "We've meticulously crafted Travel Minds with a focus on user experience and security. Our clean and modern UI/UX, complemented by light and dark mode options, provides a comfortable and visually appealing interface. Secure Google and email sign-in options, along with robust security analysis, safeguard your data. Our secure payment system enables worry-free bookings, and our wishlist feature allows you to save your favorite packages and experiences for future adventures. Plus, discover curated travel packages with ease in our showcase.",
                          textAlign: TextAlign.left,
                          style:
                          TextStyle(fontSize: 17.sp, color: Colors.white),
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Text(
                          "We are committed to continuous improvement, constantly enhancing Travel Minds with new features and refinements based on user feedback. We believe in building a community of insightful travelers, and we're dedicated to providing the tools and resources you need to create lasting memories. Our passion for travel drives us to innovate and deliver an exceptional travel experience for the modern explorer.",
                          textAlign: TextAlign.left,
                          style:
                          TextStyle(fontSize: 17.sp, color: Colors.white),
                        ),
                        SizedBox(
                          height: 2.h,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
