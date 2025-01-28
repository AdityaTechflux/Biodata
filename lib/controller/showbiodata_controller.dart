import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../request/home_screen_request.dart';
import '../request/showbiodatabymatri_id.dart';

class ShowbiodataController with ChangeNotifier {
  bool isLoading = false;

  // This is the getter for loading
  bool get loading => isLoading;

  // This is the setter for loading
  set loading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> fetchBiodata() async {
    isLoading = true;
    notifyListeners();

    try {
      userData.clear();
      Map<String, dynamic>? response = await ShowbiodatabymatriId.showBiodata();

      if (response != null &&
          response['status'] == true &&
          response['data'] != null) {
        userData = response['data'].cast<Map<String, dynamic>>();
      } else {
        print("Error: ${response?['message'] ?? 'No data found'}");
      }
    } catch (e) {
      print("Error fetching biodata: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> copyBiodata(String biodataId) async {
    loading = true;

    try {
      Map<String, dynamic>? response =
          await ShowbiodatabymatriId().copyBiodataById(biodataId);

      if (response != null && response['status'] == true) {
        print("Biodata copied successfully: ${response['message']}");
        // Optionally refresh biodata after copy
        await fetchBiodata();
        return true; // Copy succeeded
      } else {
        print("Copy failed: ${response?['message'] ?? 'Unknown error'}");
        return false; // Copy failed
      }
    } catch (e) {
      print("Error copying biodata: $e");
      return false; // Copy failed
    } finally {
      loading = false;
    }
  }

  Future<void> deleteBiodataFromController(String biodataId) async {
    loading = true;
    Map<String, dynamic>? response =
        await ShowbiodatabymatriId.deleteBiodata(biodataId);

    if (response != null && response['status'] == true) {
      userData.removeWhere((item) => item['id'] == biodataId);
      notifyListeners();
    } else {
      print("Failed to delete biodata");
    }
    loading = false;
  }

  Future<void> refreshUserData() async {
    // Logic to refresh user data from API
    isLoading = true;
    notifyListeners();

    isLoading = false;
    notifyListeners();
  }

  List<Map<String, dynamic>> userData = [];

  String privacyContent = '';

  Future<void> fetchPrivacyPolicy() async {
    try {
      await ShowbiodatabymatriId.getPrivacy();

      SharedPreferences pref = await SharedPreferences.getInstance();
      String? privacyResponse = pref.getString('privacy_response');

      if (privacyResponse != null) {
        Map<String, dynamic> parsedResponse = jsonDecode(privacyResponse);

        if (parsedResponse['success'] == true &&
            parsedResponse['data'] != null) {
          privacyContent = parsedResponse['data'];
          notifyListeners();
        } else {
          print(
              "Error: ${parsedResponse['message'] ?? 'No privacy data found'}");
        }
      } else {
        print("No privacy data found in SharedPreferences");
      }
    } catch (e) {
      print("Error fetching privacy policy: $e");
    }
  }

  Future<void> postFeedback(String message) async {
    loading = true;
    try {
      await ShowbiodatabymatriId.postFeedback(message);
      log("Feedback submitted successfully.");
    } catch (e) {
      log("Error submitting feedback: $e");
    } finally {
      loading = false;
    }
  }

  Future<void> loadPersistedBiodata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedData = prefs.getString('userData');

    if (storedData != null) {
      userData = List<Map<String, dynamic>>.from(jsonDecode(storedData));
      notifyListeners();
    } else {
      await fetchBiodata();
    }
  }
}
