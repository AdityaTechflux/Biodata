import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import '../consts/app_urls.dart';
import '../models/dummy_sample_model.dart';
import 'package:http/http.dart' as http;

import '../models/get_personal_details_api.dart';

class HomeScreenApis {
  static final HomeScreenApis _instance = HomeScreenApis._internal();

  HomeScreenApis._internal();

  factory HomeScreenApis() => _instance;

  Future<DummySampleModel?> addDummySampleApi() async {
    Uri url = Uri.parse("${AppUrls.baseUrl}/api/users/create_sample_template");
    // Uri url = Uri.parse(
    //     "http://allindiamatrimonial.com/royal_maratha/api/users/create_sample_template");

    SharedPreferences pref = await SharedPreferences.getInstance();
    String? matriId = pref.getString("matri_id");

    var payload = {
      "matri_id": matriId,
    };

    try {
      http.Response res = await http.post(
        url,
        body: jsonEncode(payload),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        log("Dummy sample created successfully: ${res.statusCode}");
        log(res.body.toString());
        return DummySampleModel.fromJson(jsonDecode(res.body));
      } else {
        log("Failed to create dummy sample: ${res.statusCode}");
        return null;
      }
    } catch (e, t) {
      log("Exception occurred while creating dummy sample: $e");
      log("Stacktrace: $t");
      return null;
    }
  }

  Future<bool> deleteSampleApi(String id) async {
    Uri url = Uri.parse(
        "http://allindiamatrimonial.com/royal_maratha/api/users/delete_sample_template?id=$id");

    try {
      http.Response res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        log("Sample deleted successfully: ${res.statusCode}");
        return true;
      } else {
        log("Failed to delete sample: ${res.statusCode}");
        return false;
      }
    } catch (e, t) {
      log("Exception occurred while deleting sample: $e");
      log("Stacktrace: $t");
      return false;
    }
  }

  // New Copy Sample API
  Future<bool> copySampleApi(String id) async {
    Uri url = Uri.parse(
        "http://allindiamatrimonial.com/royal_maratha/api/users/copy_sample_template");

    // Payload with the sample id to be copied
    var payload = {
      "id": id,
    };

    try {
      http.Response res = await http.post(
        url,
        body: jsonEncode(payload),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        log("Sample copied successfully: ${res.statusCode}");
        log(res.body.toString());
        return true;
      } else {
        log("Failed to copy sample: ${res.statusCode}");
        return false;
      }
    } catch (e, t) {
      log("Exception occurred while copying sample: $e");
      log("Stacktrace: $t");
      return false;
    }
  }

  Future<GetPersonalDetailsApi?> getPersonal() async {
    Uri url = Uri.parse(
        "http://allindiamatrimonial.com/royal_maratha/api/users/get_all_personal_details");

    try {
      // Send GET request to fetch personal details
      http.Response res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        // Parse the JSON response
        var jsonResponse = jsonDecode(res.body);
        log("API Response: $jsonResponse");

        // Return the parsed data in GetPersonalDetailsApi model
        return GetPersonalDetailsApi.fromJson(jsonResponse);
      } else {
        log("Failed to get personal details: ${res.statusCode}");
        return null;
      }
    } catch (e, t) {
      log("Exception occurred while fetching personal details: $e");
      log("Stacktrace: $t");
      return null;
    }
  }
}
