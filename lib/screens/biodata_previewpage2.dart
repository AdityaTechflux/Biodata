// import 'dart:typed_data';

// import 'package:flutter/material.dart';

// class BiodataPreviewPage2 extends StatelessWidget {
//   final Uint8List? pdfData;

//   BiodataPreviewPage2({this.pdfData});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Biodata Preview"),
//       ),
//       body: Center(
//         child: pdfData != null
//             ? Image.memory(
//                 pdfData!,
//                 width: double.infinity, // Set your fixed width
//                 height: 470, // Set your fixed height
//                 fit: BoxFit.cover,
//               )
//             : Text("No image captured"),
//       ),
//     );
//   }
// }
