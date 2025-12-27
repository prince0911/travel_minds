import 'package:mongo_dart/mongo_dart.dart';

class WishlistModel {
  ObjectId userId;
  String packageName;
  String packageImage;
  String packagePrice;
  String packageDuration;

  WishlistModel({
    required this.userId,
    required this.packageName,
    required this.packageImage,
    required this.packagePrice,
    required this.packageDuration,
  });

  /// Convert JSON to WishlistModel
  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      userId: json['userId'] is String ? ObjectId.fromHexString(json['userId']) : json['userId'],
      packageName: json['packageName'] ?? '',
      packageImage: json['packageImage'] ?? '',
      packagePrice: json['packagePrice'] ?? '',
      packageDuration: json['packageDuration'] ?? '',
    );
  }

  /// Convert WishlistModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId.toHexString(),
      'packageName': packageName,
      'packageImage': packageImage,
      'packagePrice': packagePrice,
      'packageDuration': packageDuration,
    };
  }
}
