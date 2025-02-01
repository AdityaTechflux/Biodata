import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
// import 'package:bio_data/screens/biodata_previewpage2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../consts/app_urls.dart';
// import '../request/education_details_api.dart';
import 'biodata_preview_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'create_bio_data_screen/create_bio_data_screen.dart';
// import 'dart:ui' as ui;

// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;

import 'template_selection_page.dart';

class TemplateDetailPage extends StatefulWidget {
  final String selectedTemplateUrl;
  final String biodataId;
  final String selectedLanguage;
  final String biodataName;
  // final List<Map<String, dynamic>> dynamicFieldValues1;
  // final List<Map<String, dynamic>> dynamicFieldValues2;
  // final List<Map<String, dynamic>> dynamicFieldValues3;
  // final List<Map<String, dynamic>> dynamicFieldValues4;

  const TemplateDetailPage({
    Key? key,
    required this.selectedTemplateUrl,
    required this.biodataId,
    required this.selectedLanguage,
    required this.biodataName,

    // required this.dynamicFieldValues1,
    // required this.dynamicFieldValues2,
    // required this.dynamicFieldValues3,
    // required this.dynamicFieldValues4,
  }) : super(key: key);

  @override
  _TemplateDetailPageState createState() => _TemplateDetailPageState();
}

class _TemplateDetailPageState extends State<TemplateDetailPage> {
  Map<String, dynamic>? biodataDetails;
  bool isLoading = true;
  String? errorMessage;

  String selectedShape = "Square";
  String selectedSize = "Default";
  double imageSizeMultiplier = 1.0;
  double baseImageSize = 50.0;
  String selectedColor = "Black";
  String selectedTextSize = "Large";
  double textSizeMultiplier = 1.0;
  double textSize = 14.sp;

  Color textColor = Colors.black;

  GlobalKey _globalKey = GlobalKey();

  // @override
  // void initState() {
  //   super.initState();
  //   print("bio data is is ${widget.biodataId}");
  //   selectedTextSize = "Large";
  //   WidgetsBinding.instance.addObserver(this);
  //   _secureScreen();

  //   fetchBiodataDetails();
  //   _loadPreferences().then((_) {
  //     print(
  //         'Preferences loaded: $selectedShape, $selectedSize, $selectedColor, $selectedTextSize');
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addObserver();
    _secureScreen();
    print("bio data is is ${widget.biodataId}");
    selectedTextSize = "Large";

    fetchBiodataDetails();
    _loadPreferences().then((_) {
      print(
          'Preferences loaded: $selectedShape, $selectedSize, $selectedColor, $selectedTextSize');
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

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('${widget.biodataId}_shape', selectedShape);
    await prefs.setString('${widget.biodataId}_size', selectedSize);
    await prefs.setString('${widget.biodataId}_color', selectedColor);
    await prefs.setString('${widget.biodataId}_textSize', selectedTextSize);
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedShape = prefs.getString('${widget.biodataId}_shape') ?? "Square";
      selectedSize = prefs.getString('${widget.biodataId}_size') ?? "Default";
      selectedColor = prefs.getString('${widget.biodataId}_color') ?? "Black";
      selectedTextSize =
          prefs.getString('${widget.biodataId}_textSize') ?? "Large";
      _updateSettings();
    });
  }

  void _updateSettings() {
    // Update image size multiplier
    switch (selectedSize) {
      case "Default":
        imageSizeMultiplier = 2.4;
        break;
      case "Increase 1x":
        imageSizeMultiplier = 1.2;
        break;
      case "Increase 2x":
        imageSizeMultiplier = 1.4;
        break;
      case "Increase 3x":
        imageSizeMultiplier = 1.6;
        break;
      case "Increase 4x":
        imageSizeMultiplier = 1.8;
        break;
      case "Increase 5x":
        imageSizeMultiplier = 2.0;
        break;
      case "Increase 6x":
        imageSizeMultiplier = 2.4;
        break;
      default:
        imageSizeMultiplier = 2.4;
    }

    // Update text size multiplier
    switch (selectedTextSize) {
      case "Small":
        textSizeMultiplier = 0.6;
        break;
      case "Medium":
        textSizeMultiplier = 0.8;
        break;
      case "Large":
        textSizeMultiplier = 1.0;
        break;
      default:
        textSizeMultiplier = 1.0;
    }

    // Update text color
    switch (selectedColor) {
      case "Black":
        textColor = Colors.black;
        break;
      case "Red":
        textColor = Colors.red;
        break;
      case "Blue":
        textColor = Colors.blue;
        break;
      default:
        textColor = Colors.black;
    }
  }

  void _showPhotoSizeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(),
          title: const Text('Select Photo Size'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSizeOption("Default"),
              _buildSizeOption("Increase 1x"),
              _buildSizeOption("Increase 2x"),
              _buildSizeOption("Increase 3x"),
              _buildSizeOption("Increase 4x"),
              _buildSizeOption("Increase 5x"),
              _buildSizeOption("Increase 6x"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSizeOption(String label) {
    return RadioListTile(
      title: Text(label),
      value: label,
      groupValue: selectedSize,
      onChanged: (value) {
        setState(() {
          selectedSize = value!;
          _updateSettings();
          _savePreferences();
        });
        Navigator.pop(context);
      },
    );
  }

  void _showPhotoShapeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(),
          title: const Text('Select Photo Shape'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildShapeOption("No Image"),
              _buildShapeOption("Circle"),
              _buildShapeOption("Square"),
              _buildShapeOption("Round Square"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShapeOption(String shape) {
    return RadioListTile(
      title: Text(shape),
      value: shape,
      groupValue: selectedShape,
      onChanged: (value) {
        setState(() {
          selectedShape = value!;
          _savePreferences();
        });
        Navigator.pop(context);
      },
    );
  }

  void _showTextSizeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(),
          title: const Text('Select Text Size'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextSizeOption("Small"),
              _buildTextSizeOption("Medium"),
              _buildTextSizeOption("Large"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextSizeOption(String size) {
    return RadioListTile(
      title: Text(size),
      value: size,
      groupValue: selectedTextSize,
      onChanged: (value) {
        setState(() {
          selectedTextSize = value!;
          _updateSettings();
          _savePreferences();
        });
        Navigator.pop(context);
      },
    );
  }

  void _showColorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(),
          title: const Text('Select Text Color'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildColorOption("Black"),
              _buildColorOption("Red"),
              _buildColorOption("Blue"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorOption(String color) {
    return RadioListTile(
      title: Text(color),
      value: color,
      groupValue: selectedColor,
      onChanged: (value) {
        setState(() {
          selectedColor = value!;
          _updateSettings();
          _savePreferences();
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildDisplayImage(String key) {
    // If image URL is null or empty, return nothing
    if (biodataDetails?[key] == null || biodataDetails![key]!.isEmpty) {
      return SizedBox
          .shrink(); // This will make the image space disappear completely
    }

    double baseImageSize = MediaQuery.of(context).size.width * 0.12;
    double imageSize = baseImageSize * imageSizeMultiplier;

    // Handle "No Image" case
    if (selectedShape == "No Image") {
      return SizedBox.shrink();
    }

    // Decide shape of the image
    Widget imageWidget;
    if (selectedShape == "Circle") {
      imageWidget = ClipOval(
        child: CachedNetworkImage(
          imageUrl: biodataDetails![key]!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => Icon(
            Icons.person,
            size: imageSize * 0.4,
            color: Colors.grey[600],
          ),
        ),
      );
    } else if (selectedShape == "Round Square") {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: CachedNetworkImage(
          imageUrl: biodataDetails![key]!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => Icon(
            Icons.person,
            size: imageSize * 0.4,
            color: Colors.grey[600],
          ),
        ),
      );
    } else {
      imageWidget = CachedNetworkImage(
        imageUrl: biodataDetails![key]!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => Icon(
          Icons.person,
          size: imageSize * 0.4,
          color: Colors.grey[600],
        ),
      );
    }

    return Container(
      height: imageSize,
      width: imageSize,
      decoration: BoxDecoration(
        shape: selectedShape == "Circle" ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: selectedShape == "Round Square"
            ? BorderRadius.circular(15.0)
            : null,
      ),
      child: imageWidget,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _savePreferences();
  }

  Future<void> fetchBiodataDetails() async {
    try {
      // Fetching biodata using the provided biodataId
      final response = await http.get(
        Uri.parse(
            '${AppUrls.baseUrl}/api/users/showBiodataByBiodataId?biodata_id=${widget.biodataId}'),
      );
      // final response = await http.get(
      //   Uri.parse(
      //       'http://allindiamatrimonial.com/royal_maratha/api/users/showBiodataByBiodataId?biodata_id=${widget.biodataId}'),
      // );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log('API Response: $data'); // Debug print

        if (data['status'] == true && data['data'] != null) {
          setState(() {
            biodataDetails = data['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = 'No biodata found';
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

  List<Map<String, dynamic>> savedBiodata = [];

  // Save the biodata in SharedPreferences
  Future<void> saveBiodata(Map<String, dynamic> biodata) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Fetch previously saved biodata list, or create an empty list if not available
    List<String> savedBiodataList = prefs.getStringList('savedBiodata') ?? [];

    // Convert the new biodata to JSON
    String biodataJson = json.encode(biodata);

    // Add the new biodata to the list
    savedBiodataList.add(biodataJson);

    // Save the updated list back to SharedPreferences
    await prefs.setStringList('savedBiodata', savedBiodataList);
  }

  // Fetch saved biodata from SharedPreferences

  double calculateDynamicFontSize(
      String content, double baseSize, double maxLength, int totalFields) {
    if (totalFields > 18) {
      return 14.sp * textSizeMultiplier;
    }

    return 20.sp * textSizeMultiplier;
  }

  // Make sure the preferences are saved when a setting changes
  void _updateAndSavePreferences(String key, String value) {
    setState(() {
      switch (key) {
        case 'shape':
          selectedShape = value;
          break;
        case 'size':
          selectedSize = value;
          break;
        case 'color':
          selectedColor = value;
          break;
        case 'textSize':
          selectedTextSize = value;
          break;
      }
    });

    // Save preferences to SharedPreferences
    _savePreferences(); // This will store all the updated preferences
  }

  // Store the preferences properly, including the color

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

  Uint8List? _pdfData;
  bool _isCapturing = false;

  List<Map<String, String>> _processFields(Map<String, dynamic> data) {
    // Initialize list to store processed fields
    List<Map<String, String>> processedFields = [];

    // Process form 1 (default fields)
    for (int i = 1; i <= 5; i++) {
      String titleKey = 'field_${i}_title';
      String valueKey = 'field_${i}_value';

      if (data[titleKey] != null && data[valueKey] != null) {
        processedFields
            .add({'label': data[titleKey], 'controllerValue': data[valueKey]});
      }
    }

    // Process forms 2-4
    for (int form = 2; form <= 4; form++) {
      for (int i = 1; i <= 5; i++) {
        String titleKey = 'field_${i}_title_form$form';
        String valueKey = 'field_${i}_value_form$form';

        if (data[titleKey] != null && data[valueKey] != null) {
          processedFields.add(
              {'label': data[titleKey], 'controllerValue': data[valueKey]});
        }
      }
    }

    return processedFields;
  }

  // List<TableRow> _buildDynamicRows(List<Map<String, dynamic>> dynamicData) {
  //   List<TableRow> rows = [];

  //   for (var field in dynamicData) {
  //     final label = field['label'];
  //     final value = field['controllerValue'];

  //     if (label != null &&
  //         value != null &&
  //         label.toString().trim().isNotEmpty &&
  //         value.toString().trim().isNotEmpty) {
  //       rows.add(_buildTableRow(label, value)!);
  //     }
  //   }

  //   return rows; // Returns only valid rows
  // }

  // double calculateDynamicHeight({
  //   required int staticFieldsCount,
  //   required List<List<dynamic>> dynamicFieldsLists,
  //   double rowHeight = 20.0,
  // }) {
  //   double totalFields = staticFieldsCount +
  //       dynamicFieldsLists.fold(0, (sum, list) => sum + list.length);

  //   return totalFields * rowHeight;
  // }

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
            fontSize: 9.sp * textSizeMultiplier, // Adjust font size
            color: textColor, // Apply dynamic text color
          ),
        ),
        Text(
          ":",
          style: TextStyle(
            fontSize: 9.sp * textSizeMultiplier, // Adjust font size
            color: textColor, // Apply dynamic text color
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 9.sp * textSizeMultiplier, // Adjust font size
              color: textColor, // Apply dynamic text color
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    double calculatedHeight = calculateDynamicHeight(
      staticFieldsCount: 30,
      biodataDetails: biodataDetails,
    );

    if (localizations == null ||
        biodataDetails == null ||
        widget.selectedTemplateUrl == null) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'Template Details',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFFFF5507),
        ),
        body: Center(
          child: CircularProgressIndicator(), // Show loading indicator
        ),
      );
    }

    double baseHeight = 560.h;

    // Calculate extra height dynamically
    int totalRows = 30; // Threshold for rows
    int totalDataCount = _calculateTotalDataCount(biodataDetails);
    double extraHeightPerRow = 20.h; // Extra height per additional row

    // Dynamic height logic
    double dynamicHeight = baseHeight;
    if (totalDataCount > totalRows) {
      int extraRows = totalDataCount - totalRows;
      dynamicHeight += extraRows * extraHeightPerRow;
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return TemplateSelectionPage(
                    id: widget.biodataId,
                    selectedLanguage: widget.selectedLanguage,
                    biodataName: '',
                  );
                },
              ),
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Template Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFFF5507),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isPortrait =
              MediaQuery.of(context).orientation == Orientation.portrait;
          return Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: RepaintBoundary(
              key: _globalKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            height: isPortrait ? calculatedHeight : 550.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                  widget.selectedTemplateUrl,
                                ),
                                fit: BoxFit.fill,
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize:
                                    MainAxisSize.min, // Adjust size dynamically
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 25.h,
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: 8.h),
                                      child: Text(
                                        biodataDetails?['title'] ?? 'Title',
                                        style: TextStyle(
                                          fontSize: 9.sp *
                                              textSizeMultiplier, // Adjusted font size
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
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
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 23.w),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 5.h,
                                              ),
                                              Text(
                                                localizations.personalDetails,
                                                style: TextStyle(
                                                  fontSize:
                                                      9.sp * textSizeMultiplier,
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
                                                ),
                                              ),
                                              Table(
                                                columnWidths: {
                                                  0: FixedColumnWidth(90.w),
                                                  1: FixedColumnWidth(5.w),
                                                  2: FlexColumnWidth(),
                                                },
                                                children: [
                                                  _buildTableRow(
                                                      localizations.fullName,
                                                      biodataDetails?[
                                                          'username']),
                                                  _buildTableRow(
                                                    localizations.caste,
                                                    _combineValues(
                                                        biodataDetails?[
                                                            'caste'],
                                                        biodataDetails?[
                                                            'subcaste']),
                                                  ),
                                                  _buildTableRow(
                                                      localizations.birthDate,
                                                      formatDate(
                                                          biodataDetails?[
                                                              'birthdate'])),
                                                  _buildTableRow(
                                                      localizations.birthTime,
                                                      biodataDetails?[
                                                          'birthtime']),
                                                  _buildTableRow(
                                                      localizations.birthPlace,
                                                      biodataDetails?[
                                                          'birthplace']),
                                                  _buildTableRow(
                                                      localizations.height,
                                                      biodataDetails?[
                                                          'height']),
                                                  _buildTableRow(
                                                      localizations.bloodGroup,
                                                      biodataDetails?[
                                                          'blood_group']),
                                                  _buildTableRow(
                                                      localizations.gothra,
                                                      biodataDetails?[
                                                          'gothra']),
                                                  _buildTableRow(
                                                      localizations.complexion,
                                                      biodataDetails?[
                                                          'complexion']),
                                                  ..._buildDynamicRows(
                                                      _processSpecificFields(
                                                          biodataDetails ?? {},
                                                          1)),
                                                  // _buildTableRow(
                                                  //     localizations
                                                  //         .educationLevel,
                                                  //     biodataDetails?[
                                                  //         'education_level']),
                                                  _buildTableRow(
                                                      localizations.education,
                                                      biodataDetails?[
                                                          'education_detail']),
                                                  _buildTableRow(
                                                      localizations.occupation,
                                                      biodataDetails?[
                                                          'occupation']),

                                                  _buildTableRow(
                                                      localizations
                                                          .annualIncome,
                                                      biodataDetails?[
                                                          'income']),
                                                  ..._buildDynamicRows(
                                                      _processSpecificFields(
                                                          biodataDetails ?? {},
                                                          2)),

                                                  // ..._buildDynamicRows(
                                                  //   widget.dynamicFieldValues1,
                                                  // ),
                                                  // ..._buildDynamicRows(
                                                  //   widget.dynamicFieldValues2,
                                                  // ),
                                                ]
                                                    .whereType<TableRow>()
                                                    .toList(), // Filter out null rows
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 5),
                                                child: Text(
                                                  localizations.familyDetails,
                                                  style: TextStyle(
                                                    fontSize: 10.sp *
                                                        textSizeMultiplier,
                                                    fontWeight: FontWeight.bold,
                                                    color: textColor,
                                                  ),
                                                ),
                                              ),
                                              Table(
                                                columnWidths: {
                                                  0: FixedColumnWidth(90.w),
                                                  1: FixedColumnWidth(10.w),
                                                  2: FlexColumnWidth(),
                                                },
                                                children: [
                                                  _buildTableRow(
                                                      localizations.fathersName,
                                                      biodataDetails?[
                                                          'father_name']),
                                                  _buildTableRow(
                                                      localizations
                                                          .fathersOccupation,
                                                      biodataDetails?[
                                                          'father_occupation']),
                                                  _buildTableRow(
                                                      localizations
                                                          .mobileNumber,
                                                      biodataDetails?[
                                                          'mobile']),
                                                  _buildTableRow(
                                                      localizations.mothersName,
                                                      biodataDetails?[
                                                          'mother_name']),
                                                  _buildTableRow(
                                                      localizations
                                                          .mothersOccupation,
                                                      biodataDetails?[
                                                          'mother_occupation']),
                                                  _buildTableRow(
                                                      localizations
                                                          .totalBrothers,
                                                      biodataDetails?[
                                                          'no_of_brothers']),
                                                  _buildTableRow(
                                                      localizations
                                                          .totalSisters,
                                                      biodataDetails?[
                                                          'no_of_sisters']),
                                                  _buildTableRow(
                                                      localizations
                                                          .relativeName,
                                                      biodataDetails?[
                                                          'surname_of_relatives']),
                                                  _buildTableRow(
                                                      localizations
                                                          .relativeAddress,
                                                      biodataDetails?[
                                                          'address']),
                                                  _buildTableRow(
                                                      localizations.nativePlace,
                                                      biodataDetails?[
                                                          'family_native_place']),
                                                  ..._buildDynamicRows(
                                                      _processSpecificFields(
                                                          biodataDetails ?? {},
                                                          3)),
                                                  _buildTableRow(
                                                      localizations.property,
                                                      biodataDetails?[
                                                          'property']),
                                                  _buildTableRow(
                                                      localizations
                                                          .expectations,
                                                      biodataDetails?[
                                                          'expectations']),
                                                  ..._buildDynamicRows(
                                                      _processSpecificFields(
                                                          biodataDetails ?? {},
                                                          4)),
                                                ]
                                                    .whereType<TableRow>()
                                                    .toList(),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                height: 25.h,
                                              ),
                                              // Conditional logic to check photo1 and photo2
                                              if (biodataDetails?['photo1'] !=
                                                      null &&
                                                  biodataDetails?['photo1']!
                                                      .isNotEmpty) ...[
                                                _buildDisplayImage('photo1'),
                                                SizedBox(height: 16.h),
                                                _buildDisplayImage('photo2'),
                                              ] else if (biodataDetails?[
                                                          'photo2'] !=
                                                      null &&
                                                  biodataDetails?['photo2']!
                                                      .isNotEmpty) ...[
                                                _buildDisplayImage('photo2'),
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
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.orange, width: 2.w),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateBioDataScreen(
                              uid: widget.biodataId,
                              isEdit: true,
                              // initialBiodataTitle is optional now, so you don't need to provide it
                            ),
                          ),
                        );
                        log((widget.biodataId ?? '').toString());
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit,
                            size: 20.sp,
                            color: Colors.black,
                          ),
                          SizedBox(
                            width: 5.h,
                          ),
                          Text(
                            'Edit Biodata',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.black,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: _showPhotoShapeDialog,
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/shapesp.png",
                                height:
                                    MediaQuery.of(context).size.width * 0.08,
                                width: 30.w,
                              ),
                              SizedBox(
                                height: 8.h,
                              ),
                              Text(
                                "Photo Shape",
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _showPhotoSizeDialog,
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/image.png",
                                height:
                                    MediaQuery.of(context).size.width * 0.08,
                                width: 30.w,
                              ),
                              SizedBox(
                                height: 8.h,
                              ),
                              Text(
                                "Photo Size",
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _showTextSizeDialog,
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/text-size.png",
                                height:
                                    MediaQuery.of(context).size.width * 0.08,
                                width: 30.w,
                              ),
                              SizedBox(
                                height: 8.h,
                              ),
                              Text(
                                "Text Size",
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _showColorDialog,
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/text.png",
                                height:
                                    MediaQuery.of(context).size.width * 0.08,
                                width: 30.w,
                                color: Colors.black,
                              ),
                              SizedBox(
                                height: 8.h,
                              ),
                              Text(
                                "Color",
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.orange, width: 2.w),
                          ),
                          onPressed: () {
                            // _captureScreenAndNavigate(context: context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BiodataPreviewPage(
                                  templateImage: widget.selectedTemplateUrl,
                                  biodataId: widget.biodataId,
                                  selectedLanguage: widget.selectedLanguage,
                                  selectedShape: selectedShape,
                                  imageSizeMultiplier: imageSizeMultiplier,
                                  selectedTextSize: selectedTextSize,
                                  selectedTextColor: textColor,
                                  biodataName: widget.biodataName,
                                ),
                              ),
                            );

                            // Log the values to check if everything is passing correctly
                            log("Selected language : ${widget.selectedLanguage}");
                            log("Selected shape : ${selectedShape}");
                            log("Selected size : ${selectedSize}");
                            // log("Biodata ID : ${EducationDetailsRequest().newBiodataId.toString()}");
                            log("Selected text size: $selectedTextSize");
                            log("Selected text color: $textColor");
                            // log("Dynamic fields1: ${widget.dynamicFieldValues1}");
                            // log("Dynamic fields2: ${widget.dynamicFieldValues2}");
                            // log("Dynamic fields3: ${widget.dynamicFieldValues3}");
                            // log("Dynamic fields4: ${widget.dynamicFieldValues4}");
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red,
                              ),
                              SizedBox(
                                width: 5.w,
                              ),
                              Text(
                                'Create PDF',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
