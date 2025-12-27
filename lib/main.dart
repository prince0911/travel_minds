import 'package:cloudinary_flutter/cloudinary_context.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:travel_minds/binding/firebase_options.dart';
import 'package:travel_minds/data/repositories/mongo_repository.dart';
import 'package:travel_minds/data/services/laguage_services.dart';
import 'package:travel_minds/features/authentication/controllers/authentication_file.dart';
import 'package:travel_minds/features/authentication/screens/splash_screen.dart';
import 'package:travel_minds/utils/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await MongoDb.connect();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  CloudinaryContext.cloudinary =
      Cloudinary.fromCloudName(cloudName: 'dfhbhhy9e');
  Get.lazyPut(() => AuthenticationFile());

  runApp(
      const MyApp()

  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, screenType) {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        translations: LocaleString(),
        locale: Locale('en', 'US'),
        title: 'Flutter Demo',
        themeMode: ThemeMode.system,
        theme: TAppTheme.lightTheme,
        darkTheme: TAppTheme.darkTheme,
        home: const SplashScreen(), // SplashScreen is the initial screen
      );
    });
  }
}
