// import 'dart:io';
// import 'package:bio_data/consts/colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_windowmanager/flutter_windowmanager.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// class PDFViewerScreen extends StatefulWidget {
//   final String pdfPath;
//   final String username;

//   const PDFViewerScreen({
//     Key? key,
//     required this.pdfPath,
//     required this.username,
//   }) : super(key: key);

//   @override
//   State<PDFViewerScreen> createState() => _PDFViewerScreenState();
// }

// class _PDFViewerScreenState extends State<PDFViewerScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _disableScreenCapture();
//   }

//   Future<void> _disableScreenCapture() async {
//     await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: Colors.white),
//         title: Text(widget.username),
//         backgroundColor: AppColors.orangeColor,
//       ),
//       body: SfPdfViewer.file(
//         File(widget.pdfPath),
//         canShowScrollHead: true,
//       ),
//     );
//   }
// }
