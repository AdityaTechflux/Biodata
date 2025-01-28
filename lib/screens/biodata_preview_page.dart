import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:bio_data/screens/payment_screen.dart';
import 'package:bio_data/screens/template_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../consts/app_urls.dart';

// import '../models/biodata_model.dart';

class BiodataPreviewPage extends StatefulWidget {
  final String templateImage; // URL for the selected template image
  final String biodataId;
  final String selectedLanguage;
  final String selectedShape; // New parameter for selected shape
  final double imageSizeMultiplier;
  final String selectedTextSize; // Added parameter for selected text size
  final Color selectedTextColor; // Added parameter for selected text color
  final String biodataName;

  BiodataPreviewPage({
    Key? key,
    required this.templateImage,
    required this.biodataId,
    required this.selectedLanguage,
    required this.selectedShape,
    required this.imageSizeMultiplier,
    required this.selectedTextSize,
    required this.selectedTextColor,
    required this.biodataName,
  }) : super(key: key);

  @override
  State<BiodataPreviewPage> createState() => _BiodataPreviewPageState();
}

class _BiodataPreviewPageState extends State<BiodataPreviewPage> {
  Map<String, dynamic>? biodataDetails;
  bool isLoading = true;
  String? errorMessage;
  GlobalKey _globalKey = GlobalKey();

  late TransformationController _transformationController;
  double _currentScale = 1.0;
  double _minScale = 0.5;
  double _maxScale = 3.0;

  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    // fetchBiodataDetails();
    fetchBiodataDetails(widget.biodataId);
    // _disableScreenCapture();
    log("Received text size: ${widget.selectedTextSize}");
    _transformationController = TransformationController();
    _secureScreen();

    // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Future.microtask(() {
    //   if (mounted) {
    //     fetchBiodataDetails(widget.biodataId);
    //   }
    // });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isMounted) {
        fetchBiodataDetails(widget.biodataId);
      }
    });
  }

  Future<void> _secureScreen() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    if (Platform.isAndroid) {
      const platform = MethodChannel('app_settings');
      try {
        await platform.invokeMethod('setSecureFlag');
      } catch (e) {
        print('Error setting secure flag: $e');
      }
    }
  }

  Future<void> _removeSecureScreen() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    if (Platform.isAndroid) {
      const platform = MethodChannel('app_settings');
      try {
        await platform.invokeMethod('removeSecureFlag');
      } catch (e) {
        print('Error removing secure flag: $e');
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _secureScreen();
    } else if (state == AppLifecycleState.paused) {
      _removeSecureScreen();
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    log("BiodataPreview - dispose");
    _isMounted = false;
    super.dispose();
  }

  void _handleDoubleTap() {
    if (_currentScale != 1.0) {
      // Reset to original size
      _transformationController.value = Matrix4.identity();
      _currentScale = 1.0;
    } else {
      // Zoom to 2x
      _transformationController.value = Matrix4.identity()..scale(2.0);
      _currentScale = 2.0;
    }
    setState(() {});
  }

  Future<void> _disableScreenCapture() async {
    // await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  // Future<void> shareLastGeneratedPdf() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final biodataList = prefs.getStringList('saved_biodata') ?? [];

  //     if (biodataList.isEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //             content: Text('No PDF found to share. Please create one first.')),
  //       );
  //       return;
  //     }

  //     // Decode the last generated biodata details
  //     final lastBiodata = jsonDecode(biodataList.last);
  //     final pdfPath = lastBiodata['pdfPath'] as String;

  //     // Share the PDF file
  //     await Share.shareFiles([pdfPath], text: 'Here is your generated PDF.');
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error sharing PDF: $e')),
  //     );
  //     log("Error sharing PDF: $e");
  //   }
  // }

  Future<void> shareLastGeneratedPdf(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final biodataList = prefs.getStringList('saved_biodata') ?? [];

      if (biodataList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No PDF found to share. Please create one first.'),
          ),
        );
        return;
      }

      // Decode the last generated biodata details
      final lastBiodata = jsonDecode(biodataList.last);
      final pdfPath = lastBiodata['pdfPath'] as String;

      // Share the PDF file using share_plus
      await Share.shareXFiles([XFile(pdfPath)],
          text: 'Here is your generated PDF.');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing PDF: $e')),
      );
      log("Error sharing PDF: $e");
    }
  }

  Future<void> _saveBiodata() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Create a map of biodata details
    Map<String, dynamic> biodata = {
      "templateImage": widget.templateImage,
      "biodataId": widget.biodataId,
      "selectedLanguage": widget.selectedLanguage,
      "selectedShape": widget.selectedShape,
      "imageSizeMultiplier": widget.imageSizeMultiplier,
      "selectedTextSize": widget.selectedTextSize,
      "selectedTextColor": widget.selectedTextColor.value,
      // "dynamicFieldValues1": widget.dynamicFieldValues1,
      // "dynamicFieldValues2": widget.dynamicFieldValues2,
      // "dynamicFieldValues3": widget.dynamicFieldValues3,
      // "dynamicFieldValues4": widget.dynamicFieldValues4,
    };

    // Retrieve existing biodata list
    String? biodataListString = prefs.getString('savedBiodata');
    List<Map<String, dynamic>> biodataList = biodataListString != null
        ? List<Map<String, dynamic>>.from(json.decode(biodataListString))
        : [];

    // Add the new biodata
    biodataList.add(biodata);

    // Save back to SharedPreferences
    await prefs.setString('savedBiodata', json.encode(biodataList));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Biodata saved successfully!')),
    );
  }

  Future<void> fetchBiodataDetails(String biodataId) async {
    setState(() {
      isLoading = true; // Show loading state
    });

    try {
      final response = await http.get(
        Uri.parse(
            '${AppUrls.baseUrl}/api/users/showBiodataByBiodataId?biodata_id=$biodataId'),
      );
      // final response = await http.get(
      //   Uri.parse(
      //       'http://allindiamatrimonial.com/royal_maratha/api/users/showBiodataByBiodataId?biodata_id=$biodataId'),
      // );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == true && data['data'] != null) {
          setState(() {
            biodataDetails = data['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = 'No biodata found for ID: $biodataId';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load data: ${response.statusCode}';
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $error';
      });
    }
  }

  Widget _buildDisplayImage(BuildContext context, String key) {
    double baseImageSize = MediaQuery.of(context).size.width * 0.12;
    double imageSize = baseImageSize * widget.imageSizeMultiplier;

    // Handle "No Image" case
    if (widget.selectedShape == "No Image") {
      return SizedBox.shrink(); // Return an empty widget
    }

    // Check if biodataDetails has the image key
    if (biodataDetails == null || biodataDetails![key] == null) {
      return Container(
        height: imageSize,
        width: imageSize,
      );
    }

    // Decide shape of the image
    Widget imageWidget;
    if (widget.selectedShape == "Circle") {
      imageWidget = ClipOval(
        child: CachedNetworkImage(
          imageUrl: biodataDetails![key],
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => Image.asset(
            'assets/images/profile.png',
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (widget.selectedShape == "Round Square") {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: CachedNetworkImage(
          imageUrl: biodataDetails![key],
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => Image.asset(
            'assets/images/profile.png',
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      imageWidget = CachedNetworkImage(
        imageUrl: biodataDetails![key],
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => Image.asset(
          'assets/images/profile.png',
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      height: imageSize,
      width: imageSize,
      decoration: BoxDecoration(
        shape: widget.selectedShape == "Circle"
            ? BoxShape.circle
            : BoxShape.rectangle, // Rectangle for other shapes
        borderRadius: widget.selectedShape == "Round Square"
            ? BorderRadius.circular(15.0)
            : null, // Ensure null borderRadius for other shapes
        color: Colors.grey[300],
      ),
      child: imageWidget,
    );
  }

  String formatDate(String? date) {
    if (date == null) return ''; // Handle null case
    try {
      // Parse the incoming date in 'yyyy-MM-dd HH:mm:ss' format
      DateTime parsedDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(date);
      // Format it to 'dd-MM-yyyy' (e.g., 12-06-2000)
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return date; // Return original date if parsing fails
    }
  }

  Widget _buildField(String title, String? value) {
    return Text(
      '$title ${value ?? 'N/A'}',
      style: TextStyle(
        fontSize: 12.sp,
        color: Colors.black,
        // fontWeight: FontWeight.w500,
      ),
    );
  }

  Positioned _buildProfileImage1() {
    double imageSize =
        (50 * widget.imageSizeMultiplier).h; // Responsive image size

    if (widget.selectedShape == "No Image") {
      return Positioned(
        top: 90.h,
        right: 40.w,
        child: Container(
          height: imageSize,
          width: imageSize,
        ),
      );
    }

    return Positioned(
      top: 115.h,
      right: 25.w,
      child: Container(
        height: imageSize,
        width: imageSize,
        decoration: BoxDecoration(
          borderRadius: widget.selectedShape == "Circle"
              ? BorderRadius.circular(imageSize / 2)
              : widget.selectedShape == "Round Square"
                  ? BorderRadius.circular(15.r) // Responsive radius
                  : BorderRadius.circular(0),
        ),
        child: ClipRRect(
            borderRadius: widget.selectedShape == "Circle"
                ? BorderRadius.circular(imageSize / 2)
                : widget.selectedShape == "Round Square"
                    ? BorderRadius.circular(15.r) // Responsive radius
                    : BorderRadius.circular(0),
            child: biodataDetails?['photo1'] != null
                ? CachedNetworkImage(
                    imageUrl: biodataDetails!['photo1'],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/profile.png',
                      fit: BoxFit.cover,
                    ),
                  )
                : null),
      ),
    );
  }

  bool _isLoading = false;

  Positioned _buildProfileImage2() {
    double imageSize =
        (50 * widget.imageSizeMultiplier).h; // Responsive image size

    if (widget.selectedShape == "No Image") {
      return Positioned(
        top: 90.h,
        right: 40.w,
        child: Container(
          height: imageSize,
          width: imageSize,
        ),
      );
    }

    return Positioned(
      top: 230.h,
      right: 25.w,
      child: Container(
        height: imageSize,
        width: imageSize,
        decoration: BoxDecoration(
          borderRadius: widget.selectedShape == "Circle"
              ? BorderRadius.circular(imageSize / 2)
              : widget.selectedShape == "Round Square"
                  ? BorderRadius.circular(15.r) // Responsive radius
                  : BorderRadius.circular(0),
        ),
        child: ClipRRect(
            borderRadius: widget.selectedShape == "Circle"
                ? BorderRadius.circular(imageSize / 2)
                : widget.selectedShape == "Round Square"
                    ? BorderRadius.circular(15.r) // Responsive radius
                    : BorderRadius.circular(0),
            child: biodataDetails?['photo2'] != null
                ? CachedNetworkImage(
                    imageUrl: biodataDetails!['photo2'],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/profile.png',
                      fit: BoxFit.cover,
                    ),
                  )
                : null),
      ),
    );
  }

  // Future<void> _handlePdfCreation() async {
  //   bool isPortrait =
  //       MediaQuery.of(context).orientation == Orientation.portrait;

  //   if (!isPortrait) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content:
  //             Text('Please rotate your device to portrait mode to proceed'),
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //     return;
  //   }

  //   setState(() => _isLoading = true);

  //   try {
  //     // Check permissions first
  //     if (!await _checkAndRequestPermissions()) {
  //       setState(() => _isLoading = false);
  //       return;
  //     }

  //     // Generate PDF
  //     setState(() => _isPdfGenerating = true);
  //     await _generatePdf();
  //     setState(() => _isPdfGenerating = false);

  //     // Check for existing valid payment
  //     bool hasValidPayment = await _checkExistingPayment();

  //     if (hasValidPayment) {
  //       final directory = await getApplicationDocumentsDirectory();
  //       final filePath = '${directory.path}/biodata_${widget.biodataId}.pdf';

  //       debugPrint('Saving PDF to: $filePath');

  //       final file = File(filePath);
  //       await file.writeAsBytes(_pdfData!);

  //       debugPrint('PDF saved successfully');

  //       // Double-check permissions before opening
  //       if (await _checkAndRequestPermissions()) {
  //         await _openPdfFile(filePath);
  //       }
  //     } else {
  //       await _navigateToPayment(false);
  //     }
  //   } catch (e) {
  //     debugPrint('Error in PDF creation: $e');
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error: $e')),
  //       );
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isLoading = false);
  //     }
  //   }
  // }

  // Future<bool> _checkAndRequestPermissions() async {
  //   try {
  //     // Check storage permission
  //     if (!await Permission.storage.isGranted) {
  //       final status = await Permission.storage.request();
  //       if (!status.isGranted) {
  //         if (status.isPermanentlyDenied && mounted) {
  //           _showPermissionSettingsDialog("Storage");
  //         }
  //         return false;
  //       }
  //     }

  //     // Check documents permission (for Android 13+)
  //     if (Platform.isAndroid) {
  //       if (!await Permission.manageExternalStorage.isGranted) {
  //         final status = await Permission.manageExternalStorage.request();
  //         if (!status.isGranted) {
  //           if (status.isPermanentlyDenied && mounted) {
  //             _showPermissionSettingsDialog("Files and Media");
  //           }
  //           return false;
  //         }
  //       }
  //     }

  //     return true;
  //   } catch (e) {
  //     debugPrint('Error checking permissions: $e');
  //     return false;
  //   }
  // }

  // void _showPermissionSettingsDialog(String permissionType) {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: Text('$permissionType Permission Required'),
  //       content: Text(
  //         'This app needs $permissionType permission to save and open PDF files. '
  //         'Please enable it in the app settings.',
  //       ),
  //       actions: [
  //         TextButton(
  //           child: const Text('Cancel'),
  //           onPressed: () => Navigator.of(ctx).pop(),
  //         ),
  //         TextButton(
  //           child: const Text('Open Settings'),
  //           onPressed: () {
  //             openAppSettings();
  //             Navigator.of(ctx).pop();
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Future<void> _openPdfFile(String filePath) async {
  //   try {
  //     debugPrint('Attempting to open file: $filePath');

  //     final file = File(filePath);
  //     if (await file.exists()) {
  //       debugPrint('File exists, attempting to open');

  //       // Add a small delay to ensure file writing is complete
  //       await Future.delayed(const Duration(milliseconds: 500));

  //       final result = await OpenFilex.open(filePath);
  //       debugPrint('OpenFilex result: $result');

  //       if (result.type != ResultType.done) {
  //         throw Exception('Failed to open PDF: ${result.message}');
  //       }
  //     } else {
  //       throw Exception('PDF file not found');
  //     }
  //   } catch (e) {
  //     debugPrint('Error opening PDF: $e');
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error opening PDF: $e')),
  //       );
  //     }
  //   }
  // }

  Uint8List? _pdfData;

  Future<void> captureAndSavePdf({
    required GlobalKey globalKey,
    required Map<String, dynamic>? biodataDetails,
  }) async {
    try {
      // First check for existing valid payment
      bool hasValidPayment = await _checkExistingPayment();

      if (!hasValidPayment) {
        Fluttertoast.showToast(
          msg: 'Buy the plan to save the pdf by clicking create or share pdf.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 10.0,
        );
        return;
      }

      // Proceed with PDF capture and save if payment is valid
      RenderRepaintBoundary boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Generate PDF
      final pdf = pw.Document();
      final imageMemory = pw.MemoryImage(pngBytes);
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.legal,
          build: (pw.Context context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Image(imageMemory, fit: pw.BoxFit.fill),
            );
          },
        ),
      );

      // Save PDF to a temporary file
      final tempDir = await getTemporaryDirectory();
      final fileName = "biodata.pdf";
      final file = File("${tempDir.path}/$fileName");
      await file.writeAsBytes(await pdf.save());

      // Store PDF path and all biodata details in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> savedBiodatas = prefs.getStringList('saved_biodata') ?? [];

      // Create a map with all the necessary details
      Map<String, dynamic> biodataMap = {
        'username': biodataDetails?['username'] ?? '',
        'caste': biodataDetails?['caste'] ?? '',
        'height': biodataDetails?['height'] ?? '',
        'photo1': biodataDetails?['photo1'] ?? '',
        'pdfPath': file.path,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      savedBiodatas.add(jsonEncode(biodataMap));
      await prefs.setStringList('saved_biodata', savedBiodatas);

      Fluttertoast.showToast(
        msg: 'PDF saved successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 10.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error capturing and saving PDF: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 10.0,
      );
    }
  }

  Future<void> _handleShare() async {
    setState(() {
      isShareRequested = true;
      _isLoading = true;
    });

    try {
      await _generatePdf();
      if (_pdfData == null) {
        throw Exception('Failed to generate PDF');
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? planExpiredDateStr = prefs.getString('planExpiredDate');
      String? paymentId = prefs.getString('paymentId');

      log(planExpiredDateStr.toString());

      if (planExpiredDateStr != null && paymentId != null) {
        DateTime planExpiredDate = DateTime.parse(planExpiredDateStr);
        if (DateTime.now().isBefore(planExpiredDate)) {
          // Plan is active, share directly
          await _sharePdf();
        } else {
          // Plan expired, go to payment
          await _navigateToPayment(true);
        }
      } else {
        // No plan, go to payment
        await _navigateToPayment(true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDownload() async {
    setState(() => _isLoading = true);

    try {
      await _generatePdf();
      if (_pdfData == null) {
        throw Exception('Failed to generate PDF');
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? planExpiredDateStr = prefs.getString('planExpiredDate');
      String? paymentId = prefs.getString('paymentId');

      if (planExpiredDateStr != null && paymentId != null) {
        DateTime planExpiredDate = DateTime.parse(planExpiredDateStr);
        if (DateTime.now().isBefore(planExpiredDate)) {
          // Plan is active, download directly
          await _selectFolderAndSavePdf();
        } else {
          // Plan expired, go to payment
          await _navigateToPayment(false);
        }
      } else {
        // No plan, go to payment
        await _navigateToPayment(false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _isPdfGenerating = false;

  Future<Map<String, String?>> _getCurrentUserDetails() async {
    final prefs = await SharedPreferences.getInstance();

    // Use the same keys as registration
    final email = prefs.getString('email');
    final matriId =
        prefs.getString('matri_id'); // Changed to match registration
    final token = prefs.getString('token_key'); // Added token validation
    final phone = prefs.getString('phone'); // Added phone number

    log("Retrieved user details - Email: $email, MatriId: $matriId, Token: ${token != null}, Phone: $phone");

    return {'email': email, 'matriId': matriId, 'token': token, 'phone': phone};
  }

  Future<void> _clearPaymentDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('paymentId');
      await prefs.remove('planExpiredDate');
      await prefs.remove('planName');
      await prefs.remove('planAmount');
      await prefs.remove('payment_email');
      log("Cleared payment details");
    } catch (e) {
      log("Error clearing payment details: $e");
    }
  }

  Future<bool> _checkExistingPayment() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? paymentId = prefs.getString('paymentId');
      String? planExpiredDateStr = prefs.getString('planExpiredDate');
      String? paymentEmail =
          prefs.getString('payment_email'); // Add payment email storage
      String? currentEmail =
          prefs.getString('email'); // Current logged in user's email

      log("Payment ID: $paymentId");
      log("Plan Expiry: $planExpiredDateStr");
      log("Payment Email: $paymentEmail");
      log("Current Email: $currentEmail");

      // If any of these are null, payment is not valid
      if (paymentId == null ||
          planExpiredDateStr == null ||
          paymentEmail == null ||
          currentEmail == null) {
        log("Missing payment information");
        return false;
      }

      // Check if the current email matches the payment email
      if (paymentEmail != currentEmail) {
        log("Email mismatch: Payment was made with different email");
        return false;
      }

      // Check if the plan is expired
      DateTime planExpiredDate = DateTime.parse(planExpiredDateStr);
      if (DateTime.now().isAfter(planExpiredDate)) {
        log("Plan has expired");
        // Clear payment details if expired
        await _clearPaymentDetails();
        return false;
      }

      return true;
    } catch (e) {
      log("Error checking payment: $e");
      return false;
    }
  }

  Future<void> _handlePdfCreation() async {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    if (!isPortrait) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Please rotate your device to portrait mode to proceed'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Always generate new PDF when button is clicked
      setState(() => _isPdfGenerating = true);
      await _generatePdf();
      setState(() => _isPdfGenerating = false);

      // Check for existing valid payment
      bool hasValidPayment = await _checkExistingPayment();

      if (hasValidPayment) {
        // Use app's documents directory instead of direct external storage
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/biodata_${widget.biodataId}.pdf';

        debugPrint('Attempting to save PDF to: $filePath'); // Log file path

        final file = File(filePath);
        await file.writeAsBytes(_pdfData!);

        debugPrint('PDF file saved successfully'); // Log successful save

        await _openPdfFile(filePath);
      } else {
        await _navigateToPayment(false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openPdfFile(String filePath) async {
    try {
      debugPrint('Attempting to open file: $filePath'); // Log file path

      final file = File(filePath);
      if (await file.exists()) {
        debugPrint('File exists, attempting to open'); // Log file existence

        final result = await OpenFilex.open(filePath);

        debugPrint('OpenFilex result: $result'); // Log OpenFilex result
      } else {
        debugPrint('File does not exist'); // Log file not found

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF file not found')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error opening PDF: $e'); // Log opening error

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening PDF: $e')),
        );
      }
    }
  }

  // Modified _selectFolderAndSavePdf to return the file path
  Future<String> _selectFolderAndSavePdf() async {
    try {
      if (_pdfData == null) {
        throw Exception('No PDF data available');
      }

      final directory = Directory("/storage/emulated/0/Download");
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final filePath = '${directory.path}/biodata_${widget.biodataId}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(_pdfData!);

      return filePath;
    } catch (e) {
      throw Exception('Error saving PDF: $e');
    }
  }

  // Modified _navigateToPayment to open PDF after payment
  Future<void> _navigateToPayment(bool isShare) async {
    if (_pdfData == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          pdfData: _pdfData!,
          templateImage: widget.templateImage,
          biodataId: widget.biodataId,
          selectedLanguage: widget.selectedLanguage,
          selectedShape: widget.selectedShape,
          imageSizeMultiplier: widget.imageSizeMultiplier,
          selectedTextSize: widget.selectedTextSize,
          selectedTextColor: widget.selectedTextColor,
          isShareRequested: isShare,
          biodataName: widget.biodataName,
        ),
      ),
    );

    if (result == true) {
      if (isShare) {
        await _sharePdf();
      } else {
        // Save and open PDF after successful payment
        final filePath = await _selectFolderAndSavePdf();
        await _openPdfFile(filePath);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isShare ? 'Sharing PDF...' : 'Opening PDF...'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _generatePdf() async {
    try {
      if (_globalKey.currentContext == null) {
        throw Exception('Widget is not mounted');
      }

      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to generate image data');
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();

      final pdf = pw.Document();
      final imageMemory = pw.MemoryImage(pngBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.legal,
          build: (pw.Context context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Image(imageMemory, fit: pw.BoxFit.cover),
            );
          },
        ),
      );

      _pdfData = await pdf.save();
    } catch (e) {
      throw Exception('Error generating PDF: $e');
    }
  }

  Future<void> _sharePdf() async {
    try {
      if (_pdfData == null) {
        throw Exception('No PDF data available');
      }

      // Get the temporary directory
      final tempDir = await getTemporaryDirectory();

      // Create a temporary file
      final tempFile = File(
        '${tempDir.path}/biodata_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      // Write the PDF data to the temporary file
      await tempFile.writeAsBytes(_pdfData!);

      // Share the PDF file using share_plus
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'Shared from Biodata Maker',
      );
    } catch (e) {
      throw Exception('Error sharing PDF: $e');
    }
  }

  // Future<void> _sharePdf() async {
  //   try {
  //     if (_pdfData == null) {
  //       throw Exception('No PDF data available');
  //     }

  //     final tempDir = await getTemporaryDirectory();
  //     final tempFile = File(
  //       '${tempDir.path}/biodata_${DateTime.now().millisecondsSinceEpoch}.pdf',
  //     );
  //     await tempFile.writeAsBytes(_pdfData!);

  //     await Share.shareFiles(
  //       [tempFile.path],
  //       text: 'Shared from Biodata Maker',
  //     );
  //   } catch (e) {
  //     throw Exception('Error sharing PDF: $e');
  //   }
  // }

  bool isShareRequested = false;

  double _getTextSize(String selectedTextSize) {
    if (selectedTextSize == "Small") {
      return 4.sp; // Small text size
    } else if (selectedTextSize == "Medium") {
      return 6.sp; // Medium text size
    } else if (selectedTextSize == "Large") {
      return 9.sp; // Large text size
    }
    return 8.sp; // Default size if no valid size is selected
  }

  String? _combineValues(String? caste, String? subcaste) {
    if ((caste == null || caste.trim().isEmpty || caste == 'N/A') &&
        (subcaste == null || subcaste.trim().isEmpty || subcaste == 'N/A')) {
      return null; // Return null if both values are invalid
    }

    // Combine caste and subcaste if they are valid
    String combined = '';
    if (caste != null && caste.trim().isNotEmpty && caste != 'N/A') {
      combined = caste;
    }
    if (subcaste != null && subcaste.trim().isNotEmpty && subcaste != 'N/A') {
      combined = combined.isEmpty ? subcaste : '$combined, $subcaste';
    }

    return combined;
  }

  TableRow? _buildTableRow(String label, String? value) {
    if (value == null || value.trim().isEmpty || value == 'N/A') {
      return null; // Skip rows with no valid value
    }

    return TableRow(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: _getTextSize(widget.selectedTextSize),
            color: widget.selectedTextColor,
          ),
        ),
        Text(
          ":",
          style: TextStyle(
            fontSize: _getTextSize(widget.selectedTextSize),
            color: widget.selectedTextColor,
          ),
        ),
        Padding(
          padding: EdgeInsets.all(2.0),
          child: Text(
            value,
            style: TextStyle(
              fontSize: _getTextSize(widget.selectedTextSize),
              color: widget.selectedTextColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsTable(List<TableRow?> rows) {
    return Table(
      columnWidths: {
        0: FixedColumnWidth(80.w),
        1: FixedColumnWidth(5.w),
        2: FlexColumnWidth(),
      },
      children: rows.whereType<TableRow>().toList(), // Filter out null rows
    );
  }

  Widget _buildSectionTitle(String title, dynamic widget) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Text(
        title,
        style: TextStyle(
          fontSize: _getTextSize(widget.selectedTextSize),
          fontWeight: FontWeight.bold,
          color: widget.selectedTextColor,
        ),
      ),
    );
  }

  List<Map<String, String>> _processSpecificFields(
      Map<String, dynamic> data, int formNumber) {
    List<Map<String, String>> processedFields = [];
    String formSuffix = formNumber == 1 ? '' : '_form$formNumber';

    for (int i = 1; i <= 5; i++) {
      String titleKey = 'field_${i}_title$formSuffix';
      String valueKey = 'field_${i}_value$formSuffix';

      if (data[titleKey] != null &&
          data[valueKey] != null &&
          data[titleKey].toString().isNotEmpty &&
          data[valueKey].toString().isNotEmpty) {
        processedFields
            .add({'label': data[titleKey], 'controllerValue': data[valueKey]});
      }
    }
    return processedFields;
  }

  List<TableRow> _buildDynamicRows(List<Map<String, String>> dynamicData) {
    return dynamicData
        .map((field) =>
            _buildTableRow(field['label'] ?? '', field['controllerValue']))
        .where((row) => row != null)
        .map((row) => row!)
        .toList();
  }

  int _calculateTotalDataCount(Map<String, dynamic>? data) {
    if (data == null) return 0;

    int staticFieldsCount = 30; // Your base fields count

    // Count form 1 fields
    int form1Count = _processSpecificFields(data, 1).length;

    // Count form 2 fields
    int form2Count = _processSpecificFields(data, 2).length;

    // Count form 3 fields
    int form3Count = _processSpecificFields(data, 3).length;

    // Count form 4 fields
    int form4Count = _processSpecificFields(data, 4).length;

    return staticFieldsCount +
        form1Count +
        form2Count +
        form3Count +
        form4Count;
  }

// Update the height calculation function
  double calculateDynamicHeight({
    required int staticFieldsCount,
    required Map<String, dynamic>? biodataDetails,
  }) {
    double baseHeight = 560.h;
    double extraHeightPerRow = 15.h;

    if (biodataDetails == null) return baseHeight;

    int totalDataCount = _calculateTotalDataCount(biodataDetails);
    int totalRows = 28; // Threshold for rows

    if (totalDataCount > totalRows) {
      int extraRows = totalDataCount - totalRows;
      return baseHeight + (extraRows * extraHeightPerRow);
    }

    return baseHeight;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    double calculatedHeight = calculateDynamicHeight(
      staticFieldsCount: 30,
      biodataDetails: biodataDetails,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return TemplateDetailPage(
                    selectedTemplateUrl: widget.templateImage,
                    biodataId: widget.biodataId,
                    selectedLanguage: widget.selectedLanguage,
                    biodataName: widget.biodataName,
                  );
                },
              ),
            );
          },
          icon: Icon(
            Icons.arrow_back,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Biodata Preview',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18.sp, // Responsive font size
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : biodataDetails == null
                  ? Center(
                      child: Text('No biodata found'),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 12.h,
                          ),
                          RepaintBoundary(
                            key: _globalKey,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                bool isPortrait =
                                    MediaQuery.of(context).orientation ==
                                        Orientation.portrait;
                                return SingleChildScrollView(
                                  child: InteractiveViewer(
                                    transformationController:
                                        _transformationController,
                                    minScale: 0.5,
                                    maxScale: 4.0,
                                    child: Column(
                                      children: [
                                        Container(
                                          // height: 530.h,
                                          // height: calculatedHeight,
                                          height: isPortrait
                                              ? calculatedHeight
                                              : 550.h,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                widget.templateImage,
                                              ),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 28.h,
                                                ),
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 7.h),
                                                    child: Text(
                                                      biodataDetails?[
                                                              'title'] ??
                                                          'Title',
                                                      style: TextStyle(
                                                        fontSize: _getTextSize(
                                                            widget
                                                                .selectedTextSize),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: widget
                                                            .selectedTextColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    widget.biodataName.isEmpty
                                                        ? localizations!.biodata
                                                        : widget.biodataName,
                                                    // localizations!.biodata,
                                                    style: TextStyle(
                                                      // fontSize: _getTextSize(widget
                                                      //         .selectedTextSize) *
                                                      //     1,
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: widget
                                                          .selectedTextColor,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 26.w),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            _buildSectionTitle(
                                                                localizations!
                                                                    .personalDetails,
                                                                widget),
                                                            _buildDetailsTable(
                                                              [
                                                                _buildTableRow(
                                                                    localizations
                                                                        .fullName,
                                                                    biodataDetails?[
                                                                        'username']),
                                                                _buildTableRow(
                                                                  localizations
                                                                      .caste,
                                                                  _combineValues(
                                                                      biodataDetails?[
                                                                          'caste'],
                                                                      biodataDetails?[
                                                                          'subcaste']),
                                                                ),

                                                                _buildTableRow(
                                                                    localizations
                                                                        .birthDate,
                                                                    formatDate(
                                                                        biodataDetails?[
                                                                            'birthdate'])),
                                                                _buildTableRow(
                                                                    localizations
                                                                        .birthTime,
                                                                    biodataDetails?[
                                                                        'birthtime']),
                                                                _buildTableRow(
                                                                    localizations
                                                                        .birthPlace,
                                                                    biodataDetails?[
                                                                        'birthplace']),
                                                                _buildTableRow(
                                                                    localizations
                                                                        .height,
                                                                    biodataDetails?[
                                                                        'height']),
                                                                _buildTableRow(
                                                                    localizations
                                                                        .bloodGroup,
                                                                    biodataDetails?[
                                                                        'blood_group']),
                                                                _buildTableRow(
                                                                    localizations
                                                                        .gothra,
                                                                    biodataDetails?[
                                                                        'gothra']),
                                                                _buildTableRow(
                                                                    localizations
                                                                        .complexion,
                                                                    biodataDetails?[
                                                                        'complexion']),
                                                                ..._buildDynamicRows(
                                                                    _processSpecificFields(
                                                                        biodataDetails ??
                                                                            {},
                                                                        1)),

                                                                _buildTableRow(
                                                                    localizations
                                                                        .education,
                                                                    biodataDetails?[
                                                                            'education_detail'] ??
                                                                        'N/A'),
                                                                _buildTableRow(
                                                                    localizations
                                                                        .occupation,
                                                                    biodataDetails?[
                                                                            'occupation'] ??
                                                                        'N/A'),
                                                                _buildTableRow(
                                                                    localizations
                                                                        .annualIncome,
                                                                    biodataDetails?[
                                                                            'income'] ??
                                                                        'N/A'),
                                                                ..._buildDynamicRows(
                                                                    _processSpecificFields(
                                                                        biodataDetails ??
                                                                            {},
                                                                        2)),
                                                                // ..._buildDynamicRows(
                                                                //     widget
                                                                //         .dynamicFieldValues2),
                                                              ],
                                                            ),
                                                            _buildSectionTitle(
                                                                localizations
                                                                    .familyDetails,
                                                                widget),
                                                            _buildDetailsTable(
                                                              [
                                                                _buildTableRow(
                                                                    localizations
                                                                        .fathersName,
                                                                    biodataDetails?[
                                                                        'father_name']),
                                                                _buildTableRow(
                                                                    localizations
                                                                        .fathersOccupation,
                                                                    biodataDetails?[
                                                                            'father_occupation'] ??
                                                                        'N/A'),
                                                                _buildTableRow(
                                                                    localizations
                                                                        .mobileNumber,
                                                                    biodataDetails?[
                                                                        'mobile']),
                                                                _buildTableRow(
                                                                    localizations
                                                                        .mothersName,
                                                                    biodataDetails?[
                                                                            'mother_name'] ??
                                                                        'N/A'),
                                                                _buildTableRow(
                                                                    localizations
                                                                        .mothersOccupation,
                                                                    biodataDetails?[
                                                                            'mother_occupation'] ??
                                                                        'N/A'),

                                                                _buildTableRow(
                                                                    localizations
                                                                        .totalBrothers,
                                                                    biodataDetails?[
                                                                            'no_of_brothers'] ??
                                                                        'N/A'),
                                                                _buildTableRow(
                                                                    localizations
                                                                        .totalSisters,
                                                                    biodataDetails?[
                                                                            'no_of_sisters'] ??
                                                                        'N/A'),
                                                                _buildTableRow(
                                                                    localizations
                                                                        .relativeName,
                                                                    biodataDetails?[
                                                                            'surname_of_relatives'] ??
                                                                        'N/A'),
                                                                _buildTableRow(
                                                                    localizations
                                                                        .relativeAddress,
                                                                    biodataDetails?[
                                                                            'address'] ??
                                                                        'N/A'),
                                                                _buildTableRow(
                                                                    localizations
                                                                        .nativePlace,
                                                                    biodataDetails?[
                                                                            'family_native_place'] ??
                                                                        'N/A'),
                                                                ..._buildDynamicRows(
                                                                    _processSpecificFields(
                                                                        biodataDetails ??
                                                                            {},
                                                                        3)),
                                                                // ..._buildDynamicRows(
                                                                //     widget
                                                                //         .dynamicFieldValues3),
                                                                _buildTableRow(
                                                                    localizations
                                                                        .property,
                                                                    biodataDetails?[
                                                                            'property'] ??
                                                                        'N/A'),
                                                                _buildTableRow(
                                                                    localizations
                                                                        .expectations,
                                                                    biodataDetails?[
                                                                            'expectations'] ??
                                                                        'N/A'),
                                                                ..._buildDynamicRows(
                                                                    _processSpecificFields(
                                                                        biodataDetails ??
                                                                            {},
                                                                        4)),
                                                                // ..._buildDynamicRows(
                                                                //     widget
                                                                //         .dynamicFieldValues4),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(width: 5.w),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Column(
                                                          children: [
                                                            // _buildDisplayImage(
                                                            //     context,
                                                            //     'photo1'),
                                                            // SizedBox(
                                                            //     height: 20),
                                                            // _buildDisplayImage(
                                                            //     context,
                                                            //     'photo2'),
                                                            SizedBox(
                                                              height: 20.h,
                                                            ),
                                                            if (biodataDetails?[
                                                                        'photo1'] !=
                                                                    null &&
                                                                biodataDetails?[
                                                                        'photo1']!
                                                                    .isNotEmpty) ...[
                                                              _buildDisplayImage(
                                                                  context,
                                                                  'photo1'),
                                                              SizedBox(
                                                                  height: 16.h),
                                                              _buildDisplayImage(
                                                                  context,
                                                                  'photo2'),
                                                            ] else if (biodataDetails?[
                                                                        'photo2'] !=
                                                                    null &&
                                                                biodataDetails?[
                                                                        'photo2']!
                                                                    .isNotEmpty) ...[
                                                              _buildDisplayImage(
                                                                  context,
                                                                  'photo2'),
                                                            ] else
                                                              ...[],
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
      bottomNavigationBar: Container(
        height: 60.h,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.orange, width: 2.w),
                ),
                onPressed: _isLoading ? null : _handlePdfCreation,
                child: Text(
                  'Create PDF',
                  style: TextStyle(color: Colors.black, fontSize: 12.sp),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.orange, width: 2.w),
                ),
                onPressed: _isLoading ? null : _handleShare,
                child: Text(
                  'Share PDF',
                  style: TextStyle(color: Colors.black, fontSize: 12.sp),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.orange, width: 2),
                ),
                onPressed: () async {
                  String username = biodataDetails?['username'];
                  await captureAndSavePdf(
                    globalKey: _globalKey,
                    biodataDetails: biodataDetails,
                  );
                },
                child: Text(
                  'Save',
                  style: TextStyle(color: Colors.black, fontSize: 12.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
