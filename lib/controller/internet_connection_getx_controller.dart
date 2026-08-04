import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/app_material/app_styles.dart';
import 'package:iptv/config/config.dart';
import 'package:iptv/shared_preferences/shared_pref_controller.dart';
import 'package:iptv/utils/app_helper.dart';

class InternetConnectionGetxController extends GetxController with AppHelper {
  @override
  void onInit() {
    super.onInit();

    if (!kIsWeb) {
      checkInternetConnection();
      Timer.periodic(
          const Duration(seconds: 10), (Timer t) => checkInternetConnection());
    }
  }

  String error = '';
  bool isFirest = true;
  bool closed = false;

  Future<bool> checkInternetConnection(
      {Duration timeout = const Duration(seconds: 5)}) async {
    if (SharedPrefController().isLogined) {
      try {
        final result = await Socket.connect(
            SharedPrefController()
                    .baseUrl
                    ?.replaceAll('https://', '')
                    .replaceAll('http://', '')
                    .replaceAll(RegExp(r':\d+'), '') ??
                'streams.alkmal.com',
            SharedPrefController().port.isNotEmpty
                ? int.parse(SharedPrefController().port)
                : 80,
            timeout: timeout);
        closed = false;
        try {
          if (Get.isSnackbarOpen) {
            Get.closeAllSnackbars();
          }
        } catch (_) {}
        if (!isFirest) {
          showMeesage(
              title: ' تم استعادة الاتصال ',
              // subTitle: '',
              duration: const Duration(seconds: 3));
          isFirest = true;
        }
        if(screen == 'splash_screen' && !isSendOperator){
          getOperator();
        }
        result.destroy();
        return true;
      } on SocketException catch (e) {
        if (!closed) {

          if (e.message != error) {
            error = e.message;
            try {
              Get.closeAllSnackbars();
            } catch (_) {}
            await Future.delayed(const Duration(seconds: 3));
          }
          if (e.message == 'Connection refused') {
            if (!Get.isSnackbarOpen) {
              showMeesage(
                  title: 'الخدمة غير متوفرة حاليا ',
                  // subTitle: 'ستعود الخدمة للعمل باقرب وقت ممكن',
                  isError: true,
                  duration: const Duration(days: 1),
                  mainButton: TextButton(
                      onPressed: () {
                        closed = true;

                        try {
                          Get.closeAllSnackbars();
                        } catch (_) {}
                      },
                      child: Text(
                        'الغاء',
                        style: AppStyles().font14(
                          color: AppColors.whiteColor,
                        ),
                      )));
            }
          } else {
            if (!Get.isSnackbarOpen) {
              showMeesage(
                // title: 'تم قطع اتصالك',
                title: 'لا يتوفر انترنت ',
                isError: true,
                duration: const Duration(days: 1),
                mainButton: TextButton(
                    onPressed: () {
                      closed = true;

                      try {
                        Get.closeAllSnackbars();
                      } catch (_) {}
                    },
                    child: Text(
                      'الغاء',
                      style: AppStyles().font14(
                        color: AppColors.whiteColor,
                      ),
                    )),
              );
            }
          }
          isFirest = false;
          return false;
        }
      }
    }
    return true;
  }
}
