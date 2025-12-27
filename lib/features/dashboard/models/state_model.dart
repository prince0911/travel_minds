import 'package:mongo_dart/mongo_dart.dart';
import 'package:travel_minds/features/dashboard/models/package_model.dart';

class StateModel {
  ObjectId id;
  String state;
  String stateImage;
  List<PackageModel> packages;

  StateModel({
    required this.id,
    required this.state,
    required this.stateImage,
    required this.packages,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: _parseObjectId(json['_id']),
      state: json['state'] ?? 'Unknown State',
      stateImage: json['state_image'] ?? '',
      packages: _parsePackages(json['packages']),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id.toHexString(),
    'state': state,
    'state_image': stateImage,
    'packages': packages.map((package) => package.toJson()).toList(),
  };

  /// ✅ **Helper Function: Convert `_id` to ObjectId Safely**
  static ObjectId _parseObjectId(dynamic id) {
    if (id is ObjectId) return id;
    if (id is String) return ObjectId.fromHexString(id);
    return ObjectId(); // Generates a new ObjectId if missing
  }

  /// ✅ **Helper Function: Convert `packages` JSON safely**
  static List<PackageModel> _parsePackages(dynamic json) {
    if (json is List) {
      return json.map((item) => PackageModel.fromJson(item)).toList();
    }
    return [];
  }
}
