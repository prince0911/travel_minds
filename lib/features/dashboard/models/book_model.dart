import 'package:mongo_dart/mongo_dart.dart';

class BookingModel {
  ObjectId uid;
  String fullName;
  String email;
  String contactNo;
  String date;
  int adult;
  int child;
  String packageName;
  String duration;
  String packageType;
  String tripDate;
  double packagePrice;
  int discount;
  String paymentMode;


  BookingModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.contactNo,
    required this.date,
    required this.adult,
    required this.child,
    required this.packageName,
    required this.duration,
    required this.packageType,
    required this.tripDate,
    required this.packagePrice,
    required this.discount,
    required this.paymentMode,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
     uid: json['uid'],
    fullName: json['fullName'],
    email: json['email'],
    contactNo: json['contactNo'],
    date: json['date'],
    adult: int.parse(json['people']['adult']),
    child: int.parse(json['people']['child']),
    packageName: json['packageName'],
    duration: json['duration'],
    packageType: json['packageType'],
    tripDate: json['tripDate'],
    packagePrice: (json['packagePrice'] as num).toDouble(),
    discount: (json['discount'] as num).toInt(),
    paymentMode: json['paymentMode'],
  );

  Map<String, dynamic> toJson() => {

    'uid': uid,
    'fullName': fullName,
    'email': email,
    'contactNo': contactNo,
    'date': date,
    'people': {
      'adult': adult.toString(),
      'child': child.toString(),
    },
    'packageName': packageName,
    'duration': duration,
    'packageType': packageType,
    'tripDate': tripDate,
    'packagePrice': packagePrice,
    'discount': discount,
    'paymentMode': paymentMode,
  };
}
