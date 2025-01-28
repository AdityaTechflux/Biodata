import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageChangeController with ChangeNotifier {
  Locale? _appLocale;
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  Locale? get appLocale => _appLocale;

  // Call this method on app start to set the initial language
  Future<void> init() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? languageCode = sp.getString('language_code');

    if (languageCode != null) {
      _appLocale = Locale(languageCode);
    } else {
      _appLocale = Locale('en'); // Default to English
    }

    notifyListeners();
  }

  void changeLanguage(Locale type) async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    // Set the new locale
    _appLocale = type;

    // Save the language code in shared preferences
    await sp.setString('language_code', type.languageCode);

    notifyListeners(); // Notify listeners about the change
  }

  void changeLocale(Locale newLocale) {
    if (_appLocale != newLocale) {
      _appLocale = newLocale;
      notifyListeners(); // Notify the widgets listening to this change
    }
  }

  void changeButtonColor(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners(); // Notify listeners to update UI
    }
  }
}
