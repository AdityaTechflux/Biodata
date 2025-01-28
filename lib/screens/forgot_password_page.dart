import 'dart:async';
import 'package:bio_data/screens/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
// import 'package:pinput/pinput.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import the fluttertoast package
import 'package:rxdart/rxdart.dart'; // Import rxdart

import '../controller/auth_request_controller.dart';
import 'login_form.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Timer? _resendTimer;
  final BehaviorSubject<int> _resendTimerController =
      BehaviorSubject<int>(); // Change to BehaviorSubject
  int _initialSeconds = 120; // Timer starting value
  bool _isResendButtonEnabled = false;

  @override
  void dispose() {
    _emailController.dispose();
    otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _resendTimer?.cancel(); // Cancel the timer if it's running
    _resendTimerController.close(); // Close the stream controller
    super.dispose();
  }

  // Toast message function
  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.sp,
    );
  }

  final AuthController authController = AuthController();

  void _submitForgotPassword(BuildContext context) async {
    String email = _emailController.text.trim();

    // Access AuthController via Provider
    final authController = Provider.of<AuthController>(context, listen: false);
    bool success = await authController.fetchForgetPassword(email);

    if (success) {
      _showOtpDialog(context, email); // Show OTP dialog
    } else {
      Fluttertoast.showToast(
        msg: "Email is Invalid",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _startResendTimer() {
    _isResendButtonEnabled = false; // Disable the resend button
    _resendTimerController.sink.add(_initialSeconds); // Emit initial time

    _resendTimer?.cancel(); // Cancel any existing timer

    _resendTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        _initialSeconds--;
        _resendTimerController.sink.add(_initialSeconds); // Emit updated time

        if (_initialSeconds <= 0) {
          // When timer reaches zero
          _isResendButtonEnabled = true;
          _resendTimerController.sink.add(-1); // Indicate timer end
          timer.cancel(); // Stop the timer
        }
      },
    );
  }

  void _resetTimer() {
    _resendTimer?.cancel(); // Stop any active timer
    _initialSeconds = 120; // Reset the timer to its initial value
  }

  void _showOtpDialog(BuildContext parentContext, String email) {
    otpController.clear();
    final authController =
        Provider.of<AuthController>(parentContext, listen: false);
    _resetTimer(); // Ensure timer starts fresh
    _startResendTimer(); // Start the timer

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              // borderRadius: BorderRadius.circular(20.0),
              ),
          title: const Text('OTP Verification'),
          content: SingleChildScrollView(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('We have sent a verification code to: $email'),
                  const SizedBox(height: 20),
                  Pinput(
                    controller: otpController,
                    length: 4,
                    defaultPinTheme: PinTheme(
                      width: 56,
                      height: 56,
                      textStyle: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  StreamBuilder<int>(
                    stream: _resendTimerController.stream,
                    builder: (context, snapshot) {
                      String buttonText;
                      if (_isResendButtonEnabled) {
                        buttonText = 'Resend OTP';
                      } else if (snapshot.data != null && snapshot.data! > 0) {
                        buttonText = 'Resend OTP in ${snapshot.data} seconds';
                      } else {
                        buttonText = 'You can resend the OTP now.';
                      }
                      return ElevatedButton(
                        onPressed: _isResendButtonEnabled
                            ? () async {
                                bool result = await authController
                                    .fetchForgetPassword(email);
                                if (result) {
                                  Fluttertoast.showToast(
                                    msg: 'OTP re-sent successfully!',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                  );
                                  _resetTimer(); // Reset the timer before restarting
                                  _startResendTimer();
                                } else {
                                  Fluttertoast.showToast(
                                    msg: 'Error sending OTP',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                  );
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isResendButtonEnabled
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        child: Text(
                          buttonText,
                          style: TextStyle(
                            color: _isResendButtonEnabled
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          otpController.clear();
                          Navigator.of(context).pop();
                          _resetTimer(); // Stop and reset the timer on cancel
                        },
                        child: Text('Cancel',
                            style: TextStyle(
                                color: AppTheme.primaryColor, fontSize: 18)),
                      ),
                      TextButton(
                        onPressed: () async {
                          String otp = otpController.text.trim();
                          bool isVerified =
                              await authController.verifyEmailOtp(email, otp);
                          if (isVerified) {
                            Fluttertoast.showToast(
                              msg: 'OTP verified successfully!',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                            Navigator.of(context).pop();
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              _showResetPasswordDialog(context, email, otp);
                            });
                          } else {
                            Fluttertoast.showToast(
                              msg: 'Invalid OTP. Please try again.',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                          }
                        },
                        child: Text('Verify',
                            style: TextStyle(
                                color: AppTheme.primaryColor, fontSize: 18)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showResetPasswordDialog(
      BuildContext context, String email, String otp) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final TextEditingController newPasswordController =
            TextEditingController();
        final TextEditingController confirmPasswordController =
            TextEditingController();
        bool isNewPasswordVisible = false;
        bool isConfirmPasswordVisible = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  // borderRadius: BorderRadius.circular(20.0),
                  ),
              child: Container(
                constraints:
                    const BoxConstraints(maxWidth: 400, maxHeight: 400),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: !isNewPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(isNewPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              isNewPasswordVisible = !isNewPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: !isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              isConfirmPasswordVisible =
                                  !isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: () async {
                            String newPassword =
                                newPasswordController.text.trim();
                            String confirmPassword =
                                confirmPasswordController.text.trim();
                            AuthController authController =
                                Provider.of<AuthController>(context,
                                    listen: false);

                            String result =
                                await authController.fetchResetPassword(
                                    email, otp, newPassword, confirmPassword);

                            if (result == 'success') {
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   const SnackBar(
                              //       content:
                              //           Text('Password reset successful!')),
                              // );
                              // Fluttertoast.showToast(
                              //     msg: "Password reset successful!");
                              Fluttertoast.showToast(
                                msg: 'Password reset successful!',
                                toastLength: Toast.LENGTH_LONG,
                                textColor: Colors.white,
                                backgroundColor: Colors.green,
                              );
                              Navigator.of(context).pop();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        LoginForm(onLoginSuccess: () {})),
                              );
                            } else {
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   SnackBar(
                              //     content: Text(
                              //         "New Password and Confirm Password Dont Match"),
                              //   ),
                              // );
                              // Fluttertoast.showToast(
                              //   msg:
                              //       "New Password and Confirm Password Dont Match",
                              // );
                              Fluttertoast.showToast(
                                msg:
                                    'The New Password and Confirm Password Dont Match',
                                toastLength: Toast.LENGTH_LONG,
                                textColor: Colors.white,
                                backgroundColor: Colors.red,
                              );
                            }
                          },
                          child: const Text('Reset Password'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(375, 812), minTextAdapt: true);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 80.h),
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/ic_launcher.jpeg',
                      height: 180.h,
                      width: 180.w,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.h),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Registered Email',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(23.r)),
                ),
              ),
              SizedBox(height: 20.h),
              Consumer<AuthController>(
                builder: (context, authController, child) {
                  return ElevatedButton(
                    onPressed: authController.isLoading
                        ? null
                        : () => _submitForgotPassword(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5507),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      minimumSize: const Size(double.infinity, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(23.r),
                      ),
                    ),
                    child: authController.isLoading
                        ? SizedBox(
                            height: 24.0,
                            width: 24.0,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3.0,
                            ),
                          )
                        : Text(
                            'OTP in EMail', // Text when not loading
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.white,
                            ),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
