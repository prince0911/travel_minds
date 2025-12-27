import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:travel_minds/utils/constants/colors.dart';

class TSearchBarContainer{
  TSearchBarContainer._();

  static Container darkSearchBar =  Container(
    margin: EdgeInsets.symmetric(horizontal: 3.w),
    height: 7.h,
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.sp),
      color: const Color.fromARGB(255, 106, 122, 213).withAlpha(20),
    ),
    child: TextFormField(
      cursorColor: const Color.fromARGB(255, 193, 239, 251),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.search_outlined,
          size: 20.sp,
          color: Colors.white,
        ),
        border: InputBorder.none,
        hintText: "searchlanguage".tr,
        hintStyle: TextStyle(
          fontSize: 17.sp,
          color: Colors.white,
        ),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
      ),
    ),
  );
  static Container lightSearchBar =  Container(
    margin: EdgeInsets.symmetric(horizontal: 5.w),
    height: 7.h,
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.sp),
      color: const Color.fromARGB(255, 110, 127, 223).withAlpha(40),
    ),
    child: TextFormField(
      cursorColor: TColors.textPrimary,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.search,
          size: 20.sp,
          color: TColors.textPrimary,
        ),
        border: InputBorder.none,
        hintText: "searchlanguage".tr,
        hintStyle: TextStyle(
          fontSize: 17.sp,
          color: TColors.textPrimary,
        ),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
      ),
    ),
  );
}