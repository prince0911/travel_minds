import 'package:mongo_dart/mongo_dart.dart';

class TopPackagesModel {
  String packageName;
  String packageImage;
  String packagePrice;
  String packageDuration;

  TopPackagesModel({
    required this.packageName,
    required this.packageImage,
    required this.packagePrice,
    required this.packageDuration,
  });

  /// Convert JSON to TopPackagesModel
  factory TopPackagesModel.fromJson(Map<String, dynamic> json) {
    return TopPackagesModel(
      packageName: json['packageName'] ?? '',
      packageImage: json['packageImage'] ?? '',
      packagePrice: json['packagePrice'] ?? '',
      packageDuration: json['packageDuration'] ?? '',
    );
  }

  /// Convert TopPackagesModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'packageImage': packageImage,
      'packagePrice': packagePrice,
      'packageDuration': packageDuration,
    };
  }
}
