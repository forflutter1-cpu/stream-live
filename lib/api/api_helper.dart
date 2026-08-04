import 'package:iptv/shared_preferences/shared_pref_controller.dart';

// import 'package:iptv/main.dart';

mixin ApiHelper {
  Map<String, String> get header {
    return {
      'Accept': 'application/json',
      'device-id': SharedPrefController().deviceId ?? '',
    };
  }

  String get stringHeader {
    return '?device-id=${SharedPrefController().deviceId}';
  }

  String streamUrlWithDeviceId(String url) {
    final uri = Uri.tryParse(url);
    final isAppStream = uri != null &&
        (uri.host == 'streams.alkmal.com' ||
            uri.host == 'iptv.alkmal.com' ||
            uri.host == 'alkmal.com');

    if (!isAppStream) {
      return url;
    }

    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}device-id=${SharedPrefController().deviceId}';
  }

  // Map<String, String> get headerwithAuthUserNameAndPassword {
  //   return {
  //     HttpHeaders.userAgentHeader:
  //         'vippie;${Platform.isAndroid ? 'and' : 'ios'};1.2.3',
  //     HttpHeaders.contentTypeHeader: 'text/plain',
  //     HttpHeaders.authorizationHeader:
  //         'Basic ${SharedPrefController().loginInformation}:${SharedPrefController().password}',
  //     HttpHeaders.cookieHeader:
  //         'ASP.NET_SessionId=C1BB840DB638CBCFCEE93577; ASP.NET_SessionId=9B8ABF9E1E5E316FCE012F42',
  //     'X-VIPPIE-DEVICE-ID': deviceId ?? '',
  //     'X-VIPPIE-DEVICE-NAME': deviceName ?? '',

  //     // 'api-token': 'API-TEST-TOKEN'
  //     // SharedPrefController().lang ?? Get.deviceLocale!.languageCode
  //   };
}

// Map<String, String> get headerWithToken {
//   return {
//     HttpHeaders.acceptHeader: 'application/json',
//     // HttpHeaders.authorizationHeader: 'Bearer ${SharedPrefController().token}',
//     HttpHeaders.acceptLanguageHeader: 'en',
//     'api-token': 'API-TEST-TOKEN'
//     // SharedPrefController().lang ?? Get.deviceLocale!.languageCode,
//     // HttpHeaders.authorizationHeader:
//     //     'Bearer 991|J78HuLm8hUjaNPhzmsex7a0Ofjfe9FFzttJm8UUf',
//   };
// }
// }
