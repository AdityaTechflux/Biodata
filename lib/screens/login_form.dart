// import 'dart:convert';
// import 'dart:developer';
// import 'package:bio_data/consts/colors.dart';
// import 'package:bio_data/screens/login_otp_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../consts/app_urls.dart';
// import 'forgot_password_page.dart';
// import 'home_screen/home_page.dart';
// import 'signup_form.dart';

// class LoginForm extends StatefulWidget {
//   final Function onLoginSuccess;
//   const LoginForm({super.key, required this.onLoginSuccess});

//   @override
//   _LoginFormState createState() => _LoginFormState();
// }

// class _LoginFormState extends State<LoginForm> {
//   final _formKey = GlobalKey<FormState>();
//   bool _obscurePassword = true;
//   bool _isLoading = false;

//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   void _login() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       final String email = _emailController.text.trim();
//       final String password = _passwordController.text.trim();

//       try {
//         const String apiUrl = '${AppUrls.baseUrl}/api/login';
//         // const String apiUrl =
//         //     'http://allindiamatrimonial.com/royal_maratha/api/login';

//         final response = await http.post(
//           Uri.parse(apiUrl),
//           body: {
//             'email_or_phone': email,
//             'password': password,
//           },
//         );

//         print('Response status: ${response.statusCode}');
//         print('Response body: ${response.body}');

//         var data = jsonDecode(response.body);
//         if (data["response"] == true) {
//           var tokenKey = data["data"]["token"];
//           var matriId = data["data"]["matri_id"];
//           // var _email = data["data"]["email_or_phone"];

//           // Store data in SharedPreferences
//           final SharedPreferences prefs = await SharedPreferences.getInstance();
//           await prefs.setString('matri_id', matriId);
//           await prefs.setString('token_key', tokenKey);
//           await prefs.setString('email_or_phone', email);
//           await prefs.setBool('isLoggedIn', true);

//           log(tokenKey.toString());
//           log("matriId: $matriId");
//           log("Login Successfully");
//           log(data.toString());
//           log(email.toString());

//           widget.onLoginSuccess();

//           // Navigate to HomePage after successful login
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => HomePage()),
//           );
//         } else {
//           var errorMsg = data["error_msg"];
//           _showErrorDialog(errorMsg.toString());
//           log("Login Failed");
//         }
//       } catch (e) {
//         log(e.toString());
//         _showErrorDialog("Server side error.");
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(),
//           title: Text('Error'),
//           content: SizedBox(
//             height: 65.h,
//             child: Column(
//               children: [
//                 Text(message),
//                 FilledButton(
//                   style: FilledButton.styleFrom(
//                     shape: RoundedRectangleBorder(),
//                     backgroundColor: AppColors.orangeColor,
//                   ),
//                   onPressed: () => Navigator.pop(context),
//                   child: Text(
//                     'OK',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: [],
//         );
//       },
//     );
//   }

//   TextInputType _keyboardType = TextInputType.emailAddress;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         scrollDirection: Axis.vertical,
//         child: Padding(
//           padding: EdgeInsets.all(16.0.w), // Responsive padding
//           child: Column(
//             children: <Widget>[
//               SizedBox(height: 80.h), // Responsive spacing
//               Center(
//                 child: Column(
//                   children: [
//                     Image.asset(
//                       'assets/images/ic_launcher.jpeg',
//                       height: 160.h,
//                       width: 160.w, // Responsive image height
//                     ),
//                     SizedBox(height: 20.h), // Responsive spacing
//                     Text(
//                       'Login',
//                       style: TextStyle(
//                         fontSize: 28.0.sp, // Responsive font size
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 30.h), // Responsive spacing
//               Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       controller: _emailController,
//                       decoration: InputDecoration(
//                         labelText: 'Email or Mobile no.',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(20.0),
//                         ),
//                       ),
//                       keyboardType: _keyboardType,
//                       onChanged: (value) {
//                         // Automatically remove spaces
//                         String newValue = value.replaceAll(' ', '');
//                         if (newValue != value) {
//                           _emailController.value = TextEditingValue(
//                             text: newValue,
//                             selection: TextSelection.collapsed(
//                                 offset: newValue.length),
//                           );
//                         }

//                         // Update keyboard type based on the input
//                         if (RegExp(r'^\d+$').hasMatch(newValue)) {
//                           setState(() {
//                             _keyboardType = TextInputType.phone;
//                           });
//                         } else {
//                           setState(() {
//                             _keyboardType = TextInputType.emailAddress;
//                           });
//                         }
//                       },
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your email or mobile number';
//                         }
//                         if (!RegExp(r'^\d+$').hasMatch(value) &&
//                             !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
//                                 .hasMatch(value)) {
//                           return 'Please enter a valid email or mobile number';
//                         }
//                         return null;
//                       },
//                     ),

//                     SizedBox(height: 15.h), // Responsive spacing
//                     TextFormField(
//                       controller: _passwordController,
//                       decoration: InputDecoration(
//                         labelText: 'Password',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(20.r),
//                         ),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscurePassword
//                                 ? Icons.visibility_off
//                                 : Icons.visibility,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _obscurePassword = !_obscurePassword;
//                             });
//                           },
//                         ),
//                       ),
//                       obscureText: _obscurePassword,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your password';
//                         }
//                         if (value.length < 6) {
//                           return 'Password must be at least 6 characters long';
//                         }
//                         return null;
//                       },
//                     ),
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: TextButton(
//                         onPressed: () {
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>
//                                       const ForgotPasswordPage()));
//                         },
//                         child: Text(
//                           'Forgot Password?',
//                           style: TextStyle(
//                             color: Colors.deepPurple,
//                             fontSize: 14.sp, // Responsive font size
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 10.h), // Responsive spacing
//               ElevatedButton(
//                 onPressed: _isLoading ? null : _login,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFFF5507),
//                   foregroundColor: Colors.white,
//                   padding: EdgeInsets.symmetric(
//                       vertical: 16.0.h), // Responsive padding
//                   minimumSize:
//                       Size(double.infinity, 25.h), // Responsive button height
//                   shape: RoundedRectangleBorder(
//                     borderRadius:
//                         BorderRadius.circular(23.r), // Responsive radius
//                   ),
//                 ),
//                 child: _isLoading
//                     ? SizedBox(
//                         height: 30.h, // Responsive loader size
//                         child: const CircularProgressIndicator(
//                           color: Colors.white,
//                         ),
//                       )
//                     : Text(
//                         'Login',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16.sp, // Responsive font size
//                         ),
//                       ),
//               ),
//               SizedBox(height: 10.h), // Responsive spacing
//               Text(
//                 "OR",
//                 style: TextStyle(
//                   fontSize: 18.sp, // Responsive font size
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 10.h), // Responsive spacing
//               ElevatedButton(
//                 onPressed: () {
//                   _emailController.clear();
//                   _passwordController.clear();
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) {
//                         return LoginOtpScreen();
//                       },
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFFF5507),
//                   foregroundColor: Colors.white,
//                   padding: EdgeInsets.symmetric(
//                       vertical: 16.0.h), // Responsive padding
//                   minimumSize:
//                       Size(double.infinity, 25.h), // Responsive button height
//                   shape: RoundedRectangleBorder(
//                     borderRadius:
//                         BorderRadius.circular(23.r), // Responsive radius
//                   ),
//                 ),
//                 child: Text(
//                   'Login with OTP',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16.sp, // Responsive font size
//                   ),
//                 ),
//               ),
//               SizedBox(height: 10.h), // Responsive spacing
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFFF5507),
//                   foregroundColor: Colors.white,
//                   padding: EdgeInsets.symmetric(
//                       vertical: 16.0.h), // Responsive padding
//                   minimumSize:
//                       Size(double.infinity, 25.h), // Responsive button height
//                   shape: RoundedRectangleBorder(
//                     borderRadius:
//                         BorderRadius.circular(23.r), // Responsive radius
//                   ),
//                 ),
//                 onPressed: () {
//                   _emailController.clear();
//                   _passwordController.clear();
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const SignupForm()),
//                   );
//                 },
//                 child: Text(
//                   'New User? Sign up',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16.sp, // Responsive font size
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:developer';
import 'package:bio_data/consts/colors.dart';
import 'package:bio_data/screens/login_otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../consts/app_urls.dart';
import 'forgot_password_page.dart';
import 'home_screen/home_page.dart';
import 'signup_form.dart';

class LoginForm extends StatefulWidget {
  final Function onLoginSuccess;
  const LoginForm({super.key, required this.onLoginSuccess});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      try {
        const String apiUrl = '${AppUrls.baseUrl}/api/login';

        final response = await http.post(
          Uri.parse(apiUrl),
          body: {
            'email_or_phone': email,
            'password': password,
          },
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        var data = jsonDecode(response.body);
        if (data["response"] == true) {
          var tokenKey = data["data"]["token"];
          var matriId = data["data"]["matri_id"];

          // Store data in SharedPreferences
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('matri_id', matriId);
          await prefs.setString('token_key', tokenKey);
          await prefs.setString('email_or_phone', email);
          await prefs.setBool('isLoggedIn', true);

          log(tokenKey.toString());
          log("matriId: $matriId");
          log("Login Successfully");
          log(data.toString());
          log(email.toString());

          widget.onLoginSuccess();

          // Navigate to HomePage after successful login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
          await _requestPermissions();
        } else {
          var errorMsg = data["error_msg"];
          _showErrorDialog(errorMsg.toString());
          log("Login Failed");
        }
      } catch (e) {
        log(e.toString());
        _showErrorDialog("Server side error.");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _requestPermissions() async {
    // Request storage permission
    final storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) {
      log("Storage permission granted");
    } else {
      log("Storage permission denied");
    }

    // Request photos permission
    final photosStatus = await Permission.photos.request();
    if (photosStatus.isGranted) {
      log("Photos permission granted");
    } else {
      log("Photos permission denied");
    }

    // Request media library permission (for iOS)
    final mediaLibraryStatus = await Permission.mediaLibrary.request();
    if (mediaLibraryStatus.isGranted) {
      log("Media library permission granted");
    } else {
      log("Media library permission denied");
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(),
          title: Text('Error'),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
            child: Column(
              children: [
                Text(message),
                FilledButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(),
                    backgroundColor: AppColors.orangeColor,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [],
        );
      },
    );
  }

  TextInputType _keyboardType = TextInputType.emailAddress;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
          child: Column(
            children: <Widget>[
              SizedBox(height: screenHeight * 0.1), // Responsive spacing
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/ic_launcher.jpeg',
                      height: screenHeight * 0.2,
                      width: screenWidth * 0.4, // Responsive image height
                    ),
                    SizedBox(height: screenHeight * 0.02), // Responsive spacing
                    Text(
                      'Login',
                      style: TextStyle(
                        fontSize: screenWidth * 0.07, // Responsive font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03), // Responsive spacing
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email or Mobile no.',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.05),
                        ),
                      ),
                      keyboardType: _keyboardType,
                      onChanged: (value) {
                        // Automatically remove spaces
                        String newValue = value.replaceAll(' ', '');
                        if (newValue != value) {
                          _emailController.value = TextEditingValue(
                            text: newValue,
                            selection: TextSelection.collapsed(
                                offset: newValue.length),
                          );
                        }

                        // Update keyboard type based on the input
                        if (RegExp(r'^\d+$').hasMatch(newValue)) {
                          setState(() {
                            _keyboardType = TextInputType.phone;
                          });
                        } else {
                          setState(() {
                            _keyboardType = TextInputType.emailAddress;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email or mobile number';
                        }
                        if (!RegExp(r'^\d+$').hasMatch(value) &&
                            !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                .hasMatch(value)) {
                          return 'Please enter a valid email or mobile number';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: screenHeight * 0.02), // Responsive spacing
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.05),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordPage()));
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize:
                                screenWidth * 0.04, // Responsive font size
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02), // Responsive spacing
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5507),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02), // Responsive padding
                  minimumSize: Size(double.infinity,
                      screenHeight * 0.06), // Responsive button height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        screenWidth * 0.06), // Responsive radius
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: screenHeight * 0.03, // Responsive loader size
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.04, // Responsive font size
                        ),
                      ),
              ),
              SizedBox(height: screenHeight * 0.02), // Responsive spacing
              Text(
                "OR",
                style: TextStyle(
                  fontSize: screenWidth * 0.05, // Responsive font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.02), // Responsive spacing
              ElevatedButton(
                onPressed: () {
                  _emailController.clear();
                  _passwordController.clear();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return LoginOtpScreen();
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5507),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02), // Responsive padding
                  minimumSize: Size(double.infinity,
                      screenHeight * 0.06), // Responsive button height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        screenWidth * 0.06), // Responsive radius
                  ),
                ),
                child: Text(
                  'Login with OTP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.04, // Responsive font size
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02), // Responsive spacing
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5507),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02), // Responsive padding
                  minimumSize: Size(double.infinity,
                      screenHeight * 0.06), // Responsive button height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        screenWidth * 0.06), // Responsive radius
                  ),
                ),
                onPressed: () {
                  _emailController.clear();
                  _passwordController.clear();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupForm()),
                  );
                },
                child: Text(
                  'New User? Sign up',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.04, // Responsive font size
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
