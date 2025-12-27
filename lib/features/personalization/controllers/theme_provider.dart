import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode;

  ThemeProvider({bool initialMode = false}) : _isDarkMode = initialMode;

  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData => _isDarkMode ? _darkTheme : _lightTheme;

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  final AppBarTheme _appBarTheme = const AppBarTheme(
    backgroundColor: Color.fromRGBO(28, 32, 37, 1.0), // Always dark color
    foregroundColor: Colors.white,
    elevation: 4,
  );

  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blueGrey,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromRGBO(28, 32, 37, 1.0), // ✅ Keep it dark
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 20, color: Colors.black),
      titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
    ),
  );

  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.white,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromRGBO(28, 32, 37, 1.0), // ✅ Keep it dark
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 20, color: Colors.white),
      titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
    ),
  );
}
