// import 'dart:developer';
// import 'package:bio_data/consts/app_urls.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import 'package:shared_preferences/shared_preferences.dart';

// class AuthRequest {
// static final AuthRequest _instance = AuthRequest._internal();

// AuthRequest._internal();

// factory AuthRequest() => _instance;

//   Future<String?> loginWithOtp(String phone, String appSignature) async {
//     try {
//       const String apiUrl =
//           'http://allindiamatrimonial.com/royal_maratha/api/loginWithOtp';

//       log("Requesting OTP for phone: $phone");

//       final response = await http.post(
//         Uri.parse(apiUrl),
//         body: json.encode({
//           'phone': phone,
//           'signature': appSignature,
//         }),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);

//         if (!data["response"]) {
//           return data["error_msg"];
//         }

//         return null; // OTP sent successfully, no error message
//       }

//       return "Unexpected response: ${response.statusCode}";
//     } catch (e) {
//       return "An error occurred: $e";
//     }
//   }

//   Future<String> verifyOtp(
//     String phone,
//     String otp,
//   ) async {
//     try {
//       const String apiUrl =
//           'http://allindiamatrimonial.com/royal_maratha/api/verifyLoginOtp';

//       log("Verifying OTP for phone: $phone");

//       final response = await http.post(
//         Uri.parse(apiUrl),
//         body: json.encode({
//           'phone': phone,
//           'otp': otp,
//         }),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         var responseData = jsonDecode(response.body);

//         if (responseData['response']) {
//           // Extracting the token and matri_id from response
//           var token = responseData['data']['token'];
//           var matriId = responseData['data']['matri_id'];
//           var mobileNumber = phone;

//           // Storing data in SharedPreferences
//           final SharedPreferences prefs = await SharedPreferences.getInstance();

//           // Storing data using specific keys
//           await prefs.setString('matri_id', matriId);
//           await prefs.setString('token_key', token);
//           await prefs.setString('phone', mobileNumber);

//           log("Stored phone: ${prefs.getString('phone')}");
//           log("Stored matri_id: ${prefs.getString('matri_id')}");
//           log("Stored token_key: ${prefs.getString('token_key')}");

//           return "success";
//         } else {
//           return responseData['error_msg'] ?? "OTP verification failed";
//         }
//       } else {
//         return "Server error: ${response.statusCode}";
//       }
//     } catch (e) {
//       return "Error occurred: $e";
//     }
//   }

//   Future<bool> forgetPassword(String email) async {
//     try {
//       const String apiUrl =
//           'http://allindiamatrimonial.com/royal_maratha/api/forgotPassword';

//       final response = await http.post(
//         Uri.parse(apiUrl),
//         body: {
//           'email': email,
//         },
//       );

//       if (response.statusCode == 200) {
//         // Parse the response
//         var data = jsonDecode(response.body);

//         // Handle specific response for email not found
//         if (data["res_code"] == "404" && data["message"] == "Email not found") {
//           log("Email not found in system.");
//           return false; // Indicate email does not exist or account is deleted
//         }

//         // Handle successful request if response is not an error
//         return data["otp"] != null && data["otp"] != "";
//       } else {
//         // Unexpected response status code
//         log("Unexpected response status: ${response.statusCode}");
//         return false; // OTP request failed
//       }
//     } catch (e) {
//       log("Error occurred: $e");
//       return false; // Return false on error
//     }
//   }

//   Future<String> verifyEmailOtp(String email, String otp) async {
//     try {
//       const String apiUrl =
//           'http://allindiamatrimonial.com/royal_maratha/api/verifyOtp';

//       final response = await http.post(
//         Uri.parse(apiUrl),
//         body: {
//           'email': email,
//           'otp': otp,
//         },
//       );

//       if (response.statusCode == 200) {
//         log("VERIFY OTP SUCCESSFULLY");

//         // Parse the response body
//         var responseData = jsonDecode(response.body);

//         // Check if OTP verification was successful
//         if (responseData['response'] == true) {
//           log("OTP verified successfully");
//           return "success"; // Return success
//         } else {
//           // OTP verification failed, return error message
//           log("VERIFY OTP FAILED: ${responseData['error_msg']}");
//           return responseData['error_msg'] ?? "OTP verification failed";
//         }
//       } else {
//         log("Server Error: ${response.statusCode}");
//         return "Server error: ${response.statusCode}"; // Server-side error
//       }
//     } catch (e) {
//       print("Error occurred: $e");
//       return "Error occurred: $e"; // Return error
//     }
//   }

//   Future<String> resetPassword(
//       String email, String otp, String password, String cpassword) async {
//     try {
//       const String apiUrl =
//           'http://allindiamatrimonial.com/royal_maratha/api/resetPassword';

//       final response = await http.post(
//         Uri.parse(apiUrl),
//         body: {
//           'email': email,
//           'otp': otp,
//           'password': password,
//           'cpassword': cpassword,
//         },
//       );

//       if (response.statusCode == 200) {
//         log("RESET PASSWORD SUCCESSFULLY");

//         // Parse the response body
//         var responseData = jsonDecode(response.body);

//         // Check if the reset was successful
//         if (responseData['response'] == true) {
//           log("Password reset successfully");
//           return "success"; // Return success
//         } else {
//           // Reset failed, return error message
//           log("RESET PASSWORD FAILED: ${responseData['error_msg']}");
//           return responseData['error_msg'] ?? "Password reset failed";
//         }
//       } else {
//         log("Server Error: ${response.statusCode}");
//         return "Server error: ${response.statusCode}"; // Server-side error
//       }
//     } catch (e) {
//       print("Error occurred: $e");
//       return "Error occurred: $e"; // Return error
//     }
//   }
// }

import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bio_data/consts/app_urls.dart';

class AuthRequest {
  static final AuthRequest _instance = AuthRequest._internal();

  AuthRequest._internal() {
    dev.log('AuthRequest singleton initialized', name: 'Auth');
  }

  factory AuthRequest() {
    dev.log('Getting AuthRequest instance', name: 'Auth');
    return _instance;
  }

  Future<String?> loginWithOtp(String phone, String appSignature) async {
    dev.log('Starting loginWithOtp', name: 'Auth');
    dev.log('Phone: $phone', name: 'Auth');

    try {
      final response = await http.post(
        Uri.parse('${AppUrls.baseUrl}/api/loginWithOtp'),
        body: json.encode({
          'phone': phone,
          'signature': appSignature,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      dev.log('Response status: ${response.statusCode}', name: 'Auth');
      dev.log('Response body: ${response.body}', name: 'Auth');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (!data["response"]) {
          dev.log('Login failed: ${data["error_msg"]}', name: 'Auth');
          return data["error_msg"];
        }

        dev.log('OTP sent successfully', name: 'Auth');
        return null;
      }

      dev.log('Unexpected response: ${response.statusCode}', name: 'Auth');
      return "Unexpected response: ${response.statusCode}";
    } catch (e, stackTrace) {
      dev.log('Error in loginWithOtp',
          error: e, stackTrace: stackTrace, name: 'Auth');
      return "An error occurred: $e";
    }
  }

  Future<String> verifyOtp(String phone, String otp) async {
    dev.log('Starting verifyOtp', name: 'Auth');
    dev.log('Phone: $phone, OTP: $otp', name: 'Auth');

    try {
      final response = await http.post(
        Uri.parse('${AppUrls.baseUrl}/api/verifyLoginOtp'),
        body: json.encode({
          'phone': phone,
          'otp': otp,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      dev.log('Response status: ${response.statusCode}', name: 'Auth');
      dev.log('Response body: ${response.body}', name: 'Auth');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData['response']) {
          await _saveUserData(responseData['data']['token'],
              responseData['data']['matri_id'], phone);
          dev.log('OTP verification successful', name: 'Auth');
          return "success";
        } else {
          dev.log('OTP verification failed: ${responseData['error_msg']}',
              name: 'Auth');
          return responseData['error_msg'] ?? "OTP verification failed";
        }
      }

      dev.log('Server error: ${response.statusCode}', name: 'Auth');
      return "Server error: ${response.statusCode}";
    } catch (e, stackTrace) {
      dev.log('Error in verifyOtp',
          error: e, stackTrace: stackTrace, name: 'Auth');
      return "Error occurred: $e";
    }
  }

  Future<bool> forgetPassword(String email) async {
    dev.log('Starting forgetPassword', name: 'Auth');
    dev.log('Email: $email', name: 'Auth');

    try {
      final response = await http.post(
        Uri.parse('${AppUrls.baseUrl}/api/forgotPassword'),
        body: {
          'email': email,
        },
      );

      dev.log('Response status: ${response.statusCode}', name: 'Auth');
      dev.log('Response body: ${response.body}', name: 'Auth');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data["res_code"] == "404" && data["message"] == "Email not found") {
          dev.log('Email not found in system', name: 'Auth');
          return false;
        }

        bool success = data["otp"] != null && data["otp"] != "";
        dev.log('Forget password request: ${success ? 'successful' : 'failed'}',
            name: 'Auth');
        return success;
      }

      dev.log('Unexpected status: ${response.statusCode}', name: 'Auth');
      return false;
    } catch (e, stackTrace) {
      dev.log('Error in forgetPassword',
          error: e, stackTrace: stackTrace, name: 'Auth');
      return false;
    }
  }

  Future<String> verifyEmailOtp(String email, String otp) async {
    dev.log('Starting verifyEmailOtp', name: 'Auth');
    dev.log('Email: $email, OTP: $otp', name: 'Auth');

    try {
      final response = await http.post(
        Uri.parse('${AppUrls.baseUrl}/api/verifyOtp'),
        body: {
          'email': email,
          'otp': otp,
        },
      );

      dev.log('Response status: ${response.statusCode}', name: 'Auth');
      dev.log('Response body: ${response.body}', name: 'Auth');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData['response'] == true) {
          dev.log('Email OTP verified successfully', name: 'Auth');
          return "success";
        } else {
          String errorMsg =
              responseData['error_msg'] ?? "OTP verification failed";
          dev.log('Email OTP verification failed: $errorMsg', name: 'Auth');
          return errorMsg;
        }
      }

      dev.log('Server error: ${response.statusCode}', name: 'Auth');
      return "Server error: ${response.statusCode}";
    } catch (e, stackTrace) {
      dev.log('Error in verifyEmailOtp',
          error: e, stackTrace: stackTrace, name: 'Auth');
      return "Error occurred: $e";
    }
  }

  Future<String> resetPassword(
      String email, String otp, String password, String cpassword) async {
    dev.log('Starting resetPassword', name: 'Auth');
    dev.log('Email: $email', name: 'Auth');

    try {
      final response = await http.post(
        Uri.parse('${AppUrls.baseUrl}/api/resetPassword'),
        body: {
          'email': email,
          'otp': otp,
          'password': password,
          'cpassword': cpassword,
        },
      );

      dev.log('Response status: ${response.statusCode}', name: 'Auth');
      dev.log('Response body: ${response.body}', name: 'Auth');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData['response'] == true) {
          dev.log('Password reset successful', name: 'Auth');
          return "success";
        } else {
          String errorMsg =
              responseData['error_msg'] ?? "Password reset failed";
          dev.log('Password reset failed: $errorMsg', name: 'Auth');
          return errorMsg;
        }
      }

      dev.log('Server error: ${response.statusCode}', name: 'Auth');
      return "Server error: ${response.statusCode}";
    } catch (e, stackTrace) {
      dev.log('Error in resetPassword',
          error: e, stackTrace: stackTrace, name: 'Auth');
      return "Error occurred: $e";
    }
  }

  Future<void> _saveUserData(String token, String matriId, String phone) async {
    dev.log('Saving user data', name: 'Auth');

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('matri_id', matriId);
      await prefs.setString('token_key', token);
      await prefs.setString('phone', phone);

      dev.log('Saved - Phone: $phone, Matri ID: $matriId', name: 'Auth');
      dev.log('Token saved successfully', name: 'Auth');
    } catch (e, stackTrace) {
      dev.log('Error saving user data',
          error: e, stackTrace: stackTrace, name: 'Auth');
      throw e;
    }
  }
}
