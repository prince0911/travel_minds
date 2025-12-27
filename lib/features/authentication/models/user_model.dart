import 'package:mongo_dart/mongo_dart.dart';

class UserModel {
  ObjectId id;
  String fullName;
  String email;
  String contactNo;
  String password;
  double travelPoints;
  int tripBooked;
  String profilePhoto;
  String backStreamPhoto;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.contactNo,
    required this.password,
    required this.profilePhoto,
    required this.backStreamPhoto,
    required this.travelPoints,
    required this.tripBooked,

  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['_id'] is ObjectId ? json['_id'] : ObjectId.fromHexString(json['_id']),
    fullName: json['fullName'],
    email: json['email'],
    contactNo: json['contactNo'],
    password: json['password'],
    profilePhoto: json['profilePhoto'],
    backStreamPhoto: json['backStreamPhoto'],
    travelPoints: json['travelPoints'],
    tripBooked: json['tripBooked'],

  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'fullName': fullName,
    'email': email,
    'contactNo': contactNo,
    'password': password,
    'profilePhoto': profilePhoto,
    'backStreamPhoto': backStreamPhoto,
    'travelPoints': travelPoints,
    'tripBooked': tripBooked,
  };
}
