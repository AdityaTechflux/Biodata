import 'package:flutter/material.dart';
import 'dart:developer';
import '../request/home_screen_request.dart';
import '../screens/signup_form.dart';

class HomeScreenController extends ChangeNotifier {
  bool _isLoading = false;
  String _statusMessage = '';

  bool get isLoading => _isLoading;
  String get statusMessage => _statusMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setStatusMessage(String message) {
    _statusMessage = message;
    notifyListeners();
  }

  Future<void> deleteAccount(BuildContext context) async {
    _setLoading(true);

    final result = await HomeScreenRequest().deleteAccount();
    log(result["message"] ?? "No message provided");

    _setStatusMessage(result["message"] ?? "No status message available");

    if (result["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account Deleted Successfully")),
      );
      log("Account Deleted Successfully Controller");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Error deleting account")),
      );
    }

    _setLoading(false);
  }
}
