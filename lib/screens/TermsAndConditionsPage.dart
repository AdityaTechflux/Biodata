import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_html/flutter_html.dart';

import '../consts/app_urls.dart';

class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({super.key});

  @override
  _TermsAndConditionsPageState createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  Future<String>? termsAndConditionsFuture;

  @override
  void initState() {
    super.initState();
    termsAndConditionsFuture = fetchTermsAndConditions();
  }

  // Function to fetch data from API
  Future<String> fetchTermsAndConditions() async {
    final url = Uri.parse("${AppUrls.baseUrl}/api/get_term_condition/1");
    // final url = Uri.parse(
    //     "http://allindiamatrimonial.com/royal_maratha/api/get_term_condition/1");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData["data"] ?? "No terms available.";
      } else {
        return "Failed to load terms and conditions.";
      }
    } catch (e) {
      return "An error occurred: $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 24.sp, // Responsive icon size
          ),
        ),
        title: Text(
          "Terms and Conditions",
          style: TextStyle(color: Colors.white, fontSize: 20.sp),
        ),
      ),
      body: FutureBuilder<String>(
        future: termsAndConditionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: TextStyle(fontSize: 16.sp)));
          } else if (snapshot.hasData) {
            return Padding(
              padding: EdgeInsets.all(8.w),
              child: SingleChildScrollView(
                child: Html(
                  data: snapshot.data!, // Render the HTML content
                  style: {
                    "p":
                        Style(fontSize: FontSize(16.sp)), // Style for paragraph
                    "strong": Style(fontWeight: FontWeight.bold), // Bold style
                  },
                ),
              ),
            );
          } else {
            return Center(
              child: Text(
                'No terms and conditions data available.',
                style: TextStyle(fontSize: 16.sp),
              ),
            );
          }
        },
      ),
    );
  }
}
