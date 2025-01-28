//new code 2/12/2024 time 4:43

import 'dart:async';
import 'dart:developer';
import 'package:bio_data/consts/colors.dart';
import 'package:bio_data/screens/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../controller/auth_request_controller.dart';
import 'home_screen/home_page.dart';

class LoginOtpScreen extends StatefulWidget {
  const LoginOtpScreen({Key? key}) : super(key: key);

  @override
  _LoginOtpScreenState createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> with CodeAutoFill {
  final List<String> countryCodes = ['+91', '+1', '+44', '+61', '+971'];
  String selectedCountryCode = '+91';
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  final Map<String, int> countryMobileNumberLengths = {
    '+91': 10, // India
    '+1': 10, // USA/Canada
    '+44': 10, // UK
    '+61': 9, // Australia
    '+971': 9, // UAE
  };

  Timer? _timer;
  int _resendOtpTimer = 60;
  bool _canResendOtp = false;
  String _receivedOtp = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listenOtp();
  }

  @override
  void dispose() {
    mobileNumberController.dispose();
    otpController.dispose();
    _timer?.cancel();
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  var appSignatureID = SmsAutoFill().getAppSignature;

  void submit(context) async {
    if (mobileNumberController.text == "") return;

    var appSignatureID = await SmsAutoFill().getAppSignature;
    Map sendOtpData = {
      "mobile_number": mobileNumberController.text,
      "app_signature_id": appSignatureID
    };

    log(sendOtpData.toString());
    log(appSignatureID.toString());
  }

  @override
  void codeUpdated() {
    setState(() {
      _receivedOtp = code ?? ""; // Dynamically update the OTP
      otpController.text = _receivedOtp; // Auto-fill the OTP field
    });
    log("Dynamic OTP received: $_receivedOtp");
  }

  listenOtp() async {
    await SmsAutoFill()
        .unregisterListener(); // Unregister any previous listeners
    listenForCode(); // Listen for the SMS code
    log("Listening for OTP...");
  }

  void _checkLoginStatus() async {
    bool isLoggedIn =
        await Provider.of<AuthController>(context, listen: false).isLoggedIn();
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  void _startResendOtpTimer() {
    setState(() {
      _resendOtpTimer = 60;
      _canResendOtp = false; // Disable resend button
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendOtpTimer == 0) {
        timer.cancel();
        setState(() {
          _canResendOtp = true; // Enable resend button after timer ends
        });
      } else {
        setState(() {
          _resendOtpTimer--;
        });
      }
    });
  }

  void _resendOtp(String mobileNumber, String appSignatureID) async {
    if (!Provider.of<AuthController>(context, listen: false).canResendOtp) {
      // Prevent resending OTP if not allowed
      Fluttertoast.showToast(msg: "Please wait before resending OTP.");
      return;
    }

    // Disable resend functionality immediately
    setState(() {
      _canResendOtp = false;
    });

    // Attempt to resend OTP
    String? errorMsg = await Provider.of<AuthController>(context, listen: false)
        .fetchloginWithOtp(mobileNumber, appSignatureID);

    if (errorMsg != null) {
      // Show error and reset resend button state
      Fluttertoast.showToast(msg: errorMsg);
      setState(() {
        _canResendOtp = true;
      });
    } else {
      // Clear OTP field and start timer only after successful resend
      otpController.clear();
      Fluttertoast.showToast(msg: "OTP resent to $mobileNumber");
      _startResendOtpTimer();
      // Start listening for the new OTP
      await listenOtp();
    }
  }

  void _showOtpDialog(
      BuildContext context, String mobileNumber, String appSignatureID) {
    _startResendOtpTimer(); // Start the timer when the dialog opens.
    otpController.clear(); // Clear OTP input field

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Consumer<AuthController>(
          builder: (context, controller, child) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(),
              title: const Text('OTP Verification'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('We have sent a verification code to: $mobileNumber'),
                    const SizedBox(height: 20),
                    PinFieldAutoFill(
                      decoration: BoxLooseDecoration(
                        strokeColorBuilder: FixedColorBuilder(Colors.black),
                      ),
                      currentCode:
                          otpController.text, // Pre-fill OTP if available
                      codeLength: 4,
                      onCodeChanged: (code) {
                        otpController.text = code ?? ""; // Update text field
                        print("OTP updated: $code");
                      },
                      onCodeSubmitted: (code) {
                        otpController.text = code; // Keep code when submitted
                        log("onCodeSubmitted $code");
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: controller.canResendOtp
                          ? () => _resendOtp(mobileNumber, appSignatureID)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.canResendOtp
                            ? Colors.blue // Active button color
                            : Colors.grey, // Disabled button color
                      ),
                      child: Text(
                        controller.canResendOtp
                            ? 'Resend OTP'
                            : 'Resend OTP in ${controller.resendOtpTimer}s',
                        style: TextStyle(
                          color: controller.canResendOtp
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _timer?.cancel(); // Cancel timer on cancel
                            otpController.clear();
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            String otp = otpController.text.trim();
                            print("Entered OTP: $otp");

                            // Call _verifyOtp and handle its result
                            bool isVerified =
                                await _verifyOtp(mobileNumber, otp);
                            if (isVerified) {
                              if (mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomePage(),
                                  ),
                                );
                              }
                            } else {
                              Fluttertoast.showToast(msg: "Invalid OTP");
                            }
                          },
                          child: const Text(
                            'Verify',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

  Future<bool> _verifyOtp(String mobileNumber, String otp) async {
    try {
      bool isVerified =
          await Provider.of<AuthController>(context, listen: false)
              .verifyOtp(mobileNumber, otp);
      return isVerified; // Explicitly return the result
    } catch (e) {
      print("Error in OTP verification: $e");
      return false; // Handle exceptions gracefully
    }
  }

  bool _isValidMobileNumber(String mobileNumber) {
    int expectedLength = countryMobileNumberLengths[selectedCountryCode] ?? 0;
    return mobileNumber.length == expectedLength;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                size: 40,
                color: AppColors.orangeColor,
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Image.asset(
                'assets/images/ic_launcher.jpeg',
                height: 150,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Login",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    readOnly: true,
                    initialValue: "+91",
                    decoration: InputDecoration(
                      labelText: "Country Code",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.orangeColor,
                        ),
                        borderRadius:
                            BorderRadius.circular(25.0), // Responsive radius
                      ),
                    ),
                    style: TextStyle(fontSize: 14.0),
                    textAlign: TextAlign.center, // Center-align the text
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    controller: mobileNumberController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: InputDecoration(
                      labelText: "Mobile Number",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: AppColors.orangeColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Consumer<AuthController>(
              builder: (context, controller, _) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 45.h),
                  ),
                  onPressed: () async {
                    String mobileNumber = mobileNumberController.text.trim();

                    if (!_isValidMobileNumber(mobileNumber)) {
                      Fluttertoast.showToast(
                        msg:
                            "Please enter a valid mobile number for $selectedCountryCode",
                      );
                      return;
                    }

                    String? errorMsg = await controller.fetchloginWithOtp(
                        mobileNumber, appSignatureID.toString());

                    if (errorMsg == null) {
                      submit(context);
                      _showOtpDialog(
                          context, mobileNumber, appSignatureID.toString());
                    } else {
                      Fluttertoast.showToast(msg: "Please Enter Valid Number");
                    }
                  },
                  child: controller.isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          "Send OTP",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
