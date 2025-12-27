import 'package:mongo_dart/mongo_dart.dart';

class PackageModel {
  ObjectId id;
  String name;
  List<String> categories;
  List<String> destinations;
  String duration;
  List<String> highlights;
  List<String> images;
  Pricing pricing;
  List<ScheduleDay> schedule;
  String transportation;
  String bestSeason;
  List<String> allActivities;
  String available;

  PackageModel({
    required this.id,
    required this.name,
    required this.categories,
    required this.destinations,
    required this.duration,
    required this.highlights,
    required this.images,
    required this.pricing,
    required this.schedule,
    required this.transportation,
    required this.bestSeason,
    required this.allActivities,
    required this.available,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: _parseObjectId(json['_id']),
      name: json['name'] ?? 'Unknown Package',
      categories: _parseStringList(json['categories']),
      destinations: _parseStringList(json['destinations']),
      duration: json['duration'] ?? 'Duration not available',
      highlights: _parseStringList(json['highlights']),
      images: _parseStringList(json['images']),
      pricing: Pricing.fromJson(json['pricing'] ?? {}),
      schedule: _parseScheduleList(json['schedule']),
      transportation: json['transportation'] ?? 'Transportation not available',
      bestSeason: json['best_season'] ?? 'Best season not available',
      allActivities: _parseStringList(json['all_activities']),
      available: json['available'] ?? 'Null',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id.$oid, // New way to get hex string
    'name': name,
    'categories': categories,
    'destinations': destinations,
    'duration': duration,
    'highlights': highlights,
    'images': images,
    'pricing': pricing.toJson(),
    'schedule': schedule.map((day) => day.toJson()).toList(),
    'transportation': transportation,
    'best_season': bestSeason,
    'all_activities': allActivities,
    'available': available,
  };

  static ObjectId _parseObjectId(dynamic id) {
    if (id is ObjectId) return id;
    if (id is String) return ObjectId.fromHexString(id);
    return ObjectId();
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return [];
  }


  static List<ScheduleDay> _parseScheduleList(dynamic value) {
    if (value is List) {
      return value.map((item) => ScheduleDay.fromJson(item)).toList();
    }
    return [];
  }
}

class Pricing {
  String budget;
  String premium;

  Pricing({required this.budget, required this.premium});

  factory Pricing.fromJson(Map<String, dynamic> json) => Pricing(
    budget: json['budget'] ?? 'Price not available',
    premium: json['premium'] ?? 'Price not available',
  );

  Map<String, dynamic> toJson() => {
    'budget': budget,
    'premium': premium,
  };
}

class ScheduleDay {
  int day;
  List<String> places;
  List<String> activities;
  String accommodations;

  ScheduleDay({
    required this.day,
    required this.places,
    required this.activities,
    required this.accommodations,
  });

  factory ScheduleDay.fromJson(Map<String, dynamic> json) => ScheduleDay(
    day: json['day'] is int ? json['day'] : int.tryParse(json['day'].toString()) ?? 0,
    places: _parseStringList(json['places']),
    activities: _parseStringList(json['activities']),
    accommodations: json['accommodations'] ?? 'Not Available',
  );

  Map<String, dynamic> toJson() => {
    'day': day,
    'places': places,
    'activities': activities,
    'accommodations': accommodations,
  };

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return [];
  }
}