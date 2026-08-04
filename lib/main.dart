import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flu_wake_lock/flu_wake_lock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/HomeScreen.dart';
import 'package:iptv/Screen/Auth/LoginScreen.dart';
import 'package:iptv/Screen/Auth/RegisterScreen.dart';
import 'package:iptv/Screen/Profile/ProfileScreen.dart';
import 'package:iptv/Screen/SearchScreen.dart';
import 'package:iptv/Screen/SplashScreen.dart';
import 'package:iptv/Screen/bn_screens/live_screen.dart';
import 'package:iptv/Screen/bn_screens/movie_screen.dart';
import 'package:iptv/Screen/bn_screens/series_screen.dart';
import 'package:iptv/Screen/deep_link_screen.dart';
import 'package:iptv/Screen/edu_deep_link_screen.dart';
import 'package:iptv/Screen/unknown_route_screen.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/controller/fb_notifications_controller.dart';
import 'package:iptv/localization/my_local.dart';
import 'package:iptv/localization/my_local_controller.dart';
import 'package:iptv/shared_preferences/shared_pref_controller.dart';
import 'firebase_options.dart';
import 'package:iptv/controller/internet_connection_getx_controller.dart';

// flutter build apk --release --no-shrink
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // custom error widget to avoid default red crash screen
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bug_report, size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text('حدث خطأ غير متوقع',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              // const SizedBox(height: 8),
              // Text(
              //   details.exceptionAsString(),
              //   textAlign: TextAlign.center,
              //   style: const TextStyle(color: Colors.black54),
              // ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Get.offAll(() => const SplashScreen());
                },
                child: const Text('عودة',
                    style: TextStyle(color: AppColors.primryColor)),
              )
            ],
          ),
        ),
      ),
    );
  };
  SharedPrefController().initPreferences();

  // WakelockPlus.enable();
  // configureBackgroundService();
  if (!kIsWeb) {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
    } catch (e) {
      print("Firebase already initialized: $e");
    }

    await FBNotificationsController.initNotifications();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  if (!kIsWeb) {
    FlutterDownloader.initialize(
      debug: true, // اختياري: لتفعيل وضع التصحيح
      ignoreSsl: true,
    );

    HttpOverrides.global = MyHttpOverrides(); // تعيين HttpOverrides
    final FluWakeLock fluWakeLock = FluWakeLock();
    fluWakeLock.enable();
  }

  runApp(const IPTV());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class IPTV extends StatelessWidget {
  const IPTV({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // WakelockPlus.enable();
    MyLocalController myLocalController = Get.put(MyLocalController());
    Get.put(InternetConnectionGetxController());
    return GetMaterialApp(
      locale: myLocalController.intiLang,
      translations: MyLocal(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Almarai',
        appBarTheme: const AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            backgroundColor: Colors.transparent),
        colorSchemeSeed: AppColors.primryColor,
      ),
      initialRoute: '/SplashScreen',
      unknownRoute:
          GetPage(name: '/unknown', page: () => const UnknownRouteScreen()),
      // home: OtpVerificationScreen(phoneNumber: "+1234567890"),
      // home: RegisterScreen(),
      getPages: [
        GetPage(name: '/SplashScreen', page: () => const SplashScreen()),
        GetPage(name: '/LoginScreen', page: () => const LoginScreen()),
        GetPage(name: '/RegisterScreen', page: () => const RegisterScreen()),
        GetPage(name: '/HomeScreen', page: () => const HomeScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/live', page: () => const LiveScreen()),
        GetPage(name: '/movies', page: () => const MovieScreen()),
        GetPage(name: '/series', page: () => const SeriesScreen()),
        GetPage(name: '/SearchScreen', page: () => const SearchScreen()),
        GetPage(
          name: '/search/:type',
          page: () => SearchScreen(
            selectedType: int.tryParse(Get.parameters['type'] ?? '0') ?? 0,
          ),
        ),
        GetPage(name: '/ProfileScreen', page: () => const ProfileScreen()),
        GetPage(
          name: '/live/:id/:slug',
          page: () => DeepLinkScreen(
            type: 'live',
            id: Get.parameters['id'] ?? '',
          ),
        ),
        GetPage(
          name: '/live/:id',
          page: () => DeepLinkScreen(
            type: 'live',
            id: Get.parameters['id'] ?? '',
          ),
        ),
        GetPage(
          name: '/movie/:id/:slug',
          page: () => DeepLinkScreen(
            type: 'movie',
            id: Get.parameters['id'] ?? '',
          ),
        ),
        GetPage(
          name: '/movie/:id',
          page: () => DeepLinkScreen(
            type: 'movie',
            id: Get.parameters['id'] ?? '',
          ),
        ),
        GetPage(
          name: '/series/:id/:slug',
          page: () => DeepLinkScreen(
            type: 'series',
            id: Get.parameters['id'] ?? '',
          ),
        ),
        GetPage(
          name: '/series/:id',
          page: () => DeepLinkScreen(
            type: 'series',
            id: Get.parameters['id'] ?? '',
          ),
        ),
        GetPage(
          name: '/edu',
          page: () => const EduDeepLinkScreen(type: 'home', id: ''),
        ),
        GetPage(
          name: '/edu/level/:id/:slug',
          page: () => EduDeepLinkScreen(
            type: 'level',
            id: Get.parameters['id'] ?? '',
          ),
        ),
        GetPage(
          name: '/edu/level/:id',
          page: () => EduDeepLinkScreen(
            type: 'level',
            id: Get.parameters['id'] ?? '',
          ),
        ),
        GetPage(
          name: '/level/:id/:slug',
          page: () => EduDeepLinkScreen(
            type: 'level',
            id: Get.parameters['id'] ?? '',
          ),
        ),
        GetPage(
          name: '/level/:id',
          page: () => EduDeepLinkScreen(
            type: 'level',
            id: Get.parameters['id'] ?? '',
          ),
        ),
        GetPage(
          name: '/edu/course/:id/:slug',
          page: () => EduDeepLinkScreen(
            type: 'course',
            id: Get.parameters['id'] ?? '',
          ),
        ),
        GetPage(
          name: '/edu/course/:id',
          page: () => EduDeepLinkScreen(
            type: 'course',
            id: Get.parameters['id'] ?? '',
          ),
        ),
        GetPage(
          name: '/course/:id/:slug',
          page: () => EduDeepLinkScreen(
            type: 'course',
            id: Get.parameters['id'] ?? '',
          ),
        ),
        GetPage(
          name: '/course/:id',
          page: () => EduDeepLinkScreen(
            type: 'course',
            id: Get.parameters['id'] ?? '',
          ),
        ),
        GetPage(
          name: '/edu/unit/:id/:slug',
          page: () => EduDeepLinkScreen(
            type: 'unit',
            id: Get.parameters['id'] ?? '',
          ),
        ),
        GetPage(
          name: '/edu/unit/:id',
          page: () => EduDeepLinkScreen(
            type: 'unit',
            id: Get.parameters['id'] ?? '',
          ),
        ),
        GetPage(
          name: '/unit/:id/:slug',
          page: () => EduDeepLinkScreen(
            type: 'unit',
            id: Get.parameters['id'] ?? '',
          ),
        ),
        GetPage(
          name: '/unit/:id',
          page: () => EduDeepLinkScreen(
            type: 'unit',
            id: Get.parameters['id'] ?? '',
          ),
        ),
        GetPage(
          name: '/edu/lesson/:id/:slug',
          page: () => EduDeepLinkScreen(
            type: 'lesson',
            id: Get.parameters['id'] ?? '',
          ),
        ),
        GetPage(
          name: '/edu/lesson/:id',
          page: () => EduDeepLinkScreen(
            type: 'lesson',
            id: Get.parameters['id'] ?? '',
          ),
        ),
        GetPage(
          name: '/lesson/:id/:slug',
          page: () => EduDeepLinkScreen(
            type: 'lesson',
            id: Get.parameters['id'] ?? '',
          ),
        ),
        GetPage(
          name: '/lesson/:id',
          page: () => EduDeepLinkScreen(
            type: 'lesson',
            id: Get.parameters['id'] ?? '',
          ),
        ),
        GetPage(
          name: '/edu/exam/:id/:slug',
          page: () => EduDeepLinkScreen(
            type: 'exam',
            id: Get.parameters['id'] ?? '',
          ),
        ),
        GetPage(
          name: '/edu/exam/:id',
          page: () => EduDeepLinkScreen(
            type: 'exam',
            id: Get.parameters['id'] ?? '',
          ),
        ),
        GetPage(
          name: '/exam/:id/:slug',
          page: () => EduDeepLinkScreen(
            type: 'exam',
            id: Get.parameters['id'] ?? '',
          ),
        ),
        GetPage(
          name: '/exam/:id',
          page: () => EduDeepLinkScreen(
            type: 'exam',
            id: Get.parameters['id'] ?? '',
          ),
        ),
      ],
    );
  }
}
