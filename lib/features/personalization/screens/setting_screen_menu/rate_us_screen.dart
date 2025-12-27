import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:travel_minds/data/repositories/mongo_repository.dart';

class UserReviewScreen extends StatefulWidget {
  final String fullName;
  final String email;
  const UserReviewScreen({Key? key, required this.fullName, required this.email}) : super(key: key);

  @override
  State<UserReviewScreen> createState() => _UserReviewScreenState();
}

class _UserReviewScreenState extends State<UserReviewScreen> {
  double _rating = 0.0;
  final TextEditingController _reviewController = TextEditingController();

  void _submitReview() {
    String reviewText = _reviewController.text.trim();

    if (_rating == 0.0 || reviewText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("please_rating_review".tr),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // TODO: Save the review to MongoDB or backend here

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("thank_you_review".tr),
        backgroundColor: Colors.green,
      ),
    );

    setState(() {
      _rating = 0.0;
      _reviewController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(8, 9, 11, 1),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("leave_review".tr),
        backgroundColor: Colors.grey[900],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("experience_question".tr,
                  style: TextStyle(
                    fontSize: 4.w,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  )),
              SizedBox(height: 3.h),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                glow: false,
                itemPadding: EdgeInsets.symmetric(horizontal: 2.w),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Color.fromRGBO(141, 223, 244, 1), // Bright cyan blue
                ),
                unratedColor: Colors.white24, // Light grey for unselected stars
                onRatingUpdate: (rating) => setState(() => _rating = rating),
              ),

              SizedBox(height: 5.h),
              Container(
                height: 20.h,
        
                child: TextField(
                  controller: _reviewController,
                  maxLines: 5,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "write_your_review".tr,
                    hintStyle: TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.grey[850],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2.w),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: Color.fromRGBO(141, 223, 244, 1.0)), // Border color
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.w)),
                ),
                onPressed: () async {
                  String reviewText = _reviewController.text.trim();

                  if (_rating == 0.0 || reviewText.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please give a rating and write a review."),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  // TODO: Replace with actual user ID, name, and email (you can fetch these from your auth/user context)// ← Replace this with actual logged-in user's ID
                 // ← Replace with logged-in user's email

                  bool success = await MongoDb.submitUserReview(
                    fullName: widget.fullName,
                    email: widget.email,
                    rating: _rating,
                    comment: reviewText,
                     date: DateTime.now(),
                  );

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Thank you for your review!"),
                        backgroundColor: Colors.green,
                      ),
                    );

                    setState(() {
                      _rating = 0.0;
                      _reviewController.clear();
                    });

                  }
                },

                child: Center(
                  child: Text(
                    "submit_review".tr,
                    style: TextStyle(
                        color: Color.fromRGBO(141, 223, 244, 1.0),
                        fontSize: 4.w,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
