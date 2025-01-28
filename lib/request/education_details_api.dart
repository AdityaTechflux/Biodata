import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../consts/app_urls.dart';

class EducationDetailsRequest {
  String newBiodataId = '';
  static final EducationDetailsRequest _instance =
      EducationDetailsRequest._internal();

  EducationDetailsRequest._internal();

  factory EducationDetailsRequest() => _instance;

  // Personal Details API
  Future<dynamic> personalDetailsApi(
    String title,
    String userName,
    String caste,
    String subCaste,
    String birthDate,
    String birthTime,
    String birthPlace,
    String height,
    String bloodGroup,
    String gothra,
    String complexion,
  ) async {
    // Uri url = Uri.parse(
    //     "http://allindiamatrimonial.com/royal_maratha/api/users/personal_details");
    Uri url = Uri.parse("${AppUrls.baseUrl}/api/users/personal_details");

    SharedPreferences pref = await SharedPreferences.getInstance();
    String? matriId = pref.getString("matri_id");

    var payload = {
      'title': title,
      'username': userName,
      'caste': caste,
      'subcaste': subCaste,
      'birthdate': birthDate,
      'birthtime': birthTime,
      'birthplace': birthPlace,
      'height': height,
      'blood_group': bloodGroup,
      'gothra': gothra,
      'complexion': complexion,
      'matri_id': matriId,
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

      if (res.statusCode == 200 || res.statusCode == 201) {
        var responseData = jsonDecode(res.body);
        log(responseData.toString());
        if (responseData['response'] == true) {
          newBiodataId = responseData['data']['biodata_id'].toString();
          await pref.setString("biodata_id", newBiodataId); // Save as String
          log(res.body.toString());
          log("personal Details updated successfully: ${res.statusCode}");
          log("Biodata ID saved: $newBiodataId");
          return responseData;
        } else {
          log("Error: ${responseData['error_msg']}");
        }
      } else {
        var responseData = jsonDecode(res.body);
        log("Failed: ${res.statusCode}, ${responseData['error_msg']}");
      }
    } catch (e) {
      log("Exception occurred: $e");
    }
    return null;
  }

  Future<void> addNewFieldApi({
    required Map<String, String> titlesAndValues,
  }) async {
    // Uri url = Uri.parse(
    //     "http://allindiamatrimonial.com/royal_maratha/api/users/register_bio_data_extra_field");
    Uri url =
        Uri.parse("${AppUrls.baseUrl}/api/users/register_bio_data_extra_field");

    SharedPreferences pref = await SharedPreferences.getInstance();
    String? matriId = pref.getString("matri_id");
    String? biodataId = pref.getString("biodata_id");

    log("Matri ID: $matriId, Biodata ID: $biodataId");

    if (matriId == null || biodataId == null) {
      log("Matri ID or Biodata ID is missing");
      return;
    }

    // Construct the payload dynamically
    Map<String, String> payload = {
      "biodata_id": biodataId,
    };

    int index = 1;
    titlesAndValues.forEach((key, value) {
      payload["field_${index}_title"] = key;
      payload["field_${index}_value"] = value;
      index++;
    });

    // Add Form 2, Form 3, and Form 4 predefined fields
    for (int form = 2; form <= 4; form++) {
      for (int i = 1; i <= 5; i++) {
        payload["field_${i}_title_form$form"] = "Title $i for Form $form";
        payload["field_${i}_value_form$form"] = "Value $i for Form $form";
      }
    }

    try {
      http.Response res = await http.post(
        url,
        body: payload,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        log("Details added successfully: ${res.statusCode}");
        log("Response: ${res.body}");
      } else {
        log("Failed to add details. Status Code: ${res.statusCode}");
        log("Response: ${res.body}");
      }
    } catch (e) {
      log("Exception occurred: $e");
    }
  }

  Future<bool> registerBiodataExtraField({
    required List<Map<String, String>> personalFields,
    required List<Map<String, String>> educationFields,
    required List<Map<String, String>> familyFields,
    required List<Map<String, String>> otherFields,
  }) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String? biodataId = pref.getString("biodata_id");

      log(biodataId.toString());

      if (biodataId == null) {
        log("Biodata ID is missing");
        return false;
      }

      Uri url = Uri.parse(
          '${AppUrls.baseUrl}/api/users/register_bio_data_extra_field');
      // Uri url = Uri.parse(
      //     'http://allindiamatrimonial.com/royal_maratha/api/users/register_bio_data_extra_field');

      // Build the payload as form data
      Map<String, String> payload = {
        'biodata_id': biodataId,
      };

      // Add personal fields (Form 1)
      for (int i = 0; i < personalFields.length; i++) {
        payload['field_${i + 1}_title'] = personalFields[i]['title'] ?? '';
        payload['field_${i + 1}_value'] = personalFields[i]['value'] ?? '';
      }

      // Add education fields (Form 2)
      for (int i = 0; i < educationFields.length; i++) {
        payload['field_${i + 1}_title_form2'] =
            educationFields[i]['title'] ?? '';
        payload['field_${i + 1}_value_form2'] =
            educationFields[i]['value'] ?? '';
      }

      // Add family fields (Form 3)
      for (int i = 0; i < familyFields.length; i++) {
        payload['field_${i + 1}_title_form3'] = familyFields[i]['title'] ?? '';
        payload['field_${i + 1}_value_form3'] = familyFields[i]['value'] ?? '';
      }

      // Add other fields (Form 4)
      for (int i = 0; i < otherFields.length; i++) {
        payload['field_${i + 1}_title_form4'] = otherFields[i]['title'] ?? '';
        payload['field_${i + 1}_value_form4'] = otherFields[i]['value'] ?? '';
      }

      log("Sending payload: $payload");

      final response = await http.post(
        url,
        body: payload,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
      );

      log("Response status: ${response.statusCode}");
      log("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        log(responseData.toString());
        if (responseData['status'] == true) {
          log("Extra fields registered successfully");

          return true;
        } else {
          log("Failed to register fields: ${responseData['message']}");
          return false;
        }
      } else {
        log("Failed to register extra fields. Status code: ${response.statusCode}");
        log("Response body: ${response.body}");
        return false;
      }
    } catch (e) {
      log("Error registering extra fields: $e");
      return false;
    }
  }

  Future<void> educationDetailsApi(
    String educationLevel,
    String income,
    String occupation,
    String educationDetail,
  ) async {
    Uri url = Uri.parse("${AppUrls.baseUrl}/api/users/EducationOccupation");
    // Uri url = Uri.parse(
    //     "http://allindiamatrimonial.com/royal_maratha/api/users/EducationOccupation");
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? matriId = pref.getString("matri_id");
    String? biodataId = pref.getString("biodata_id");

    log("Matri ID: $matriId, Biodata ID: $biodataId");

    // Ensure income is always treated as a string
    String incomeValue = income.trim(); // Remove leading/trailing spaces

    var payload = {
      "education_level": educationLevel,
      "education_detail": educationDetail,
      "occupation": occupation,
      "income": incomeValue, // Send income as a string
      "matri_id": matriId,
      "biodata_id": biodataId,
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
        log("Education Details updated successfully: ${res.statusCode}");
        log(res.body.toString());
      } else {
        log("Failed to update Education Details: ${res.statusCode}");
        log(res.body.toString());
      }
    } catch (e) {
      log("Exception occurred while updating Education Details: $e");
    }
  }

  Future<void> editBiodataApi({
    String? title,
    String? username,
    String? caste,
    String? subcaste,
    String? birthdate,
    String? birthtime,
    String? birthplace,
    String? height,
    String? bloodGroup,
    String? gothra,
    String? complexion,
    String? educationDetail,
    String? income,
    String? occupation,
    String? educationLevel,
    String? property,
    String? expectations,
    String? fatherName,
    String? motherName,
    String? fatherOccupation,
    String? motherOccupation,
    String? address,
    String? noOfBrothers,
    String? noOfSisters,
    String? mobile,
    String? mamaSurname,
    String? surnameOfRelatives,
    String? familyNativePlace,
    required String biodataId,
    File? photo1,
    File? photo2,
    List<Map<String, String>>? personalFields,
    List<Map<String, String>>? educationFields,
    List<Map<String, String>>? familyFields,
    List<Map<String, String>>? otherFields,
  }) async {
    Uri url = Uri.parse("${AppUrls.baseUrl}/api/EditBiodata");
    // Uri url = Uri.parse(
    //     "http://allindiamatrimonial.com/royal_maratha/api/EditBiodata");

    SharedPreferences pref = await SharedPreferences.getInstance();
    String? matriId = pref.getString("matri_id");
    log("Matri Id: $matriId");

    var request = http.MultipartRequest('POST', url);

    // Add non-null fields only
    var fields = {
      "title": title,
      "username": username,
      "caste": caste,
      "subcaste": subcaste,
      "birthdate": birthdate,
      "birthtime": birthtime,
      "birthplace": birthplace,
      "height": height,
      "blood_group": bloodGroup,
      "gothra": gothra,
      "complexion": complexion,
      "education_detail": educationDetail,
      "income": income,
      "occupation": occupation,
      "education_level": educationLevel,
      "property": property,
      "expectations": expectations,
      "father_name": fatherName,
      "mother_name": motherName,
      "father_occupation": fatherOccupation,
      "mother_occupation": motherOccupation,
      "address": address,
      "no_of_brothers": noOfBrothers,
      "no_of_sisters": noOfSisters,
      "mobile": mobile,
      "mama_surname": mamaSurname,
      "surname_of_relatives": surnameOfRelatives,
      "family_native_place": familyNativePlace,
      "matri_id": matriId,
      "biodata_id": biodataId,
    };

    // Add only non-null fields to request
    fields.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value;
      }
    });

    // Add dynamic personal fields if provided
    if (personalFields != null) {
      for (int i = 0; i < personalFields.length; i++) {
        if (personalFields[i]['title'] != null) {
          request.fields["field_${i + 1}_title"] = personalFields[i]['title']!;
        }
        if (personalFields[i]['value'] != null) {
          request.fields["field_${i + 1}_value"] = personalFields[i]['value']!;
        }
      }
    }

    // Add dynamic education fields if provided
    if (educationFields != null) {
      for (int i = 0; i < educationFields.length; i++) {
        if (educationFields[i]['title'] != null) {
          request.fields["field_${i + 1}_title_form2"] =
              educationFields[i]['title']!;
        }
        if (educationFields[i]['value'] != null) {
          request.fields["field_${i + 1}_value_form2"] =
              educationFields[i]['value']!;
        }
      }
    }

    // Add dynamic family fields if provided
    if (familyFields != null) {
      for (int i = 0; i < familyFields.length; i++) {
        if (familyFields[i]['title'] != null) {
          request.fields["field_${i + 1}_title_form3"] =
              familyFields[i]['title']!;
        }
        if (familyFields[i]['value'] != null) {
          request.fields["field_${i + 1}_value_form3"] =
              familyFields[i]['value']!;
        }
      }
    }

    // Add dynamic other fields if provided
    if (otherFields != null) {
      for (int i = 0; i < otherFields.length; i++) {
        if (otherFields[i]['title'] != null) {
          request.fields["field_${i + 1}_title_form4"] =
              otherFields[i]['title']!;
        }
        if (otherFields[i]['value'] != null) {
          request.fields["field_${i + 1}_value_form4"] =
              otherFields[i]['value']!;
        }
      }
    }

    // Add photos if provided
    if (photo1 != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'photo1',
        photo1.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    if (photo2 != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'photo2',
        photo2.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    try {
      var response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        log("Biodata updated successfully: ${response.statusCode}");
        log(responseBody);
        return;
      } else {
        log("Failed to update Biodata: ${response.statusCode}");
        log(responseBody);
        throw Exception("Failed to update biodata: ${response.statusCode}");
      }
    } catch (e) {
      log("Exception occurred while updating Biodata: $e");
      throw e;
    }
  }

  // Upload Profile Image1 API
  Future<void> uploadProfileImageApi1(File imageFile) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? matriId = pref.getString("matri_id");
    String? biodataId = pref.getString("biodata_id");

    // Debugging logs
    log("Matri ID: $matriId");
    log("Biodata ID: $biodataId");

    if (matriId == null || matriId.isEmpty) {
      log("Matri ID is missing or empty");
      return;
    }

    if (biodataId == null || biodataId.isEmpty) {
      log("Biodata ID is missing or empty");
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${AppUrls.baseUrl}/api/users/insertImage"),
      // Uri.parse(
      //     "http://allindiamatrimonial.com/royal_maratha/api/users/insertImage"),
    );

    request.fields['biodata_id'] = biodataId; // Correct biodata ID
    request.fields['matri_id'] = matriId;
    request.files
        .add(await http.MultipartFile.fromPath('photo1', imageFile.path));

    try {
      var res = await request.send();
      var responseData = await http.Response.fromStream(res);

      if (res.statusCode == 200) {
        var responseJson = jsonDecode(responseData.body);
        log("Image1 upload response: $responseJson");
        log(res.toString());

        if (responseJson['response'] == true) {
          log("Image1 uploaded successfully.");
        } else {
          log("Error uploading image1: ${responseJson['error_msg']}");
        }
      } else {
        log("Failed to upload image1: ${res.statusCode}");
      }
    } catch (e) {
      log("Image1 upload error: $e");
    }
  }

  Future<void> uploadProfileImageApi2(File imageFile) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? matriId = pref.getString("matri_id");
    String? biodataId = pref.getString("biodata_id");

    // Debugging logs
    log("Matri ID: $matriId");
    log("Biodata ID: $biodataId");

    if (matriId == null || matriId.isEmpty) {
      log("Matri ID is missing or empty");
      return;
    }

    if (biodataId == null || biodataId.isEmpty) {
      log("Biodata ID is missing or empty");
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${AppUrls.baseUrl}/api/users/insertImage2"),
      // Uri.parse(
      //     "http://allindiamatrimonial.com/royal_maratha/api/users/insertImage2"),
    );

    request.fields['biodata_id'] = biodataId; // Correct biodata ID
    request.fields['matri_id'] = matriId;
    request.files
        .add(await http.MultipartFile.fromPath('photo2', imageFile.path));

    try {
      var res = await request.send();
      var responseData = await http.Response.fromStream(res);

      if (res.statusCode == 200) {
        var responseJson = jsonDecode(responseData.body);
        log("Image2 upload response: $responseJson");
        log(res.toString());
        if (responseJson['response'] == true) {
          log("Image2 uploaded successfully.");
        } else {
          log("Error uploading image2: ${responseJson['error_msg']}");
        }
      } else {
        log("Failed to upload image2: ${res.statusCode}");
      }
    } catch (e) {
      log("Image2 upload error: $e");
    }
  }

  // Family Details API
  Future<void> familyDetailsApi(
      String fathersName,
      String fatherOccupation,
      String mothersName,
      String mothersOccupation,
      String mobileNumber,
      String totalBrothers,
      String totalSisters,
      String residentialAddress,
      String maternalUncle,
      String nativePlace,
      String surnameRelatives) async {
    Uri url = Uri.parse("${AppUrls.baseUrl}/api/users/FamilyDetails");
    // Uri url = Uri.parse(
    //     "http://allindiamatrimonial.com/royal_maratha/api/users/FamilyDetails");
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? matriId = pref.getString("matri_id");
    String? biodataId = pref.getString("biodata_id"); // Retrieve as String

    log("Matri ID: $matriId, Biodata ID: $biodataId");

    var payload = {
      "father_name": fathersName,
      "mother_name": mothersName,
      "father_occupation": fatherOccupation,
      "mother_occupation": mothersOccupation,
      "address": residentialAddress,
      "no_of_brothers": totalBrothers,
      "no_of_sisters": totalSisters,
      "mobile": mobileNumber,
      "mama_surname": maternalUncle,
      "surname_of_relatives": surnameRelatives,
      "family_native_place": nativePlace,
      "biodata_id": biodataId,
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
        log("Family Details updated successfully: ${res.statusCode}");
        log(res.body.toString());
      } else {
        log("Failed to update Family Details: ${res.statusCode}");
      }
    } catch (e) {
      log("Exception occurred while updating Family Details: $e");
    }
  }

  // Other Details API
  Future<void> otherDetailsApi(String property, String expectation) async {
    Uri url = Uri.parse("${AppUrls.baseUrl}/api/users/OtherDetails");
    // Uri url = Uri.parse(
    //     "http://allindiamatrimonial.com/royal_maratha/api/users/OtherDetails");
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? matriId = pref.getString("matri_id");
    String? biodataId = pref.getString("biodata_id"); // Retrieve as String

    log("Matri ID: $matriId, Biodata ID: $biodataId");

    var payload = {
      "property": property,
      "expectations": expectation,
      "matri_id": matriId,
      "biodata_id": biodataId,
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
        log("Other Details updated successfully: ${res.statusCode}");
        log(res.body.toString());
      } else {
        log("Failed to update Other Details: ${res.statusCode}");
      }
    } catch (e) {
      log("Exception occurred while updating Other Details: $e");
    }
  }
}
