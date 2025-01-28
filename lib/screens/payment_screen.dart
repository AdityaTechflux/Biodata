import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:developer';
import 'package:bio_data/consts/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../consts/app_urls.dart';
import '../controller/subscription_controller.dart';
import '../models/get_payment_model.dart';
import 'biodata_preview_page.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    Key? key,
    required this.templateImage,
    required this.biodataId,
    required this.selectedLanguage,
    required this.selectedShape,
    required this.imageSizeMultiplier,
    required this.selectedTextSize,
    required this.selectedTextColor,
    required this.pdfData,
    required this.isShareRequested,
    required this.biodataName,
  }) : super(key: key);

  final String templateImage;
  final String biodataId;
  final String selectedLanguage;
  final String selectedShape;
  final double imageSizeMultiplier;
  final String selectedTextSize;
  final Color selectedTextColor;
  final Uint8List pdfData;
  final bool isShareRequested;
  final String biodataName;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Razorpay? _razorpay;
  bool _isNavigating = false;
  late SubscriptionController _subscriptionController;

  // Store selected plan details
  String? _selectedPlanName;
  int? _selectedAmount;
  int? _selectedPlanDays;

  @override
  void initState() {
    super.initState();
    log("Initializing PaymentScreen...");
    _initializeRazorpay();
    _loadUserEmail();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      log("Fetching subscriptions...");
      _subscriptionController =
          Provider.of<SubscriptionController>(context, listen: false);
      _subscriptionController.fetchSubscriptions();
    });
  }

  @override
  void dispose() {
    log("Disposing Razorpay instance...");
    _razorpay?.clear();
    super.dispose();
  }

  String? _userEmail;
  String? _userMatriid;

  Future<void> _loadUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');
      final matriId = prefs.getString('matri_id');
      setState(() {
        _userEmail = email;
        _userMatriid = matriId;
      });
      log("Loaded user email: $_userEmail");
      log("Loaded Matri Id: $_userMatriid");
    } catch (e) {
      log("Error loading user email: $e");
    }
  }

  void _initializeRazorpay() {
    log("Initializing Razorpay...");
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openRazorpayCheckout(GetPaymentModel paymentData) {
    try {
      log("Preparing Razorpay checkout options...");
      final orderId = paymentData.order?.id;
      if (orderId == null) throw Exception("Order ID is missing");

      final amount = paymentData.order?.amount ?? 0;
      if (amount <= 0) throw Exception("Invalid amount specified");

      // Store selected plan details
      _selectedPlanName = paymentData.subscriptionDetails?.planName;
      _selectedAmount = amount ~/ 100; // Convert from paisa to rupees
      _selectedPlanDays = paymentData.subscriptionDetails?.planDays;

      log("Selected plan details: Name: $_selectedPlanName, Amount: $_selectedAmount, Days: $_selectedPlanDays");

      final options = {
        'key': paymentData.order?.key,
        'amount': amount,
        'currency': paymentData.order?.currency,
        'name': paymentData.order?.businessName,
        'description': "Plan Name: $_selectedPlanName",
        'order_id': orderId,
        'prefill': {
          'name': paymentData.order?.customerDetail?.name,
          'email': _userEmail ?? paymentData.order?.customerDetail?.email,
          'contact': paymentData.order?.customerDetail?.contact,
        },
        'theme': {'color': paymentData.order?.razorpayModalTheme},
      };

      log('email: $_userEmail');
      log('matri_id: $_userMatriid');

      log("Opening Razorpay checkout with email: ${_userEmail ?? 'fallback email'}");
      _razorpay?.open(options);
    } catch (e) {
      log("Failed to open Razorpay: $e");
      _showError("Failed to open Razorpay: $e");
    }
  }

  Future<void> _savePaymentDetails(String paymentId) async {
    try {
      log("Saving payment details...");
      final prefs = await SharedPreferences.getInstance();

      if (_selectedPlanName == null ||
          _selectedAmount == null ||
          _selectedPlanDays == null) {
        throw Exception("Selected plan details not available");
      }

      final now = DateTime.now();
      final planExpiredDate = now.add(Duration(days: _selectedPlanDays!));

      // Get current user's email
      final currentEmail = prefs.getString('email');
      if (currentEmail == null) {
        throw Exception("User email not found");
      }

      await prefs.setString('paymentId', paymentId);
      await prefs.setString(
          'planExpiredDate', planExpiredDate.toIso8601String());
      await prefs.setString('planName', _selectedPlanName!);
      await prefs.setInt('planAmount', _selectedAmount!);
      await prefs.setString(
          'payment_email', currentEmail); // Store email used for payment

      log("Payment details saved successfully with email: $currentEmail");
    } catch (e) {
      log("Error saving payment details: $e");
      throw Exception("Failed to save payment details: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      log("Payment success response received: ${response.paymentId}");
      final isVerified = await _verifyPaymentOnBackend(response);
      if (!isVerified) throw Exception("Payment verification failed");

      if (_isNavigating) return;
      _isNavigating = true;

      await _savePaymentDetails(response.paymentId!);
      // await _savePaymentDetails(response);

      if (widget.isShareRequested) {
        await _sharePdf();
      } else {
        await _selectFolderAndSavePdf();
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BiodataPreviewPage(
              biodataId: widget.biodataId,
              selectedLanguage: widget.selectedLanguage,
              templateImage: widget.templateImage,
              selectedShape: widget.selectedShape,
              imageSizeMultiplier: widget.imageSizeMultiplier,
              selectedTextSize: widget.selectedTextSize,
              selectedTextColor: widget.selectedTextColor,
              biodataName: widget.biodataName,
            ),
          ),
        );
      }
    } catch (e) {
      log("Error handling payment success: $e");
      _showError("Error handling payment success: $e");
    } finally {
      _isNavigating = false;
    }
  }

  void _showError(String message) {
    log("Displaying error message: $message");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _verifyPaymentOnBackend(PaymentSuccessResponse response) async {
    const callbackUrl = '${AppUrls.baseUrl}/api/verify_payment';

    try {
      log("Verifying payment on backend...");
      final body = {
        'razorpay_order_id': response.orderId,
        'razorpay_payment_id': response.paymentId,
        'razorpay_signature': response.signature,
      };

      final result = await http.post(
        Uri.parse(callbackUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      log("Backend verification response: ${result.body}");
      if (result.statusCode == 200) {
        final responseData = jsonDecode(result.body);
        return responseData['success'] == true;
      } else {
        throw Exception("Backend response error: ${result.body}");
      }
    } catch (e) {
      log("Failed to verify payment on backend: $e");
      throw Exception("Failed to verify payment on backend: $e");
    }
  }

  Future<void> _selectFolderAndSavePdf() async {
    try {
      final directory = Directory("/storage/emulated/0/Download");
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final file = File('${directory.path}/biodata.pdf');
      await file.writeAsBytes(widget.pdfData);

      if (mounted) {
        _showSuccess('PDF saved successfully at: ${file.path}');
      }
    } catch (e) {
      _showError('Error saving PDF: $e');
    }
  }

  // Future<void> _sharePdf() async {
  //   try {
  //     final tempDir = await getTemporaryDirectory();
  //     final tempFile = File('${tempDir.path}/biodata_share.pdf');
  //     await tempFile.writeAsBytes(widget.pdfData);
  //     await Share.shareFiles([tempFile.path], text: 'Check out my biodata!');
  //   } catch (e) {
  //     _showError('Error sharing PDF: $e');
  //   }
  // }

  Future<void> _sharePdf() async {
    try {
      // Get the temporary directory
      final tempDir = await getTemporaryDirectory();

      // Create a temporary file
      final tempFile = File('${tempDir.path}/biodata_share.pdf');

      // Write the PDF data to the temporary file
      await tempFile.writeAsBytes(widget.pdfData);

      // Share the PDF file using share_plus
      await Share.shareXFiles(
        [XFile(tempFile.path)], // Use XFile instead of File
        text: 'Check out my biodata!',
      );
    } catch (e) {
      _showError('Error sharing PDF: $e');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    log("Payment error occurred: ${response.message}");
    _showError("Payment failed Please Try Again");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    log("External wallet selected: ${response.walletName}");
    _showError("External wallet selected: ${response.walletName}");
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    log("Displaying success message: $message");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subscription Plans"),
      ),
      body: Consumer<SubscriptionController>(
        builder: (context, subscriptionController, child) {
          if (subscriptionController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final subscriptions = subscriptionController.subscriptionData?.data;
          if (subscriptions == null || subscriptions.isEmpty) {
            return const Center(child: Text("No subscriptions available"));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: subscriptions.length,
              itemBuilder: (context, index) {
                final subscription = subscriptions[index];
                return GestureDetector(
                  onTap: () async {
                    log("Selected subscription plan: ${subscription.planName}");
                    try {
                      await subscriptionController
                          .getPaymentDetails(subscription.id.toString());
                      final paymentData = subscriptionController.paymentData;
                      if (paymentData?.success == true) {
                        log("Payment data fetched successfully.");
                        openRazorpayCheckout(paymentData!);
                      } else {
                        log("Failed to initiate payment.");
                        _showError("Failed to initiate payment.");
                      }
                    } catch (e) {
                      log("Error occurred: $e");
                      _showError("Error occurred: $e");
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.orangeColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            subscription.planName ?? "Unknown Plan",
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "₹${subscription.price}",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppColors.orangeColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              log("Selected subscription plan: ${subscription.planName}");
                              try {
                                await subscriptionController.getPaymentDetails(
                                    subscription.id.toString());
                                final paymentData =
                                    subscriptionController.paymentData;
                                if (paymentData?.success == true) {
                                  log("Payment data fetched successfully.");
                                  openRazorpayCheckout(paymentData!);
                                } else {
                                  log("Failed to initiate payment.");
                                  _showError("Failed to initiate payment.");
                                }
                              } catch (e) {
                                log("Error occurred: $e");
                                _showError("Error occurred: $e");
                              }
                            },
                            child: const Text(
                              "Pay Now",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
// import 'dart:io';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'dart:developer';
// import 'package:bio_data/consts/colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:share/share.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;

// import '../consts/app_urls.dart';
// import '../controller/subscription_controller.dart';
// import '../models/get_payment_model.dart';
// import 'biodata_preview_page.dart';

// class PaymentScreen extends StatefulWidget {
//   const PaymentScreen({
//     Key? key,
//     required this.templateImage,
//     required this.biodataId,
//     required this.selectedLanguage,
//     required this.selectedShape,
//     required this.imageSizeMultiplier,
//     required this.selectedTextSize,
//     required this.selectedTextColor,
//     required this.pdfData,
//     required this.isShareRequested,
//     required this.biodataName,
//   }) : super(key: key);

//   final String templateImage;
//   final String biodataId;
//   final String selectedLanguage;
//   final String selectedShape;
//   final double imageSizeMultiplier;
//   final String selectedTextSize;
//   final Color selectedTextColor;
//   final Uint8List pdfData;
//   final bool isShareRequested;
//   final String biodataName;

//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   Razorpay? _razorpay;
//   bool _isNavigating = false;
//   late SubscriptionController _subscriptionController;

//   // Store selected plan details
//   String? _selectedPlanName;
//   int? _selectedAmount;
//   int? _selectedPlanDays;

//   @override
//   void initState() {
//     super.initState();
//     log("Initializing PaymentScreen...");
//     _initializeRazorpay();
//     _loadUserEmail();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       log("Fetching subscriptions...");
//       _subscriptionController =
//           Provider.of<SubscriptionController>(context, listen: false);
//       _subscriptionController.fetchSubscriptions();
//     });
//   }

//   @override
//   void dispose() {
//     log("Disposing Razorpay instance...");
//     _razorpay?.clear();
//     super.dispose();
//   }

//   String? _userEmail;
//   String? _userMatriid;

//   Future<void> _loadUserEmail() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final email = prefs.getString('email');
//       final matriId = prefs.getString('matri_id');
//       setState(() {
//         _userEmail = email;
//         _userMatriid = matriId;
//       });
//       log("Loaded user email: $_userEmail");
//       log("Loaded Matri Id: $_userMatriid");
//     } catch (e) {
//       log("Error loading user email: $e");
//     }
//   }

//   void _initializeRazorpay() {
//     log("Initializing Razorpay...");
//     _razorpay = Razorpay();
//     _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }

//   void openRazorpayCheckout(GetPaymentModel paymentData) {
//     try {
//       log("Preparing Razorpay checkout options...");
//       final orderId = paymentData.order?.id;
//       if (orderId == null) throw Exception("Order ID is missing");

//       final amount = paymentData.order?.amount ?? 0;
//       if (amount <= 0) throw Exception("Invalid amount specified");

//       // Store selected plan details
//       _selectedPlanName = paymentData.subscriptionDetails?.planName;
//       _selectedAmount = amount ~/ 100; // Convert from paisa to rupees
//       _selectedPlanDays = paymentData.subscriptionDetails?.planDays;

//       log("Selected plan details: Name: $_selectedPlanName, Amount: $_selectedAmount, Days: $_selectedPlanDays");

//       final options = {
//         'key': paymentData.order?.key,
//         'amount': amount,
//         'currency': paymentData.order?.currency,
//         'name': paymentData.order?.businessName,
//         'description': "Plan Name: $_selectedPlanName",
//         'order_id': orderId,
//         'prefill': {
//           'name': paymentData.order?.customerDetail?.name,
//           'email': _userEmail ?? paymentData.order?.customerDetail?.email,
//           'contact': paymentData.order?.customerDetail?.contact,
//         },
//         'theme': {'color': paymentData.order?.razorpayModalTheme},
//       };

//       log('email: $_userEmail');
//       log('matri_id: $_userMatriid');

//       log("Opening Razorpay checkout with email: ${_userEmail ?? 'fallback email'}");
//       _razorpay?.open(options);
//     } catch (e) {
//       log("Failed to open Razorpay: $e");
//       _showError("Failed to open Razorpay: $e");
//     }
//   }

//   Future<void> _savePaymentDetails(String paymentId) async {
//     try {
//       log("Saving payment details...");
//       final prefs = await SharedPreferences.getInstance();

//       if (_selectedPlanName == null ||
//           _selectedAmount == null ||
//           _selectedPlanDays == null) {
//         throw Exception("Selected plan details not available");
//       }

//       final now = DateTime.now();
//       final planExpiredDate = now.add(Duration(days: _selectedPlanDays!));

//       // Get current user's email
//       final currentEmail = prefs.getString('email');
//       if (currentEmail == null) {
//         throw Exception("User email not found");
//       }

//       await prefs.setString('paymentId', paymentId);
//       await prefs.setString(
//           'planExpiredDate', planExpiredDate.toIso8601String());
//       await prefs.setString('planName', _selectedPlanName!);
//       await prefs.setInt('planAmount', _selectedAmount!);
//       await prefs.setString(
//           'payment_email', currentEmail); // Store email used for payment

//       log("Payment details saved successfully with email: $currentEmail");
//     } catch (e) {
//       log("Error saving payment details: $e");
//       throw Exception("Failed to save payment details: $e");
//     }
//   }

//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     try {
//       log("Payment success response received: ${response.paymentId}");
//       final isVerified = await _verifyPaymentOnBackend(response);
//       if (!isVerified) throw Exception("Payment verification failed");

//       if (_isNavigating) return;
//       _isNavigating = true;

//       await _savePaymentDetails(response.paymentId!);
//       // await _savePaymentDetails(response);

//       if (widget.isShareRequested) {
//         await _sharePdf();
//       } else {
//         await _selectFolderAndSavePdf();
//       }

//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => BiodataPreviewPage(
//               biodataId: widget.biodataId,
//               selectedLanguage: widget.selectedLanguage,
//               templateImage: widget.templateImage,
//               selectedShape: widget.selectedShape,
//               imageSizeMultiplier: widget.imageSizeMultiplier,
//               selectedTextSize: widget.selectedTextSize,
//               selectedTextColor: widget.selectedTextColor,
//               biodataName: widget.biodataName,
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       log("Error handling payment success: $e");
//       _showError("Error handling payment success: $e");
//     } finally {
//       _isNavigating = false;
//     }
//   }



//   void _showError(String message) {
//     log("Displaying error message: $message");
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<bool> _verifyPaymentOnBackend(PaymentSuccessResponse response) async {
//     const callbackUrl = '${AppUrls.baseUrl}/api/verify_payment';
//     // const callbackUrl =
//     //     'http://allindiamatrimonial.com/royal_maratha/api/verify_payment';

//     try {
//       log("Verifying payment on backend...");
//       final body = {
//         'razorpay_order_id': response.orderId,
//         'razorpay_payment_id': response.paymentId,
//         'razorpay_signature': response.signature,
//       };

//       final result = await http.post(
//         Uri.parse(callbackUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(body),
//       );

//       log("Backend verification response: ${result.body}");
//       if (result.statusCode == 200) {
//         final responseData = jsonDecode(result.body);
//         return responseData['success'] == true;
//       } else {
//         throw Exception("Backend response error: ${result.body}");
//       }
//     } catch (e) {
//       log("Failed to verify payment on backend: $e");
//       throw Exception("Failed to verify payment on backend: $e");
//     }
//   }

//   Future<void> _selectFolderAndSavePdf() async {
//     try {
//       final directory = Directory("/storage/emulated/0/Download");
//       if (!await directory.exists()) {
//         await directory.create(recursive: true);
//       }

//       final file = File(
//           '${directory.path}/biodata_${DateTime.now().millisecondsSinceEpoch}.pdf');
//       await file.writeAsBytes(widget.pdfData);

//       if (mounted) {
//         _showSuccess('PDF saved successfully at: ${file.path}');
//       }
//     } catch (e) {
//       _showError('Error saving PDF: $e');
//     }
//   }

//   Future<void> _sharePdf() async {
//     try {
//       final tempDir = await getTemporaryDirectory();
//       final tempFile = File('${tempDir.path}/biodata_share.pdf');
//       await tempFile.writeAsBytes(widget.pdfData);
//       await Share.shareFiles([tempFile.path], text: 'Check out my biodata!');
//     } catch (e) {
//       _showError('Error sharing PDF: $e');
//     }
//   }

//   void _handlePaymentError(PaymentFailureResponse response) {
//     log("Payment error occurred: ${response.message}");
//     _showError("Payment failed Please Try Again");
//   }

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     log("External wallet selected: ${response.walletName}");
//     _showError("External wallet selected: ${response.walletName}");
//   }

//   void showAlertDialog(BuildContext context, String title, String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showSuccess(String message) {
//     log("Displaying success message: $message");
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.green,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Subscription Plans"),
//       ),
//       body: Consumer<SubscriptionController>(
//         builder: (context, subscriptionController, child) {
//           if (subscriptionController.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final subscriptions = subscriptionController.subscriptionData?.data;
//           if (subscriptions == null || subscriptions.isEmpty) {
//             return const Center(child: Text("No subscriptions available"));
//           }

//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: GridView.builder(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 childAspectRatio: 0.8,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//               ),
//               itemCount: subscriptions.length,
//               itemBuilder: (context, index) {
//                 final subscription = subscriptions[index];
//                 return GestureDetector(
//                   onTap: () async {
//                     log("Selected subscription plan: ${subscription.planName}");
//                     try {
//                       await subscriptionController
//                           .getPaymentDetails(subscription.id.toString());
//                       final paymentData = subscriptionController.paymentData;
//                       if (paymentData?.success == true) {
//                         log("Payment data fetched successfully.");
//                         openRazorpayCheckout(paymentData!);
//                       } else {
//                         log("Failed to initiate payment.");
//                         _showError("Failed to initiate payment.");
//                       }
//                     } catch (e) {
//                       log("Error occurred: $e");
//                       _showError("Error occurred: $e");
//                     }
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8.r),
//                       border: Border.all(color: AppColors.orangeColor),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             subscription.planName ?? "Unknown Plan",
//                             style: Theme.of(context).textTheme.titleLarge,
//                             textAlign: TextAlign.center,
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             "₹${subscription.price}",
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .titleMedium
//                                 ?.copyWith(
//                                   color: AppColors.orangeColor,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                           ),
//                           const SizedBox(height: 16),
//                           ElevatedButton(
//                             onPressed: () async {
//                               log("Selected subscription plan: ${subscription.planName}");
//                               try {
//                                 await subscriptionController.getPaymentDetails(
//                                     subscription.id.toString());
//                                 final paymentData =
//                                     subscriptionController.paymentData;
//                                 if (paymentData?.success == true) {
//                                   log("Payment data fetched successfully.");
//                                   openRazorpayCheckout(paymentData!);
//                                 } else {
//                                   log("Failed to initiate payment.");
//                                   _showError("Failed to initiate payment.");
//                                 }
//                               } catch (e) {
//                                 log("Error occurred: $e");
//                                 _showError("Error occurred: $e");
//                               }
//                             },
//                             child: const Text(
//                               "Pay Now",
//                               style: TextStyle(color: Colors.white),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
