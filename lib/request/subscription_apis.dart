import 'dart:convert';
import 'dart:developer'; // For logging
import 'package:http/http.dart' as http;
import '../consts/app_urls.dart';
import '../models/subscription_api_model.dart'; // Import the model

class SubscriptionApis {
  static final SubscriptionApis _instance = SubscriptionApis._internal();
  SubscriptionApis._internal();

  factory SubscriptionApis() => _instance;

  final String _baseUrl = '${AppUrls.baseUrl}/api/all_biodata_subscriptions';

  // Method to get the subscription data
  Future<SubscriptionApiModel?> getSubscriptions() async {
    try {
      Uri url = Uri.parse(_baseUrl);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        log("API Response: ${response.body}");
        return SubscriptionApiModel.fromJson(jsonDecode(response.body));
      } else {
        log("Failed to load subscriptions. Status Code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log("Error fetching subscriptions: $e");
      return null;
    }
  }
}
