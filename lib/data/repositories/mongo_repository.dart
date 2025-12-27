import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:bcrypt/bcrypt.dart';
import 'package:travel_minds/features/dashboard/models/wishlist_model.dart';


class MongoDb{
  static late Db db;
  static late var userCollection;
  static const String CONNECTION_MINE_URL = "mongodb+srv://prince_04:UFxoGjKjTrSoNtxe@cluster0.euwenlb.mongodb.net/trip_planner?retryWrites=true&w=majority&appName=Cluster0tls=true";
  static const String CONNECTION_URL = "mongodb+srv://rapidtow04:M817PAYgfkv7Ae4q@cluster0.eivh2.mongodb.net/trip_planner?retryWrites=true&w=majority&tls=true";

  static const String USERS_COLLECTION = "users";
  static const String BOOKS_COLLECTION = "bookdetails";
  static const String HOME_COLLECTION = "home_photos";
  static const String TOP_PACKAGES_COLLECTION = "top_packages";
  static const String WISHLIST_COLLECTION = "wishlist";
  static const String ALL_PACKAGES_COLLECTION = "all_packages";
  static const String REVIEWS_COLLECTION = "reviews";

  static var wishlistCollection = db.collection(WISHLIST_COLLECTION);

  static Future<void> connect() async {
    try {
      db = await Db.create(CONNECTION_URL);
      await db.open();
      userCollection = db.collection(USERS_COLLECTION);
      inspect(db);
      print('MongoDB connected');
    } catch (e) {
      print('MongoDB Connection Error: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAllPackages() async {
    var userCollection = MongoDb.db.collection(ALL_PACKAGES_COLLECTION);
    try {
      return await userCollection.find().toList(); // Fetch data from the all_packages collection
    } catch (e) {
      print('Error fetching packages: $e');
      return [];
    }
  }
  static Future<List<Map<String, dynamic>>> fetchTopPackages() async {
    var collection = MongoDb.db.collection(TOP_PACKAGES_COLLECTION);
    try {
      return await collection.find().toList(); // Fetch data from the all_packages collection
    } catch (e) {
      print('Error fetching packages: $e');
      return [];
    }
  }

  static Future<List<String>> getPackageImages(String packageName) async {
    try {
      var packageCollection = MongoDb.db.collection(ALL_PACKAGES_COLLECTION);
      var allStates = await packageCollection.find().toList();

      for (var state in allStates) {
        List<dynamic> packages = state['packages'];

        for (var package in packages) {
          if (package['name'] == packageName) {
            return List<String>.from(package['images'] ?? []); // Return list of image URLs
          }
        }
      }

      print("⚠️ No images found for package: $packageName");
      return [];
    } catch (e) {
      print("❌ Error fetching images: $e");
      return [];
    }
  }


  static Future<Map<String, dynamic>?> getDataOfUserByEmail(String email) async {
    try {
      var userCollection = MongoDb.db.collection(USERS_COLLECTION);
      // Find the document where the email matches
      var userDocument = await userCollection.findOne({"email": email});

      // If a document is found, return it
      if (userDocument != null) {
        return userDocument;
      } else {
        print("No user found with the email: $email");
        return null;
      }
    } catch (e) {
      print('Error retrieving data: $e');
      return null;
    }
  }

  // static Future<List<Map<String, dynamic>>> getUserPaymentHistory(String email) async {
  //   try {
  //     var userCollection = MongoDb.db.collection(PAYMENT_COLLECTION);
  //
  //     // Find all documents where the email matches
  //     var userDocuments = await userCollection.find({"email": email}).toList();
  //
  //     // If documents are found, return them
  //     if (userDocuments.isNotEmpty) {
  //       return userDocuments;
  //     } else {
  //       print("No user records found with the email: $email");
  //       return [];
  //     }
  //   } catch (e) {
  //     print('Error retrieving user records: $e');
  //     return [];
  //   }
  // }


  static Future<Map<String, dynamic>?> getPackageByName(String packageName) async {
    try {
      var packageCollection = MongoDb.db.collection(ALL_PACKAGES_COLLECTION);
      var allStates = await packageCollection.find().toList();

      for (var state in allStates) {
        List<dynamic> packages = state['packages'];

        for (var package in packages) {
          if (package['name'] == packageName) {
            return {
              "state": state['state'], // ✅ Return state name
              "package": package       // ✅ Return package details
            };
          }
        }
      }

      print("⚠️ Package '$packageName' not found!");
      return null; // If no package matches
    } catch (e) {
      print("❌ Error fetching package by name: $e");
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getFavourite(mongo.ObjectId userId) async {
    try {
      var _favouriteCollection = MongoDb.db.collection(WISHLIST_COLLECTION);
      final favourites = await _favouriteCollection.find(mongo.where.eq("userId", userId)).toList();
      return favourites.map((fav) => fav.cast<String, dynamic>()).toList();
    } catch (e) {
      print("❌ Error fetching favourites: $e");
      return [];
    }
  }


  static String hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }


  static Future<bool> registerUser(ObjectId id, String email,String contactNo, String password,String fullName,String profilePhoto,String backStreamPhoto,double travelPoints,int tripBooked) async {
    try {
      var userCollection = MongoDb.db.collection(USERS_COLLECTION);

      // Hash the password
      String hashedPassword = hashPassword(password);

      var result = await userCollection.insertOne({
        'id': id,
        'fullName': fullName,
        'email': email,
        'contactNo': contactNo,
        'password': hashedPassword,
        'profilePhoto': profilePhoto,
        'backStreamPhoto': backStreamPhoto,
        'travelPoints': travelPoints,
        'tripBooked': tripBooked,

      });

      // Log success or failure
      if (result.isSuccess) {
        print('User registered successfully: $email');
      } else {
        print('Failed to register user: $email');
      }

      return result.isSuccess;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  static Future<bool> checkUserInMongoDB(String email) async {
    try {
      var userCollection = MongoDb.db.collection(USERS_COLLECTION);
      var userDocument = await userCollection.findOne({"email": email});

      if (userDocument != null) {
        print("✅ User found in MongoDB: ${userDocument['fullName']}");
        return true; // User exists
      } else {
        print("⚠️ User not found in MongoDB");
        return false; // User does not exist
      }
    } catch (e) {
      print('❌ Error checking user in MongoDB: $e');
      return false;
    }
  }


  static Future<bool> bookUser( ObjectId uid ,String fullName,String email, String contactNo,String date, int adult,int child,String packageName ,String duration,String packageType , String tripDate,double packagePrice ,int discount, String paymentMode) async {
    try {
      var userCollection = MongoDb.db.collection(BOOKS_COLLECTION);

      var result = await userCollection.insertOne({

        'uid': uid,
        'fullName': fullName,
        'email': email,
        'contactNo': contactNo,
        'date': date,
        'people': {
          'adult': adult,
          'child': child,
        },
        'packageName': packageName,
        'duration':duration,
        'packageType': packageType,
        'tripDate': tripDate,
        'packagePrice': packagePrice,
        'discount': discount,
        'paymentMode': paymentMode,
      });

      // Log success or failure
      if (result.isSuccess) {
        print('User booked successfully.');
      } else {
        print('Failed to book user.');
      }

      return result.isSuccess;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getHomeData() async {
    try {
      var homeCollection = MongoDb.db.collection(HOME_COLLECTION);
      var homeData = await homeCollection.findOne();

      if (homeData != null) {
        return {
          "imageSlider": List<String>.from(homeData["imageSlider"] ?? []),
          "categories": List<Map<String, dynamic>>.from(homeData["categories"] ?? []),
        };
      } else {
        print("No home data found.");
        return null;
      }
    } catch (e) {
      print('Error retrieving home data: $e');
      return null;
    }
  }



  static Future<List<Map<String, dynamic>>> getUserBookingHistory(String email) async {
    try {
      var bookingsCollection = MongoDb.db.collection(BOOKS_COLLECTION);
      var userBookings = await bookingsCollection.find({"email": email}).toList();

      if (userBookings.isNotEmpty) {
        return userBookings;
      } else {
        print("No booking history found for email: $email");
        return [];
      }
    } catch (e) {
      print('Error retrieving booking history: $e');
      return [];
    }
  }

  static Future<bool> submitUserReview({
    required String fullName,
    required String email,
    required double rating,
    required String comment,
    required DateTime date,
  }) async {
    try {
      var reviewsCollection = MongoDb.db.collection(REVIEWS_COLLECTION);

      var reviewData = {

        "fullName": fullName,
        "email": email,
        "rating": rating,
        "comment": comment,
        "timestamp": DateTime.now(),
      };

      var result = await reviewsCollection.insertOne(reviewData);

      if (result.isSuccess) {
        print("✅ Review submitted successfully.");
      } else {
        print("❌ Failed to submit review.");
      }

      return result.isSuccess;
    } catch (e) {
      print("❌ Error submitting review: $e");
      return false;
    }
  }


  static Future<String> updateByEmail(String email,int tripPoints) async {
    try {
      var collection = MongoDb.db.collection(USERS_COLLECTION); // Replace 'users' with your actual collection name

      var result = await collection.update(
          where.eq('email', email), // Match document where email matches
          modify
            // Set new fName
              .set('travelPoints', tripPoints) // Set new lName
              // .set('address', address)
              // .set('dateOfBirth', dateOfBirth)
        // Set new phone number
        // Set new phone number
      );

      // Check if the update modified any documents
      if (result['nModified'] != null && result['nModified'] > 0) {
        return "Data Updated";
      } else {
        return "Update Failed or No Document Found with Email: $email";
      }
    } catch (e) {
      print('Error updating data: $e');
      return e.toString();
    }
  }

  static Future<String> updateProfilePhoto(String url,email) async{
    try{
      var collection = MongoDb.db.collection(USERS_COLLECTION); // Replace 'users' with your actual collection name

      var result = await collection.update(
          where.eq('email', email), // Match document where email matches
          modify
              .set('profilePhoto',url ) // Set new fName
      );
      if (result['nModified'] != null && result['nModified'] > 0) {
        return "Data Updated";
      } else {
        return "Update Failed or No Document Found with Email: $email";
      }
    }catch(e){
      print('Error updating data: $e');
      return e.toString();
    }
  }
  static Future<String> updatebackStreamPhoto(String url,email) async{
    try{
      var collection = MongoDb.db.collection(USERS_COLLECTION); // Replace 'users' with your actual collection name

      var result = await collection.update(
          where.eq('email', email), // Match document where email matches
          modify
              .set('backStreamPhoto',url ) // Set new fName
      );
      if (result['nModified'] != null && result['nModified'] > 0) {
        return "Data Updated";
      } else {
        return "Update Failed or No Document Found with Email: $email";
      }
    }catch(e){
      print('Error updating data: $e');
      return e.toString();
    }
  }

  // static Future<bool> addToWishlist(ObjectId userId, Map<String, dynamic> package) async {
  //   try {
  //     var collection = MongoDb.db.collection(WISHLIST_COLLECTION);
  //     // ✅ Correct way to get ObjectId as a String
  //     await collection.insert({
  //       "userId": userId,
  //       "packageId": ObjectId.fromHexString(package['_id']), // ✅ Store as a string
  //       "packageName": package["name"],
  //       "packageImage": package["images"][0],
  //       "packagePrice": package["pricing"]["budget"],
  //       "packageDuration": package["duration"]
  //     });
  //
  //     return true;
  //   } catch (e, stacktrace) {
  //     print("❌ Error adding to wishlist: $e");
  //     print("📜 Stacktrace: $stacktrace");
  //     return false;
  //   }
  // }
  //
  // static Future<bool> removeFromWishlist(ObjectId userId, ObjectId packageId) async {
  //   try {
  //     var collection = MongoDb.db.collection(WISHLIST_COLLECTION);
  //
  //     var result = await collection.deleteOne({
  //       "userId": userId,
  //       "packageId": packageId, // Now both are ObjectId
  //     });
  //
  //     return result.isSuccess;
  //   } catch (e) {
  //     print("Error removing from wishlist: $e");
  //     return false;
  //   }
  // }

  static Future<bool> isPackageInWishlist(ObjectId userId,String packageName) async {
    try {
      var result = await wishlistCollection.findOne({
        "userId": userId,
        "packageName": packageName,
      });

      return result != null;
    } catch (e) {
      print("❌ Error checking wishlist: $e");
      return false;
    }
  }

  // ✅ Add to Wishlist
  static Future<bool> addToWishlist(WishlistModel item) async {
    try {
      bool exists = await isPackageInWishlist(item.userId, item.packageName);
      if (exists) {
        print("⚠️ Package already in wishlist.");
        return false;
      }

      await wishlistCollection.insertOne({
        "userId": item.userId,
        "packageName": item.packageName,
        "packageImage": item.packageImage,
        "packagePrice": item.packagePrice,
        "packageDuration": item.packageDuration
      });
      print("✅ Added to Wishlist.");
      return true;
    } catch (e) {
      print("❌ Error adding to wishlist: $e");
      return false;
    }
  }

  // ✅ Remove from Wishlist
  static Future<bool> removeFromWishlist(ObjectId userId, String packageName) async {
    try {
      var result = await wishlistCollection.deleteOne({
        "userId": userId,
        "packageName": packageName,
      });

      return result.isSuccess;
    } catch (e) {
      print("❌ Error removing from wishlist: $e");
      return false;
    }
  }

  // ✅ Get Wishlist for User
  static Future<List<WishlistModel>> getUserWishlist(ObjectId userId) async {
    try {
      var result = await wishlistCollection.find({"userId": userId}).toList();

      return result.map((json) => WishlistModel.fromJson(json)).toList();
    } catch (e) {
      print("❌ Error fetching wishlist: $e");
      return [];
    }
  }


  static Future<void> close() async {
    await db.close();
    print("🔌 MongoDB Disconnected.");
  }
  // static Future<void> delete(PaymentModel data) async {
  //   try {
  //     var userCollection = MongoDb.db.collection(PAYMENT_COLLECTION);
  //     await userCollection.remove(where.id(data.pid));
  //   } catch (e) {
  //     print('Error deleting data: $e');
  //   }
  // }
}