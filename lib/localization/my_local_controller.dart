import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyLocalController extends GetxController {
  Locale intiLang = const Locale('ar');
  // SharedPrefController().lang == null
  //     ? Get.deviceLocale!
  //     // ? Get.deviceLocale!
  //     : SharedPrefController().lang == 'ar'
  //         ? const Locale('ar')
  //         : const Locale('en');

  void changeLang({required String langCode}) {
    Locale locale = Locale(langCode);
    // SharedPrefController().updateLang(lang: langCode);
    Get.updateLocale(locale);
  }
}
