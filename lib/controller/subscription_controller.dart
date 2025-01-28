import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:developer';
import '../models/get_payment_model.dart';
import '../request/payment_request.dart';
import '../request/subscription_apis.dart';
import '../models/subscription_api_model.dart';

class SubscriptionController extends ChangeNotifier {
  bool isLoading = false;
  bool isPaymentProcessing = false;
  SubscriptionApiModel? subscriptionData;
  GetPaymentModel? paymentData;
  String selectedPlanName = '';
  int selectedAmount = 0;
  String? error;

  Function(PaymentSuccessResponse)? onPaymentSuccess;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setPaymentProcessing(bool value) {
    isPaymentProcessing = value;
    notifyListeners();
  }

  Future<void> fetchSubscriptions() async {
    if (isLoading) return;

    setLoading(true);
    try {
      final response = await SubscriptionApis().getSubscriptions();

      if (response != null && response.response == true) {
        subscriptionData = response;
        log("Fetched ${response.data?.length ?? 0} subscription plans.");
      } else {
        error = "Failed to fetch subscriptions";
        log("Failed to fetch subscriptions or no data returned.");
        throw Exception("Failed to fetch subscriptions");
      }
    } catch (e) {
      error = e.toString();
      log("Error while fetching subscriptions: $e");
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<GetPaymentModel?> getPaymentDetails(String subscriptionId) async {
    if (isPaymentProcessing) return null;

    setPaymentProcessing(true);
    error = null;

    try {
      // Add timeout to the request
      paymentData =
          await PaymentRequests().paymentRequest(subscriptionId).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out after 30 seconds');
        },
      );

      if (paymentData != null && paymentData?.order != null) {
        return paymentData;
      } else {
        error = "Invalid payment data received from server";
        throw Exception("Invalid payment data received from server");
      }
    } catch (e) {
      error = e.toString();
      log("Error getting payment details: $e");
      rethrow;
    } finally {
      setPaymentProcessing(false);
      notifyListeners();
    }
  }
}
