import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:sizer/sizer.dart';
import 'package:travel_minds/features/authentication/screens/signin_screen.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class Onbording {
  final String img;

  Onbording({required this.img});
}

List<Onbording> onbordingData = [
  Onbording(
    img: "assets/images/onb1.png",
  ),
  Onbording(
    img: "assets/images/onb2.png",
  ),
  Onbording(
    img: "assets/images/onb3.png",
  ),
];

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController pagecontroller = PageController(initialPage: 0);
  int currentIndexindex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(11, 16, 24, 1),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Column(
            children: [
              SizedBox(
                height: 15.h,
              ),
              SizedBox(
                height: 51.h,
                child: PageView.builder(
                    controller: pagecontroller,
                    onPageChanged: (value) {
                      setState(() {
                        currentIndexindex = value;
                      });
                    },
                    itemCount: onbordingData.length,
                    itemBuilder: (context, index) => Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                            height: 50.h,
                            child: Image.asset(
                              onbordingData[index].img,
                              fit: BoxFit.cover,
                            )),
                      ],
                    )),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    3,
                        (index) => Container(
                      margin: const EdgeInsets.only(left: 5),
                      height: 8,
                      width: currentIndexindex == index ? 15 : 8,
                      decoration: BoxDecoration(
                        color: currentIndexindex == index
                            ? const Color.fromARGB(255, 126, 197, 230)
                            : const Color.fromRGBO(177, 176, 176, 1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    )),
              ),
              SizedBox(
                height: 5.h,
              ),
              Text(
                textAlign: TextAlign.center,
                currentIndexindex == 0
                    ? "onboard1".tr
                    : currentIndexindex == 1
                    ? "onboard2".tr
                    : "onboard3".tr,
                style: TextStyle(
                    color: const Color.fromARGB(255, 251, 248, 226),
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 9.h,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 3.w,
                  ),
                  currentIndexindex == 2
                      ? const SizedBox()
                      : InkWell(
                    onTap: () {
                      pagecontroller.jumpToPage(currentIndexindex = 2);
                    },
                    child: Chip(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.sp)),
                        backgroundColor:
                        const Color.fromARGB(255, 93, 170, 206),
                        labelPadding: EdgeInsets.symmetric(
                            vertical: 0.3.h, horizontal: 5.w),
                        label: Text(
                          "skip".tr,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600),
                        )),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      setState(() {
                        currentIndexindex != 2
                            ? pagecontroller.nextPage(
                            duration: const Duration(seconds: 1),
                            curve: Curves.ease)
                            : Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => const SignInScreen()),
                                (route) => false);
                      });
                    },
                    child: Chip(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.sp)),
                        backgroundColor:
                        const Color.fromARGB(255, 93, 170, 206),
                        labelPadding: EdgeInsets.symmetric(
                            vertical: 0.3.h, horizontal: 5.w),
                        label: Text(
                          currentIndexindex == 2 ? "getstarted".tr : "next".tr,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600),
                        )),
                  ),
                  SizedBox(
                    width: 3.w,
                  )
                ],
              ),
              const Spacer()
            ],
          ),
        ));
  }
}
