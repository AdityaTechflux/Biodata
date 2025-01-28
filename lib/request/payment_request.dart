import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

import '../consts/app_urls.dart';
import '../models/get_payment_model.dart'; // For logging

// class PaymentRequests {
//   static final PaymentRequests _instance = PaymentRequests._internal();
//   PaymentRequests._internal();
//   factory PaymentRequests() => _instance;

//   Future<GetPaymentModel> paymentRequest(String subscriptionId) async {
//     // Create a custom HTTP client with more lenient settings
//     final httpClient = HttpClient()
//       ..connectionTimeout = const Duration(seconds: 30)
//       ..idleTimeout = const Duration(seconds: 60)
//       ..badCertificateCallback = (cert, host, port) => true;

//     final client = IOClient(httpClient);

//     try {
//       SharedPreferences pref = await SharedPreferences.getInstance();
//       String? matriId = pref.getString("matri_id");

//       if (matriId == null) {
//         throw Exception("Matri ID not found");
//       }

//       // Try HTTPS first, fall back to HTTP if needed
//       final urls = [
//         // "https://allindiamatrimonial.com/royal_maratha/api/create_order",
//         "http://allindiamatrimonial.com/royal_maratha/api/create_order"
//       ];

//       Exception? lastError;
//       for (final urlString in urls) {
//         try {
//           final url = Uri.parse(urlString);
//           log('Attempting request to: $url');

//           final response = await client
//               .post(
//             url,
//             headers: {
//               'Content-Type': 'application/json',
//               'Accept': 'application/json',
//             },
//             body: jsonEncode({
//               'subscription_id': subscriptionId,
//               'matri_id': matriId,
//             }),
//           )
//               .timeout(
//             const Duration(seconds: 30),
//             onTimeout: () {
//               throw TimeoutException('Request timed out');
//             },
//           );

//           if (response.statusCode == 201 || response.statusCode == 200) {
//             final jsonResponse = jsonDecode(response.body);
//             return GetPaymentModel.fromJson(jsonResponse);
//           }

//           lastError = Exception('Server returned ${response.statusCode}');
//         } catch (e) {
//           lastError = Exception(e.toString());
//           log('Failed attempt with $urlString: $e');
//           continue;
//         }
//       }

//       throw lastError ?? Exception('All connection attempts failed');
//     } catch (e) {
//       log('Payment request failed: $e');
//       throw Exception('Payment request failed: $e');
//     } finally {
//       client.close();
//     }
//   }
// }

class PaymentRequests {
  static final PaymentRequests _instance = PaymentRequests._internal();
  PaymentRequests._internal();
  factory PaymentRequests() => _instance;

  Future<GetPaymentModel> paymentRequest(String subscriptionId) async {
    // NOTE: Verify this is the correct endpoint path
    final url = Uri.parse(
        "${AppUrls.baseUrl}/api/create_order"); // or whatever the correct endpoint is

    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String? matriId = pref.getString("matri_id");

      if (matriId == null) {
        throw Exception("Matri ID not found");
      }

      log('Attempting payment request:');
      log('URL: $url');
      log('Matri ID: $matriId');
      log('Subscription ID: $subscriptionId');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'subscription_id': subscriptionId,
              'matri_id': matriId,
            }),
          )
          .timeout(const Duration(seconds: 30));

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 404) {
        throw Exception(
            "API endpoint not found. Please verify the correct URL.");
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          return GetPaymentModel.fromJson(jsonResponse);
        } catch (e) {
          log('JSON parsing error: $e');
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      log('Payment request failed: $e');
      throw Exception('Payment request failed: $e');
    }
  }
}

// class PaymentRequests {
//   static final PaymentRequests _instance = PaymentRequests._internal();
//   PaymentRequests._internal();
//   factory PaymentRequests() => _instance;

//   Future<GetPaymentModel?> paymentRequest(String subscriptionId) async {
//     // Uri url = Uri.parse("${AppUrls.baseUrl}/api/create_order");
//     Uri url = Uri.parse(
//         "http://allindiamatrimonial.com/royal_maratha/api/create_order");
//     SharedPreferences pref = await SharedPreferences.getInstance();
//     String? matriId = pref.getString("matri_id");

//     var headers = {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//     };
//     var payload = {
//       'subscription_id': subscriptionId,
//       'matri_id': matriId,
//     };
//     log('Sending request to: $url');
//     log('Payload: ${jsonEncode(payload)}');
//     log('Headers: ${jsonEncode(headers)}');
//     try {
//       http.Response res =
//           await http.post(url, headers: headers, body: jsonEncode(payload));
//       if (res.statusCode == 201) {
//         log("Payment data fetched successfully", name: "PAYMENT REQUESTS API");
//         return GetPaymentModel.fromJson(
//           jsonDecode(res.body),
//         );
//       } else {
//         log("Error: ${res.statusCode} - ${res.body}",
//             name: "Payment REQUESTS API");
//         return null;
//       }
//     } catch (e) {
//       log(e.toString(), name: "Razorpay REQUESTS API");
//     }
//     return null;
//   }
// }

// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:developer'; // For logging

// class PaymentRequest {
//   // Singleton pattern
//   static final PaymentRequest _instance = PaymentRequest._internal();
//   PaymentRequest._internal();
//   factory PaymentRequest() => _instance;

//   Future<void> createOrder({
//     required String receiptId,
//     required String paymentId,
//     required String paymentMode,
//     required String planName,
//     required String planActivated,
//     required String planExpired,
//     required String planDuration,
//     required String currency,
//     required String planAmount,
//     // required String bankDetail,
//     required String transactionId,
//     required String status,
//   }) async {
//     // Get the stored matri_id from SharedPreferences
//     SharedPreferences pref = await SharedPreferences.getInstance();
//     String? matriId = pref.getString("matri_id");

//     if (matriId == null || matriId.isEmpty) {
//       log("Matri ID is missing");
//       return;
//     }

//     // Payload data for the API request
//     var payload = {
//       'matri_id': matriId,
//       // 'name': name,
//       'receipt_id': receiptId,
//       'payment_id': paymentId,
//       // 'email': email,
//       'payment_mode': paymentMode,
//       'plan_name': planName,
//       'plan_activated': planActivated,
//       'plan_expired': planExpired,
//       'plan_duration': planDuration,
//       'currency': currency,
//       'plan_amount': planAmount,
//       // 'bank_detail': bankDetail,
//       'transaction_id': transactionId,
//       'status': status,
//     };

//     // API endpoint
//     Uri url = Uri.parse(
//         'http://allindiamatrimonial.com/royal_maratha/api/create_order');

//     // Logging the request payload for debugging
//     log("Sending order creation request: $payload");

//     try {
//       // Send POST request
//       http.Response res = await http.post(
//         url,
//         body: jsonEncode(payload),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );

//       if (res.statusCode == 201) {
//         var responseData = jsonDecode(res.body);
//         log("Order creation successful: ${res.body}");
//         log("After Payment susseccfull");
//         // Handle the success response here
//       } else {
//         log("Failed to create order: ${res.statusCode}");
//         log("Error response: ${res.body}");
//       }
//     } catch (e, stacktrace) {
//       log("Exception occurred during order creation: $e");
//       log("Stacktrace: $stacktrace");
//     }
//   }
// }
