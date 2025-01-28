import 'dart:convert';
import 'dart:developer';
import 'package:bio_data/screens/home_screen/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

import '../consts/app_urls.dart';
import '../consts/colors.dart';
import 'template_detail_page.dart';

class TemplateSelectionPage extends StatefulWidget {
  final String id;
  final String selectedLanguage;
  final String biodataName;

  TemplateSelectionPage({
    Key? key,
    required this.id,
    required this.selectedLanguage,
    required this.biodataName,
  }) : super(key: key);

  @override
  _TemplateSelectionPageState createState() => _TemplateSelectionPageState();
}

class _TemplateSelectionPageState extends State<TemplateSelectionPage> {
  List<Map<String, dynamic>> frames = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchTemplates();
  }

  Future<void> fetchTemplates() async {
    try {
      final response = await http.get(
        Uri.parse('${AppUrls.baseUrl}/api/fetchAllThemes'),
      );
      // final response = await http.get(
      //   Uri.parse(
      //       'http://allindiamatrimonial.com/royal_maratha/api/fetchAllThemes'),
      // );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log('API Response: $data');

        if (data['data'] != null &&
            data['data'] is List &&
            data['data'].isNotEmpty) {
          setState(() {
            frames = List<Map<String, dynamic>>.from(
              data['data'].map((item) => {
                    'frame_image': item['frame_image'],
                    'id': item['id'], // Use 'id' as biodataId
                  }),
            );
            isLoading = false;
            errorMessage = null;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = 'No templates found';
          });
          log('No templates found in response');
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load templates: ${response.statusCode}';
        });
        log('Failed to load templates: ${response.statusCode}');
        log('Response body: ${response.body}');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $error';
      });
      log('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context); // Ensure proper back navigation
        return true; // Indicate the back button has been handled
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Select Template',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20.sp, // Responsive font size
            ),
          ),
          backgroundColor: Color(0xFFFF5507),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return HomePage();
                  },
                ),
              );
            },
          ),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                color: AppColors.orangeColor,
              ))
            : errorMessage != null
                ? Center(child: Text(errorMessage!))
                : GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 15.h,
                      childAspectRatio: 3 / 4,
                    ),
                    itemCount: frames.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TemplateDetailPage(
                                selectedTemplateUrl:
                                    frames[index]['frame_image'].toString(),
                                biodataId: widget.id, // Pass dynamic id
                                selectedLanguage: widget.selectedLanguage,
                                biodataName: widget.biodataName,
                                // dynamicFieldValues1: widget.dynamicFieldValues1,
                                // dynamicFieldValues2: widget.dynamicFieldValues2,
                                // dynamicFieldValues3: widget.dynamicFieldValues3,
                                // dynamicFieldValues4: widget.dynamicFieldValues4,
                              ),
                            ),
                          );
                          // log("dynamic fields1:${widget.dynamicFieldValues1} ");
                          // log("dynamic fields2:${widget.dynamicFieldValues2} ");
                          // log("dynamic fields3:${widget.dynamicFieldValues3} ");
                          // log("dynamic fields4:${widget.dynamicFieldValues4} ");
                          log("Selected language : ${widget.selectedLanguage}");
                          log("biodata id : ${widget.id}");
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              frames[index]['frame_image'].toString(),
                              // fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                return Center(
                                    child: Icon(Icons.error, size: 40));
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
