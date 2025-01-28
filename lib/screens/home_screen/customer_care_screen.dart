import 'package:bio_data/consts/colors.dart';
import 'package:flutter/material.dart';
// import 'package:velocity_x/velocity_x.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomerCareScreen extends StatelessWidget {
  const CustomerCareScreen({super.key});

  // Function to open messaging app with a specific number
  void _openMessagingApp() async {
    final Uri smsUri = Uri(scheme: 'sms', path: '9699604797');
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      print("Could not launch messaging app.");
    }
  }

  // Function to open phone dialer with a specific number
  void _openPhoneDialer() async {
    final Uri telUri = Uri(scheme: 'tel', path: '9699604797');
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      print("Could not launch phone dialer.");
    }
  }

  // Function to open email app with a specific email address
  void _openEmailApp() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'apps4you01@gmail.com',
      queryParameters: {'subject': ''},
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      print("Could not launch email app.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Customer Care',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.orangeColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 80.h.heightBox,
            SizedBox(
              height: 80.h,
            ),
            Row(
              children: [
                Image.asset(
                  "assets/images/whatsapp-icon.png",
                  height: 30.h,
                  width: 30.w,
                ),
                // 10.w.widthBox,
                SizedBox(
                  width: 10.h,
                ),

                Text(
                  "What's App Support",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 20.sp,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _openMessagingApp,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Text(
                      "Message Us",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // 30.h.heightBox,
            SizedBox(
              height: 30.h,
            ),

            Row(
              children: [
                Icon(
                  Icons.phone,
                  color: Colors.blueAccent,
                  size: 24.sp,
                ),
                // 10.w.widthBox,
                SizedBox(
                  width: 10.h,
                ),

                Text(
                  "Call Support",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 20.sp,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _openPhoneDialer,
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Text(
                      "Call Us",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // 30.h.heightBox,
            SizedBox(
              height: 30.h,
            ),

            Row(
              children: [
                Text(
                  "@",
                  style: TextStyle(
                    color: Colors.brown,
                    fontSize: 30.sp,
                  ),
                ),
                // 10.w.widthBox,
                SizedBox(
                  width: 10.h,
                ),

                Text(
                  "Email Support",
                  style: TextStyle(
                    color: Colors.brown,
                    fontSize: 20.sp,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: _openEmailApp,
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Text(
                      "Mail Us",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
