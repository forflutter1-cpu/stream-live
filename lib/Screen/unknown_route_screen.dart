import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/SplashScreen.dart';

class UnknownRouteScreen extends StatefulWidget {
  const UnknownRouteScreen({super.key});

  @override
  State<UnknownRouteScreen> createState() => _UnknownRouteScreenState();
}

class _UnknownRouteScreenState extends State<UnknownRouteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAll(() => const SplashScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
