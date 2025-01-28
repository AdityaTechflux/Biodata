import 'dart:convert';
import 'dart:io';
import 'package:bio_data/consts/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedBiodata extends StatefulWidget {
  const SavedBiodata({Key? key}) : super(key: key);

  @override
  _SavedBiodataState createState() => _SavedBiodataState();
}

class _SavedBiodataState extends State<SavedBiodata> {
  List<Map<String, dynamic>> savedBiodata = [];
  bool isLoading = true;

  Future<void> _fetchBiodataInfo() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> savedBiodataList =
          prefs.getStringList('saved_biodata') ?? [];

      setState(() {
        savedBiodata = savedBiodataList
            .map((jsonString) =>
                Map<String, dynamic>.from(json.decode(jsonString)))
            .toList()
            .reversed
            .toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading biodata: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _openPdfFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await OpenFilex.open(filePath);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF file not found')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening PDF: $e')),
        );
      }
    }
  }

  Future<void> _deleteBiodata(int index) async {
    try {
      final actualIndex = savedBiodata.length - 1 - index;

      final filePath = savedBiodata[index]['pdfPath'];
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> savedList = prefs.getStringList('saved_biodata') ?? [];
      savedList.removeAt(actualIndex);
      await prefs.setStringList('saved_biodata', savedList);

      setState(() {
        savedBiodata.removeAt(index);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biodata deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting biodata: $e')),
        );
      }
    }
  }

  // Future<void> _sharePdf(String pdfPath, String username) async {
  //   try {
  //     final file = File(pdfPath);
  //     if (await file.exists()) {
  //       await Share.shareFiles(
  //         [pdfPath],
  //         subject: 'Biodata for $username',
  //         text: 'Sharing biodata PDF for $username',
  //       );
  //     } else {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('PDF file not found')),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error sharing PDF: $e')),
  //       );
  //     }
  //   }
  // }

  Future<void> _sharePdf(
      String pdfPath, String username, BuildContext context) async {
    try {
      final file = File(pdfPath);

      // Check if the file exists
      if (await file.exists()) {
        // Share the PDF file using share_plus
        await Share.shareXFiles(
          [XFile(pdfPath)], // Use XFile instead of File
          subject: 'Biodata for $username',
          text: 'Sharing biodata PDF for $username',
        );
      } else {
        // Show an error if the file does not exist
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF file not found')),
          );
        }
      }
    } catch (e) {
      // Handle any errors that occur during sharing
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing PDF: $e')),
        );
      }
    }
  }

  Future<void> _editUsername(int index) async {
    final TextEditingController usernameController = TextEditingController(
      text: savedBiodata[index]['username'],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(),
        backgroundColor: Colors.white,
        title: Text('Edit Username'),
        content: TextField(
          controller: usernameController,
          decoration: InputDecoration(labelText: 'Username'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.orangeColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              String newUsername = usernameController.text.trim();
              if (newUsername.isNotEmpty) {
                final actualIndex = savedBiodata.length - 1 - index;
                savedBiodata[index]['username'] = newUsername;

                SharedPreferences prefs = await SharedPreferences.getInstance();
                List<String> savedList =
                    prefs.getStringList('saved_biodata') ?? [];
                Map<String, dynamic> biodata =
                    json.decode(savedList[actualIndex]);
                biodata['username'] = newUsername;

                savedList[actualIndex] = json.encode(biodata);
                await prefs.setStringList('saved_biodata', savedList);

                setState(() {
                  savedBiodata[index]['username'] = newUsername;
                });

                Navigator.of(context).pop();

                if (mounted) {
                  Fluttertoast.showToast(
                    msg: 'Username updated successfully',
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                  );
                }
              }
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: AppColors.orangeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchBiodataInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text("Saved Biodata"),
        backgroundColor: AppColors.orangeColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : savedBiodata.isEmpty
              ? const Center(
                  child: Text(
                    'No saved biodata found',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: savedBiodata.length,
                  itemBuilder: (context, index) {
                    final biodata = savedBiodata[index];
                    return _buildBiodataCard(context, biodata, index);
                  },
                ),
    );
  }

  Widget _buildBiodataCard(
      BuildContext context, Map<String, dynamic> biodata, int index) {
    return GestureDetector(
      onTap: () {
        // _openPdfFile(biodata['pdfPath']);
      },
      child: Card(
        color: Colors.white,
        elevation: 5,
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: biodata['photo1'] != null &&
                          biodata['photo1'].toString().isNotEmpty
                      ? NetworkImage(biodata['photo1'])
                      : const AssetImage("assets/images/profile.png")
                          as ImageProvider,
                ),
                title: Text(
                  biodata['username'] ?? 'Unknown',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Container(
                height: 60.h,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBioOptionButton(
                      Icons.edit,
                      'Rename',
                      () => _editUsername(index),
                    ),
                    _buildBioOptionButton(
                      Icons.picture_as_pdf,
                      'View PDF',
                      () => _openPdfFile(biodata['pdfPath']),
                    ),
                    _buildBioOptionButton(
                      Icons.share,
                      'Share',
                      () => _sharePdf(biodata['pdfPath'],
                          biodata['username'] ?? 'Unknown', context),
                    ),
                    _buildBioOptionButton(
                      Icons.delete,
                      'Delete',
                      () => _deleteBiodata(index),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBioOptionButton(
      IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 25.sp, color: AppColors.orangeColor),
          SizedBox(
            height: 5.h,
          ),
          Text(
            label,
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
}
