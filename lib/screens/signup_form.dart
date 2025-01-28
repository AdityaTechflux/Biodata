import 'dart:developer';
import 'dart:io';
import 'package:bio_data/screens/login_form.dart';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../consts/app_urls.dart';
import 'TermsAndConditionsPage.dart';
import 'home_screen/home_page.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  int? _mobileNumber; // Change to int
  String? _email, _password;
  final String _verify = "Verify";
  bool _isLoading = false;

  final List<String> countryCodes = ['+91', '+1', '+44', '+61', '+971'];
  String selectedCountryCode = '+91';

  // Country-specific mobile number lengths
  final Map<String, int> countryMobileNumberLengths = {
    '+91': 10, // India
    '+1': 10, // USA/Canada
    '+44': 10, // UK
    '+61': 9, // Australia
    '+971': 9, // UAE
  };

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(),
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text("Okay"),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  // Future<void> _registerUser() async {
  //   if (_formKey.currentState!.validate()) {
  //     _formKey.currentState!.save();

  //     setState(() {
  //       _isLoading = true;
  //     });

  //     final dio = Dio();
  //     const String apiUrl = "${AppUrls.baseUrl}/api/register";
  //     // const String apiUrl =
  //     //     "http://allindiamatrimonial.com/royal_maratha/api/register";

  //     try {
  //       final response = await dio.post(
  //         apiUrl,
  //         data: {
  //           "phone": _mobileNumber.toString(),
  //           "email": _email,
  //           "password": _password,
  //           "cpass_status": _verify,
  //         },
  //         options: Options(
  //           headers: {
  //             'Content-Type': 'application/json; charset=UTF-8',
  //           },
  //           validateStatus: (status) => true,
  //         ),
  //       );

  //       if (response.statusCode == 200) {
  //         final responseData = response.data;
  //         log(responseData.toString());

  //         if (responseData["response"] == true) {
  //           var matriId = responseData["data"]["matri_id"];
  //           var token = responseData["data"]["token"];
  //           var mobileNumber = _mobileNumber.toString();
  //           var emailAddress = _email;

  //           final SharedPreferences prefs =
  //               await SharedPreferences.getInstance();

  //           // Use the same key names as in the deleteAccount logic
  //           await prefs.setString('matri_id', matriId); // Correct key
  //           await prefs.setString('token_key', token); // Use 'token_key' here
  //           await prefs.setString('phone', mobileNumber);
  //           await prefs.setString('email', emailAddress.toString());

  //           log("Stored phone: ${prefs.getString('phone')}");
  //           log("Stored matri_id: ${prefs.getString('matri_id')}");
  //           log("Stored token_key: ${prefs.getString('token_key')}");
  //           log("Stored email: ${prefs.getString('email')}");

  //           // Navigate to the home page after successful registration
  //           Navigator.pushReplacement(
  //             context,
  //             MaterialPageRoute(builder: (context) => HomePage()),
  //           );

  //           await _requestPermissions();
  //         } else {
  //           // Handle and format error messages from the response
  //           var errors = responseData['error_msg'];
  //           String formattedErrors;

  //           if (errors is List) {
  //             formattedErrors =
  //                 errors.join("\n"); // Join multiple errors with newlines
  //           } else {
  //             formattedErrors = errors.toString();
  //           }

  //           // Show error dialog with formatted errors
  //           _showErrorDialog('Registration Error', formattedErrors);
  //         }
  //       } else {
  //         _showErrorDialog(
  //           'Server Error',
  //           'Code: ${response.statusCode}. ${response.statusMessage}',
  //         );
  //       }
  //     } on DioException catch (e) {
  //       // Handle specific Dio exceptions
  //       if (e.type == DioExceptionType.connectionTimeout) {
  //         _showErrorDialog(
  //           'Network Error',
  //           'Connection timed out. Please check your internet connection and try again.',
  //         );
  //       } else if (e.type == DioExceptionType.receiveTimeout) {
  //         _showErrorDialog(
  //           'Server Error',
  //           'The server took too long to respond. Please try again later.',
  //         );
  //       } else if (e.error is SocketException) {
  //         _showErrorDialog(
  //           'Network Error',
  //           'Please check your internet connection and try again.',
  //         );
  //       } else {
  //         _showErrorDialog(
  //             'Unexpected Error', 'An unexpected error occurred: ${e.message}');
  //       }
  //     } catch (e) {
  //       // Handle general exceptions
  //       _showErrorDialog('Unexpected Error', 'An error occurred: $e');
  //     } finally {
  //       // Reset loading state
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

  Future<void> _requestPermissions() async {
    try {
      // Check and request storage permission
      if (!await Permission.storage.isGranted) {
        final storageStatus = await Permission.storage.request();
        if (storageStatus.isPermanentlyDenied) {
          _showPermissionDeniedDialog("Storage");
        }
      }

      // Check and request photos permission
      if (!await Permission.photos.isGranted) {
        final photosStatus = await Permission.photos.request();
        if (photosStatus.isPermanentlyDenied) {
          _showPermissionDeniedDialog("Photos");
        }
      }

      // Check and request media library permission (for iOS)
      if (!await Permission.mediaLibrary.isGranted) {
        final mediaLibraryStatus = await Permission.mediaLibrary.request();
        if (mediaLibraryStatus.isPermanentlyDenied) {
          _showPermissionDeniedDialog("Media Library");
        }
      }
    } catch (e) {
      print("Error requesting permissions: $e");
    }
  }

  void _showPermissionDeniedDialog(String permission) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("$permission Permission Denied"),
        content: Text(
            "This app requires $permission permission to function properly. Please enable it in the app settings."),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text("Open Settings"),
            onPressed: () {
              openAppSettings(); // Open app settings
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      final dio = Dio();
      const String apiUrl = "${AppUrls.baseUrl}/api/register";

      try {
        final response = await dio.post(
          apiUrl,
          data: {
            "phone": _mobileNumber.toString(),
            "email": _email,
            "password": _password,
            "cpass_status": _verify,
          },
          options: Options(
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
            },
            validateStatus: (status) => true,
          ),
        );

        if (response.statusCode == 200) {
          final responseData = response.data;
          log(responseData.toString());

          if (responseData["response"] == true) {
            var matriId = responseData["data"]["matri_id"];
            var token = responseData["data"]["token"];
            var mobileNumber = _mobileNumber.toString();
            var emailAddress = _email;

            final SharedPreferences prefs =
                await SharedPreferences.getInstance();

            await prefs.setString('matri_id', matriId);
            await prefs.setString('token_key', token);
            await prefs.setString('phone', mobileNumber);
            await prefs.setString('email', emailAddress.toString());

            log("Stored phone: ${prefs.getString('phone')}");
            log("Stored matri_id: ${prefs.getString('matri_id')}");
            log("Stored token_key: ${prefs.getString('token_key')}");
            log("Stored email: ${prefs.getString('email')}");

            // Check if the widget is still mounted before navigating
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            }

            await _requestPermissions();
          } else {
            var errors = responseData['error_msg'];
            String formattedErrors;

            if (errors is List) {
              formattedErrors = errors.join("\n");
            } else {
              formattedErrors = errors.toString();
            }

            if (mounted) {
              _showErrorDialog('Registration Error', formattedErrors);
            }
          }
        } else {
          if (mounted) {
            _showErrorDialog(
              'Server Error',
              'Code: ${response.statusCode}. ${response.statusMessage}',
            );
          }
        }
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionTimeout) {
          if (mounted) {
            _showErrorDialog(
              'Network Error',
              'Connection timed out. Please check your internet connection and try again.',
            );
          }
        } else if (e.type == DioExceptionType.receiveTimeout) {
          if (mounted) {
            _showErrorDialog(
              'Server Error',
              'The server took too long to respond. Please try again later.',
            );
          }
        } else if (e.error is SocketException) {
          if (mounted) {
            _showErrorDialog(
              'Network Error',
              'Please check your internet connection and try again.',
            );
          }
        } else {
          if (mounted) {
            _showErrorDialog('Unexpected Error',
                'An unexpected error occurred: ${e.message}');
          }
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog('Unexpected Error', 'An error occurred: $e');
        }
      } finally {
        // Check if the widget is still mounted before calling setState
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset:
            true, // Allow resizing to avoid keyboard issues
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0), // Responsive padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 40), // Responsive spacing
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/ic_launcher.jpeg',
                          height: 160.h,
                          width: 160.w, // Responsive image height
                        ),
                        SizedBox(height: 20), // Responsive spacing
                        Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 28.0, // Responsive font size
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10), // Responsive spacing
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                readOnly: true,
                                initialValue: "+91",
                                decoration: InputDecoration(
                                  labelText: "Country Code",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                ),
                                style: TextStyle(fontSize: 14.0),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(width: 5.0),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Mobile Number*',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your Mobile Number';
                                  }
                                  if (value.length != 10) {
                                    return 'Please enter a valid 10-digit mobile number';
                                  }
                                  return null;
                                },
                                onSaved: (value) =>
                                    _mobileNumber = int.tryParse(value!),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15.0), // Responsive spacing
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email*',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  20.0), // Responsive radius
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                          onSaved: (value) => _email = value,
                        ),
                        SizedBox(height: 15.0), // Responsive spacing
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password*',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  20.0), // Responsive radius
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscureText,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters long';
                            }
                            return null;
                          },
                          onSaved: (value) => _password = value,
                        ),
                        SizedBox(height: 20.0), // Responsive spacing
                        RichText(
                          text: TextSpan(
                            text: 'By submitting you agree to our ',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16.0, // Responsive font size
                            ),
                            children: [
                              TextSpan(
                                text: 'Terms and Conditions.',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 14.0, // Responsive font size
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TermsAndConditionsPage()),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _registerUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5507),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                vertical: 16.0), // Responsive padding
                            minimumSize: Size(double.infinity,
                                40.0), // Responsive button height
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  23.0), // Responsive radius
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 16.0, // Responsive font size
                                  ),
                                ),
                        ),
                        SizedBox(height: 15.0), // Responsive spacing
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "You already have an account? ",
                              style: TextStyle(
                                fontSize: 14.0, // Responsive font size
                                color: Colors.purple,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginForm(
                                      onLoginSuccess: () {},
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding:
                                    EdgeInsets.all(5.0), // Responsive padding
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      25.0), // Responsive radius
                                  border: Border.all(
                                    color: Colors.orange,
                                  ),
                                ),
                                child: Text(
                                  "Login Now",
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 14.0, // Responsive font size
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
