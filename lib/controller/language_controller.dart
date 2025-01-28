import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends ChangeNotifier {
  int _selectedIndex = 0; // Always starts with English (index 0)
  int get selectedIndex => _selectedIndex;
  Locale _appLocale = const Locale('en'); // Always defaults to English

  Locale get appLocale => _appLocale;

  // List of languages
  final List<Map<String, String>> languages = [
    {'locale': 'en', 'name': 'English'},
    {'locale': 'hi', 'name': 'हिंदी'},
    {'locale': 'mr', 'name': 'मराठी'},
    {'locale': 'gu', 'name': 'ગુજરાતી'},
    {'locale': 'bn', 'name': 'বাংলা'},
    {'locale': 'kn', 'name': 'ಕನ್ನಡ'},
    {'locale': 'pa', 'name': 'ਪੰਜਾਬੀ'},
    // {'locale': 'ur', 'name': 'اردو'},
    {'locale': 'te', 'name': 'తెలుగు'},
    {'locale': 'ta', 'name': 'தமிழ்'},
  ];

  // Constructor no longer needs to load saved locale
  LanguageController() {
    // Initialize with English by default
    _selectedIndex = 0;
    _appLocale = const Locale('en');
  }

  // Change locale without saving to SharedPreferences
  void changeLocale(String languageCode) {
    _appLocale = Locale(languageCode);
    _selectedIndex =
        languages.indexWhere((language) => language['locale'] == languageCode);
    notifyListeners();
  }
}
