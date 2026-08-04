import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/HomeScreen.dart';
import 'package:iptv/shared_preferences/shared_pref_controller.dart';

String currentAppRoute() {
  if (kIsWeb) {
    final fragment = Uri.base.fragment;
    if (fragment.startsWith('/')) {
      return fragment;
    }
  }
  return Get.currentRoute;
}

bool isProtectedFriendlyRoute(String route) {
  return route.startsWith('/live/') ||
      route.startsWith('/movie/') ||
      route.startsWith('/series/') ||
      route.startsWith('/edu') ||
      route.startsWith('/course/') ||
      route.startsWith('/unit/') ||
      route.startsWith('/lesson/') ||
      route.startsWith('/exam/');
}

Future<void> savePendingRoute(String route) async {
  if (route.isEmpty ||
      route == '/' ||
      route == '/SplashScreen' ||
      route == '/LoginScreen' ||
      route == '/HomeScreen') {
    return;
  }
  await SharedPrefController().updatePendingRoute(pendingRoute: route);
}

Future<void> saveCurrentRouteAsPending() async {
  final route = currentAppRoute();
  if (isProtectedFriendlyRoute(route)) {
    await savePendingRoute(route);
  }
}

Future<void> openPendingRouteOrHome() async {
  final pendingRoute = SharedPrefController().pendingRoute;
  if (pendingRoute != null &&
      pendingRoute.isNotEmpty &&
      isProtectedFriendlyRoute(pendingRoute)) {
    await SharedPrefController().clearPendingRoute();
    Get.offAllNamed(pendingRoute);
    return;
  }
  Get.offAll(() => const HomeScreen());
}
