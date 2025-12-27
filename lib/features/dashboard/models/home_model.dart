import 'package:mongo_dart/mongo_dart.dart';

class HomeDataModel {
  ObjectId id;
  List<String> imageSlider;
  List<Category> categories;

  HomeDataModel({
    required this.id,
    required this.imageSlider,
    required this.categories,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    return HomeDataModel(
      id: json['_id']['\$oid'] != null ? ObjectId.parse(json['_id']['\$oid']) : ObjectId(),
      imageSlider: List<String>.from(json['imageSlider']),
      categories: (json['categories'] as List)
          .map((category) => Category.fromJson(category))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'imageSlider': imageSlider,
      'categories': categories.map((category) => category.toJson()).toList(),
    };
  }
}

class Category {
  String name;
  String image;

  Category({
    required this.name,
    required this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
    };
  }
}
