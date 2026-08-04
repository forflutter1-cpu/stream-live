import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/Auth/LoginScreen.dart';
import 'package:iptv/Screen/Auth/operator_screen.dart';
import 'package:iptv/Screen/Auth/public_screen.dart';
import 'package:iptv/Screen/SplashScreen.dart';
import 'package:iptv/Screen/edu/teach_screen.dart';
import 'package:iptv/api/api_controller/api_controller.dart';
import 'package:iptv/database/database_helper.dart';
import 'package:iptv/shared_preferences/shared_pref_controller.dart';
import 'package:iptv/utils/app_helper.dart';
import 'package:iptv/utils/deep_link_redirect.dart';
import 'package:permission_handler/permission_handler.dart';

String screen = '';
bool isSendOperator = true;

class GlobalHelper with AppHelper {}

final globalHelper = GlobalHelper();

void getOperator() async {
  permission();
  operatorModel = await ApiController().getOperator();
  String version = await ApiController().getAppVersion(); // الحصول على الإصدار
  String buildNumber =
      await ApiController().getBuildNumber(); // الحصول على رقم البناء
  final currentVersion = '$version+$buildNumber';

  if (operatorModel != null) {
    isSendOperator = true;
    final approvedVersion = _platformVersion(isTest: false);
    final testVersion = _platformVersion(isTest: true);
    final isTestNewerThanRelease =
        _compareAppVersions(testVersion, approvedVersion) > 0;
    final shouldUseTest =
        isTestNewerThanRelease && _isSameVersion(currentVersion, testVersion);
    navigate(isTest: shouldUseTest);
  } else {
    _openManualLogin();
  }

  // if ('$version+$buildNumber' == operatorModel?.testAndroid ||
  //     '$version+$buildNumber' == operatorModel?.testIos) {
  //   isSendOperator = true;
  //   SharedPrefController().isLogined
  //       ? Get.offAll(() => const HomeScreen())
  //       : Get.offAll(() => (operatorModel?.testType == 'private' ||
  //               (operatorModel?.testType == 'operator' &&
  //                   SharedPrefController().operator != null))
  //           ? const LoginScreen()
  //           : operatorModel?.testType == 'operator' &&
  //                   SharedPrefController().operator == null
  //               ? const OperatorScreen()
  //               : operatorModel?.testType == 'public'
  //                   ? const PublicScreen()
  //                   : const StoreScreen());
  // } else if ((Platform.isAndroid
  //             ? operatorModel?.android
  //             : operatorModel?.ios) ==
  //         '$version+$buildNumber' ||
  //     (Platform.isAndroid ? operatorModel?.android : operatorModel?.ios) ==
  //         null) {
  //   if (operatorModel != null &&
  //       operatorModel!.type != SharedPrefController().typeOperator) {
  //     await SharedPrefController().clear();
  //     if (!kIsWeb) {
  //       await DatabaseHelper.instance.clearDatabase();
  //     }
  //   }
  //   if (operatorModel != null) {
  //     isSendOperator = true;
  //     SharedPrefController()
  //         .updateTypeOperator(typeOperator: operatorModel!.type!);
  //     // Get.offAll(() => const LoginScreen());
  //     // if (operatorModel?.type != 'teach') {
  //     //   SystemChrome.setPreferredOrientations([
  //     //     // DeviceOrientation.portraitUp,
  //     //     // DeviceOrientation.portraitDown,_betterPlayerController
  //     //     DeviceOrientation.landscapeRight,
  //     //     DeviceOrientation.landscapeLeft
  //     //   ]);
  //     //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
  //     //       overlays: []);
  //     // }
  //     SharedPrefController().isLogined
  //         ? Get.offAll(() => const HomeScreen())
  //         : Get.offAll(() => (operatorModel?.type == 'private' ||
  //                 (operatorModel?.type == 'operator' &&
  //                     SharedPrefController().operator != null))
  //             ? const LoginScreen()
  //             : operatorModel?.type == 'operator' &&
  //                     SharedPrefController().operator == null
  //                 ? const OperatorScreen()
  //                 : operatorModel?.type == 'public'
  //                     ? const PublicScreen()
  //                     : const StoreScreen());
  //   }
  // } else {
  //   globalHelper.showAppUpdateDialoag(appUrl: operatorModel?.appUrl);
  // }
}

void navigate({required bool isTest}) async {
  final operatorType = _platformType(isTest: isTest);
  if (operatorType != SharedPrefController().typeOperator) {
    final pendingRoute = SharedPrefController().pendingRoute;
    await SharedPrefController().clear();
    if (pendingRoute != null && pendingRoute.isNotEmpty) {
      await SharedPrefController()
          .updatePendingRoute(pendingRoute: pendingRoute);
    }
    if (!kIsWeb) {
      await DatabaseHelper.instance.clearDatabase();
    }
  }
  await SharedPrefController().updateTypeOperator(typeOperator: operatorType);
  if (SharedPrefController().isLogined) {
    await openPendingRouteOrHome();
  } else {
    Get.offAll(() => (operatorType == 'private' ||
            (operatorType == 'operator' &&
                SharedPrefController().operator != null))
        ? const LoginScreen()
        : operatorType == 'operator' && SharedPrefController().operator == null
            ? const OperatorScreen()
            : operatorType == 'public'
                ? const PublicScreen()
                // 'teach' type → شاشة التعليم
                : const TeachScreen());
  }
}

String? _platformVersion({required bool isTest}) {
  final isIos = defaultTargetPlatform == TargetPlatform.iOS;
  if (isTest) {
    return isIos ? operatorModel?.testIos : operatorModel?.testAndroid;
  }
  return isIos ? operatorModel?.ios : operatorModel?.android;
}

String _platformType({required bool isTest}) {
  if (!isTest) {
    return _normalizeType(operatorModel?.type);
  }
  final androidType = operatorModel?.testTypeAndroid;
  final sharedType = operatorModel?.testType;
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return _normalizeType(sharedType);
  }
  return _normalizeType(
      androidType?.isNotEmpty == true ? androidType : sharedType);
}

String _normalizeType(String? type) {
  final normalized = type?.trim();
  return normalized == null || normalized.isEmpty ? 'private' : normalized;
}

bool _isSameVersion(String? first, String? second) {
  return !_isVersionUnreadable(first) &&
      !_isVersionUnreadable(second) &&
      first!.trim() == second!.trim();
}

bool _isVersionUnreadable(String? version) {
  return version == null || version.trim().isEmpty;
}

int _compareAppVersions(String? first, String? second) {
  if (_isVersionUnreadable(first) || _isVersionUnreadable(second)) {
    return 0;
  }
  final left = _versionParts(first!);
  final right = _versionParts(second!);
  final length = left.length > right.length ? left.length : right.length;
  for (var i = 0; i < length; i++) {
    final leftValue = i < left.length ? left[i] : 0;
    final rightValue = i < right.length ? right[i] : 0;
    if (leftValue != rightValue) {
      return leftValue.compareTo(rightValue);
    }
  }
  return 0;
}

List<int> _versionParts(String version) {
  return version
      .split(RegExp(r'[.+-]'))
      .map((part) => int.tryParse(part.trim()) ?? 0)
      .toList();
}

void _openManualLogin() {
  isSendOperator = false;
  Get.offAll(() => const PublicScreen());
}

void permission() async {
  if (!await Permission.notification.isGranted) {
    await Permission.notification.request();
  }
}
