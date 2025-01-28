import 'dart:developer';
import 'package:bio_data/consts/colors.dart';
import 'package:bio_data/screens/create_bio_data_screen/create_bio_data_screen.dart';
import 'package:bio_data/screens/home_screen/customer_care_screen.dart';
import 'package:bio_data/screens/home_screen/privacy_policy_screen.dart';
import 'package:bio_data/screens/saved_biodata.dart';
import 'package:bio_data/screens/signup_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controller/home_screen_controller.dart';
import '../../controller/showbiodata_controller.dart';
import '../login_form.dart';
import '../template_selection_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, RouteAware {
  late TabController _tabController;
  String? _authToken;
  bool _isLoading = true; // Track loading state
  bool _isNavigatingFromCreateBiodata = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _getAuthToken();
    _getMatriIdAndFetchBiodata();
    _loadInitialData();
    _requestPermissions();
    // _loadData();
  }

  Future<void> _requestPermissions() async {
    // Request storage permission
    final storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) {
      print("Storage permission granted");
    } else {
      print("Storage permission denied");
    }

    // Request photos permission
    final photosStatus = await Permission.photos.request();
    if (photosStatus.isGranted) {
      print("Photos permission granted");
    } else {
      print("Photos permission denied");
    }

    // Request media library permission (for iOS)
    final mediaLibraryStatus = await Permission.mediaLibrary.request();
    if (mediaLibraryStatus.isGranted) {
      print("Media library permission granted");
    } else {
      print("Media library permission denied");
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true; // Show loading when starting data fetch
    });
    await _getAuthToken();
    await _getMatriIdAndFetchBiodata();
    setState(() {
      _isLoading = false; // Hide loading after data fetch is complete
      _isNavigatingFromCreateBiodata = false;
    });
  }

  Future<void> _getMatriIdAndFetchBiodata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? matriId = prefs.getString('matri_id');
    if (matriId != null) {
      await _fetchBiodataInfo();
    } else {
      print('matriId is null. Unable to fetch biodata.');
      if (mounted) {
        setState(() {
          _isLoading = false; // Mark loading as false if matriId is null
        });
      }
    }
  }

  Future<void> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(
        () {
          _authToken = prefs.getString('token_key');
        },
      );
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(),
          title: Text("Confirm Logout"),
          content: Text("Are you sure you want to Logout?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel logout
              },
              child: Text("NO"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm logout
              },
              child: Text(
                "YES",
              ),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token_key');
      await prefs.remove('matri_id');

      log("Payment details cleared successfully");

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => LoginForm(onLoginSuccess: () {})),
        (Route<dynamic> route) => false,
      );
    } else {
      log("Error clearing payment details:");
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<ShowbiodataController>(context, listen: false)
        .fetchBiodata();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchBiodataInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final matriId = prefs.getString('matri_id');

    if (matriId != null) {
      final controller =
          Provider.of<ShowbiodataController>(context, listen: false);
      await controller.fetchBiodata();
    } else {
      print('matriId is null. Unable to fetch biodata.');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route-aware events when this widget becomes visible
    ModalRoute.of(context)?.addScopedWillPopCallback(_handleWillPop);
  }

  Future<void> _onScreenResume() async {
    // Refresh data when returning to this screen
    await _loadInitialData();
  }

  Future<bool> _handleWillPop() async {
    // Handle back button to confirm logout or exit
    return Future.value(true); // Handle back logic here
  }

  DateTime? lastBackPressTime;

  Future<bool> onWillPop() async {
    if (lastBackPressTime == null) {
      // First back press
      lastBackPressTime = DateTime.now();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Press back again to log out"),
          duration: Duration(seconds: 2),
        ),
      );
      // Reset the time after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        lastBackPressTime = null;
      });
      return false;
    }

    // Check if within 2 seconds of first press
    final now = DateTime.now();
    final difference = now.difference(lastBackPressTime!);

    if (difference < const Duration(seconds: 2)) {
      // Valid second press within 2 seconds
      lastBackPressTime = null; // Reset the time
      await _handleLogout(context);
      return true;
    } else {
      // Too much time has passed, treat as first press
      lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Press back again to log out"),
          duration: Duration(seconds: 2),
        ),
      );
      // Reset the time after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        lastBackPressTime = null;
      });
      return false;
    }
  }

  Future<void> _navigateToCreateBiodata() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateBioDataScreen(
          uid: '',
          isEdit: false,
          initialBiodataTitle: '',
        ),
      ),
    );

    if (result == true) {
      _isNavigatingFromCreateBiodata = true;
      await _loadInitialData();
    }
  }

  bool _isMenuLoading = false;

  // Updated menu click handler
  void _handleMenuItemClick(String value) async {
    // For quick actions, don't show loading
    if (value == 'share' || value == 'RateApp') {
      if (value == 'share') {
        _shareApp();
      } else {
        _rateApp(context);
      }
      return; // Exit early for quick actions
    }

    // For other actions that need loading
    try {
      setState(() {
        _isMenuLoading = true; // Start loading
      });

      switch (value) {
        case 'Feedback':
          await _feedback(context, feedbackController);
          break;
        case 'PrivacyPolicy':
          await _privacyPolicy();
          break;
        case 'CustomerCare':
          await _customerCare();
          break;
        case 'delete':
          _showDeleteAccountConfirmation(context);
          break;
        case 'logout':
          await _handleLogout(context);
          break;
      }
    } catch (e) {
      print('Error in menu action: $e');
      // Optionally show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred')),
      );
    } finally {
      // Only update state if widget is still mounted
      if (mounted) {
        setState(() {
          _isMenuLoading = false; // Stop loading
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              'Biodata Maker',
              style: TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
            backgroundColor: const Color(0xFFFF5508),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SavedBiodata(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.save,
                  color: Colors.white,
                ),
              ),
              PopupMenuButton<String>(
                color: Colors.white,
                onSelected: _handleMenuItemClick,
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem(
                        value: 'share', child: Text('Share App')),
                    const PopupMenuItem(
                        value: 'RateApp', child: Text('Rate App')),
                    const PopupMenuItem(
                        value: 'Feedback', child: Text('Feedback')),
                    const PopupMenuItem(
                        value: 'PrivacyPolicy', child: Text('Privacy Policy')),
                    const PopupMenuItem(
                        value: 'CustomerCare', child: Text('Customer Care')),
                    const PopupMenuItem(
                        value: 'delete', child: Text('Delete Account')),
                    const PopupMenuItem(value: 'logout', child: Text('Logout')),
                  ];
                },
                icon: const Icon(Icons.menu, color: Colors.white),
              ),
            ],
          ),
          body: WillPopScope(
            onWillPop: () async {
              SystemNavigator.pop();
              return false;
            },
            child: FutureBuilder(
              future: _fetchBiodataInfo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: AppColors.orangeColor,
                  ));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load data'));
                } else {
                  return RefreshIndicator(
                    onRefresh: _loadInitialData,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Column(
                        children: [
                          SizedBox(height: 10.h),
                          ElevatedButton.icon(
                            onPressed: _navigateToCreateBiodata,
                            icon: Icon(Icons.brush, size: 18.sp),
                            label: Text(
                              'Create Biodata',
                              style: TextStyle(fontSize: 18.sp),
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 40.h),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 10.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Expanded(
                            child: Consumer<ShowbiodataController>(
                              builder: (context, controller, _) {
                                if (controller.isLoading) {
                                  return Center(
                                      child: CircularProgressIndicator(
                                    color: AppColors.orangeColor,
                                  ));
                                }
                                if (controller.userData.isEmpty) {
                                  return Center(
                                      child: Text('No data available'));
                                }
                                return ListView.builder(
                                  itemCount: controller.userData.length,
                                  itemBuilder: (context, index) {
                                    final biodata = controller.userData[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TemplateSelectionPage(
                                              id: (biodata['id'] ?? '')
                                                  .toString(),
                                              selectedLanguage: '',
                                              biodataName: '',
                                            ),
                                          ),
                                        );
                                      },
                                      child: _buildBiodataCard(
                                          context, biodata, controller, index),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
        // Loading overlay
        if (_isMenuLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5508)),
              ),
            ),
          ),
      ],
    ));
  }

  Widget _buildBiodataCard(BuildContext context, Map<String, dynamic> biodata,
      ShowbiodataController controller, int number) {
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: Stack(
        children: [
          // Main content
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                  leading: CircleAvatar(
                    radius: 30.r,
                    backgroundImage: biodata['photo1'] != null &&
                            biodata['photo1'].isNotEmpty
                        ? NetworkImage(biodata['photo1'])
                        : AssetImage("assets/images/profile.png")
                            as ImageProvider,
                  ),
                  title: Text(
                    '${biodata['username'] ?? 'John'}',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                  ),
                  subtitle: Text(
                    'Caste: ${biodata['caste'] ?? 'Maratha'} \nHeight: ${biodata['height'] ?? ''}',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
                Container(
                  color: Colors.grey[200],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBioOptionButton(
                        Icons.edit,
                        'Edit',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateBioDataScreen(
                                uid: (biodata['id'] ?? '').toString(),
                                isEdit: true,
                                initialBiodataTitle: '',
                              ),
                            ),
                          );
                        },
                      ),
                      _buildBioOptionButton(
                        Icons.copy,
                        'Copy',
                        () async {
                          bool success = await controller
                              .copyBiodata(biodata['id'].toString());

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success
                                  ? "Biodata copied successfully!"
                                  : "Failed to copy biodata."),
                            ),
                          );
                        },
                      ),
                      _buildBioOptionButton(
                        Icons.delete,
                        'Delete',
                        () async {
                          bool? confirmDelete = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(),
                                title: Row(
                                  children: [
                                    Icon(Icons.delete,
                                        size: 35.sp, color: Colors.black45),
                                    Text("Confirm Delete"),
                                  ],
                                ),
                                content: Text(
                                    "Are you sure you want to delete this biodata?"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text("NO",
                                        style: TextStyle(
                                            color: AppColors.orangeColor)),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text("YES",
                                        style: TextStyle(
                                            color: AppColors.orangeColor)),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmDelete == true) {
                            await controller.deleteBiodataFromController(
                                biodata['id'].toString());

                            controller.userData.removeWhere(
                                (item) => item['id'] == biodata['id']);
                            controller.notifyListeners();
                          }
                        },
                      ),
                      _buildBioOptionButton(
                        Icons.file_copy,
                        'Template',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TemplateSelectionPage(
                                id: (biodata['id'] ?? '').toString(),
                                selectedLanguage: '',
                                biodataName: '',
                              ),
                            ),
                          );
                          log(biodata['id'].toString());
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Number indicator in top right corner
          Positioned(
            top: 0.h,
            right: 0.w,
            child: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: AppColors.orangeColor,
                // borderRadius: BorderRadius.circular(15.r),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${number + 1}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioOptionButton(
      IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.grey[700], size: 20.sp),
          onPressed: onPressed,
        ),
        GestureDetector(
          onTap: onPressed,
          child: Text(
            label,
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
      ],
    );
  }

  final feedbackController = ShowbiodataController();

  _feedback(BuildContext context, ShowbiodataController feedbackController) {
    final TextEditingController feedbackControllerText =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.all(16),
          title: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.orangeColor,
                child: Icon(
                  Icons.email,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Submit Feedback',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SizedBox(
            height: 300, // Increased height for the dialog
            width: 300, // Adjusted width for proportion
            child: Column(
              children: [
                Expanded(
                  // Makes the TextFormField fill available space
                  child: TextFormField(
                    controller: feedbackControllerText,
                    maxLines: null, // Allows the field to grow with content
                    expands: true, // Enables it to fill available space
                    decoration: InputDecoration(
                      labelText: "Tell us where we can improve",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Dismiss dialog
                      },
                      child: const Text('Maybe Later'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Handle submit feedback logic here
                        String feedbackMessage =
                            feedbackControllerText.text.trim();
                        if (feedbackMessage.isNotEmpty) {
                          feedbackController.postFeedback(feedbackMessage);
                        }
                        Fluttertoast.showToast(
                          msg: "Thank You For Your Feedback",
                        );
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orangeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _privacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrivacyPolicyScreen(),
      ),
    );
  }

  _customerCare() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerCareScreen(),
      ),
    );
  }

  final String appLink =
      "https://play.google.com/store/apps/details?id=com.iw.biodatamakermarathi&hl=en";

  void _rateApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(),
          backgroundColor: Colors.white,
          title: Text("Rate App"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  "Best of luck for your future. Please give us a 5-star rating."),
              SizedBox(height: 10),
              // Rating Builder
            ],
          ),
          actions: [
            TextButton(
              child: Text("Maybe Later"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Rate Now"),
              onPressed: () {
                _navigateToPlayStore();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToPlayStore() async {
    if (await canLaunch(appLink)) {
      await launch(appLink);
    } else {
      throw 'Could not launch $appLink';
    }
  }

  void _shareApp() {
    const String appLink =
        'https://play.google.com/store/apps/details?id=com.marriagecreate.biodata&hl=en-US';
    const String message = 'Check out this awesome app: $appLink';
    Share.share(message);
  }

  void _showDeleteAccountConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return WillPopScope(
          // Prevent back button from dismissing dialog
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(),
            backgroundColor: Colors.white,
            title: Text('Delete Account'),
            content: Text(
                'Are you sure you want to delete your account? This action cannot be undone.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Delete'),
                onPressed: () async {
                  final controller =
                      Provider.of<HomeScreenController>(context, listen: false);
                  await controller.deleteAccount(context);

                  // Clear the entire navigation stack and replace with SignupForm
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => SignupForm(),
                    ),
                    (Route<dynamic> route) =>
                        false, // Remove all previous routes
                  );

                  log("Delete button pressed.");
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
