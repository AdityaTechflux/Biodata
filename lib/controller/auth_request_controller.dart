import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../request/auth_request.dart';

class AuthController extends ChangeNotifier {
  bool _isLoading = false;
  Timer? _timer; // Timer for OTP resend countdown
  int _resendOtpTimer = 60; // Duration for OTP resend timer
  bool _canResendOtp = false; // Flag for enabling resend button

  bool get isLoading => _isLoading;
  bool get canResendOtp => _canResendOtp;
  int get resendOtpTimer => _resendOtpTimer;

  Future<String?> fetchloginWithOtp(String phone, String appSignature) async {
    _isLoading = true;
    notifyListeners();

    AuthRequest authRequest = AuthRequest();
    String? errorMsg = await authRequest.loginWithOtp(phone, appSignature);

    _isLoading = false;
    notifyListeners();

    if (errorMsg == null) {
      _startResendOtpTimer();
    }

    return errorMsg;
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    _isLoading = true;
    notifyListeners();

    AuthRequest authRequest = AuthRequest();
    String result = await authRequest.verifyOtp(phone, otp);

    bool success = result == "success";

    if (success) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('phone', phone);
    }

    _isLoading = false;
    notifyListeners();

    return success;
  }

  void _startResendOtpTimer() {
    _resendOtpTimer = 60;
    _canResendOtp = false;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendOtpTimer > 0) {
        _resendOtpTimer--;
        notifyListeners();
      } else {
        _canResendOtp = true;
        notifyListeners();
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<bool> fetchForgetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    AuthRequest authRequest = AuthRequest();
    bool success = await authRequest.forgetPassword(email);

    _isLoading = false;
    notifyListeners();

    return success;
  }

  Future<bool> verifyEmailOtp(String email, String otp) async {
    _isLoading = true;
    notifyListeners();

    AuthRequest authRequest = AuthRequest();
    String result = await authRequest.verifyEmailOtp(email, otp);

    bool success = result == "success"; // Check if the result is "success"

    if (success) {
      // Save login status to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('email', email); // Optionally save the phone number
    }

    _isLoading = false;
    notifyListeners();

    return success;
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('phone');
  }

  // Reset password using email, OTP, and new password
  Future<String> fetchResetPassword(
      String email, String otp, String password, String cpassword) async {
    _isLoading = true;
    notifyListeners();

    AuthRequest authRequest = AuthRequest();
    String result =
        await authRequest.resetPassword(email, otp, password, cpassword);

    _isLoading = false;
    notifyListeners();

    return result;
  }
}
