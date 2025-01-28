import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bio_data/consts/colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../consts/app_urls.dart';
import '../../consts/lists.dart';
import '../../controller/language_controller.dart';
import '../../helper/helper.dart';
import '../../request/education_details_api.dart';
import '../height_selector_dialog.dart';
import '../image_cropper_widget.dart';
import '../template_selection_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
// import 'package:image_cropper/image_cropper.dart';

class GridPainter extends CustomPainter {
  final divisions = 2;
  final strokeWidth = 1.0;
  final Color color = Colors.black54;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..color = color;

    final spacing = size / (divisions + 1);
    for (var i = 1; i < divisions + 1; i++) {
      // draw vertical line
      canvas.drawLine(
        Offset(spacing.width * i, 0),
        Offset(spacing.width * i, size.height),
        paint,
      );

      // draw horizontal line
      canvas.drawLine(
        Offset(0, spacing.height * i),
        Offset(size.width, spacing.height * i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => false;
}

// class CreateBioDataScreen extends StatefulWidget {
//   CreateBioDataScreen({
//     Key? key,
//     required this.uid,
//     required this.isEdit,
//     required this.initialBiodataTitle,
//   }) : super(key: key);

//   final String uid;
//   final bool isEdit;
//   final String initialBiodataTitle;

//   @override
//   State<CreateBioDataScreen> createState() => _CreateBioDataScreenState();
// }

class CreateBioDataScreen extends StatefulWidget {
  CreateBioDataScreen({
    Key? key,
    required this.uid,
    required this.isEdit,
    this.initialBiodataTitle = '', // Make it optional with default empty string
  }) : super(key: key);

  final String uid;
  final bool isEdit;
  final String initialBiodataTitle;

  @override
  State<CreateBioDataScreen> createState() => _CreateBioDataScreenState();
}

class _CreateBioDataScreenState extends State<CreateBioDataScreen> {
  String? selectedCaste,
      selectedDay,
      selectedMonth,
      selectedYear,
      selectedHeight,
      selectedBloodGroup;
  TimeOfDay? selectedTime;
  Map<String, dynamic>? biodataDetails;
  bool isLoading = true;
  String? errorMessage;
  String biodataTitle = '';

  // final _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Form key

  final TextEditingController otherCasteController = TextEditingController();
  // late final TextEditingController titleController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController subCasteController = TextEditingController();
  final TextEditingController birthPlaceController = TextEditingController();
  final TextEditingController gothraController = TextEditingController();
  final TextEditingController complexionController = TextEditingController();
  final TextEditingController birthTimeController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController educationLevelController =
      TextEditingController();
  final TextEditingController educationController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController annualIncomeController = TextEditingController();
  TextEditingController propertyController = TextEditingController();
  TextEditingController expectationsController = TextEditingController();

  final List<TextEditingController> familyControllers = [
    TextEditingController(), // Father's Name
    TextEditingController(), // Father's Occupation
    TextEditingController(), // Mother's Name
    TextEditingController(), // Mother's Occupation
    TextEditingController(), // Mobile Number
    TextEditingController(), // Total Brothers
    TextEditingController(), // Total Sisters
    TextEditingController(), // Residential Address
    TextEditingController(), // Maternal Uncle
    TextEditingController(),
    TextEditingController(),
  ];

  final List<TextEditingController> personalControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  late TextEditingController titleController;
  bool isEditing = false; // Tracks if the title is being edited
  TextEditingController titleTextController = TextEditingController();

  List<bool> isVisible = [true, true];

  final List<TextEditingController> controllers = [];

  void _deleteField(int index) {
    setState(() {
      isVisible[index] = false; // Hide the selected field
      // Optionally clear the controller if you want to reset the input
      if (index == 0) gothraController.clear();
      if (index == 1) complexionController.clear();
    });
  }

  String gothraLabel = '';
  String complexionLabel = '';
  String propertyLabel = '';
  String expectationsLabel = '';
  List<String> labels = [];
  List<String> familyLabels = [];
  List<String> personalLabels = [];
  final List<TextEditingController> controllers2 = [];
  List<String> labels2 = [];

  List<bool> educationFieldVisibility = [];

  List<bool> personalDynamicFieldVisibility = [];
  List<bool> educationDynamicFieldVisibility = [];
  List<bool> familyDynamicFieldVisibility = [];
  List<bool> otherDynamicFieldVisibility = [];

  @override
  void initState() {
    super.initState();

    if (widget.isEdit) {
      setState(() {
        biodataTitle = widget.initialBiodataTitle;
      });
    }

    titleController = TextEditingController();
    titleTextController.text = "Biodata";

    print("bio data is is ${widget.uid}");
    if (widget.isEdit) {
      fetchBiodataDetails();
    }

    controllers2.addAll(
      [gothraController, complexionController],
    );

    controllers.addAll(
      [
        educationController,
        occupationController,
        annualIncomeController,
      ],
    );
    otherDynamicFieldVisibility =
        List.generate(dynamicOtherFields.length, (index) => true);

    personalDynamicFieldVisibility =
        List.generate(personalDynamicFields.length, (index) => true);

    // personalDynamicFieldVisibility = [];
    familyDynamicFieldVisibility =
        List.generate(dynamicfamilyFields.length, (index) => true);

    educationFieldVisibility =
        List.generate(controllers.length, (index) => true);
    educationDynamicFieldVisibility =
        List.generate(dynamicEducationFields.length, (index) => true);
    fieldOrder = List.generate(familyControllers.length, (index) => index);
  }

  void _deleteOtherDynamicField(int index) {
    setState(() {
      // Ensure the visibility array is properly initialized
      while (otherDynamicFieldVisibility.length < dynamicOtherFields.length) {
        otherDynamicFieldVisibility.add(true);
      }

      // Set visibility to false for the deleted field
      otherDynamicFieldVisibility[index] = false;

      // Clear the data but keep the field (to maintain indices)
      var controller =
          dynamicOtherFields[index]['controller'] as TextEditingController;
      controller.text = '';
      dynamicOtherFields[index]['label'] = '';
    });
  }

  void _deleteDynamicPersonalField(int index) {
    setState(() {
      // Ensure the visibility array is properly initialized
      while (personalDynamicFieldVisibility.length <
          personalDynamicFields.length) {
        personalDynamicFieldVisibility.add(true);
      }

      // Set visibility to false for the deleted field
      personalDynamicFieldVisibility[index] = false;

      // Clear the data but keep the field (to maintain indices)
      var controller =
          personalDynamicFields[index]['controller'] as TextEditingController;
      controller.text = '';
      personalDynamicFields[index]['label'] = '';
    });
  }

  void _deleteEducationDynamicField(int index) {
    setState(() {
      // Ensure the visibility array is properly initialized
      while (educationDynamicFieldVisibility.length <
          dynamicEducationFields.length) {
        educationDynamicFieldVisibility.add(true);
      }

      // Set visibility to false for the deleted field
      educationDynamicFieldVisibility[index] = false;

      // Clear the data but keep the field (to maintain indices)
      var controller =
          dynamicEducationFields[index]['controller'] as TextEditingController;
      controller.text = '';
      dynamicEducationFields[index]['label'] = '';
    });
  }

  void _deleteFamilyDynamicField(int index) {
    setState(() {
      // Ensure the visibility array is properly initialized
      while (familyDynamicFieldVisibility.length < dynamicfamilyFields.length) {
        familyDynamicFieldVisibility.add(true);
      }

      // Set visibility to false for the deleted field
      familyDynamicFieldVisibility[index] = false;

      // Clear the data but keep the field (to maintain indices)
      var controller =
          dynamicfamilyFields[index]['controller'] as TextEditingController;
      controller.text = '';
      dynamicfamilyFields[index]['label'] = '';
    });
  }

  // Future<void> fetchBiodataDetails() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse(
  //         'http://allindiamatrimonial.com/royal_maratha/api/users/showBiodataByBiodataId?biodata_id=${widget.uid}',
  //       ),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       log(data.toString());

  //       if (data['status'] == true && data['data'] != null) {
  //         setState(() {
  //           biodataDetails = data['data'];
  //           _populateControllersWithBiodata(); // Populate fields with data
  //           isLoading = false;
  //         });
  //       } else {
  //         setState(() {
  //           isLoading = false;
  //           errorMessage = 'No biodata found';
  //         });
  //       }
  //     } else {
  //       setState(() {
  //         isLoading = false;
  //         errorMessage = 'Failed to load data: ${response.statusCode}';
  //       });
  //     }
  //   } catch (error) {
  //     setState(() {
  //       isLoading = false;
  //       errorMessage = 'Error: $error';
  //     });
  //   }
  // }

  Future<void> fetchBiodataDetails() async {
    // Check if widget is mounted before proceeding
    if (!mounted) return;

    try {
      final response = await http.get(
        Uri.parse(
          '${AppUrls.baseUrl}/api/users/showBiodataByBiodataId?biodata_id=${widget.uid}',
        ),
        // Uri.parse(
        //   'http://allindiamatrimonial.com/royal_maratha/api/users/showBiodataByBiodataId?biodata_id=${widget.uid}',
        // ),
      );

      // Check mounted state again after the async operation
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log(data.toString());

        if (data['status'] == true && data['data'] != null) {
          if (mounted) {
            // Check mounted before setState
            setState(() {
              biodataDetails = data['data'];
              _populateControllersWithBiodata();
              isLoading = false;
            });
          }
        } else {
          if (mounted) {
            // Check mounted before setState
            setState(() {
              isLoading = false;
              errorMessage = 'No biodata found';
            });
          }
        }
      } else {
        if (mounted) {
          // Check mounted before setState
          setState(() {
            isLoading = false;
            errorMessage = 'Failed to load data: ${response.statusCode}';
          });
        }
      }
    } catch (error) {
      if (mounted) {
        // Check mounted before setState
        setState(() {
          isLoading = false;
          errorMessage = 'Error: $error';
        });
      }
    }
  }

  List<bool> familyFieldVisibility = List.generate(11, (_) => true);

// Function to delete a specific family field
  void _deleteFamilyField(int index) {
    setState(() {
      familyFieldVisibility[index] = false; // Hide the selected field
      familyControllers[index].clear(); // Optionally clear the text
    });
  }

  List<bool> personalFieldVisibility = List.filled(7, true);

  // void _movePersonalField(int fromIndex, int toIndex) {
  //   setState(
  //     () {
  //       if (toIndex < 0 ||
  //           toIndex >=
  //               personalControllers.length + personalDynamicFields.length) {
  //         return;
  //       }

  //       if (fromIndex < personalControllers.length &&
  //           toIndex < personalControllers.length) {
  //         final tempController = personalControllers[fromIndex];
  //         personalControllers[fromIndex] = personalControllers[toIndex];
  //         personalControllers[toIndex] = tempController;

  //         final tempLabel = personalLabels[fromIndex];
  //         personalLabels[fromIndex] = personalLabels[toIndex];
  //         personalLabels[toIndex] = tempLabel;

  //         final tempVisibility = personalFieldVisibility[fromIndex];
  //         personalFieldVisibility[fromIndex] = personalFieldVisibility[toIndex];
  //         personalFieldVisibility[toIndex] = tempVisibility;
  //       } else if (fromIndex >= personalControllers.length &&
  //           toIndex >= personalControllers.length) {
  //         int fromDynamicIndex = fromIndex - personalControllers.length;
  //         int toDynamicIndex = toIndex - personalControllers.length;

  //         final tempField = personalDynamicFields[fromDynamicIndex];
  //         personalDynamicFields[fromDynamicIndex] =
  //             personalDynamicFields[toDynamicIndex];
  //         personalDynamicFields[toDynamicIndex] = tempField;
  //       } else if (fromIndex < personalControllers.length &&
  //           toIndex >= personalControllers.length) {
  //         int toDynamicIndex = toIndex - personalControllers.length;

  //         final tempController = personalControllers[fromIndex];
  //         final tempLabel = personalLabels[fromIndex];
  //         final tempVisibility = personalFieldVisibility[fromIndex];

  //         personalControllers[fromIndex] =
  //             personalDynamicFields[toDynamicIndex]['controller'];
  //         personalLabels[fromIndex] =
  //             personalDynamicFields[toDynamicIndex]['label'];
  //         personalFieldVisibility[fromIndex] = true;

  //         personalDynamicFields[toDynamicIndex]['controller'] = tempController;
  //         personalDynamicFields[toDynamicIndex]['label'] = tempLabel;
  //       } else if (fromIndex >= personalControllers.length &&
  //           toIndex < personalControllers.length) {
  //         int fromDynamicIndex = fromIndex - personalControllers.length;

  //         final tempController = personalControllers[toIndex];
  //         final tempLabel = personalLabels[toIndex];
  //         final tempVisibility = personalFieldVisibility[toIndex];

  //         personalControllers[toIndex] =
  //             personalDynamicFields[fromDynamicIndex]['controller'];
  //         personalLabels[toIndex] =
  //             personalDynamicFields[fromDynamicIndex]['label'];
  //         personalFieldVisibility[toIndex] = true; // Make visible

  //         personalDynamicFields[fromDynamicIndex]['controller'] =
  //             tempController;
  //         personalDynamicFields[fromDynamicIndex]['label'] = tempLabel;
  //       }
  //     },
  //   );
  // }

  void _movePersonalField(int fromIndex, int toIndex) {
    setState(() {
      // Calculate total number of fields
      int totalFields =
          personalControllers.length + personalDynamicFields.length;

      // Validate index bounds
      if (toIndex < 0 || toIndex >= totalFields) {
        return;
      }

      // Helper function to convert field to map format
      Map<String, dynamic> convertToFieldMap(
          TextEditingController controller, String label) {
        return {
          'controller': controller,
          'label': label,
          'focusNode': FocusNode(),
        };
      }

      // Helper function to update personal field
      void updatePersonalField(int index, Map<String, dynamic> fieldData) {
        personalControllers[index] = fieldData['controller'];
        personalLabels[index] = fieldData['label'];
        personalFieldVisibility[index] = true;
      }

      // Store source field data
      Map<String, dynamic> sourceField;
      if (fromIndex < personalControllers.length) {
        sourceField = convertToFieldMap(
            personalControllers[fromIndex], personalLabels[fromIndex]);
      } else {
        sourceField = Map<String, dynamic>.from(
            personalDynamicFields[fromIndex - personalControllers.length]);
      }

      // Store target field data
      Map<String, dynamic> targetField;
      if (toIndex < personalControllers.length) {
        targetField = convertToFieldMap(
            personalControllers[toIndex], personalLabels[toIndex]);
      } else {
        targetField = Map<String, dynamic>.from(
            personalDynamicFields[toIndex - personalControllers.length]);
      }

      // Perform the swap
      if (fromIndex < personalControllers.length) {
        updatePersonalField(fromIndex, targetField);
      } else {
        personalDynamicFields[fromIndex - personalControllers.length] =
            targetField;
      }

      if (toIndex < personalControllers.length) {
        updatePersonalField(toIndex, sourceField);
      } else {
        personalDynamicFields[toIndex - personalControllers.length] =
            sourceField;
      }
    });
  }

  void _deletePersonalField(int index) {
    setState(() {
      personalFieldVisibility[index] = false; // Hide the field
      personalControllers[index].clear(); // Optionally clear the text
    });
  }

  void _deleteEducationField(int index) {
    setState(() {
      educationFieldVisibility[index] = false; // Hide the field
      controllers[index].clear(); // Clear the text
      controllers.removeAt(index);
      labels.removeAt(index);
    });
  }

  bool isPropertyVisible = true;
  bool isExpectationsVisible = true;

  void _deletePropertyField() {
    setState(() {
      isPropertyVisible = false; // Hide the property field
      propertyController.clear(); // Optionally clear the text
    });
  }

  void _deleteExpectationsField() {
    setState(() {
      isExpectationsVisible = false; // Hide the expectations field
      expectationsController.clear(); // Optionally clear the text
    });
  }

  List<bool> isVisible2 = List.generate(11, (index) => true);

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return ''; // Handle null or empty case

    try {
      // Parse the date from the string input
      DateTime parsedDate = DateTime.parse(date);

      // Format the date as 'dd/MM/yyyy' to match your required format
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      // Log the error and return the original date if parsing fails
      debugPrint('Error formatting birth date: $e');
      return date;
    }
  }

  _populateDynamicFields() {
    if (biodataDetails == null) return;

    // Clear existing fields
    personalDynamicFields.clear();
    dynamicEducationFields.clear();
    dynamicfamilyFields.clear();
    dynamicOtherFields.clear();

    // Helper function to populate fields
    void populateFormFields(
        List<Map<String, dynamic>> targetList, String formSuffix) {
      for (int i = 1; i <= 5; i++) {
        String titleKey = formSuffix.isEmpty
            ? 'field_${i}_title'
            : 'field_${i}_title_form$formSuffix';
        String valueKey = formSuffix.isEmpty
            ? 'field_${i}_value'
            : 'field_${i}_value_form$formSuffix';

        String title = biodataDetails?[titleKey] ?? '';
        String value = biodataDetails?[valueKey] ?? '';

        // Only add field if title exists
        if (title.isNotEmpty) {
          TextEditingController controller = TextEditingController(text: value);
          FocusNode focusNode = FocusNode();

          targetList.add({
            'label': title,
            'controller': controller,
            'focusNode': focusNode,
          });
        }
      }
    }

    setState(() {
      // Populate all dynamic field lists
      populateFormFields(personalDynamicFields, ''); // Form 1
      populateFormFields(dynamicEducationFields, '2'); // Form 2
      populateFormFields(dynamicfamilyFields, '3'); // Form 3
      populateFormFields(dynamicOtherFields, '4'); // Form 4
    });
  }

  void _populateControllersWithBiodata() async {
    if (biodataDetails != null) {
      try {
        // setState(() {
        //   biodataTitle = safeString(biodataDetails!['title'] ?? '');
        // });

        // Helper function to safely convert null to empty string
        String safeString(dynamic value) => value?.toString() ?? '';

        fullNameController.text = safeString(biodataDetails!['username']);
        otherCasteController.text = safeString(biodataDetails!['caste']);
        selectedCaste =
            safeString(biodataDetails!['caste']); // Set selected caste
        subCasteController.text = safeString(biodataDetails!['subcaste']);
        personalControllers[0].text =
            formatDate(safeString(biodataDetails!['birthdate']));
        personalControllers[1].text = safeString(biodataDetails!['birthtime']);
        personalControllers[2].text = safeString(biodataDetails!['birthplace']);
        personalControllers[3].text = safeString(biodataDetails!['height']);
        personalControllers[4].text =
            safeString(biodataDetails!['blood_group']);
        personalControllers[5].text = safeString(biodataDetails!['gothra']);
        personalControllers[6].text = safeString(biodataDetails!['complexion']);
        educationLevelController.text =
            safeString(biodataDetails!['education_level']);
        educationController.text =
            safeString(biodataDetails!['education_detail']);
        occupationController.text = safeString(biodataDetails!['occupation']);
        annualIncomeController.text = safeString(biodataDetails!['income']);
        propertyController.text = safeString(biodataDetails!['property']);
        expectationsController.text =
            safeString(biodataDetails!['expectations']);
        titleController.text = safeString(biodataDetails!['title']);

        // Family controllers
        familyControllers[0].text = safeString(biodataDetails!['father_name']);
        familyControllers[1].text =
            safeString(biodataDetails!['father_occupation']);
        familyControllers[2].text = safeString(biodataDetails!['mobile']);
        familyControllers[3].text = safeString(biodataDetails!['mother_name']);
        familyControllers[4].text =
            safeString(biodataDetails!['mother_occupation']);
        familyControllers[5].text =
            safeString(biodataDetails!['no_of_brothers']);
        familyControllers[6].text =
            safeString(biodataDetails!['no_of_sisters']);
        familyControllers[7].text =
            safeString(biodataDetails!['surname_of_relatives']);
        familyControllers[8].text = safeString(biodataDetails!['address']);
        familyControllers[9].text = safeString(biodataDetails!['mama_surname']);
        familyControllers[10].text =
            safeString(biodataDetails!['family_native_place']);

        await _populateDynamicFields();

        // Handle image loading
        await _loadImage(biodataDetails!['photo1'], 1);
        await _loadImage(biodataDetails!['photo2'], 2);
      } catch (e) {
        debugPrint('Error populating form data: $e');
        // You might want to show a snackbar or alert to the user here
      }
    }
  }

// Helper method to load images
  Future<void> _loadImage(String? imageUrl, int imageNumber) async {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(imageUrl));
        final documentDirectory = await getApplicationDocumentsDirectory();
        final filePath =
            '${documentDirectory.path}/profile_image$imageNumber.jpg';
        final imageFile = File(filePath);
        await imageFile.writeAsBytes(response.bodyBytes);

        setState(() {
          if (imageNumber == 1) {
            imageFile1 = imageFile;
          } else {
            imageFile2 = imageFile;
          }
        });
      } catch (e) {
        debugPrint('Error loading image$imageNumber: $e');
      }
    }
  }

  Future<void> saveAllApi(BuildContext context, String selectedLanguage) async {
    final educationRequest = EducationDetailsRequest();
    try {
      // First call personalDetailsApi to get the initial biodata_id
      var personalResult = await educationRequest.personalDetailsApi(
        titleController.text,
        fullNameController.text,
        otherCasteController.text,
        subCasteController.text,
        personalControllers[0].text, // Birth Date
        personalControllers[1].text, // Birth Time
        personalControllers[2].text, // Birth Place
        personalControllers[3].text, // Height
        personalControllers[4].text, // Blood Group
        personalControllers[5].text, // Gothra
        personalControllers[6].text, // Complexion
      );

      if (personalResult == null) {
        throw Exception("Failed to save personal details");
      }

      // Convert dynamic fields to the required format with proper type casting
      List<Map<String, String>> convertDynamicFields(
          List<Map<String, dynamic>> dynamicFields) {
        return dynamicFields.map((field) {
          final controller = field['controller'] as TextEditingController;
          return {
            'title': (field['label'] ?? '').toString(),
            'value': controller.text,
          };
        }).toList();
      }

      // Convert all dynamic fields using the helper function
      final personalFields = convertDynamicFields(personalDynamicFields);
      final educationFields = convertDynamicFields(dynamicEducationFields);
      final familyFields = convertDynamicFields(dynamicfamilyFields);
      final otherFields = convertDynamicFields(dynamicOtherFields);

      // Register all dynamic fields using the new API
      bool fieldsRegistered = await educationRequest.registerBiodataExtraField(
        personalFields: personalFields,
        educationFields: educationFields,
        familyFields: familyFields,
        otherFields: otherFields,
      );

      if (!fieldsRegistered) {
        throw Exception("Failed to register extra fields");
      }

      // Call other APIs
      await educationRequest.educationDetailsApi(
        educationLevelController.text,
        annualIncomeController.text,
        occupationController.text,
        educationController.text,
      );

      await educationRequest.familyDetailsApi(
        familyControllers[0].text, // Father's Name
        familyControllers[1].text, // Father's Occupation
        familyControllers[3].text, // Mother's Occupation
        familyControllers[4].text, // Mother's Name
        familyControllers[2].text, // Mobile Number
        familyControllers[5].text, // Total Brothers
        familyControllers[6].text, // Total Sisters
        familyControllers[8].text, // Residential Address
        familyControllers[9].text, // Maternal Uncle
        familyControllers[10].text, // Native Place
        familyControllers[7].text, // Surname of Relatives
      );

      await educationRequest.otherDetailsApi(
        propertyController.text,
        expectationsController.text,
      );

      // Handle image uploads
      if (imageFile1 != null) {
        await educationRequest.uploadProfileImageApi1(imageFile1!);
        log("Image1 uploaded successfully.");
      }

      if (imageFile2 != null) {
        await educationRequest.uploadProfileImageApi2(imageFile2!);
        log("Image2 uploaded successfully.");
      }

      // Navigate to the next page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TemplateSelectionPage(
            id: educationRequest.newBiodataId,
            selectedLanguage: selectedLanguage,
            biodataName: biodataTitle,
          ),
        ),
      );
      log("biodataTitle is $biodataTitle");
    } catch (e) {
      log("Error saving data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "An error occurred while saving your data. Please try again."),
        ),
      );
    }
  }

  // Add this method in your _CreateBioDataScreenState class
  List<Map<String, String>> convertDynamicFields(
      List<Map<String, dynamic>> dynamicFields) {
    return dynamicFields.map((field) {
      final controller = field['controller'] as TextEditingController;
      return {
        'title': (field['label'] ?? '').toString(),
        'value': controller.text,
      };
    }).toList();
  }

  Future<void> saveAllApi2(
      BuildContext context, String selectedLanguage) async {
    final educationRequest = EducationDetailsRequest();

    try {
      if (widget.isEdit) {
        if (widget.isEdit) {
          await educationRequest.editBiodataApi(
            title: titleController.text,
            username: fullNameController.text,
            caste: selectedCaste,
            subcaste: subCasteController.text,
            birthdate: personalControllers[0].text,
            birthtime: personalControllers[1].text,
            birthplace: personalControllers[2].text,
            height: personalControllers[3].text,
            bloodGroup: personalControllers[4].text,
            gothra: personalControllers[5].text,
            complexion: personalControllers[6].text,
            educationDetail: educationController.text,
            income: annualIncomeController.text,
            occupation: occupationController.text,
            educationLevel: educationLevelController.text,
            property: propertyController.text,
            expectations: expectationsController.text,
            fatherName: familyControllers[0].text,
            motherName: familyControllers[3].text,
            fatherOccupation: familyControllers[1].text,
            motherOccupation: familyControllers[4].text,
            address: familyControllers[8].text,
            noOfBrothers: familyControllers[5].text,
            noOfSisters: familyControllers[6].text,
            mobile: familyControllers[2].text,
            mamaSurname: familyControllers[9].text,
            surnameOfRelatives: familyControllers[7].text,
            familyNativePlace: familyControllers[10].text,
            biodataId: widget.uid,
            photo1: imageFile1,
            photo2: imageFile2,
            personalFields: convertDynamicFields(personalDynamicFields),
            educationFields: convertDynamicFields(dynamicEducationFields),
            familyFields: convertDynamicFields(dynamicfamilyFields),
            otherFields: convertDynamicFields(dynamicOtherFields),
          );
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TemplateSelectionPage(
              id: widget.uid,
              selectedLanguage: selectedLanguage,
              biodataName: biodataTitle,
            ),
          ),
        );
      } else {
        await saveAllApi(context, selectedLanguage);
      }
    } catch (e) {
      print("Error saving data: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text("An error occurred while saving your data. Please try again."),
      ));
    }
  }

  List<Map<String, dynamic>> personalDynamicFields = [];

  void _showAddFieldDialog(BuildContext context) {
    TextEditingController labelController = TextEditingController();

    if (personalDynamicFields.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only add up to 5 fields.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(),
          content: TextFormField(
            controller: labelController,
            decoration: InputDecoration(labelText: "Enter Field Label"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (labelController.text.isNotEmpty) {
                  FocusNode newFocusNode = FocusNode();
                  setState(() {
                    personalDynamicFields.add({
                      'label': labelController.text,
                      'controller': TextEditingController(),
                      'focusNode': newFocusNode,
                    });
                    personalDynamicFieldVisibility.add(true);
                  });
                  Navigator.of(context).pop();
                  Future.delayed(Duration(milliseconds: 100), () {
                    newFocusNode.requestFocus();
                  });
                }
              },
              child: Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> dynamicEducationFields = [];

  void _showAddEducationFieldDialog(BuildContext context) {
    TextEditingController labelController = TextEditingController();

    if (dynamicEducationFields.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You can only add up to 5 fields.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(),
          // title: Text("Add New Education Field"),
          content: TextFormField(
            controller: labelController,
            decoration: InputDecoration(labelText: "Enter Field Label"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (labelController.text.isNotEmpty) {
                  FocusNode newFocusNode = FocusNode();
                  setState(() {
                    dynamicEducationFields.add({
                      'label': labelController.text,
                      'controller': TextEditingController(),
                      'focusNode': newFocusNode,
                    });
                    educationDynamicFieldVisibility
                        .add(true); // Add visibility for new field
                  });
                  Navigator.of(context).pop();
                  Future.delayed(Duration(milliseconds: 100), () {
                    newFocusNode.requestFocus();
                  });
                }
              },
              child: Text(
                'Add',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> dynamicfamilyFields = [];

  void _showAddFamilyFieldDialog(BuildContext context) {
    TextEditingController labelController = TextEditingController();

    if (dynamicfamilyFields.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You can only add up to 5 fields.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(),
          // title: Text("Add New Education Field"),
          content: TextFormField(
            controller: labelController,
            decoration: InputDecoration(labelText: "Enter Field Label"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              // onPressed: () {
              //   if (labelController.text.isNotEmpty) {
              //     FocusNode newFocusNode = FocusNode();
              //     setState(() {
              //       dynamicfamilyFields.add({
              //         'label': labelController.text,
              //         'controller': TextEditingController(),
              //         'focusNode': newFocusNode,
              //       });
              //     });
              //     Navigator.of(context).pop();
              //     Future.delayed(Duration(milliseconds: 100), () {
              //       newFocusNode.requestFocus();
              //     });
              //   }
              // },
              onPressed: () {
                if (labelController.text.isNotEmpty) {
                  FocusNode newFocusNode = FocusNode();
                  setState(() {
                    dynamicfamilyFields.add({
                      'label': labelController.text,
                      'controller': TextEditingController(),
                      'focusNode': newFocusNode,
                    });
                    familyDynamicFieldVisibility
                        .add(true); // Add visibility for new field
                  });
                  Navigator.of(context).pop();
                  Future.delayed(Duration(milliseconds: 100), () {
                    newFocusNode.requestFocus();
                  });
                }
              },
              child: Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> dynamicOtherFields = [];

  void _showAddOtherFieldDialog(BuildContext context) {
    TextEditingController labelController = TextEditingController();

    if (dynamicOtherFields.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You can only add up to 5 fields.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(),
          // title: Text("Add New Education Field"),
          content: TextFormField(
            controller: labelController,
            decoration: InputDecoration(labelText: "Enter Field Label"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (labelController.text.isNotEmpty) {
                  // Add new controller, focus node, and update UI with the entered label
                  FocusNode newFocusNode = FocusNode();
                  setState(() {
                    dynamicOtherFields.add({
                      'label': labelController.text, // Store the label
                      'controller':
                          TextEditingController(), // Create a controller
                      'focusNode': newFocusNode, // Add a focus node
                    });
                  });
                  Navigator.of(context).pop(); // Close the dialog
                  Future.delayed(Duration(milliseconds: 100), () {
                    newFocusNode.requestFocus(); // Focus the new TextFormField
                  });
                }
              },
              child: Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Access the localization to get the invocation text
    final localization = AppLocalizations.of(context);
    if (localization != null) {
      titleController.text = localization.invocation; // Set the initial text
    } else {
      titleController.text =
          "|| Shree Ganeshaya Namah ||"; // Fallback in case localization is not available
    }

    // final localization = AppLocalizations.of(context);
    if (localization != null) {
      setState(() {
        gothraLabel = localization.gothra;
        complexionLabel = localization.complexion;
        propertyLabel = localization.property;
        expectationsLabel = localization.expectations;
        title = localization.personalDetails;
        educationOccupationDetailsTitle =
            localization.educationOccupationDetails;
        familyDetails = localization.familyDetails;
        othersDetails = localization.otherDetails;
        biodataTitle = localization.biodata;
        labels = [
          localization.education,
          localization.occupation,
          localization.annualIncome,
        ];
        personalLabels = [
          localization.birthDate,
          localization.birthTime,
          localization.birthPlace,
          localization.height,
          localization.bloodGroup,
          localization.gothra,
          localization.complexion,
        ];
        familyLabels = [
          localization.fathersName,
          localization.fathersOccupation,
          localization.mobileNumber,
          localization.mothersName,
          localization.mothersOccupation,
          localization.totalBrothers,
          localization.totalSisters,
          localization.relativeName,
          localization.relativeAddress,
          localization.maternalUncle,
          localization.nativePlace,
        ];
      });
    }
  }

  String educationOccupationDetailsTitle = '';

  void _showEditPopupEducationOccupation(BuildContext context) {
    TextEditingController textController = TextEditingController();
    textController.text = educationOccupationDetailsTitle;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(),
          title: const Text("Change Header"),
          content: TextFormField(
            controller: textController,
            decoration: InputDecoration(
              labelText: "Enter Header Name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without changes
              },
              child: const Text("Cancel"),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.orangeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
              ),
              onPressed: () {
                setState(() {
                  educationOccupationDetailsTitle =
                      textController.text; // Update the title
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showEditPopupBiodataTitle(BuildContext context) {
    TextEditingController textController = TextEditingController();
    textController.text = biodataTitle;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(),
          title: const Text("Change Header"),
          content: TextFormField(
            controller: textController,
            decoration: InputDecoration(
              labelText: "Enter Header Name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without changes
              },
              child: const Text("Cancel"),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.orangeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
              ),
              onPressed: () {
                setState(() {
                  biodataTitle = textController.text; // Update the title
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  String familyDetails = '';

  void _showEditPopupFamilyDetails(BuildContext context) {
    TextEditingController textController = TextEditingController();
    textController.text = familyDetails;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(),
          title: const Text("Change Header"),
          content: TextFormField(
            controller: textController,
            decoration: InputDecoration(
              labelText: "Enter Header Name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without changes
              },
              child: const Text("Cancel"),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.orangeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
              ),
              onPressed: () {
                setState(() {
                  familyDetails = textController.text; // Update the title
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  String othersDetails = '';

  void _showEditPopupOtherDetails(BuildContext context) {
    TextEditingController textController = TextEditingController();
    textController.text = othersDetails;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(),
          title: const Text("Change Header"),
          content: TextFormField(
            controller: textController,
            decoration: InputDecoration(
              labelText: "Enter Header Name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without changes
              },
              child: const Text("Cancel"),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.orangeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
              ),
              onPressed: () {
                setState(() {
                  othersDetails = textController.text; // Update the title
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  String title = '';

  void _showEditPopup(BuildContext context) {
    TextEditingController textController = TextEditingController();
    textController.text = title;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(),
          title: const Text("Change Header"),
          content: TextFormField(
            controller: textController,
            decoration: InputDecoration(
              labelText: "Enter Header Name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without changes
              },
              child: const Text("Cancel"),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.orangeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
              ),
              onPressed: () {
                setState(() {
                  title = textController.text; // Update the title
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  bool _isLoading = false;

  // Future<void> _cropImage1(File image) async {
  //   CroppedFile? croppedFile = await ImageCropper().cropImage(
  //     sourcePath: image.path,
  //     uiSettings: [
  //       AndroidUiSettings(
  //         toolbarTitle: 'Cropper',
  //         toolbarColor: Colors.deepOrange,
  //         toolbarWidgetColor: Colors.white,
  //         // aspectRatioPresets: [
  //         //   CropAspectRatioPreset.original,
  //         //   CropAspectRatioPreset.square,
  //         //   // CropAspectRatioPresetCustom(), // Custom ratio (2:3)
  //         // ],
  //       ),
  //       IOSUiSettings(
  //         title: 'Cropper',
  //         // aspectRatioPresets: [
  //         //   CropAspectRatioPreset.original,
  //         //   CropAspectRatioPreset.square,
  //         //   // CropAspectRatioPresetCustom(), // Custom ratio (2:3)
  //         // ],
  //       ),
  //       WebUiSettings(context: context),
  //     ],
  //   );

  //   if (croppedFile != null) {
  //     setState(() {
  //       imageFile1 = File(croppedFile.path);
  //     });
  //   }
  // }

  Future<void> _cropImage2(File image) async {
    // CroppedFile? croppedFile = await ImageCropper().cropImage(
    //   sourcePath: image.path,
    //   uiSettings: [
    //     AndroidUiSettings(
    //       toolbarTitle: 'Cropper',
    //       toolbarColor: Colors.deepOrange,
    //       toolbarWidgetColor: Colors.white,
    //       aspectRatioPresets: [
    //         CropAspectRatioPreset.original,
    //         CropAspectRatioPreset.square,
    //         // CropAspectRatioPresetCustom(), // Custom ratio (2:3)
    //       ],
    //     ),
    //     IOSUiSettings(
    //       title: 'Cropper',
    //       aspectRatioPresets: [
    //         CropAspectRatioPreset.original,
    //         CropAspectRatioPreset.square,
    //         // CropAspectRatioPresetCustom(), // Custom ratio (2:3)
    //       ],
    //     ),
    //     WebUiSettings(context: context),
    //   ],
    // );

    // if (croppedFile != null) {
    //   setState(() {
    //     imageFile1 = File(croppedFile.path);
    //   });
    // }
  }

  File? imageFile1;
  File? imageFile2;

  final ImagePicker _picker = ImagePicker();

  Future<void> _selectImage1(BuildContext context) async {
    await _showImageSourceDialog(
      context,
      onImageSelected: (File? image) {
        if (image != null) {
          setState(() {
            imageFile1 = image;
          });
        }
      },
    );
  }

  Future<void> _selectImage2(BuildContext context) async {
    await _showImageSourceDialog(
      context,
      onImageSelected: (File? image) {
        if (image != null) {
          setState(() {
            imageFile2 = image;
          });
        }
      },
    );
  }

  // Future<File?> _cropImage(File image) async {
  //   try {
  //     // Create a controller for the cropper
  //     final _cropController = CropController();
  //     bool _isCircleUi = false; // State variable for circle UI

  //     // Read the image file as bytes
  //     final Uint8List imageBytes = await image.readAsBytes();

  //     // Show the cropping dialog
  //     final croppedData = await showDialog<Uint8List?>(
  //       context: context,
  //       builder: (context) => StatefulBuilder(
  //         // Use StatefulBuilder to manage state
  //         builder: (context, setState) => Dialog(
  //           child: Container(
  //             color: Colors.white,
  //             width: MediaQuery.of(context).size.width * 0.8,
  //             height: MediaQuery.of(context).size.height * 0.8,
  //             child: Column(
  //               children: [
  //                 Expanded(
  //                   child: Crop(
  //                     controller: _cropController,
  //                     image: imageBytes,
  //                     onCropped: (result) {
  //                       switch (result) {
  //                         case CropSuccess(:final croppedImage):
  //                           Navigator.of(context).pop(croppedImage);
  //                         case CropFailure(:final cause):
  //                           ScaffoldMessenger.of(context).showSnackBar(
  //                             SnackBar(content: Text('Failed to crop: $cause')),
  //                           );
  //                           Navigator.of(context).pop(null);
  //                       }
  //                     },
  //                     interactive: true,
  //                     fixCropRect: false,
  //                     radius: 8,
  //                     withCircleUi: _isCircleUi, // Use the state variable
  //                     overlayBuilder: (context, rect) {
  //                       return _isCircleUi
  //                           ? ClipOval(
  //                               child: CustomPaint(painter: GridPainter()))
  //                           : CustomPaint(painter: GridPainter());
  //                     },
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.all(16),
  //                   child: Column(
  //                     children: [
  //                       // Aspect ratio controls
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           IconButton(
  //                             icon: Icon(Icons.crop_16_9),
  //                             onPressed: () {
  //                               setState(() {
  //                                 _isCircleUi = false;
  //                                 _cropController.aspectRatio = 16 / 9;
  //                               });
  //                             },
  //                           ),
  //                           IconButton(
  //                             icon: Icon(Icons.crop_5_4),
  //                             onPressed: () {
  //                               setState(() {
  //                                 _isCircleUi = false;
  //                                 _cropController.aspectRatio = 4 / 3;
  //                               });
  //                             },
  //                           ),
  //                           IconButton(
  //                             icon: Icon(Icons.crop_square),
  //                             onPressed: () {
  //                               setState(() {
  //                                 _isCircleUi = false;
  //                                 _cropController.aspectRatio = 1;
  //                               });
  //                             },
  //                           ),
  //                           IconButton(
  //                             icon: Icon(Icons.circle),
  //                             onPressed: () {
  //                               setState(() {
  //                                 _isCircleUi = true;
  //                                 _cropController.aspectRatio = 1;
  //                               });
  //                             },
  //                           ),
  //                         ],
  //                       ),
  //                       SizedBox(height: 16),
  //                       // Crop button
  //                       ElevatedButton(
  //                         onPressed: () {
  //                           if (_isCircleUi) {
  //                             _cropController.cropCircle();
  //                           } else {
  //                             _cropController.crop();
  //                           }
  //                         },
  //                         child: Padding(
  //                           padding: const EdgeInsets.symmetric(
  //                             vertical: 12,
  //                             horizontal: 24,
  //                           ),
  //                           child: Text('CROP'),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     );

  //     if (croppedData != null) {
  //       // Create a temporary file to store the cropped image
  //       final tempDir = await getTemporaryDirectory();
  //       final tempFile = File(
  //           '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg');

  //       // Write the cropped data to the file
  //       await tempFile.writeAsBytes(croppedData);
  //       return tempFile;
  //     }
  //     return null;
  //   } catch (e) {
  //     print('Error cropping image: $e');
  //     return null;
  //   }
  // }

  // Future<void> _showImageSourceDialog(
  //   BuildContext context, {
  //   required Function(File?) onImageSelected,
  // }) async {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => ImagePickerScreen(
  //         onImageSelected: (File? image) {
  //           if (image != null) {
  //             onImageSelected(image);
  //           }
  //           Navigator.pop(context);
  //         },
  //         aspectRatio: 1.0, // For profile picture, using 1:1 ratio
  //         enableCircularCrop: true,
  //       ),
  //     ),
  //   );
  // }

  Future<void> _showImageSourceDialog(
    BuildContext context, {
    required Function(File?) onImageSelected,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text('Choose'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceOption(
                    context: context,
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () async {
                      final pickedFile = await ImagePicker().pickImage(
                        source: ImageSource.camera,
                      );
                      if (pickedFile != null) {
                        File? croppedImage = await _cropImage(
                          File(pickedFile.path),
                        );
                        onImageSelected(croppedImage);
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                  _buildSourceOption(
                    context: context,
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () async {
                      final pickedFile = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      if (pickedFile != null) {
                        File? croppedImage = await _cropImage(
                          File(pickedFile.path),
                        );
                        onImageSelected(croppedImage);
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<File?> _cropImage(File image) async {
    try {
      final File? croppedFile = await Navigator.push<File>(
        context,
        MaterialPageRoute(
          builder: (context) => ImageCropperScreen(imageFile: image),
        ),
      );

      return croppedFile;
    } catch (e) {
      print('Error cropping image: $e');
      return null;
    }
  }

  Widget _buildSourceOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 40,
            color: Colors.black,
          ),
          SizedBox(height: 10),
          Text(label),
        ],
      ),
    );
  }

  // Future<void> _showImageSourceDialog(
  //   BuildContext context, {
  //   required Function(File?) onImageSelected,
  // }) async {
  //   await showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(),
  //         title: Text('Choose'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Row(
  //                   children: [
  //                     Column(
  //                       children: [
  //                         IconButton(
  //                           onPressed: () async {
  //                             final pickedFile = await _picker.pickImage(
  //                                 source: ImageSource.camera);
  //                             if (pickedFile != null) {
  //                               File? croppedImage = await _cropImage(
  //                                 File(pickedFile.path),
  //                               );
  //                               onImageSelected(croppedImage);
  //                             }
  //                             Navigator.of(context).pop();
  //                           },
  //                           icon: Icon(
  //                             Icons.camera_alt,
  //                             size: 40,
  //                             color: Colors.black,
  //                           ),
  //                         ),
  //                         SizedBox(
  //                           height: 10,
  //                         ),
  //                         Text('Camera'),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(
  //                   width: 40.w,
  //                 ),
  //                 Row(
  //                   children: [
  //                     Column(
  //                       children: [
  //                         IconButton(
  //                           onPressed: () async {
  //                             final pickedFile = await _picker.pickImage(
  //                                 source: ImageSource.gallery);
  //                             if (pickedFile != null) {
  //                               File? croppedImage = await _cropImage(
  //                                 File(pickedFile.path),
  //                               );
  //                               onImageSelected(croppedImage);
  //                             }
  //                             Navigator.of(context).pop();
  //                           },
  //                           icon: Icon(
  //                             Icons.photo_library,
  //                             size: 40,
  //                             color: Colors.black,
  //                           ),
  //                         ),
  //                         SizedBox(
  //                           height: 10,
  //                         ),
  //                         Text('Gallery'),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // Future<File?> _cropImage(File image, BuildContext context) async {
  //   try {
  //     final cropController = CustomImageCropController();

  //     final result = await showDialog<Uint8List?>(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (context) => Dialog(
  //         backgroundColor: Colors.black,
  //         child: Container(
  //           constraints: BoxConstraints(
  //             maxWidth: MediaQuery.of(context).size.width * 0.9,
  //             maxHeight: MediaQuery.of(context).size.height * 0.8,
  //           ),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Expanded(
  //                 child: CustomImageCrop(
  //                   cropController: cropController,
  //                   image: FileImage(image),
  //                   // aspectRatio: 1,
  //                   // customAspectRatio: CustomAspectRatio(1, 1),
  //                   canRotate: true,
  //                   borderRadius: 0,
  //                   overlayColor: Colors.black.withOpacity(0.6),
  //                   cropPercentage: 0.8, // 80% of the image size
  //                 ),
  //               ),
  //               Container(
  //                 padding: const EdgeInsets.all(16),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                   children: [
  //                     TextButton(
  //                       onPressed: () => Navigator.of(context).pop(null),
  //                       style: TextButton.styleFrom(
  //                         foregroundColor: Colors.white,
  //                       ),
  //                       child: const Text('Cancel'),
  //                     ),
  //                     ElevatedButton(
  //                       onPressed: () async {
  //                         try {
  //                           // Get the cropped image data
  //                           final croppedData =
  //                               await cropController.onCropImage();
  //                           if (croppedData != null) {
  //                             Navigator.of(context).pop(croppedData);
  //                           } else {
  //                             Navigator.of(context).pop(null);
  //                           }
  //                         } catch (e) {
  //                           print('Error during crop: $e');
  //                           Navigator.of(context).pop(null);
  //                         }
  //                       },
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: Colors.blue,
  //                         foregroundColor: Colors.white,
  //                       ),
  //                       child: const Text('Crop'),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );

  //     if (result != null) {
  //       // Save the cropped image to a temporary file
  //       final tempDir = await getTemporaryDirectory();
  //       final timestamp = DateTime.now().millisecondsSinceEpoch;
  //       final newFile = File('${tempDir.path}/cropped_$timestamp.jpg');

  //       await newFile.writeAsBytes(result);
  //       return newFile;
  //     }

  //     return null;
  //   } catch (e) {
  //     print('Error cropping image: $e');
  //     return null;
  //   }
  // }

  // Future<File?> _cropImage(File image) async {
  //   try {
  //     CroppedFile? croppedFile = await ImageCropper().cropImage(
  //       sourcePath: image.path,
  //       compressFormat: ImageCompressFormat.jpg,
  //       compressQuality: 100,
  //       aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
  //       uiSettings: [
  //         AndroidUiSettings(
  //           toolbarTitle: 'Crop Image',
  //           toolbarColor: Colors.blue,
  //           toolbarWidgetColor: Colors.white,
  //           initAspectRatio: CropAspectRatioPreset.original,
  //           lockAspectRatio: false,
  //           // Added aspect ratio presets
  //           // aspectRatioPresets: [
  //           //   CropAspectRatioPreset.original,
  //           //   CropAspectRatioPreset.square,
  //           //   CropAspectRatioPreset.ratio3x2,
  //           //   CropAspectRatioPreset.ratio4x3,
  //           //   CropAspectRatioPreset.ratio16x9
  //           // ],
  //           // Added UI customization
  //           activeControlsWidgetColor: Colors.blue,
  //           dimmedLayerColor: Colors.black.withOpacity(0.6),
  //           showCropGrid: true,
  //           hideBottomControls: false,
  //           statusBarColor: Colors.blue.shade900,
  //           // Guidelines customization
  //           cropGridColor: Colors.white,
  //           cropGridStrokeWidth: 1,
  //           cropFrameColor: Colors.white,
  //           cropFrameStrokeWidth: 2,
  //         ),
  //         IOSUiSettings(
  //           title: 'Crop Image',
  //           doneButtonTitle: 'Done',
  //           cancelButtonTitle: 'Cancel',
  //           // Added aspect ratio presets
  //           // aspectRatioPresets: [
  //           //   CropAspectRatioPreset.original,
  //           //   CropAspectRatioPreset.square,
  //           //   CropAspectRatioPreset.ratio3x2,
  //           //   CropAspectRatioPreset.ratio4x3,
  //           //   CropAspectRatioPreset.ratio16x9,
  //           // ],
  //           // Added UI customization
  //           hidesNavigationBar: true,
  //           showCancelConfirmationDialog: true,
  //           rotateButtonsHidden: false,
  //           rotateClockwiseButtonHidden: false,
  //           resetButtonHidden: false,
  //           aspectRatioPickerButtonHidden: false,
  //           showActivitySheetOnDone: true,
  //         ),
  //       ],
  //     );

  //     if (croppedFile != null) {
  //       // Additional image processing after cropping
  //       final File processedFile = File(croppedFile.path);
  //       return processedFile;
  //     }
  //     return null;
  //   } catch (e) {
  //     print('Error cropping image: $e');
  //     return null;
  //   }
  // }

  // Future<File?> _cropImage(File image) async {
  //   try {
  //     CroppedFile? croppedFile = await ImageCropper().cropImage(
  //       sourcePath: image.path,
  //       compressFormat: ImageCompressFormat.jpg,
  //       compressQuality: 100,
  //       // Remove the fixed aspect ratio to allow different crop options
  //       uiSettings: [
  //         AndroidUiSettings(
  //           toolbarTitle: 'Crop Image',
  //           toolbarColor: Colors.blue,
  //           toolbarWidgetColor: Colors.white,
  //           initAspectRatio: CropAspectRatioPreset.original,
  //           lockAspectRatio: false,
  //           // Enable different crop options
  //           aspectRatioPresets: [
  //             CropAspectRatioPreset.original,
  //             CropAspectRatioPreset.square,
  //             CropAspectRatioPreset.ratio3x2,
  //             CropAspectRatioPreset.ratio4x3,
  //             CropAspectRatioPreset.ratio16x9,
  //             CropAspectRatioPreset.ratio5x3,
  //             CropAspectRatioPreset.ratio7x5,
  //           ],
  //           activeControlsWidgetColor: Colors.blue,
  //           dimmedLayerColor: Colors.black.withOpacity(0.6),
  //           showCropGrid: true,
  //           hideBottomControls: false,
  //           statusBarColor: Colors.blue.shade900,
  //           cropGridColor: Colors.white,
  //           cropGridStrokeWidth: 1,
  //           cropFrameColor: Colors.white,
  //           cropFrameStrokeWidth: 2,
  //         ),
  //         IOSUiSettings(
  //           title: 'Crop Image',
  //           doneButtonTitle: 'Done',
  //           cancelButtonTitle: 'Cancel',
  //           // Enable different crop options
  //           aspectRatioPresets: [
  //             CropAspectRatioPreset.original,
  //             CropAspectRatioPreset.square,
  //             CropAspectRatioPreset.ratio3x2,
  //             CropAspectRatioPreset.ratio4x3,
  //             CropAspectRatioPreset.ratio16x9,
  //             CropAspectRatioPreset.ratio5x3,
  //             CropAspectRatioPreset.ratio7x5,
  //           ],
  //           hidesNavigationBar: true,
  //           showCancelConfirmationDialog: true,
  //           rotateButtonsHidden: false,
  //           rotateClockwiseButtonHidden: false,
  //           resetButtonHidden: false,
  //           aspectRatioPickerButtonHidden: false,
  //           showActivitySheetOnDone: true,
  //         ),
  //       ],
  //     );

  //     if (croppedFile != null) {
  //       final File processedFile = File(croppedFile.path);
  //       return processedFile;
  //     }
  //     return null;
  //   } catch (e) {
  //     print('Error cropping image: $e');
  //     return null;
  //   }
  // }

  // Future<File?> _cropImage(File image) async {
  //   CroppedFile? croppedFile = await ImageCropper().cropImage(
  //     sourcePath: image.path,
  //     uiSettings: [
  //       AndroidUiSettings(
  //         toolbarTitle: 'Crop Image',
  //         toolbarColor: Colors.blue,
  //         toolbarWidgetColor: Colors.white,
  //         initAspectRatio: CropAspectRatioPreset.original,
  //         lockAspectRatio: false,
  //       ),
  //       IOSUiSettings(
  //         title: 'Crop Image',
  //       ),
  //       WebUiSettings(context: context),
  //     ],
  //   );

  //   if (croppedFile != null) {
  //     return File(croppedFile.path);
  //   }
  //   return null;
  // }

  Future<void> _selectDate(BuildContext context, int index) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            colorScheme: ColorScheme.light(primary: Colors.blue),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            dialogBackgroundColor: Colors.white,
          ),
          child: child ?? SizedBox(),
        );
      },
    );

    if (pickedDate != null) {
      // Format the date to 'dd/MM/yyyy' and set it in the text controller
      String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      personalControllers[index].text = formattedDate;
    }
  }

  Future<void> _selectTime(BuildContext context, int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        // Force English locale
        return Localizations.override(
          context: context,
          locale: const Locale('en', 'US'),
          child: Theme(
            data: ThemeData(
              colorScheme: ColorScheme.light(
                primary: Colors.blue,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
              buttonTheme: ButtonThemeData(
                shape: RoundedRectangleBorder(),
                textTheme: ButtonTextTheme.primary,
              ),
            ),
            child: MediaQuery(
              // Force 24-hour format to false for AM/PM style
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
              child: child!,
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Format time in English AM/PM format
        final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
        final minute = picked.minute.toString().padLeft(2, '0');
        final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
        personalControllers[index].text = '$hour:$minute $period';
      });
    }
  }

  late TextEditingController _searchController;
  late List<String> _filteredOptions;

  Future<void> _selectHeight(BuildContext context, int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return HeightSelectorDialog(
          heightOptions: heightOptions,
          onHeightSelected: (String selectedHeight) {
            setState(() {
              personalControllers[index].text = selectedHeight;
            });
          },
        );
      },
    );
  }

  Future<void> showSelectionDialog({
    required BuildContext context,
    required String title,
    required List<String> options,
    required Function(String) onSelected,
    required TextEditingController controller,
  }) async {
    List<String> filteredOptions = List.from(options);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.orangeColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          TextField(
                            controller: TextEditingController(),
                            onChanged: (query) {
                              setState(() {
                                filteredOptions = options
                                    .where((option) => option
                                        .toLowerCase()
                                        .contains(query.toLowerCase()))
                                    .toList();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: filteredOptions.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: Colors.grey[300],
                        ),
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              filteredOptions[index],
                              style: TextStyle(fontSize: 16),
                            ),
                            onTap: () {
                              onSelected(filteredOptions[index]);
                              controller.text = filteredOptions[index];
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
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

  Future<void> _selectBloodGroup(BuildContext context, int index) async {
    final localization = AppLocalizations.of(context);
    int bloodGroupIndex =
        personalLabels.indexWhere((label) => label == localization!.bloodGroup);

    if (bloodGroupIndex == -1) {
      bloodGroupIndex = index;
    }

    await showSelectionDialog(
      context: context,
      title: 'Select Blood Group*',
      options: bloodGroups,
      controller: personalControllers[bloodGroupIndex],
      onSelected: (String selectedValue) {
        setState(() {
          personalControllers[bloodGroupIndex].text = selectedValue;
        });
      },
    );
  }

  // Future<void> _selectBloodGroup(BuildContext context, int index) async {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return SimpleDialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(),
  //         title: Text('Select Blood Group'),
  //         children: bloodGroups.asMap().entries.map((entry) {
  //           int i = entry.key;
  //           String bloodGroup = entry.value;

  //           return Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               SimpleDialogOption(
  //                 onPressed: () {
  //                   setState(() {
  //                     personalControllers[index].text = bloodGroup;
  //                   });
  //                   Navigator.pop(context);
  //                 },
  //                 child: Text(bloodGroup),
  //               ),
  //               if (i != bloodGroups.length - 1)
  //                 Divider(
  //                   color: Colors.grey,
  //                   thickness: 1.0,
  //                   indent: 16.0,
  //                   endIndent: 16.0,
  //                 ),
  //             ],
  //           );
  //         }).toList(),
  //       );
  //     },
  //   );
  // }

  // Future<void> _selectBloodGroup(BuildContext context, int index) async {
  //   final TextEditingController searchController = TextEditingController();
  //   List<String> filteredGroups = List.from(bloodGroups);

  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return Dialog(
  //             backgroundColor: Colors.white,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             child: Container(
  //               width: double.infinity,
  //               constraints: BoxConstraints(
  //                 maxHeight: MediaQuery.of(context).size.height * 0.5,
  //               ),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Container(
  //                     padding: const EdgeInsets.all(16),
  //                     decoration: BoxDecoration(
  //                       color: AppColors.orangeColor,
  //                       borderRadius: BorderRadius.only(
  //                         topLeft: Radius.circular(8),
  //                         topRight: Radius.circular(8),
  //                       ),
  //                     ),
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                           children: [
  //                             Text(
  //                               'Select Blood Group*',
  //                               style: TextStyle(
  //                                 fontSize: 20,
  //                                 fontWeight: FontWeight.bold,
  //                                 color: Colors.white,
  //                               ),
  //                             ),
  //                             GestureDetector(
  //                               onTap: () => Navigator.pop(context),
  //                               child: Icon(
  //                                 Icons.close,
  //                                 color: Colors.white,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                         SizedBox(height: 12),
  //                         TextField(
  //                           controller: searchController,
  //                           onChanged: (value) {
  //                             setState(() {
  //                               filteredGroups = bloodGroups
  //                                   .where((group) => group
  //                                       .toLowerCase()
  //                                       .contains(value.toLowerCase()))
  //                                   .toList();
  //                             });
  //                           },
  //                           decoration: InputDecoration(
  //                             hintText: 'Search...',
  //                             filled: true,
  //                             fillColor: Colors.white,
  //                             border: OutlineInputBorder(
  //                               borderRadius: BorderRadius.circular(25),
  //                               borderSide: BorderSide.none,
  //                             ),
  //                             contentPadding: EdgeInsets.symmetric(
  //                               horizontal: 20,
  //                               vertical: 10,
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   Flexible(
  //                     child: ListView.separated(
  //                       shrinkWrap: true,
  //                       itemCount: filteredGroups.length,
  //                       separatorBuilder: (context, index) => Divider(
  //                         height: 1,
  //                         color: Colors.grey[300],
  //                       ),
  //                       itemBuilder: (context, index) {
  //                         return ListTile(
  //                           title: Text(
  //                             filteredGroups[index],
  //                             style: TextStyle(fontSize: 16),
  //                           ),
  //                           onTap: () {
  //                             this.setState(() {
  //                               personalControllers[index].text =
  //                                   filteredGroups[index];
  //                             });
  //                             Navigator.pop(context);
  //                           },
  //                         );
  //                       },
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  // Future<void> _selectBloodGroup(BuildContext context, int index) async {
  //   final localization = AppLocalizations.of(context);
  //   // Find the actual index of the blood group field
  //   int bloodGroupIndex =
  //       personalLabels.indexWhere((label) => label == localization!.bloodGroup);

  //   // If we couldn't find the blood group field, use the provided index
  //   if (bloodGroupIndex == -1) {
  //     bloodGroupIndex = index;
  //   }

  //   final TextEditingController searchController = TextEditingController();
  //   List<String> filteredGroups = List.from(bloodGroups);

  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return Dialog(
  //             backgroundColor: Colors.white,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             child: Container(
  //               width: double.infinity,
  //               constraints: BoxConstraints(
  //                 maxHeight: MediaQuery.of(context).size.height * 0.5,
  //               ),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   // ... your existing header code ...
  //                   Flexible(
  //                     child: ListView.separated(
  //                       shrinkWrap: true,
  //                       itemCount: filteredGroups.length,
  //                       separatorBuilder: (context, index) => Divider(
  //                         height: 1,
  //                         color: Colors.grey[300],
  //                       ),
  //                       itemBuilder: (context, index) {
  //                         return ListTile(
  //                           title: Text(
  //                             filteredGroups[index],
  //                             style: TextStyle(fontSize: 16),
  //                           ),
  //                           onTap: () {
  //                             this.setState(() {
  //                               // Use the correct index for the blood group field
  //                               personalControllers[bloodGroupIndex].text =
  //                                   filteredGroups[index];
  //                             });
  //                             Navigator.pop(context);
  //                           },
  //                         );
  //                       },
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  // Future<void> _selectBloodGroup(BuildContext context, int index) async {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return SimpleDialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(),
  //         title: Text('Select Blood Group'),
  //         children: bloodGroups.map((bloodGroup) {
  //           return SimpleDialogOption(
  //             onPressed: () {
  //               setState(() {
  //                 personalControllers[index].text = bloodGroup;
  //               });
  //               Navigator.pop(context);
  //             },
  //             child: Text(bloodGroup),
  //           );
  //         }).toList(),
  //       );
  //     },
  //   );
  // }

  void swapEducationFields(int currentIndex, int newIndex) {
    if (newIndex >= 0 && newIndex < dynamicEducationFields.length) {
      setState(() {
        final temp = dynamicEducationFields[currentIndex];
        dynamicEducationFields[currentIndex] = dynamicEducationFields[newIndex];
        dynamicEducationFields[newIndex] = temp;
      });
    }
  }

  Widget _buildImagePickerWidget(File? imageFile, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
              child: ClipOval(
                child: imageFile != null
                    ? Image.file(
                        imageFile,
                        fit: BoxFit.cover,
                        height: 100,
                        width: 100,
                      )
                    : Icon(
                        Icons.camera_alt,
                        size: 60,
                      ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  // color: AppColors.orangeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black),
                ),
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(label, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  // Widget _buildImagePickerWidget(File? imageFile, String label) {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       Stack(
  //         children: [
  //           Container(
  //             height: 100,
  //             width: 100,
  //             decoration: BoxDecoration(
  //               shape: BoxShape.circle,
  //               border: Border.all(color: Colors.grey),
  //             ),
  //             child: ClipOval(
  //               child: imageFile != null
  //                   ? Image.file(
  //                       imageFile,
  //                       fit: BoxFit.cover,
  //                       height: 100,
  //                       width: 100,
  //                     )
  //                   : Icon(
  //                       Icons.camera_alt,
  //                       size: 60,
  //                     ),
  //             ),
  //           ),
  //           // Edit button
  //           Positioned(
  //             right: 0,
  //             bottom: 0,
  //             child: Container(
  //               decoration: BoxDecoration(
  //                 color: Colors.black,
  //                 shape: BoxShape.circle,
  //                 border: Border.all(color: Colors.black),
  //               ),
  //               padding: const EdgeInsets.all(4.0),
  //               child: Icon(
  //                 Icons.edit,
  //                 color: Colors.white,
  //                 size: 15,
  //               ),
  //             ),
  //           ),
  //           // Delete button - only show if there's an image

  //           Positioned(
  //             left: 0,
  //             bottom: 0,
  //             child: GestureDetector(
  //               onTap: () {
  //                 setState(() {
  //                   if (imageFile == imageFile1) {
  //                     imageFile1 = null;
  //                   } else if (imageFile == imageFile2) {
  //                     imageFile2 = null;
  //                   }
  //                 });
  //               },
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   color: Colors.black,
  //                   shape: BoxShape.circle,
  //                   border: Border.all(color: Colors.black),
  //                 ),
  //                 padding: const EdgeInsets.all(4.0),
  //                 child: Icon(
  //                   Icons.delete,
  //                   color: Colors.white,
  //                   size: 15,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //       SizedBox(height: 10),
  //       Text(label, style: TextStyle(fontSize: 14)),
  //     ],
  //   );
  // }

  void _showLanguageSwitchDialog(
    BuildContext context,
    String languageCode,
    LanguageController controller,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(),
          title: Text(
            'Alert !',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Switching language may delete some entered data',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: AppColors.orangeColor,
                  fontSize: 18,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Find the selected language or set to a default if not found
                final selectedLanguage = controller.languages.firstWhere(
                  (lang) => lang['locale'] == languageCode,
                  orElse: () => {'locale': languageCode, 'name': 'Unknown'},
                );

                // Safely access the name and locale fields, handling nulls
                final selectedName = selectedLanguage['name'] ?? 'Unknown';
                final selectedLocale =
                    selectedLanguage['locale'] ?? languageCode;

                // Log the selected language name and locale code
                log("Switching to language: $selectedName ($selectedLocale)");
                controller.changeLocale(languageCode);

                Navigator.of(context).pop();
              },
              child: Text(
                'SWITCH',
                style: TextStyle(
                  color: AppColors.orangeColor,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void swapFields() {
    setState(() {
      // Swap the text in the controllers
      String temp = gothraController.text;
      gothraController.text = complexionController.text;
      complexionController.text = temp;

      // Swap the labels
      String tempLabel = gothraLabel;
      gothraLabel = complexionLabel;
      complexionLabel = tempLabel;
    });
  }

  // void _moveField(int fromIndex, int toIndex, List list) {
  //   if (toIndex >= 0 && toIndex < list.length) {
  //     setState(() {
  //       // Swap elements in the list
  //       final temp = list[fromIndex];
  //       list[fromIndex] = list[toIndex];
  //       list[toIndex] = temp;
  //     });
  //   }
  // }

  // void _moveField(int fromIndex, int toIndex) {
  //   if (toIndex >= 0 && toIndex < controllers.length) {
  //     setState(() {
  //       // Swap controllers and labels
  //       final tempController = controllers[fromIndex];
  //       controllers[fromIndex] = controllers[toIndex];
  //       controllers[toIndex] = tempController;

  //       final tempLabel = labels[fromIndex];
  //       labels[fromIndex] = labels[toIndex];
  //       labels[toIndex] = tempLabel;
  //     });
  //   }
  // }

  void _moveField(int fromIndex, int toIndex) {
    setState(() {
      // Calculate total number of fields
      int totalFields = controllers.length + dynamicEducationFields.length;

      // Validate index bounds
      if (toIndex < 0 || toIndex >= totalFields) {
        return;
      }

      // Helper function to convert education field to map format
      Map<String, dynamic> convertToFieldMap(
          TextEditingController controller, String label) {
        return {
          'controller': controller,
          'label': label,
          'focusNode': FocusNode(),
        };
      }

      // Helper function to update static education field
      void updateEducationField(int index, Map<String, dynamic> fieldData) {
        controllers[index] = fieldData['controller'];
        labels[index] = fieldData['label'];
      }

      // Store source field data
      Map<String, dynamic> sourceField;
      if (fromIndex < controllers.length) {
        sourceField =
            convertToFieldMap(controllers[fromIndex], labels[fromIndex]);
      } else {
        sourceField = Map<String, dynamic>.from(
            dynamicEducationFields[fromIndex - controllers.length]);
      }

      // Store target field data
      Map<String, dynamic> targetField;
      if (toIndex < controllers.length) {
        targetField = convertToFieldMap(controllers[toIndex], labels[toIndex]);
      } else {
        targetField = Map<String, dynamic>.from(
            dynamicEducationFields[toIndex - controllers.length]);
      }

      // Perform the swap
      if (fromIndex < controllers.length) {
        updateEducationField(fromIndex, targetField);
      } else {
        dynamicEducationFields[fromIndex - controllers.length] = targetField;
      }

      if (toIndex < controllers.length) {
        updateEducationField(toIndex, sourceField);
      } else {
        dynamicEducationFields[toIndex - controllers.length] = sourceField;
      }
    });
  }

  // void _moveFamilyField(int fromIndex, int toIndex) {
  //   if (toIndex >= 0 && toIndex < familyControllers.length) {
  //     setState(() {
  //       // Swap controllers and labels
  //       final tempController = familyControllers[fromIndex];
  //       familyControllers[fromIndex] = familyControllers[toIndex];
  //       familyControllers[toIndex] = tempController;

  //       final tempLabel = familyLabels[fromIndex];
  //       familyLabels[fromIndex] = familyLabels[toIndex];
  //       familyLabels[toIndex] = tempLabel;
  //     });
  //   }
  // }

  // void _moveFamilyField(int fromIndex, int toIndex) {
  //   setState(() {
  //     // Calculate total number of fields
  //     int totalFields = familyControllers.length + dynamicfamilyFields.length;

  //     // Validate index bounds
  //     if (toIndex < 0 || toIndex >= totalFields) {
  //       return;
  //     }

  //     // Helper function to convert family field to map format
  //     Map<String, dynamic> convertToFieldMap(
  //         TextEditingController controller, String label) {
  //       return {
  //         'controller': controller,
  //         'label': label,
  //         'focusNode': FocusNode(),
  //       };
  //     }

  //     // Helper function to update static family field
  //     void updateFamilyField(int index, Map<String, dynamic> fieldData) {
  //       familyControllers[index] = fieldData['controller'];
  //       familyLabels[index] = fieldData['label'];
  //     }

  //     // Store source field data
  //     Map<String, dynamic> sourceField;
  //     if (fromIndex < familyControllers.length) {
  //       sourceField = convertToFieldMap(
  //           familyControllers[fromIndex], familyLabels[fromIndex]);
  //     } else {
  //       sourceField = Map<String, dynamic>.from(
  //           dynamicfamilyFields[fromIndex - familyControllers.length]);
  //     }

  //     // Store target field data
  //     Map<String, dynamic> targetField;
  //     if (toIndex < familyControllers.length) {
  //       targetField = convertToFieldMap(
  //           familyControllers[toIndex], familyLabels[toIndex]);
  //     } else {
  //       targetField = Map<String, dynamic>.from(
  //           dynamicfamilyFields[toIndex - familyControllers.length]);
  //     }

  //     // Perform the swap
  //     if (fromIndex < familyControllers.length) {
  //       updateFamilyField(fromIndex, targetField);
  //     } else {
  //       dynamicfamilyFields[fromIndex - familyControllers.length] = targetField;
  //     }

  //     if (toIndex < familyControllers.length) {
  //       updateFamilyField(toIndex, sourceField);
  //     } else {
  //       dynamicfamilyFields[toIndex - familyControllers.length] = sourceField;
  //     }
  //   });
  // }
  List<int> fieldOrder = [];

  void _moveFamilyField(int fromIndex, int toIndex) {
    setState(() {
      // Calculate total number of fields
      int totalFields = familyControllers.length + dynamicfamilyFields.length;

      // Validate index bounds
      if (toIndex < 0 || toIndex >= totalFields) {
        return;
      }

      // Handle swapping within static fields
      if (fromIndex < familyControllers.length &&
          toIndex < familyControllers.length) {
        // Swap controllers
        TextEditingController tempController = familyControllers[fromIndex];
        familyControllers[fromIndex] = familyControllers[toIndex];
        familyControllers[toIndex] = tempController;

        // Swap labels
        String tempLabel = familyLabels[fromIndex];
        familyLabels[fromIndex] = familyLabels[toIndex];
        familyLabels[toIndex] = tempLabel;
      }
      // Handle swapping between static and dynamic fields
      else if (fromIndex < familyControllers.length &&
          toIndex >= familyControllers.length) {
        // Get dynamic field index
        int dynamicIndex = toIndex - familyControllers.length;

        // Store static field data
        TextEditingController staticController = familyControllers[fromIndex];
        String staticLabel = familyLabels[fromIndex];

        // Store dynamic field data
        TextEditingController dynamicController =
            dynamicfamilyFields[dynamicIndex]['controller'];
        String dynamicLabel = dynamicfamilyFields[dynamicIndex]['label'];
        FocusNode dynamicFocusNode =
            dynamicfamilyFields[dynamicIndex]['focusNode'];

        // Update static field
        familyControllers[fromIndex] = dynamicController;
        familyLabels[fromIndex] = dynamicLabel;

        // Update dynamic field
        dynamicfamilyFields[dynamicIndex] = {
          'controller': staticController,
          'label': staticLabel,
          'focusNode': dynamicFocusNode,
        };
      }
      // Handle swapping from dynamic to static field
      else if (fromIndex >= familyControllers.length &&
          toIndex < familyControllers.length) {
        // Get dynamic field index
        int dynamicIndex = fromIndex - familyControllers.length;

        // Store dynamic field data
        TextEditingController dynamicController =
            dynamicfamilyFields[dynamicIndex]['controller'];
        String dynamicLabel = dynamicfamilyFields[dynamicIndex]['label'];
        FocusNode dynamicFocusNode =
            dynamicfamilyFields[dynamicIndex]['focusNode'];

        // Store static field data
        TextEditingController staticController = familyControllers[toIndex];
        String staticLabel = familyLabels[toIndex];

        // Update static field
        familyControllers[toIndex] = dynamicController;
        familyLabels[toIndex] = dynamicLabel;

        // Update dynamic field
        dynamicfamilyFields[dynamicIndex] = {
          'controller': staticController,
          'label': staticLabel,
          'focusNode': dynamicFocusNode,
        };
      }
      // Handle swapping between dynamic fields
      else if (fromIndex >= familyControllers.length &&
          toIndex >= familyControllers.length) {
        int fromDynamicIndex = fromIndex - familyControllers.length;
        int toDynamicIndex = toIndex - familyControllers.length;

        // Store the source field's data
        Map<String, dynamic> tempField =
            Map<String, dynamic>.from(dynamicfamilyFields[fromDynamicIndex]);

        // Perform the swap
        dynamicfamilyFields[fromDynamicIndex] =
            dynamicfamilyFields[toDynamicIndex];
        dynamicfamilyFields[toDynamicIndex] = tempField;
      }
    });
  }

  // void _moveFamilyField(int fromIndex, int toIndex) {
  //   setState(() {
  //     // Calculate total fields and validate bounds
  //     int totalFields = familyControllers.length + dynamicfamilyFields.length;
  //     if (toIndex < 0 || toIndex >= totalFields) return;

  //     // Get source field data
  //     TextEditingController sourceController;
  //     String sourceLabel;
  //     FocusNode? sourceFocusNode;

  //     if (fromIndex < familyControllers.length) {
  //       sourceController = familyControllers[fromIndex];
  //       sourceLabel = familyLabels[fromIndex];
  //       sourceFocusNode = null;
  //     } else {
  //       int dynamicFromIndex = fromIndex - familyControllers.length;
  //       sourceController = dynamicfamilyFields[dynamicFromIndex]['controller'];
  //       sourceLabel = dynamicfamilyFields[dynamicFromIndex]['label'];
  //       sourceFocusNode = dynamicfamilyFields[dynamicFromIndex]['focusNode'];
  //     }

  //     // Get target field data
  //     TextEditingController targetController;
  //     String targetLabel;
  //     FocusNode? targetFocusNode;

  //     if (toIndex < familyControllers.length) {
  //       targetController = familyControllers[toIndex];
  //       targetLabel = familyLabels[toIndex];
  //       targetFocusNode = null;
  //     } else {
  //       int dynamicToIndex = toIndex - familyControllers.length;
  //       targetController = dynamicfamilyFields[dynamicToIndex]['controller'];
  //       targetLabel = dynamicfamilyFields[dynamicToIndex]['label'];
  //       targetFocusNode = dynamicfamilyFields[dynamicToIndex]['focusNode'];
  //     }

  //     // Swap the actual data
  //     if (fromIndex < familyControllers.length) {
  //       familyControllers[fromIndex] = targetController;
  //       familyLabels[fromIndex] = targetLabel;
  //     } else {
  //       int dynamicFromIndex = fromIndex - familyControllers.length;
  //       dynamicfamilyFields[dynamicFromIndex] = {
  //         'controller': targetController,
  //         'label': targetLabel,
  //         'focusNode': targetFocusNode ?? FocusNode(),
  //       };
  //     }

  //     if (toIndex < familyControllers.length) {
  //       familyControllers[toIndex] = sourceController;
  //       familyLabels[toIndex] = sourceLabel;
  //     } else {
  //       int dynamicToIndex = toIndex - familyControllers.length;
  //       dynamicfamilyFields[dynamicToIndex] = {
  //         'controller': sourceController,
  //         'label': sourceLabel,
  //         'focusNode': sourceFocusNode ?? FocusNode(),
  //       };
  //     }
  //   });
  // }

  // void swapPropertyExpectations() {
  //   setState(() {
  //     String temp = propertyController.text;
  //     propertyController.text = expectationsController.text;
  //     expectationsController.text = temp;

  //     // Swap the labels
  //     String tempLabel = propertyLabel;
  //     propertyLabel = expectationsLabel;
  //     expectationsLabel = tempLabel;
  //   });
  // }

  void _moveOtherField(int fromIndex, int toIndex) {
    setState(() {
      // Create a combined list of all fields
      List<FieldData> allFields = [];

      // Store the current texts before making any changes
      String? propertyText = isPropertyVisible ? propertyController.text : null;
      String? expectationsText =
          isExpectationsVisible ? expectationsController.text : null;
      List<dynamic> dynamicTexts =
          dynamicOtherFields.map((field) => field['controller'].text).toList();

      // Add static fields if visible
      if (isPropertyVisible) {
        allFields.add(FieldData(
          controller: propertyController,
          label: propertyLabel,
        ));
      }
      if (isExpectationsVisible) {
        allFields.add(FieldData(
          controller: expectationsController,
          label: expectationsLabel,
        ));
      }

      // Add dynamic fields
      allFields.addAll(dynamicOtherFields.map((field) => FieldData(
            controller: field['controller'],
            label: field['label'],
          )));

      // Validate bounds
      if (fromIndex < 0 ||
          fromIndex >= allFields.length ||
          toIndex < 0 ||
          toIndex >= allFields.length) {
        return;
      }

      // Store the texts that need to be swapped
      String fromText = allFields[fromIndex].controller.text;
      String toText = allFields[toIndex].controller.text;
      String fromLabel = allFields[fromIndex].label;
      String toLabel = allFields[toIndex].label;

      // Update the fields based on swap
      int staticFieldCount =
          (isPropertyVisible ? 1 : 0) + (isExpectationsVisible ? 1 : 0);

      if (fromIndex < staticFieldCount) {
        // From is a static field
        if (fromIndex == 0 && isPropertyVisible) {
          propertyController.text = toText;
          propertyLabel = toLabel;
        } else if (isExpectationsVisible) {
          expectationsController.text = toText;
          expectationsLabel = toLabel;
        }
      } else {
        // From is a dynamic field
        int dynamicFromIndex = fromIndex - staticFieldCount;
        dynamicOtherFields[dynamicFromIndex]['controller'].text = toText;
        dynamicOtherFields[dynamicFromIndex]['label'] = toLabel;
      }

      if (toIndex < staticFieldCount) {
        // To is a static field
        if (toIndex == 0 && isPropertyVisible) {
          propertyController.text = fromText;
          propertyLabel = fromLabel;
        } else if (isExpectationsVisible) {
          expectationsController.text = fromText;
          expectationsLabel = fromLabel;
        }
      } else {
        // To is a dynamic field
        int dynamicToIndex = toIndex - staticFieldCount;
        dynamicOtherFields[dynamicToIndex]['controller'].text = fromText;
        dynamicOtherFields[dynamicToIndex]['label'] = fromLabel;
      }
    });
  }

  bool isDataChanged = false;
  void onSaveData() {
    // Call this method when data is saved or updated
    setState(() {
      isDataChanged = true;
    });
  }

  Future<bool> onWillPop() async {
    // Return to HomePage with isDataChanged status
    Navigator.pop(context, isDataChanged);
    return false; // Prevent default back button behavior
  }

  // bool _isEditable = false;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    if (localization == null) {
      throw FlutterError('Localization not found for the current context.');
    }
    final controller = Provider.of<LanguageController>(context, listen: false);

    List<String> castes = [
      localization.buddhism,
      localization.christian,
      localization.hindu,
      localization.islam,
      localization.sikh,
      localization.parsi,
      localization.jain,
      localization.jewish,
    ];

    List<String> educationLevels = [
      localization.hsc,
      localization.ssc,
      localization.intermediate,
      localization.graduate,
      localization.postGraduate,
      localization.engineerBTech,
      localization.mTech,
      localization.beme,
      localization.doctor,
      localization.bams,
      localization.lawyer,
      localization.diploma,
      localization.iti,
      localization.pharmacy,
      localization.bpharmacy,
      localization.mpharmacy,
      localization.mba,
      localization.hotelManagement,
    ];

    Future<void> _showEducationLevelDialog() async {
      final TextEditingController searchController = TextEditingController();
      List<String> filteredLevels = List.from(educationLevels);

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.orangeColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Select Education Level*',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            TextField(
                              controller: searchController,
                              onChanged: (value) {
                                setState(() {
                                  filteredLevels = educationLevels
                                      .where((level) => level
                                          .toLowerCase()
                                          .contains(value.toLowerCase()))
                                      .toList();
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: filteredLevels.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: Colors.grey[300],
                          ),
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                filteredLevels[index],
                                style: TextStyle(fontSize: 16),
                              ),
                              onTap: () {
                                educationLevelController.text =
                                    filteredLevels[index];
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
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

    final FocusNode dynamicFieldFocusNode = FocusNode();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, isDataChanged);
          },
          icon: Icon(Icons.arrow_back),
        ),
        backgroundColor: AppColors.orangeColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Create Biodata",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Consumer<LanguageController>(
                  builder: (context, controller, _) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            List.generate(controller.languages.length, (index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                  side: BorderSide(
                                    color: AppColors.orangeColor,
                                  ),
                                ),
                                backgroundColor: controller.selectedIndex ==
                                        index
                                    ? AppColors.orangeColor // Selected color
                                    : Colors.grey.shade300, // Unselected color
                              ),
                              onPressed: () {
                                final selectedLocale =
                                    controller.languages[index]['locale']!;
                                _showLanguageSwitchDialog(
                                    context, selectedLocale, controller);
                              },
                              child: Text(
                                controller.languages[index]['name']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: controller.selectedIndex == index
                                      ? Colors.white // Selected text color
                                      : Colors.black, // Unselected text color
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: titleController,
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      biodataTitle,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: Size(15, 15),
                      ),
                      onPressed: () {
                        _showEditPopupBiodataTitle(context);
                      },
                      icon: Icon(
                        Icons.edit,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _selectImage1(context),
                      child: _buildImagePickerWidget(imageFile1, ""),
                    ),
                    SizedBox(width: 15),
                    GestureDetector(
                      onTap: () => _selectImage2(context),
                      child: _buildImagePickerWidget(imageFile2, ""),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 5),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: Size(15, 15),
                        ),
                        onPressed: () {
                          _showEditPopup(context); // Show the edit popup
                        },
                        icon: Icon(
                          Icons.edit,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: fullNameController,
                  decoration: InputDecoration(
                    labelText: localization.fullName,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        value: (selectedCaste != null &&
                                castes.contains(selectedCaste))
                            ? selectedCaste
                            : null, // Ensure the value is in the list
                        decoration:
                            InputDecoration(labelText: localization.caste),
                        items: castes.toSet().map(
                          (caste) {
                            return DropdownMenuItem<String>(
                              value: caste,
                              child: Text(caste),
                            );
                          },
                        ).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedCaste = newValue ??
                                ''; // Assign the new value or empty string
                            otherCasteController.text = newValue ?? '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter a Caste';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 5.w,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: subCasteController,
                        decoration:
                            InputDecoration(labelText: localization.subcaste),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter a Subcaste';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Column(
                  children: List.generate(personalControllers.length, (index) {
                    return Visibility(
                      visible: personalFieldVisibility[index],
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: personalLabels[index] ==
                                      localization.birthDate
                                  ? () => _selectDate(context, index)
                                  : personalLabels[index] ==
                                          localization.birthTime
                                      ? () => _selectTime(context, index)
                                      : personalLabels[index] ==
                                              localization.height
                                          ? () => _selectHeight(context, index)
                                          : personalLabels[index] ==
                                                  localization.bloodGroup
                                              ? () => _selectBloodGroup(
                                                  context, index)
                                              : null,
                              child: AbsorbPointer(
                                absorbing: personalLabels[index] ==
                                        localization.birthDate ||
                                    personalLabels[index] ==
                                        localization.birthTime ||
                                    personalLabels[index] ==
                                        localization.height ||
                                    personalLabels[index] ==
                                        localization.bloodGroup,
                                child: TextFormField(
                                  controller: personalControllers[index],
                                  decoration: InputDecoration(
                                    labelText: personalLabels[index],
                                    suffixIcon: personalLabels[index] ==
                                            "Birth Date"
                                        ? null
                                        : personalLabels[index] == "Birth Time"
                                            ? null
                                            : null,
                                  ),
                                  keyboardType:
                                      personalLabels[index] == "Height"
                                          ? TextInputType.number
                                          : TextInputType.text,
                                  inputFormatters: personalLabels[index] ==
                                          "Height"
                                      ? [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(3),
                                        ]
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              GestureDetector(
                                child: Icon(Icons.keyboard_arrow_up,
                                    color: AppColors.orangeColor),
                                onTap: () =>
                                    _movePersonalField(index, index - 1),
                              ),
                              IconButton(
                                icon: Icon(Icons.keyboard_arrow_down,
                                    color: AppColors.orangeColor),
                                onPressed: () =>
                                    _movePersonalField(index, index + 1),
                              ),
                            ],
                          ),
                          GestureDetector(
                            child: Icon(Icons.delete,
                                color: AppColors.orangeColor),
                            onTap: () => _deletePersonalField(index),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                SizedBox(height: 10),
                Column(
                  children: personalDynamicFields.asMap().entries.map((entry) {
                    int dynamicIndex = entry.key;
                    int actualIndex = dynamicIndex + personalControllers.length;
                    Map<String, dynamic> field = entry.value;

                    // Safely check visibility with null coalescing
                    bool isVisible =
                        dynamicIndex < personalDynamicFieldVisibility.length
                            ? personalDynamicFieldVisibility[dynamicIndex]
                            : true;
                    if (isVisible) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 18),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: field['controller'],
                                focusNode: field['focusNode'],
                                decoration:
                                    InputDecoration(labelText: field['label']),
                              ),
                            ),
                            Column(
                              children: [
                                GestureDetector(
                                  child: Icon(Icons.keyboard_arrow_up,
                                      color: AppColors.orangeColor),
                                  onTap: () {
                                    if (actualIndex > 0) {
                                      _movePersonalField(
                                          actualIndex, actualIndex - 1);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.keyboard_arrow_down,
                                      color: AppColors.orangeColor),
                                  onPressed: () {
                                    if (actualIndex <
                                        (personalControllers.length +
                                            personalDynamicFields.length -
                                            1)) {
                                      _movePersonalField(
                                          actualIndex, actualIndex + 1);
                                    }
                                  },
                                ),
                              ],
                            ),
                            GestureDetector(
                              child: Icon(Icons.delete,
                                  color: AppColors.orangeColor),
                              onTap: () =>
                                  _deleteDynamicPersonalField(dynamicIndex),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Container(); // Return empty container for invisible fields
                    }
                  }).toList(),
                ),
                // Column(
                //   children: personalDynamicFields.asMap().entries.map((entry) {
                //     int dynamicIndex = entry.key;
                //     int actualIndex = dynamicIndex + personalControllers.length;
                //     Map<String, dynamic> field = entry.value;

                //     // Only show fields that are visible
                //     if (personalDynamicFieldVisibility[dynamicIndex]) {
                //       return Padding(
                //         padding: EdgeInsets.only(bottom: 18),
                //         child: Row(
                //           children: [
                //             Expanded(
                //               child: TextFormField(
                //                 controller: field['controller'],
                //                 focusNode: field['focusNode'],
                //                 decoration:
                //                     InputDecoration(labelText: field['label']),
                //               ),
                //             ),
                //             Column(
                //               children: [
                //                 GestureDetector(
                //                   child: Icon(Icons.keyboard_arrow_up,
                //                       color: AppColors.orangeColor),
                //                   onTap: () {
                //                     if (actualIndex > 0) {
                //                       _movePersonalField(
                //                           actualIndex, actualIndex - 1);
                //                     }
                //                   },
                //                 ),
                //                 IconButton(
                //                   icon: Icon(Icons.keyboard_arrow_down,
                //                       color: AppColors.orangeColor),
                //                   onPressed: () {
                //                     if (actualIndex <
                //                         (personalControllers.length +
                //                             personalDynamicFields.length -
                //                             1)) {
                //                       _movePersonalField(
                //                           actualIndex, actualIndex + 1);
                //                     }
                //                   },
                //                 ),
                //               ],
                //             ),
                //             GestureDetector(
                //               child: Icon(Icons.delete,
                //                   color: AppColors.orangeColor),
                //               onTap: () =>
                //                   _deleteDynamicPersonalField(dynamicIndex),
                //             ),
                //           ],
                //         ),
                //       );
                //     } else {
                //       // Return an empty container for invisible fields
                //       return Container();
                //     }
                //   }).toList(),
                // ),
                // Column(
                //   children:
                //       personalDynamicFields.asMap().entries.where((entry) {
                //     // Only show fields that are visible
                //     return personalDynamicFieldVisibility[entry.key];
                //   }).map((entry) {
                //     int dynamicIndex = entry.key;
                //     int actualIndex = dynamicIndex + personalControllers.length;
                //     Map<String, dynamic> field = entry.value;

                //     return Visibility(
                //       visible: personalDynamicFieldVisibility[dynamicIndex],
                //       child: Padding(
                //         padding: EdgeInsets.only(bottom: 18),
                //         child: Row(
                //           children: [
                //             Expanded(
                //               child: TextFormField(
                //                 controller: field['controller'],
                //                 focusNode: field['focusNode'],
                //                 decoration:
                //                     InputDecoration(labelText: field['label']),
                //               ),
                //             ),
                //             Column(
                //               children: [
                //                 GestureDetector(
                //                   child: Icon(Icons.keyboard_arrow_up,
                //                       color: AppColors.orangeColor),
                //                   onTap: () {
                //                     if (actualIndex > 0) {
                //                       _movePersonalField(
                //                           actualIndex, actualIndex - 1);
                //                     }
                //                   },
                //                 ),
                //                 IconButton(
                //                   icon: Icon(Icons.keyboard_arrow_down,
                //                       color: AppColors.orangeColor),
                //                   onPressed: () {
                //                     if (actualIndex <
                //                         (personalControllers.length +
                //                             personalDynamicFields.length -
                //                             1)) {
                //                       _movePersonalField(
                //                           actualIndex, actualIndex + 1);
                //                     }
                //                   },
                //                 ),
                //               ],
                //             ),
                //             GestureDetector(
                //               child: Icon(Icons.delete,
                //                   color: AppColors.orangeColor),
                //               onTap: () =>
                //                   _deleteDynamicPersonalField(dynamicIndex),
                //             ),
                //           ],
                //         ),
                //       ),
                //     );
                //   }).toList(),
                // ),
                // Column(
                //   children: personalDynamicFields.asMap().entries.map((entry) {
                //     int dynamicIndex = entry.key;
                //     int actualIndex = dynamicIndex + personalControllers.length;
                //     Map<String, dynamic> field = entry.value;

                //     return Padding(
                //       padding: EdgeInsets.only(bottom: 18),
                //       child: Row(
                //         children: [
                //           Expanded(
                //             child: TextFormField(
                //               controller: field['controller'],
                //               focusNode: field['focusNode'],
                //               decoration:
                //                   InputDecoration(labelText: field['label']),
                //             ),
                //           ),
                //           Column(
                //             children: [
                //               GestureDetector(
                //                 child: Icon(Icons.keyboard_arrow_up,
                //                     color: AppColors.orangeColor),
                //                 onTap: () {
                //                   if (actualIndex > 0) {
                //                     _movePersonalField(
                //                         actualIndex, actualIndex - 1);
                //                   }
                //                 },
                //               ),
                //               IconButton(
                //                 icon: Icon(Icons.keyboard_arrow_down,
                //                     color: AppColors.orangeColor),
                //                 onPressed: () {
                //                   if (actualIndex <
                //                       (personalControllers.length +
                //                           personalDynamicFields.length -
                //                           1)) {
                //                     _movePersonalField(
                //                         actualIndex, actualIndex + 1);
                //                   }
                //                 },
                //               ),
                //             ],
                //           ),
                //           GestureDetector(
                //             child: Icon(Icons.delete,
                //                 color: AppColors.orangeColor),
                //             onTap: () =>
                //                 _deleteDynamicPersonalField(dynamicIndex),
                //           ),
                //         ],
                //       ),
                //     );
                //   }).toList(),
                // ),
                // Column(
                //   children: personalDynamicFields.asMap().entries.map((entry) {
                //     // Add personalControllers.length to the index to account for personal fields
                //     int dynamicIndex = entry.key;
                //     int actualIndex = dynamicIndex + personalControllers.length;
                //     Map<String, dynamic> field = entry.value;

                //     return Padding(
                //       padding: EdgeInsets.only(bottom: 18),
                //       child: Row(
                //         children: [
                //           Expanded(
                //             child: TextFormField(
                //               controller: field['controller'],
                //               focusNode: field['focusNode'],
                //               decoration:
                //                   InputDecoration(labelText: field['label']),
                //             ),
                //           ),
                //           Column(
                //             children: [
                //               GestureDetector(
                //                 child: Icon(Icons.keyboard_arrow_up,
                //                     color: AppColors.orangeColor),
                //                 onTap: () {
                //                   // Check if we can move up (including into personal fields)
                //                   if (actualIndex > 0) {
                //                     _movePersonalField(
                //                         actualIndex, actualIndex - 1);
                //                   }
                //                 },
                //               ),
                //               IconButton(
                //                 icon: Icon(Icons.keyboard_arrow_down,
                //                     color: AppColors.orangeColor),
                //                 onPressed: () {
                //                   // Check if we can move down
                //                   if (actualIndex <
                //                       (personalControllers.length +
                //                           personalDynamicFields.length -
                //                           1)) {
                //                     _movePersonalField(
                //                         actualIndex, actualIndex + 1);
                //                   }
                //                 },
                //               ),
                //             ],
                //           ),
                //           GestureDetector(
                //             child: Icon(Icons.delete,
                //                 color: AppColors.orangeColor),
                //             onTap: () =>
                //                 _deleteDynamicPersonalField(dynamicIndex),
                //           ),
                //         ],
                //       ),
                //     );
                //   }).toList(),
                // ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () {
                      // FocusScope.of(context).unfocus();
                      _showAddFieldDialog(context);
                    },
                    child: Text(
                      "Add New Field",
                      style: TextStyle(color: AppColors.orangeColor),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.topLeft,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text(
                          educationOccupationDetailsTitle,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // const SizedBox(width: 5),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black,
                            minimumSize: Size(15, 15),
                          ),
                          onPressed: () {
                            _showEditPopupEducationOccupation(context);
                          },
                          icon: Icon(
                            Icons.edit,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: educationLevelController,
                  readOnly: true,
                  decoration:
                      InputDecoration(labelText: localization.educationLevel),
                  onTap: _showEducationLevelDialog,
                ),

                Column(
                  children: [
                    // Static education fields
                    Column(
                      children: List.generate(controllers.length, (index) {
                        return Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controllers[index],
                                decoration:
                                    InputDecoration(labelText: labels[index]),
                              ),
                            ),
                            Column(
                              children: [
                                GestureDetector(
                                  child: Icon(Icons.keyboard_arrow_up,
                                      color: AppColors.orangeColor),
                                  onTap: () => _moveField(index, index - 1),
                                ),
                                IconButton(
                                  icon: Icon(Icons.keyboard_arrow_down,
                                      color: AppColors.orangeColor),
                                  onPressed: () => _moveField(index, index + 1),
                                ),
                              ],
                            ),
                            GestureDetector(
                              child: Icon(Icons.delete,
                                  color: AppColors.orangeColor),
                              onTap: () => _deleteEducationField(index),
                            ),
                          ],
                        );
                      }),
                    ),
                    // Dynamic education fields
                    // Column(
                    //   children:
                    //       dynamicEducationFields.asMap().entries.map((entry) {
                    //     int dynamicIndex = entry.key;
                    //     int actualIndex = dynamicIndex + controllers.length;
                    //     Map<String, dynamic> field = entry.value;

                    //     return Row(
                    //       children: [
                    //         Expanded(
                    //           child: TextFormField(
                    //             controller: field['controller'],
                    //             decoration:
                    //                 InputDecoration(labelText: field['label']),
                    //             focusNode: field['focusNode'],
                    //           ),
                    //         ),
                    //         Column(
                    //           children: [
                    //             GestureDetector(
                    //               child: Icon(Icons.keyboard_arrow_up,
                    //                   color: AppColors.orangeColor),
                    //               onTap: () {
                    //                 if (actualIndex > 0) {
                    //                   _moveField(actualIndex, actualIndex - 1);
                    //                 }
                    //               },
                    //             ),
                    //             IconButton(
                    //               icon: Icon(Icons.keyboard_arrow_down,
                    //                   color: AppColors.orangeColor),
                    //               onPressed: () {
                    //                 if (actualIndex <
                    //                     (controllers.length +
                    //                         dynamicEducationFields.length -
                    //                         1)) {
                    //                   _moveField(actualIndex, actualIndex + 1);
                    //                 }
                    //               },
                    //             ),
                    //           ],
                    //         ),
                    //         GestureDetector(
                    //           child: Icon(Icons.delete,
                    //               color: AppColors.orangeColor),
                    //           onTap: () {
                    //             setState(() {
                    //               field['controller'].dispose();
                    //               dynamicEducationFields.removeAt(dynamicIndex);
                    //             });
                    //           },
                    //         ),
                    //       ],
                    //     );
                    //   }).toList(),
                    // ),
                    Column(
                      children:
                          dynamicEducationFields.asMap().entries.map((entry) {
                        int dynamicIndex = entry.key;
                        int actualIndex = dynamicIndex + controllers.length;
                        Map<String, dynamic> field = entry.value;

                        // Check visibility
                        bool isVisible = dynamicIndex <
                                educationDynamicFieldVisibility.length
                            ? educationDynamicFieldVisibility[dynamicIndex]
                            : true;

                        if (isVisible) {
                          return Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: field['controller'],
                                  decoration: InputDecoration(
                                      labelText: field['label']),
                                  focusNode: field['focusNode'],
                                ),
                              ),
                              Column(
                                children: [
                                  GestureDetector(
                                    child: Icon(Icons.keyboard_arrow_up,
                                        color: AppColors.orangeColor),
                                    onTap: () {
                                      if (actualIndex > 0) {
                                        _moveField(
                                            actualIndex, actualIndex - 1);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.keyboard_arrow_down,
                                        color: AppColors.orangeColor),
                                    onPressed: () {
                                      if (actualIndex <
                                          (controllers.length +
                                              dynamicEducationFields.length -
                                              1)) {
                                        _moveField(
                                            actualIndex, actualIndex + 1);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              GestureDetector(
                                child: Icon(Icons.delete,
                                    color: AppColors.orangeColor),
                                onTap: () =>
                                    _deleteEducationDynamicField(dynamicIndex),
                              ),
                            ],
                          );
                        } else {
                          return Container(); // Return empty container for invisible fields
                        }
                      }).toList(),
                    ),
                  ],
                ),
                // Button to add new field
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () =>
                        _showAddEducationFieldDialog(context), // Show dialog
                    child: Text(
                      "Add New Field",
                      style: TextStyle(color: AppColors.orangeColor),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Text(
                        familyDetails,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: Size(15, 15),
                        ),
                        onPressed: () {
                          _showEditPopupFamilyDetails(context);
                        },
                        icon: Icon(
                          Icons.edit,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: List.generate(familyControllers.length, (index) {
                    return Visibility(
                      visible:
                          familyFieldVisibility[index], // Only show if visible
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: familyControllers[index],
                              decoration: InputDecoration(
                                  labelText: familyLabels[index]),
                              keyboardType: index ==
                                      2 // Mobile Number field (assuming index 4)
                                  ? TextInputType.number
                                  : TextInputType.text,
                              inputFormatters: index == 2
                                  ? [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ]
                                  : null,
                            ),
                          ),
                          Column(
                            children: [
                              GestureDetector(
                                child: Icon(Icons.keyboard_arrow_up,
                                    color: AppColors.orangeColor),
                                onTap: () => _moveFamilyField(index, index - 1),
                              ),
                              IconButton(
                                icon: Icon(Icons.keyboard_arrow_down,
                                    color: AppColors.orangeColor),
                                onPressed: () =>
                                    _moveFamilyField(index, index + 1),
                              ),
                            ],
                          ),
                          GestureDetector(
                            child: Icon(Icons.delete,
                                color: AppColors.orangeColor),
                            onTap: () => _deleteFamilyField(index),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                // Column(
                //   children: dynamicfamilyFields.asMap().entries.map((entry) {
                //     int dynamicIndex = entry.key;
                //     int actualIndex = dynamicIndex + familyControllers.length;
                //     Map<String, dynamic> field = entry.value;

                //     return Row(
                //       children: [
                //         Expanded(
                //           child: TextFormField(
                //             controller: field['controller'],
                //             decoration:
                //                 InputDecoration(labelText: field['label']),
                //             focusNode: field['focusNode'],
                //           ),
                //         ),
                //         Column(
                //           children: [
                //             GestureDetector(
                //               child: Icon(Icons.keyboard_arrow_up,
                //                   color: AppColors.orangeColor),
                //               onTap: () {
                //                 if (actualIndex > 0) {
                //                   _moveFamilyField(
                //                       actualIndex, actualIndex - 1);
                //                 }
                //               },
                //             ),
                //             IconButton(
                //               icon: Icon(Icons.keyboard_arrow_down,
                //                   color: AppColors.orangeColor),
                //               onPressed: () {
                //                 if (actualIndex <
                //                     (familyControllers.length +
                //                         dynamicfamilyFields.length -
                //                         1)) {
                //                   _moveFamilyField(
                //                       actualIndex, actualIndex + 1);
                //                 }
                //               },
                //             ),
                //           ],
                //         ),
                //         GestureDetector(
                //           child:
                //               Icon(Icons.delete, color: AppColors.orangeColor),
                //           onTap: () {
                //             setState(() {
                //               field['controller'].dispose();
                //               dynamicfamilyFields.removeAt(dynamicIndex);
                //             });
                //           },
                //         ),
                //       ],
                //     );
                //   }).toList(),
                // ),
                Column(
                  children: dynamicfamilyFields.asMap().entries.map((entry) {
                    int dynamicIndex = entry.key;
                    int actualIndex = dynamicIndex + familyControllers.length;
                    Map<String, dynamic> field = entry.value;

                    // Check visibility
                    bool isVisible =
                        dynamicIndex < familyDynamicFieldVisibility.length
                            ? familyDynamicFieldVisibility[dynamicIndex]
                            : true;

                    if (isVisible) {
                      return Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: field['controller'],
                              decoration:
                                  InputDecoration(labelText: field['label']),
                              focusNode: field['focusNode'],
                            ),
                          ),
                          Column(
                            children: [
                              GestureDetector(
                                child: Icon(Icons.keyboard_arrow_up,
                                    color: AppColors.orangeColor),
                                onTap: () {
                                  if (actualIndex > 0) {
                                    _moveFamilyField(
                                        actualIndex, actualIndex - 1);
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.keyboard_arrow_down,
                                    color: AppColors.orangeColor),
                                onPressed: () {
                                  if (actualIndex <
                                      (familyControllers.length +
                                          dynamicfamilyFields.length -
                                          1)) {
                                    _moveFamilyField(
                                        actualIndex, actualIndex + 1);
                                  }
                                },
                              ),
                            ],
                          ),
                          GestureDetector(
                            child: Icon(Icons.delete,
                                color: AppColors.orangeColor),
                            onTap: () =>
                                _deleteFamilyDynamicField(dynamicIndex),
                          ),
                        ],
                      );
                    } else {
                      return Container(); // Return empty container for invisible fields
                    }
                  }).toList(),
                ),
                // Button to add new field
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () => _showAddFamilyFieldDialog(context),
                    child: Text(
                      "Add New Field",
                      style: TextStyle(color: AppColors.orangeColor),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Text(
                        othersDetails,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // const SizedBox(width: 5),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: Size(15, 15),
                        ),
                        onPressed: () {
                          _showEditPopupOtherDetails(context);
                        },
                        icon: Icon(
                          Icons.edit,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),

                Column(
                  children: [
                    // Static fields (Property and Expectations)
                    Column(
                      children: [
                        if (isPropertyVisible)
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: propertyController,
                                  decoration:
                                      InputDecoration(labelText: propertyLabel),
                                ),
                              ),
                              Column(
                                children: [
                                  GestureDetector(
                                    child: Icon(Icons.keyboard_arrow_up,
                                        color: AppColors.orangeColor),
                                    onTap: () => _moveOtherField(0, 0),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.keyboard_arrow_down,
                                        color: AppColors.orangeColor),
                                    onPressed: () => _moveOtherField(0, 1),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                child: Icon(Icons.delete,
                                    color: AppColors.orangeColor),
                                onTap: _deletePropertyField,
                              ),
                            ],
                          ),
                        if (isExpectationsVisible)
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: expectationsController,
                                  decoration: InputDecoration(
                                      labelText: expectationsLabel),
                                ),
                              ),
                              Column(
                                children: [
                                  GestureDetector(
                                    child: Icon(Icons.keyboard_arrow_up,
                                        color: AppColors.orangeColor),
                                    onTap: () => _moveOtherField(1, 0),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.keyboard_arrow_down,
                                        color: AppColors.orangeColor),
                                    onPressed: () => _moveOtherField(1, 2),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                child: Icon(Icons.delete,
                                    color: AppColors.orangeColor),
                                onTap: _deleteExpectationsField,
                              ),
                            ],
                          ),
                      ],
                    ),
                    // Dynamic fields
                    //     Column(
                    //       children: dynamicOtherFields.asMap().entries.map((entry) {
                    //         int dynamicIndex = entry.key;
                    //         int actualIndex = dynamicIndex +
                    //             (isPropertyVisible ? 1 : 0) +
                    //             (isExpectationsVisible ? 1 : 0);
                    //         Map<String, dynamic> field = entry.value;

                    //         return Row(
                    //           children: [
                    //             Expanded(
                    //               child: TextFormField(
                    //                 controller: field['controller'],
                    //                 decoration:
                    //                     InputDecoration(labelText: field['label']),
                    //                 focusNode: field['focusNode'],
                    //               ),
                    //             ),
                    //             Column(
                    //               children: [
                    //                 GestureDetector(
                    //                   child: Icon(Icons.keyboard_arrow_up,
                    //                       color: AppColors.orangeColor),
                    //                   onTap: () {
                    //                     if (actualIndex > 0) {
                    //                       _moveOtherField(
                    //                           actualIndex, actualIndex - 1);
                    //                     }
                    //                   },
                    //                 ),
                    //                 IconButton(
                    //                   icon: Icon(Icons.keyboard_arrow_down,
                    //                       color: AppColors.orangeColor),
                    //                   onPressed: () {
                    //                     int totalFields =
                    //                         (isPropertyVisible ? 1 : 0) +
                    //                             (isExpectationsVisible ? 1 : 0) +
                    //                             dynamicOtherFields.length;
                    //                     if (actualIndex < totalFields - 1) {
                    //                       _moveOtherField(
                    //                           actualIndex, actualIndex + 1);
                    //                     }
                    //                   },
                    //                 ),
                    //               ],
                    //             ),
                    //             GestureDetector(
                    //               child: Icon(Icons.delete,
                    //                   color: AppColors.orangeColor),
                    //               onTap: () {
                    //                 setState(() {
                    //                   field['controller'].dispose();
                    //                   dynamicOtherFields.removeAt(dynamicIndex);
                    //                 });
                    //               },
                    //             ),
                    //           ],
                    //         );
                    //       }).toList(),
                    //     ),
                    //   ],
                    // ),
                    Column(
                      children: dynamicOtherFields.asMap().entries.map((entry) {
                        int dynamicIndex = entry.key;
                        int actualIndex = dynamicIndex +
                            (isPropertyVisible ? 1 : 0) +
                            (isExpectationsVisible ? 1 : 0);
                        Map<String, dynamic> field = entry.value;

                        // Check visibility
                        bool isVisible =
                            dynamicIndex < otherDynamicFieldVisibility.length
                                ? otherDynamicFieldVisibility[dynamicIndex]
                                : true;

                        if (isVisible) {
                          return Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: field['controller'],
                                  decoration: InputDecoration(
                                      labelText: field['label']),
                                  focusNode: field['focusNode'],
                                ),
                              ),
                              Column(
                                children: [
                                  GestureDetector(
                                    child: Icon(Icons.keyboard_arrow_up,
                                        color: AppColors.orangeColor),
                                    onTap: () {
                                      if (actualIndex > 0) {
                                        _moveOtherField(
                                            actualIndex, actualIndex - 1);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.keyboard_arrow_down,
                                        color: AppColors.orangeColor),
                                    onPressed: () {
                                      int totalFields =
                                          (isPropertyVisible ? 1 : 0) +
                                              (isExpectationsVisible ? 1 : 0) +
                                              dynamicOtherFields.length;
                                      if (actualIndex < totalFields - 1) {
                                        _moveOtherField(
                                            actualIndex, actualIndex + 1);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              GestureDetector(
                                child: Icon(Icons.delete,
                                    color: AppColors.orangeColor),
                                onTap: () =>
                                    _deleteOtherDynamicField(dynamicIndex),
                              ),
                            ],
                          );
                        } else {
                          return Container(); // Return empty container for invisible fields
                        }
                      }).toList(),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () =>
                            _showAddOtherFieldDialog(context), // Show dialog
                        child: Text(
                          "Add New Field",
                          style: TextStyle(color: AppColors.orangeColor),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                setState(() {
                                  _isLoading = true;
                                });

                                String selectedLanguage =
                                    Localizations.localeOf(context)
                                        .languageCode;
                                // Call your saveAllApi or any other function here
                                await saveAllApi2(context, selectedLanguage);

                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : Text(
                              widget.isEdit == false ? "Save All" : "Update!",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void markDataAsChanged() {
    if (!isDataChanged) {
      setState(() {
        isDataChanged = true;
      });
    }
  }
}
