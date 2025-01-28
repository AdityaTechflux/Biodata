import 'dart:convert';
import 'dart:io';

import 'package:bio_data/controller/auth_request_controller.dart';
import 'package:bio_data/controller/home_screen_controller.dart';
import 'package:bio_data/controller/language_change_controller.dart';
import 'package:bio_data/controller/payment_controller.dart';
import 'package:bio_data/controller/swapping_controller.dart';
import 'package:bio_data/screens/network_connectivity_screen.dart';
import 'package:bio_data/screens/signup_form.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controller/language_controller.dart';
import 'controller/network_connecticity_service.dart';
import 'controller/showbiodata_controller.dart';
import 'controller/subscription_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'screens/AppTheme.dart';
import 'screens/home_screen/home_page.dart';
import 'screens/login_form.dart';
import 'screens/template_selection_page.dart';
// import 'package:app_settings/app_settings.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey();
BuildContext get appContext => navigatorKey.currentState!.context;
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  runApp(
    ChangeNotifierProvider(
      create: (context) => LanguageChangeController(),
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
  // Check login state
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({required this.isLoggedIn, super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ShowbiodataController()),
            ChangeNotifierProvider(create: (_) => SwappingController()),
            ChangeNotifierProvider(create: (_) => HomeScreenController()),
            // ChangeNotifierProvider(create: (_) => CreateBiodataController()),
            ChangeNotifierProvider(create: (_) => AuthController()),
            ChangeNotifierProvider(create: (_) => SubscriptionController()),
            // ChangeNotifierProvider(create: (_) => PaymentController()),
            ChangeNotifierProvider(create: (_) => LanguageController()),
          ],
          child: Consumer<LanguageController>(
            builder: (context, controller, _) {
              return MaterialApp(
                navigatorObservers: [routeObserver],
                debugShowCheckedModeBanner: false,
                title: 'Biodata Maker',
                theme: AppTheme.lightTheme,
                locale: controller.appLocale ?? Locale('en'),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: isLoggedIn ? const HomePage() : const SignupForm(),
                routes: {
                  '/home': (context) => const HomePage(),
                  '/login': (context) => LoginForm(
                        onLoginSuccess: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                      ),
                  '/alldetailpage': (context) => TemplateSelectionPage(
                        id: '',
                        selectedLanguage: '',
                        biodataName: '',
                      ),
                },
              );
            },
          ),
        );
      },
    );
  }
}

class CheckAuth extends StatefulWidget {
  const CheckAuth({super.key});

  @override
  State<CheckAuth> createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initialize();
  }

  Future<void> _initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (loggedIn) {
      String? matriId = prefs.getString('matri_id');
      if (matriId != null) {
        final controller =
            Provider.of<ShowbiodataController>(context, listen: false);
        await controller.fetchBiodata();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('An error occurred. Please try again.')),
          );
        }

        // Check if logged in
        SharedPreferences prefs =
            SharedPreferences.getInstance() as SharedPreferences;
        final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

        return isLoggedIn ? const HomePage() : const SignupForm();
      },
    );
  }
}


// name: bio_data
// description: "A new Flutter project."
// publish_to: 'none'
// version: 1.18.0+18

// environment:
//   sdk: '>=3.2.0 <4.0.0'

// dependencies:
//   cached_network_image: ^3.3.0
//   crop_your_image: ^2.0.0
//   custom_image_crop: ^0.1.1
//   dio: ^5.4.0
//   file_picker: ^8.1.7
//   flutter:
//     sdk: flutter
//   flutter_html: ^3.0.0-beta.2
//   flutter_localization: ^0.3.0
//   flutter_screenutil: ^5.9.0
//   # flutter_windowmanager: ^0.2.0
//   fluttertoast: ^8.2.4
//   http: ^1.1.2
//   image_picker: ^1.0.5
//   intl: ^0.19.0
//   open_filex: ^4.3.4
//   path_provider: ^2.1.1
//   pdf: ^3.10.7
//   pinput: ^5.0.0
//   provider: ^6.1.1
//   razorpay_flutter: ^1.3.5
//   # share: 2.0.4
//   shared_preferences: ^2.2.2
//   sms_autofill: ^2.3.0
//   share_plus: ^10.1.4
//   url_launcher: ^6.2.2
//   permission_handler: 11.3.1



// dev_dependencies:
//   flutter_lints: ^4.0.0
//   flutter_test:
//     sdk: flutter

// flutter:
//   generate: true
//   uses-material-design: true
//   assets:
//     - assets/
//     - assets/images/