import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../consts/app_urls.dart';

class ShowbiodatabymatriId {
  static final ShowbiodatabymatriId _instance =
      ShowbiodatabymatriId._internal();
  ShowbiodatabymatriId._internal();

  factory ShowbiodatabymatriId() => _instance;

  Future<Map<String, dynamic>?> copyBiodataById(String biodataId) async {
    final url = Uri.parse('${AppUrls.baseUrl}/api/copy_biodata_by_biodata_id');
    // final url = Uri.parse(
    //     'http://allindiamatrimonial.com/royal_maratha/api/copy_biodata_by_biodata_id');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? authToken = prefs.getString('token_key');

      // Define headers for the request
      final headers = {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json'
      };

      // Define the body with biodata ID
      final body = jsonEncode({
        'biodata_id': biodataId,
      });

      // Send POST request
      final response = await http.post(url, headers: headers, body: body);

      // Check response status
      if (response.statusCode == 200) {
        // Parse response body if the request was successful
        final responseData = jsonDecode(response.body);
        log('Copy successful: $responseData');
        return responseData;
      } else {
        // Handle errors
        log('Failed to copy biodata. Status code: ${response.statusCode}');
        log('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      // Log any exceptions
      log('Error in copyBiodataById: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> showBiodata() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? matriId = pref.getString("matri_id");

    if (matriId == null) {
      print('No matri_id found in SharedPreferences');
      return null;
    }

    final url = Uri.parse('${AppUrls.baseUrl}/api/users/showBiodataByMatriId')
        .replace(queryParameters: {'matri_id': matriId});
    // final url = Uri.parse(
    //         'http://allindiamatrimonial.com/royal_maratha/api/users/showBiodataByMatriId')
    //     .replace(queryParameters: {'matri_id': matriId});

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == false &&
            data['message'] == "Biodata record is already deleted") {
          return null; // Indicate biodata is deleted
        }

        log(response.body);
        return data;
      } else {
        log('Failed to fetch biodata: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
    return null;
  }

  // Deletes biodata from server
  static Future<Map<String, dynamic>?> deleteBiodata(String biodataId) async {
    final url = Uri.parse('${AppUrls.baseUrl}/api/users/delete')
        .replace(queryParameters: {'biodata_id': biodataId});
    // final url = Uri.parse(
    //         'http://allindiamatrimonial.com/royal_maratha/api/users/delete')
    //     .replace(queryParameters: {'biodata_id': biodataId});

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        log("Biodata Deleted Successfully");
        return jsonDecode(response.body);
      } else {
        log("Failed to delete biodata: ${response.statusCode}");
      }
    } catch (e) {
      log("Error occurred during deletion: $e");
    }
    return null;
  }

  static Future<void> getPrivacy() async {
    // Static number for privacy, in this case it's always '1'
    final url = Uri.parse('${AppUrls.baseUrl}/api/getPrivacy/1');
    // final url = Uri.parse(
    //     'http://allindiamatrimonial.com/royal_maratha/api/getPrivacy/1');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Parse the JSON response
        final jsonResponse = jsonDecode(response.body);
        print('Privacy response: $jsonResponse');
      } else {
        print('Failed to fetch privacy details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  static Future<void> postFeedback(String message) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? matriId = pref.getString("matri_id");

    if (matriId == null) {
      print("matri_id is null. Cannot send feedback.");
      return;
    }

    final url = Uri.parse('${AppUrls.baseUrl}/api/feedback');

    // final url =
    //     Uri.parse('http://allindiamatrimonial.com/royal_maratha/api/feedback');

    try {
      final response = await http.post(
        url,
        body: {
          'matri_id': matriId,
          'message': message,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        log("Feedback response: $jsonResponse");
      } else {
        log("Failed to post feedback: ${response.statusCode}");
      }
    } catch (e) {
      log("Error posting feedback: $e");
    }
  }
}
