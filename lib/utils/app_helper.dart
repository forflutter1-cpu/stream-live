import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/SplashScreen.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/app_material/app_styles.dart';
import 'package:iptv/shared_preferences/shared_pref_controller.dart';
import 'package:url_launcher/url_launcher.dart';

mixin AppHelper {
  void showMeesage({
    required String title,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
    TextButton? mainButton,
  }) {
    // Ensure we show the snackbar after the current frame so Overlay is available
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // If overlay/context is not yet available, delay a bit and try again
        if (Get.overlayContext == null) {
          Future.delayed(const Duration(milliseconds: 300), () {
            try {
              Get.rawSnackbar(
                messageText: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                snackStyle: SnackStyle.FLOATING,
                backgroundColor: isError ? Colors.red : Colors.green,
                duration: duration,
                margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                borderRadius: 12,
                maxWidth: 250, // الحد الأقصى للعرض حسب النص
                mainButton: mainButton,
                isDismissible: true,
                snackPosition: SnackPosition.TOP,
                forwardAnimationCurve: Curves.easeOut,
              );
            } catch (_) {}
          });
        } else {
          try {
            Get.rawSnackbar(
              messageText: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              snackStyle: SnackStyle.FLOATING,
              backgroundColor: isError ? Colors.red : Colors.green,
              duration: duration,
              margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              borderRadius: 12,
              maxWidth: 250, // الحد الأقصى للعرض حسب النص
              mainButton: mainButton,
              isDismissible: true,
              snackPosition: SnackPosition.TOP,
              forwardAnimationCurve: Curves.easeOut,
            );
          } catch (_) {}
        }
      });
    } catch (_) {}
  }


  String generateRandomString() {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random.secure();
    return List.generate(64, (index) => chars[random.nextInt(chars.length)])
        .join('');
  }

  bool isTowDayAgoOrMore({bool isLast = false}) {
    DateTime now = DateTime.now();

    Duration difference = now.difference(
        SharedPrefController().lastDataUpdate != null
            ? DateTime.parse(SharedPrefController().lastDataUpdate!)
            : now);

    if (SharedPrefController().lastDataUpdate == null) {
      SharedPrefController()
          .updateLastDataUpdata(lastDataUpdate: DateTime.now().toString());
    }

    if (difference.inDays >= 2) {
      if (isLast) {
        SharedPrefController()
            .updateLastDataUpdata(lastDataUpdate: DateTime.now().toString());
      }
      return true;
    } else {
      return false;
    }
  }

  String getErrorMessage(int errorCode) {
    switch (errorCode) {
      case -875574348: // local404
        return "الملف غير موجود على الجهاز.";
      case -1162824012: // localIOe
        return "حدث خطأ في الإدخال/الإخراج.";
      case -558323010: // interBug
        return "خطأ داخلي في التطبيق.";
      case -1397118274: // smallBuf
        return "حجم الذاكرة المؤقتة صغير جداً.";
      case -1128613112: // noDecoder
        return "لم يتم العثور على فك الشيفرة المطلوب.";
      case -1296385272: // noDemuxer
        return "لم يتم العثور على مفسر البيانات المطلوب.";
      case -1129203192: // noEncoder
        return "لم يتم العثور على مشفر البيانات المطلوب.";
      case -541478725: // fileEnd
        return "تم الوصول إلى نهاية الملف.";
      case -1414092869: // exitImm
        return "تم طلب الخروج الفوري.";
      case -542398533: // extErr
        return "خطأ عام في مكتبة خارجية.";
      case -1279870712: // noFilter
        return "لم يتم العثور على الفلتر المطلوب.";
      case -1094995529: // badData
        return "تم العثور على بيانات غير صالحة أثناء المعالجة.";
      case -1481985528: // noMuxer
        return "لم يتم العثور على خالط البيانات المطلوب.";
      case -1414549496: // noOption
        return "لم يتم العثور على الخيار المطلوب.";
      case -1163346256: // noImplemented
        return "الميزة غير مطبقة بعد في FFmpeg.";
      case -1330794744: // noProtocol
        return "لم يتم العثور على البروتوكول المطلوب.";
      case -1381258232: // noStream
        return "لم يتم العثور على التدفق المطلوب.";
      case -1313558101: // unknown
        return "خطأ غير معروف.";
      case -808465656: // http400
        return "طلب غير صالح (400).";
      case -825242872: // http401
        return "غير مصرح بالوصول (401).";
      case -858797304: // http403
        return "الوصول مرفوض (403).";
      case -875574520: // http404
        return "لم يتم العثور على الصفحة المطلوبة (404).";
      case -1482175736: // http4xx
        return "خطأ في الطلب (4xx).";
      case -1482175992: // http5xx
        return "خطأ في الخادم (5xx).";
      default:
        return "حدث خطأ غير معروف.";
    }
  }

  void soonDialog() {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          Get.defaultDialog(
            title: 'قريبا',
            titleStyle: AppStyles().font18(
              fontWeight: FontWeight.bold,
              color: AppColors.primryColor,
            ),
            content: Text(
              'قيد التطوير',
              style: AppStyles().font14(),
            ),
            textCancel: 'حسنا',
            cancelTextColor: AppColors.primryColor,
            onCancel: () {
              try {
                Get.back();
              } catch (_) {}
            },
          );
        } catch (_) {}
      });
    } catch (_) {}
  }

  void updateDialog() {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          Get.defaultDialog(
            title: 'يتم التحديث',
            titleStyle: AppStyles().font18(
              fontWeight: FontWeight.bold,
              color: AppColors.primryColor,
            ),
            content: Text(
              'لا يمكنك تحديث اكثر من قسم بنفس الوقت',
              style: AppStyles().font14(),
              textAlign: TextAlign.center,
            ),
            textCancel: 'حسنا',
            cancelTextColor: AppColors.primryColor,
            onCancel: () {
              try {
                Get.back();
              } catch (_) {}
            },
          );
        } catch (_) {}
      });
    } catch (_) {}
  }

  void forceUpdateDialog() {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          Get.defaultDialog(
            title: 'تحديث القنوات',
            titleStyle: AppStyles().font18(
              fontWeight: FontWeight.bold,
              color: AppColors.primryColor,
            ),
            content: Text(
              'يوجد تحديث جديد للقنوات',
              style: AppStyles().font14(),
              textAlign: TextAlign.center,
            ),
            textCancel: 'تحديث',
            cancelTextColor: AppColors.primryColor,
            onCancel: () {
              try {
                Get.back();
              } catch (_) {}
            },
          );
        } catch (_) {}
      });
    } catch (_) {}
  }

  void showAppUpdateDialoag({String? appUrl}) {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          Get.defaultDialog(
            title: 'اصدار جديد',
            titleStyle: AppStyles().font18(
              fontWeight: FontWeight.bold,
              color: AppColors.primryColor,
            ),
            content: Text(
              'قم بتحديث تطبيقك لاخر اصدار',
              style: AppStyles().font14(),
              textAlign: TextAlign.center,
            ),
            textCancel: 'تحديث الآن',
            cancelTextColor: AppColors.primryColor,
            onCancel: () {
              try {
                if (appUrl != null) {
                  launch(url: appUrl);
                }
                Get.back();
              } catch (_) {}
            },
          );
        } catch (_) {}
      });
    } catch (_) {}
  }

  void contactDialog({bool actice = true}) {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          Get.defaultDialog(
            title: actice ? (operatorModel!.data?.title ?? 'تواصل معنا') : 'انتهاء الاشتراك',
            titleStyle: actice
                ? AppStyles().font20(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primryColor,
                  )
                : AppStyles().font18(
                    color: AppColors.redColor,
                    fontWeight: FontWeight.bold,
                  ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  actice
                      ? Text(
                          operatorModel!.data?.description ?? '',
                          style: AppStyles().font14(),
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          'تم انتهاء الاشتراك بتاريخ ${timeStam(SharedPrefController().expDate ?? '0')}',
                          style: AppStyles().font14(
                            color: AppColors.redColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Visibility(
                        visible: operatorModel!.data != null &&
                            operatorModel!.data!.email.isNotEmpty,
                        child: IconButton(
                          onPressed: () {
                            try {
                              launch(url: operatorModel!.data!.email);
                            } catch (_) {}
                          },
                          icon: const Icon(
                            Icons.email,
                            size: 40,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: operatorModel!.data != null &&
                            operatorModel!.data!.phone.isNotEmpty,
                        child: IconButton(
                          onPressed: () {
                            try {
                              launch(url: operatorModel!.data!.phone);
                            } catch (_) {}
                          },
                          icon: const Icon(
                            Icons.call,
                            size: 40,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: operatorModel!.data != null &&
                            operatorModel!.data!.facebook.isNotEmpty,
                        child: IconButton(
                          onPressed: () {
                            try {
                              launch(url: operatorModel!.data!.facebook);
                            } catch (_) {}
                          },
                          icon: SvgPicture.asset(
                            'images/facebook.svg',
                            height: 35,
                            width: 35,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: operatorModel!.data != null &&
                            operatorModel!.data!.instagram.isNotEmpty,
                        child: IconButton(
                          onPressed: () {
                            try {
                              launch(url: operatorModel!.data!.instagram);
                            } catch (_) {}
                          },
                          icon: SvgPicture.asset(
                            'images/Instagram.svg',
                            height: 35,
                            width: 35,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: operatorModel!.data != null &&
                            operatorModel!.data!.twitter.isNotEmpty,
                        child: IconButton(
                          onPressed: () {
                            try {
                              launch(url: operatorModel!.data!.twitter);
                            } catch (_) {}
                          },
                          icon: SvgPicture.asset(
                            'images/T.svg',
                            height: 35,
                            width: 35,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: operatorModel!.data != null &&
                            operatorModel!.data!.telegram.isNotEmpty,
                        child: IconButton(
                          onPressed: () {
                            try {
                              launch(url: operatorModel!.data!.telegram);
                            } catch (_) {}
                          },
                          icon: SvgPicture.asset(
                            'images/telegram.svg',
                            height: 35,
                            width: 35,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: operatorModel!.data != null &&
                            operatorModel!.data!.whatsapp.isNotEmpty,
                        child: IconButton(
                          onPressed: () {
                            try {
                              launch(url: operatorModel!.data!.whatsapp);
                            } catch (_) {}
                          },
                          icon: SvgPicture.asset(
                            'images/w.svg',
                            height: 35,
                            width: 35,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: operatorModel!.data != null &&
                            operatorModel!.data!.website.isNotEmpty,
                        child: IconButton(
                          onPressed: () {
                            try {
                              launch(url: operatorModel!.data!.website);
                            } catch (_) {}
                          },
                          icon: const Icon(
                            Icons.language_sharp,
                            size: 40,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            textCancel: 'حسنا',
            cancelTextColor: AppColors.primryColor,
            onCancel: () {
              try {
                Get.back();
              } catch (_) {}
            },
          );
        } catch (_) {}
      });
    } catch (_) {}
  }

  Duration parseDuration(String time) {
    final parts = time.split(':').map(int.parse).toList();
    if (parts.length == 3) {
      return Duration(hours: parts[0], minutes: parts[1], seconds: parts[2]);
    } else {
      throw FormatException('Invalid time format');
    }
  }

  Future<void> launch({required String url}) async {
    String formattedUrl = url;

    if (RegExp(r'^\+?\d+$').hasMatch(url)) {
      formattedUrl = 'tel:$url'; // تحويل الرقم إلى رابط اتصال
    } else if (RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(url)) {
      formattedUrl = 'mailto:$url'; // تحويل الإيميل إلى رابط إرسال بريد
    }

    if (!await launchUrl(Uri.parse(formattedUrl),
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch'.tr);
    }
  }

  void showErrorDialog(String message) {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          Get.defaultDialog(
            title: 'خطأ!',
            titleStyle: AppStyles().font18(
              fontWeight: FontWeight.bold,
              color: AppColors.redColor,
            ),
            content: Text(
              message,
              style: AppStyles().font14(),
              textAlign: TextAlign.center,
            ),
            cancel: TextButton(
              onPressed: () {
                try {
                  Get.back();
                } catch (_) {}
              },
              child: Text(
                'الغاء',
                style: AppStyles().font14(
                  color: AppColors.primryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        } catch (_) {}
      });
    } catch (_) {}
  }

  String timeStam(String timestamp) {
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp) * 1000);
    return "${date.year}-${date.month}-${date.day}";
  }

  // String getCountryCode(String phoneNumber) {
  //   // استخراج كود الدولة من رقم الهاتف
  //   String countryCode = '';
  //   for (int i = 1; i <= 4; i++) {
  //     countryCode = phoneNumber.substring(0, i);
  //     // البحث عن الدولة في القائمة
  //     for (var country in countriesCode) {
  //       if (country[1].toString() == countryCode) {
  //         return country[1].toString();
  //       }
  //     }
  //   }
  //   return 'Country not found';
  // }

  // String getMessageFromCode(String code) {
  //   Map<String, String> codeToMessage = {
  //     "200": "OK",
  //     "201": "SMS_SEND",
  //     "202": "CALLBACK",
  //     "203": "MAIL_SEND",
  //     "400": "INVALID_PARAMETER",
  //     "401": "INVALID_PASSWORD",
  //     "402": "INVALID_PHONE_NUMBER",
  //     "403": "TOO_MANY_REQUESTS",
  //     "404": "INVALID_HTTP_METHOD",
  //     "405": "INVALID_CODE",
  //     "406": "INVALID_LOGIN_PASSWORD",
  //     "407": "INVALID_CONTENT_TYPE",
  //     "408": "USERNAME_ALREADY_EXIST",
  //     "409": "EMAIL_ALREADY_EXIST",
  //     "410": "INVALID_EMAIL",
  //     "411": "FILE_TOO_LARGE",
  //     "412": "TOO_MANY_ATTEMPTS",
  //     "413": "UNEQUAL_VALUE",
  //     "414": "ERROR_API_WHEN_SENDING_SMS",
  //     "415": "LAST_REMAINING_ATTEMPTS",
  //     "416": "NO_INFO_ABOUT_VERSION",
  //     "417": "INVALID_VERSION",
  //     "418": "INVALID_USERNAME",
  //     "419": "INVALID_COUNTRY",
  //     "420": "INVALID_JSON_FORMAT",
  //     "421": "ERROR_PROVIDER_WHEN_SENDING_SMS",
  //     "422": "ERROR_BLACKLIST_WHEN_SENDING_SMS",
  //     "423": "INVALID_AUTHENTICATION_HEADER",
  //     "424": "INVALID_USER_AGENT",
  //     "425": "INVALID_RESOURCE_KEY",
  //     "426": "RECOMMENDATION_ALREADY_EXIST",
  //     "427": "SIP_CLIENT_DOES_NOT_EXIST",
  //     "429": "LOCAL_CONTACT_DOES_NOT_EXIST",
  //     "430": "TRANSACTION_ALREADY_FINALIZED",
  //     "431": "APPLE_REQUEST_FAILED",
  //     "432": "FRAUD_ATTEMPT",
  //     "433": "INVALID_PRODUCT_ID",
  //     "434": "INVALID_PURCHASE_STATE",
  //     "435": "PURCHASE_CANCELED",
  //     "436": "PHONE_NUMBER_ALREADY_EXIST",
  //     "437": "CLIENT_PASS_ALREADY_EXIST",
  //     "438": "CLIENT_PASS_DOES_NOT_EXIST",
  //     "439": "CLIENT_PASS_MUST_BE_DIFFERENT",
  //     "440": "CLIENT_PASS_DOES_NOT_MATCH",
  //     "441": "PHONE_NUMBER_ALREADY_ASSIGNED",
  //     "442": "NOT_ENOUGH_FUNDS",
  //     "443": "GROUP_CHAT_TOO_MANY_MEMBERS",
  //     "444": "GROUP_CHAT_DOES_NOT_EXIST",
  //     "445": "CLIENT_IS_NOT_ACTIVE",
  //     "446": "PLAN_ALREADY_ASSIGN",
  //     "447": "PLAN_NOT_AVAILABLE",
  //     "448": "METHOD_DISABLED",
  //     "449": "INVITE_NOT_ALL_SEND",
  //     "450": "INVITE_SEND_LIMIT",
  //     "451": "TOO_MANY_DEVICES",
  //     "452": "CLIENT_EMAIL_DOES_NOT_EXIST",
  //     "453": "CONTACT_TOKEN_EXPIRED",
  //     "454": "CONTACT_TOKEN_PENDING",
  //     "455": "INVALID_PIN",
  //     "456": "GROUP_CHAT_STATUS_ALREADY_SET",
  //     "457": "GROUP_CHAT_STATUS_NOT_CONFIRMED",
  //     "458": "ERROR_BUYING_DID",
  //     "459": "USERNAME_ALREADY_ASSIGNED",
  //     "460": "INVALID_SIGNIN_TOKEN",
  //     "461": "TARIFF_ALREADY_ASSIGN",
  //     "500": "INTERNAL_ERROR",
  //   };

  //   return codeToMessage[code] ?? "Unknown code";
  // }
}
