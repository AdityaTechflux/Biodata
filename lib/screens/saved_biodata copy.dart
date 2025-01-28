import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SavedBiodata extends StatefulWidget {
  const SavedBiodata({Key? key}) : super(key: key);

  @override
  _SavedBiodataState createState() => _SavedBiodataState();
}

class _SavedBiodataState extends State<SavedBiodata> {
  List<Map<String, dynamic>> savedBiodata = [];

  Future<void> _fetchBiodataInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setStringList('savedBiodata', []);
    List<String> savedBiodataList = prefs.getStringList('savedBiodata') ?? [];

    // log(savedBiodataList.toString());

    // Convert JSON strings to a List<Map<String, dynamic>>
    // setState(() {

    //   // log(savedBiodata);
    // });
    savedBiodata = savedBiodataList
        .map((jsonString) => Map<String, dynamic>.from(json.decode(jsonString)))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchBiodataInfo(); // Fetch the data when the widget is first initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Saved Biodata")),
      body: savedBiodata.isEmpty
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator if no data is available
          : ListView.builder(
              itemCount: savedBiodata.length,
              itemBuilder: (context, index) {
                final biodata = savedBiodata[index];
                return GestureDetector(
                  onTap: () {
                    // Handle tap on biodata (e.g., open the template page)
                  },
                  child: _buildBiodataCard(context, biodata),
                );
              },
            ),
    );
  }

  Widget _buildBiodataCard(BuildContext context, Map<String, dynamic> biodata) {
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: biodata['photo1'] != null
                    ? NetworkImage(biodata['photo1'])
                    : AssetImage("assets/images/profile.png") as ImageProvider,
              ),
              title: Text('${biodata['username'] ?? 'John'}'),
              subtitle: Text(
                'Caste: ${biodata['caste'] ?? 'Maratha'} \nHeight: ${biodata['height'] ?? ''}',
              ),
            ),
            Container(
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBioOptionButton(Icons.edit, 'Edit', () {
                    // Handle edit action
                  }),
                  _buildBioOptionButton(Icons.delete, 'Delete', () {
                    // Handle delete action
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioOptionButton(IconData icon, String label, Function onTap) {
    return TextButton.icon(
      onPressed: () => onTap(),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
