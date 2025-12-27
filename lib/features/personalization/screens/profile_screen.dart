import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:travel_minds/data/repositories/mongo_repository.dart';
import 'package:travel_minds/features/personalization/screens/favourites_screen.dart';
import 'package:travel_minds/features/personalization/screens/history_screen.dart';
import 'package:travel_minds/features/personalization/screens/setting_screen.dart';
import 'package:travel_minds/utils/http/http_client.dart';
import 'package:travel_minds/utils/theme/custom_themes/text_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool circular = false;
  final ImagePicker picker = ImagePicker();
  String? userEmail;
  var id;
  bool isLoading = true;
  bool isDelayed = true;
  String profilePhoto = "";
  String backStreamPhoto = "";
  String fullName = "Loading...";
  String email = "Loading...";
  int travelPoints = 0;
  int tripBooked = 0;

  CropAspectRatio? _selectedAspectRatio;

  final List<CropAspectRatio> _aspectRatios = [
    CropAspectRatio(ratioX: 1, ratioY: 1),  // Square
    CropAspectRatio(ratioX: 3, ratioY: 2),  // 3:2
    CropAspectRatio(ratioX: 4, ratioY: 3),  // 4:3
    CropAspectRatio(ratioX: 16, ratioY: 9), // 16:9
  ];

  @override
  void initState() {
    super.initState();
    getCurrentUserEmail().then((_) {
      if (userEmail != null) {
        fetchUserData(userEmail!).then((data) {
          setState(() {
            profilePhoto = data["profilePhoto"] ?? "";
            backStreamPhoto = data["backStreamPhoto"] ?? "";
            fullName = data["fullName"] ?? "Unknown";
            email = data["email"] ?? "No email";
            travelPoints = (data["travelPoints"] ?? 0).toInt();
            tripBooked = (data["tripBooked"] ?? 0).toInt();
            isLoading = false;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color.fromRGBO(8, 9, 11, 1),
      body: isLoading
          ? profileShimmer()
          : _buildProfileContent(),
      endDrawer: NavigationDrawerScreen(profilePhoto: profilePhoto, fullName: fullName, emailAddress: email),
    );
  }

  Widget _buildProfileContent() {
    return Stack(
      children: [
        // Background Image
        Positioned(
          top: 1.h,
          child: (backStreamPhoto.isEmpty)
              ? Image.asset(
            'assets/images/default_backstream.png',
            height: 25.h,
            width: 100.w,
            fit: BoxFit.cover,
          )
              : Image.network(
            "$backStreamPhoto?timestamp=${DateTime.now().millisecondsSinceEpoch}",
            height: 25.h,
            width: 100.w,
            fit: BoxFit.cover,
          ),
        ),

        // Gradient Overlay
        Positioned(
          top: 1.h,
          child: Container(
            height: 25.h,
            width: 100.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.5),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        // Settings Icon
        Positioned(
          top: 7.h,
          left: 7.w,
          child: InkWell(
            onTap: () async {
              if (await _checkPermissions()) {
                showImagePicker(context, false);
              }
            },
            child: Icon(Icons.camera_alt, color: Colors.white, size: 3.h),
          ),
        ),
        Positioned(
          top: 7.h,
          right: 7.w,
          child: Builder(
            builder: (context) => InkWell(
              onTap: () {
                debugPrint("Settings clicked");
                Scaffold.of(context).openEndDrawer();
              },
              child: Icon(Icons.settings, size: 3.5.h, color: Colors.white),
            ),
          ),
        ),
        // Profile Photo & Name
        Positioned(
          top: 21.h,
          child: Row(
            children: [
              SizedBox(width: 5.w),
              (profilePhoto.isEmpty)
                  ? CircleAvatar(
                backgroundColor: const Color.fromRGBO(8, 9, 11, 1),
                radius: 27.sp,
                child: Container(
                  height: 9.4.h,
                  width: 9.4.h,
                  decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(28.sp)),
                  child: Icon(
                    Icons.person,
                    size: 8.h,
                  ),
                ),
              )
                  : CircleAvatar(
                backgroundColor: const Color.fromRGBO(8, 9, 11, 1),
                radius: 27.sp,
                child: CircleAvatar(
                  radius: 26.sp,
                  child: Container(
                    height: 9.4.h,
                    width: 9.4.h,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(28.sp),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28.sp),
                      child: Image.network(
                        "$profilePhoto?timestamp=${DateTime.now().millisecondsSinceEpoch}",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
            ],
          ),
        ),
        // Add Profile Picture Button
        Positioned(
          top: 28.h,
          left: 22.w,
          child: InkWell(
            onTap: () async {
              if (await _checkPermissions()) {
                showImagePicker(context, true);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(10)),
              height: 20,
              width: 20,
              child: Icon(Icons.add, color: Colors.white, size: 2.h),
            ),
          ),
        ),

        // User Info
        _buildUserInfo("Full Name", fullName, 32.h),
        _buildUserInfo("Email Address", email, 34.h),

        Positioned(
          top: 40.h,
          left: 6.w,
          child: Container(
            height: 12.h,
            width: 88.w,
            decoration: BoxDecoration(
              color: Colors.grey[900], // Dark background
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Image(image: AssetImage('assets/images/reward_bg.png'), fit: BoxFit.fill),
          ),
        ),
        Positioned(
            top: 42.h,
            left: 12.w,
            child: Text('your_points'.tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.sp,color: Colors.white))),
        Positioned(
            top: 46.h,
            left: 15.w,
            child: Text('${travelPoints.toDouble()}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19.sp, color: const Color.fromARGB(255, 179, 226, 255)))),
        Positioned(
            top: 43.h,
            right: 14.w,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.asset('assets/images/coin.png', height: 6.h),
            )),

        Positioned(
          top: 56.h,
          left: 6.w,
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FavouritesScreen(userEmail: userEmail!)));
            },
            child: Container(
              height: 6.h,
              width: 88.w,
              decoration: BoxDecoration(
                color: Colors.grey[900], // Dark background
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: ListTile(
                title: Text('favourites'.tr, style: TextStyle(color: Colors.white, fontSize: 3.7.w)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 4.w),
              ),
            ),
          ),
        ),
        Positioned(
          top: 63.5.h,
          left: 6.w,
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Historyscreen(userEmail: userEmail!)));
            },
            child: Container(
              height: 6.h,
              width: 88.w,
              decoration: BoxDecoration(
                color: Colors.grey[900], // Dark background
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: ListTile(
                title: Text('tripHistory'.tr, style: TextStyle(color: Colors.white, fontSize: 3.7.w)),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 4.w),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(String title, String value, double topPosition) {
    return Positioned(
      top: topPosition,
      left: 6.w,
      child: Text('$value', style: TextStyle(color: Colors.white, fontSize: 15.sp)),
    );
  }

  Future<bool> _checkPermissions() async {
    Map<Permission, PermissionStatus> status = await [
      Permission.storage,
      Permission.camera,
    ].request();

    return status[Permission.storage]!.isGranted &&
        status[Permission.camera]!.isGranted;
  }

  void showImagePicker(BuildContext context, bool value) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Card(
          child: Container(
            width: double.infinity,
            height: 15.h,
            margin: EdgeInsets.only(top: 2.h),
            padding: EdgeInsets.all(2.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildImagePickerOption("gallery".tr, Icons.image, () {
                  _imageFromGallery(value);
                }),
                _buildImagePickerOption("Camera", Icons.camera_alt, () {
                  _imageFromCamera(value);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePickerOption(String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: () {
          onTap();
          Navigator.pop(context);
        },
        child: Column(
          children: [
            Icon(icon, size: 7.h),
            SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 2.h, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  _imageFromGallery(bool value) async {
    XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        circular = true;
      });

      // Await the result of _cropImage to get the cropped file
      File? croppedFile = await _cropImage(File(image.path));

      if (croppedFile != null) {
        // Proceed with the upload for the cropped image
        Uint8List bytes = await croppedFile.readAsBytes();

        HttpHelper()
            .uploadImage(bytes, image.name, id)
            .then((onValue) {
          setState(() {
            if (value) {
              profilePhoto = onValue['location'].toString();
            } else {
              backStreamPhoto = onValue['location'].toString();
            }
            circular = false;
          });
          if (value) {
            MongoDb.updateProfilePhoto(profilePhoto, email);
          } else {
            MongoDb.updatebackStreamPhoto(backStreamPhoto, email);
          }
          // Fetch updated data
          fetchUserData(userEmail!).then((data) {
            setState(() {
              if (value) {
                profilePhoto = data["profilePhoto"] ?? "";
              } else {
                backStreamPhoto = data["backStreamPhoto"] ?? "";
              }
            });
          });
          if (value) {
            showSnackBar("Profile picture updated successfully");
          } else {
            showSnackBar("BackStream picture updated successfully");
          }
        }).catchError((error) {
          setState(() {
            circular = false;
          });
          showSnackBar("Upload failed: $error", color: Colors.red);
          print("Upload failed: $error");
        });
      } else {
        setState(() {
          circular = false;
        });
        print("Image cropping failed.");
      }
    }
  }

  _imageFromCamera(bool value) async {
    XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (image != null) {
      setState(() {
        circular = true;
      });
      File? croppedFile = await _cropImage(File(image.path));
      if (croppedFile != null) {
        Uint8List bytes = await croppedFile.readAsBytes();
        HttpHelper().uploadImage(bytes, image.name, id).then((onValue) {
          setState(() {
            if (value) {
              profilePhoto = onValue['location'].toString();
            } else {
              backStreamPhoto = onValue['location'].toString();
            }
            circular = false;
          });
          if (value) {
            MongoDb.updateProfilePhoto(profilePhoto, email);
          } else {
            MongoDb.updatebackStreamPhoto(backStreamPhoto, email);
          }

          // Fetch updated data
          fetchUserData(userEmail!).then((data) {
            setState(() {
              if (value) {
                profilePhoto = data["profilePhoto"] ?? "";
              } else {
                backStreamPhoto = data["backStreamPhoto"] ?? "";
              }
            });
          });
          if (value) {
            showSnackBar("Profile picture updated successfully");
          } else {
            showSnackBar("BackStream picture updated successfully");
          }
        }).catchError((error) {
          setState(() {
            circular = false;
          });
          showSnackBar("Upload failed: $error", color: Colors.red);
          print("Upload failed: $error");
        });
      }
    }
  }

  Future<File?> _cropImage(File file) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: _selectedAspectRatio ?? _aspectRatios[0], // Default to Square
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Image Cropper",
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: "Image Cropper")
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null; // If cropping fails, return null.
  }

  // Function to select aspect ratio
  void _selectAspectRatio(int index) {
    _selectedAspectRatio = _aspectRatios[index];
  }

  void showSnackBar(String message, {Color color = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> getCurrentUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser ;

    if (user != null) {
      setState(() {
        userEmail = user.email;
      });
    } else {
      setState(() {
        userEmail = 'No user logged in';
      });
    }
  }

  Future<Map<String, dynamic>> fetchUserData(String email) async {
    var data = await MongoDb.getDataOfUserByEmail(email) ?? {};
    return {
      "profilePhoto": data["profilePhoto"] ?? "",
      "backStreamPhoto": data["backStreamPhoto"] ?? "",
      "fullName": data["fullName"] ?? "Unknown",
      "email": data["email"] ?? "No email",
      "travelPoints": (data["travelPoints"] ?? 0).toInt(),
      "tripBooked": (data["tripBooked"] ?? 0).toInt(),
    };
  }

  Widget profileShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[400]!,
      highlightColor: Colors.white,
      child: Stack(
        children: [
          Positioned(
            top: 1.h,
            child: Container(
              height: 25.h,
              width: 100.w,
              color: Colors.grey.withOpacity(0.8),
            ),
          ),
          Positioned(
            top: 34.h,
            left: 6.w,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Container(
                height: 1.5.h,
                width: 50.w,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          Positioned(
            top: 37.h,
            left: 6.w,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Container(
                height: 1.5.h,
                width: 80.w,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          Positioned(
            top: 42.h,
            left: 6.w,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Container(
                height: 10.h,
                width: 88.w,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          Positioned(
            top: 21.h,
            left: 6.w,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Container(
                height: 10.h,
                width: 10.h,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: 56.h,
            left: 6.w,
            child: Container(
              height: 6.h,
              width: 88.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7), // Dark background
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
          ),
          Positioned(
            top: 63.5.h,
            left: 6.w,
            child: Container(
              height: 6.h,
              width: 88.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7), // Dark background
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
          ),
        ],
      ),
    );
  }
}