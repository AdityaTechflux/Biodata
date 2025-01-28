import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';

import '../../consts/app_urls.dart'; // Import the flutter_html package

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  // Function to fetch privacy policy data from the API
  Future<String> fetchPrivacyPolicy() async {
    final url = Uri.parse('${AppUrls.baseUrl}/api/getPrivacy/1');
    // final url = Uri.parse(
    //     'http://allindiamatrimonial.com/royal_maratha/api/getPrivacy/1');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return jsonResponse['data']; // Return the privacy policy content
        } else {
          return 'Error: No privacy data available';
        }
      } else {
        return 'Error: Failed to load privacy policy';
      }
    } catch (e) {
      return 'Error: $e';
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
          "Privacy Policy",
          style: TextStyle(color: Colors.white, fontSize: 20.sp),
        ),
      ),
      body: FutureBuilder<String>(
        future: fetchPrivacyPolicy(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: TextStyle(fontSize: 16.sp)));
          } else if (snapshot.hasData) {
            return Padding(
              padding: EdgeInsets.all(16.w),
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
                'No privacy policy data available.',
                style: TextStyle(fontSize: 16.sp),
              ),
            );
          }
        },
      ),
    );
  }
}
