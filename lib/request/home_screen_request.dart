import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../consts/app_urls.dart';

class HomeScreenRequest {
  static final HomeScreenRequest _instance = HomeScreenRequest._internal();
  factory HomeScreenRequest() => _instance;
  HomeScreenRequest._internal();

  final String baseUrl = "http://allindiamatrimonial.com/royal_maratha/api";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token_key');
  }

  Future<String?> _getMatriId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('matri_id');
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final prefs = await SharedPreferences.getInstance(); // Define prefs here
      final String? matriId = await _getMatriId();
      final String? token = await _getToken();
      log("Token: $token, MatriId: $matriId");

      if (matriId == null || token == null) {
        log("Missing matri_id or token, clearing local data.");
        await prefs.clear(); // Clear local data
        return {"success": true, "message": "Account deleted successfully."};
      }

      final String apiUrl =
          '${AppUrls.baseUrl}/api/delete_account_byid/$matriId';
      // final String apiUrl =
      //     'http://allindiamatrimonial.com/royal_maratha/api/delete_account_byid/$matriId';

      log("Sending DELETE request to: $apiUrl");
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      log("Response status: ${response.statusCode}");
      log("Response body: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["response"] == true) {
          await prefs.clear(); // Clear local data after successful deletion
          log("Account deleted successfully.");
          return {
            "success": true,
            "message": data["success_msg"] ?? "Account deleted successfully"
          };
        } else {
          return {
            "success": false,
            "message": data["error_msg"] ?? "Failed to delete account"
          };
        }
      } else {
        return {
          "success": false,
          "message": "Server error: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error during account deletion: $e"};
    }
  }

  Future<Map<String, dynamic>?> copyBiodataByMatriId() async {
    final url = Uri.parse('${AppUrls.baseUrl}/api/copy_biodata_by_matri_id');
    // final url = Uri.parse(
    //     'http://allindiamatrimonial.com/royal_maratha/api/copy_biodata_by_matri_id');

    try {
      // Get matri_id from SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? matriId = prefs.getString('matri_id');

      if (matriId == null) {
        print('matri_id is not available in SharedPreferences');
        return null;
      }
      // Send the POST request
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"matri_id": matriId}),
      );

      if (response.statusCode == 200) {
        // Parse the response and return the copied biodata data
        Map<String, dynamic> responseData = jsonDecode(response.body);

        // Check if the response has a success status and data field
        if (responseData['status'] == true && responseData['data'] != null) {
          log('Copy successful');
          return responseData['data']; // Return the copied biodata data
        } else {
          log('Failed to copy biodata: ${responseData['message']}');
          return null;
        }
      } else {
        log('Failed to copy biodata: ${response.body}');
        return null;
      }
    } catch (e) {
      log('Error occurred while copying biodata: $e');
      return null;
    }
  }

  // Copy Biodata method
  Future<Map<String, dynamic>> copyBiodata() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? matriId = prefs.getString('matri_id');
      String? token = prefs.getString('token_key');

      if (matriId == null ||
          matriId.isEmpty ||
          token == null ||
          token.isEmpty) {
        return {"success": false, "message": "matri_id or token not found."};
      }

      final String apiUrl = '${AppUrls.baseUrl}/api/copy_biodata_by_matri_id';

      // final String apiUrl =
      //     'http://allindiamatrimonial.com/royal_maratha/api/copy_biodata_by_matri_id';

      // Send POST request with matri_id in body
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'matri_id': matriId,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["response"] == true) {
          String successMessage =
              data["success_msg"] ?? "Biodata copied successfully";
          return {"success": true, "message": successMessage};
        } else {
          String errorMessage = data["error_msg"] ?? "Failed to copy biodata";
          return {"success": false, "message": errorMessage};
        }
      } else {
        return {
          "success": false,
          "message": "Server error: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error during biodata copy: $e"};
    }
  }
}
