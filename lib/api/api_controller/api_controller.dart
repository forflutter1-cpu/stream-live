import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:iptv/Screen/HomeScreen.dart';
import 'package:iptv/api/api_helper.dart';
import 'package:iptv/api/api_setting.dart';
import 'package:iptv/database/database_helper.dart';
import 'package:iptv/model/category_model.dart';
import 'package:iptv/model/contact_model.dart';
import 'package:iptv/model/movie_derails_model.dart';
import 'package:iptv/model/operator_model.dart';
import 'package:iptv/model/profile_model.dart';
import 'package:iptv/model/series_details_model.dart';
import 'package:iptv/model/stream_model.dart';
import 'package:iptv/model/stream_series_model.dart';
import 'package:iptv/shared_preferences/shared_pref_controller.dart';
import 'package:iptv/utils/app_helper.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ApiController with ApiHelper, AppHelper {
  Future<void> checkProfile() async {
    try {
      Uri url = Uri.parse(
          '${ApiSettings.checkProfileUrl}password=${SharedPrefController().password}&username=${SharedPrefController().name}');

      var response = await http.get(url);
      var jsonResponse = jsonDecode(response.body);
      ProfileModel profileModel = ProfileModel.fromJson(jsonResponse);
      await SharedPrefController()
          .saveUserData(profileModel: profileModel, isLogined: true);
    } catch (e) {
      return;
    }
  }

  Future<ProfileModel?> login({
    required String userName,
    required String password,
  }) async {
    try {
      setData(
        userName: userName,
        password: password,
      );
      Uri url = Uri.parse(
          '${ApiSettings.loginUrl}username=$userName&password=$password');

      var response = await http.get(url, headers: header);

      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ProfileModel.fromJson(jsonResponse);
      } else {
        showMeesage(title: jsonResponse!['message'], isError: true);
        return null;
      }
    } catch (e) {
      showMeesage(title: 'حدث خطا ما !', isError: true);

      return null;
    }
  }

  Future<void> changePaswword({
    required String userName,
    required String password,
    required String newPasswordConfirmation,
    required String newPassword,
  }) async {
    try {
      Uri url = Uri.parse(
          '${ApiSettings.changePasswordUrl}username=$userName&password=$password&new_password=$newPassword&new_password_confirmation=$newPasswordConfirmation');

      var response = await http.get(url, headers: header);

      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await SharedPrefController().saveUserData(
            profileModel: ProfileModel.fromJson(jsonResponse), isLogined: true);
        showMeesage(
          title: jsonResponse!['message'] ?? 'تمت العملية بنجاح',
        );
        Get.offAll(() => const HomeScreen());
        // return ProfileModel.fromJson(jsonResponse);
      } else {
        showMeesage(
            title: jsonResponse!['message'] ?? 'حدث خطا ما !', isError: true);
      }
    } catch (e) {
      showMeesage(title: 'حدث خطا ما !', isError: true);
    }
  }

  Future<void> updateProfile({
    String? userName,
    String? email,
    String? mobile,
  }) async {
    try {
      Uri url = Uri.parse(
          '${ApiSettings.updateProfileUrl}name=${userName ?? ''}&email=${email ?? ''}&mobile=${mobile ?? ''}&username=${SharedPrefController().name}&password=${SharedPrefController().password}');

      var response = await http.get(url, headers: header);

      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await SharedPrefController().saveUserData(
            profileModel: ProfileModel.fromJson(jsonResponse), isLogined: true);
        showMeesage(
          title: jsonResponse!['message'] ?? 'تمت العملية بنجاح',
        );
        Get.offAll(() => const HomeScreen());
        // return ProfileModel.fromJson(jsonResponse);
      } else {
        showMeesage(
            title: jsonResponse!['message'] ?? 'حدث خطا ما !', isError: true);
      }
    } catch (e) {
      showMeesage(title: 'حدث خطا ما !', isError: true);
    }
  }

  Future<String?> appleLogin() async {
    try {
      AuthorizationCredentialAppleID credential =
          await SignInWithApple.getAppleIDCredential(
        // webAuthenticationOptions: WebAuthenticationOptions(
        //   clientId: 'com.kamal.ajnadeen',
        //   redirectUri: Uri.parse(ApiSettings.appleUrl),
        // ),
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // if (credential.['status']) {
      //   await SharedPrefController().saveUserData(
      //       registerModel: getRegisterModel(data: jsonResponse['data']),
      //       isLogined: true);
      //   return null;
      // }

      // ===================================

      Uri uri = Uri.parse(ApiSettings.appleUrl);
      var response = await http.post(uri,
          headers: header, body: {'id_token': credential.identityToken});
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status']) {
        // await SharedPrefController().saveUserData(
        //     registerModel: getRegisterModel(data: jsonResponse['data']),
        //     isLogined: true);
        // Get.snackbar(
        //   'Seccses',
        //   jsonResponse['message'],
        //   backgroundColor: Colors.green,
        //   margin: EdgeInsets.zero,
        //   snackStyle: SnackStyle.GROUNDED,
        // );

        // SharedPrefController().role == 'Customer'
        //     ? Get.offAll(
        //         () => const HomeScreen(),
        //         transition: Transition.size,
        //         duration: const Duration(milliseconds: 1500),
        //         curve: Curves.easeIn,
        //       )
        //     : Get.offAll(
        //         () => const OrdersScreen(),
        //         transition: Transition.size,
        //         duration: const Duration(milliseconds: 1500),
        //         curve: Curves.easeIn,
        //       );
        return null;
      } else {
        return jsonResponse['message'];
      }
    } catch (e) {
      return 'SOMETHING WENT WRONG!';
    }
  }

  Future<String?> googleLogin({
    required String token,
  }) async {
    try {
      Uri uri = Uri.parse('${ApiSettings.googleUrl}$token');

      var response = await http.get(uri, headers: header);
      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status']) {
        // await SharedPrefController().saveUserData(
        //     registerModel: getRegisterModel(data: jsonResponse['data']),
        //     isLogined: true);
        return null;
      } else {
        return jsonResponse['message'];
      }
    } catch (e) {
      return 'SOMETHING WENT WRONG!';
    }
  }

  void setData({
    required String userName,
    required String password,
  }) async {
    try {
      Uri url = Uri.parse(
          '${ApiSettings.setDataUrl}?username=$userName&password=$password&server=${SharedPrefController().baseUrl ?? 'https://streams.alkmal.com'} &os=${_platformName()}');
      await http.get(url, headers: header);
    } catch (e) {
      return;
    }
  }

  Future<ProfileModel?> register({
    required String userName,
    required String password,
    required String email,
    required String mobile,
  }) async {
    try {
      Uri url = Uri.parse(
        '${ApiSettings.loginUrl}name=$userName&password=$password&email=$email&mobile=$mobile&action=register',
      );

      var response = await http.get(url, headers: header);
      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ProfileModel.fromJson(jsonResponse);
      } else {
        showMeesage(title: jsonResponse!['message'], isError: true);
        return null;
      }
    } catch (e) {
      showMeesage(title: 'حدث خطا ما !', isError: true);
      return null;
    }
  }

  Future<void> sendVerify({
    required bool isEmail,
  }) async {
    try {
      Uri url = Uri.parse(
          '${ApiSettings.sendVerifyUrl}username=${SharedPrefController().name}&password=${SharedPrefController().password}&verify=${isEmail ? 'email' : 'mobile'}');

      var response = await http.get(url, headers: header);

      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || jsonResponse['status']) {
        showMeesage(
          title: jsonResponse!['message'] ?? 'تمت العملية بنجاح',
        );
      } else {
        showMeesage(
            title: jsonResponse!['message'] ?? 'حدث خطا ما !', isError: true);
      }
    } catch (e) {
      showMeesage(title: 'حدث خطا ما !', isError: true);
    }
  }

  Future<void> checkVerify({
    required bool isEmail,
    required String code,
  }) async {
    try {
      Uri url = Uri.parse(
          '${ApiSettings.checkVerifyUrl}username=${SharedPrefController().name}&password=${SharedPrefController().password}&verify=${isEmail ? 'email' : 'mobile'}&code=$code');

      var response = await http.get(url, headers: header);

      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || jsonResponse['status']) {
        showMeesage(
          title: jsonResponse!['message'] ?? 'تمت العملية بنجاح',
        );
        isEmail
            ? SharedPrefController()
                .updateEmailVerifiedAt(emailVerifiedAt: 'emailVerifiedAt')
            : SharedPrefController()
                .updateMobileVerifiedAt(mobileVerifiedAt: 'mobileVerifiedAt');

        Get.offAll(() => const HomeScreen());
      } else {
        showMeesage(
            title: jsonResponse!['message'] ?? 'حدث خطا ما !', isError: true);
      }
    } catch (e) {
      showMeesage(title: 'حدث خطا ما !', isError: true);
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      // الخطوة 1: اجلب البيانات من API
      Uri url = Uri.parse(ApiSettings.categoriesUrl
          .replaceAll('ThePassword', SharedPrefController().password)
          .replaceAll('TheName', SharedPrefController().name));

      var response = await http.get(url, headers: header);
      var jsonResponse = jsonDecode(response.body) as List;
      var categories =
          jsonResponse.map((e) => CategoryModel.fromJson(e)).toList();

      // الخطوة 2: خزّن البيانات في قاعدة البيانات
      final dbHelper = DatabaseHelper.instance;
      for (var category in categories) {
        await dbHelper.insertCategory(category);
      }

      // الخطوة 3: استرجع البيانات المخزنة من قاعدة البيانات
      return await dbHelper.getAllCategories();
    } catch (e) {
      return [];
    }
  }

  Future<List<StreamModel>> getStreams({Function(double)? onProgress}) async {
    try {
      final dbHelper = DatabaseHelper.instance;

      // الخطوة 1: حاول جلب البيانات من قاعدة البيانات
      List<StreamModel> localStreams = await dbHelper.getAllStreams();

      if (localStreams.isNotEmpty) {
        final freeStreams = localStreams
            .where((stream) => stream.categoryId == 'free_channels')
            .toList();

        // إذا لا توجد قنوات مجانية محلياً أو كانت بدون روابط مباشرة → أعد التحميل
        final needsRefresh = freeStreams.isEmpty ||
            freeStreams.every((stream) =>
                stream.directSource == null || stream.directSource!.isEmpty);

        if (!needsRefresh) {
          // إذا كانت البيانات المحلية مكتملة، استخدمها مباشرة
          return localStreams;
        }
        // وإلا امسح القديم وأعد التحميل
        await dbHelper.clearStreams();
      }

      {
        // الخطوة 2: جلب البيانات من API وتخزينها في قاعدة البيانات
        Uri url = Uri.parse(ApiSettings.streamsUrl
            .replaceAll('ThePassword', SharedPrefController().password)
            .replaceAll('TheName', SharedPrefController().name));

        // هنا نستخدم request لإرسال الطلب
        var request = http.Request('GET', url);
        var streamedResponse = await request.send();

        // إجمالي حجم البيانات (content-length)
        int totalBytes = streamedResponse.contentLength ?? 0;

        int receivedBytes = 0;

        // نحتاج لتخزين البايتات المستلمة بشكل جزئي هنا
        StringBuffer responseBody = StringBuffer();

        // متابعة تحميل البيانات من السيرفر
        await for (var chunk in streamedResponse.stream) {
          receivedBytes += chunk.length;
          responseBody.write(utf8.decode(chunk));

          // تحديث نسبة التقدم بناءً على البايتات المستلمة
          if (totalBytes != 0 && onProgress != null) {
            double downloadProgress = (receivedBytes / totalBytes) *
                0.5; // تخصيص 50% للجلب من السيرفر
            onProgress(downloadProgress);
          }
        }

        // بعد اكتمال الاستلام نحول الـ response إلى JSON
        var jsonResponse = jsonDecode(responseBody.toString()) as List;
        var streams = jsonResponse.map((e) => StreamModel.fromJson(e)).toList();

        // إعداد متغيرات نسبة التقدم لتخزين البيانات في قاعدة البيانات
        int totalItems = streams.length;
        int processedItems = 0;

        // حساب نسبة التقدم أثناء تخزين البيانات في قاعدة البيانات
        // for (var stream in streams) {
        await dbHelper.insertStream(streams);
        processedItems++;

        // حساب نسبة التحميل بالنسبة للـ 50% الخاصة بقاعدة البيانات
        double progress = 0.5 + (processedItems / totalItems) * 0.5;

        // تحديث نسبة التحميل باستخدام الدالة المتاحة (إن وجدت)
        if (onProgress != null) {
          onProgress(progress);
        }
        // }

        return streams;
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<CategoryModel>> getMovieCategories() async {
    try {
      // الخطوة 1: اجلب البيانات من API
      Uri url = Uri.parse(ApiSettings.categoriesUrl
          .replaceAll('ThePassword', SharedPrefController().password)
          .replaceAll('TheName', SharedPrefController().name)
          .replaceAll('get_live_categories', 'get_vod_categories'));

      var response = await http.get(url, headers: header);
      var jsonResponse = jsonDecode(response.body) as List;
      var categories =
          jsonResponse.map((e) => CategoryModel.fromJson(e)).toList();

      // الخطوة 2: خزّن البيانات في قاعدة البيانات
      final dbHelper = DatabaseHelper.instance;
      for (var category in categories) {
        await dbHelper.insertMovieCategory(category);
      }

      // الخطوة 3: استرجع البيانات المخزنة من قاعدة البيانات
      return await dbHelper.getAllMovieCategories();
    } catch (e) {
      return [];
    }
  }

  Future<List<StreamModel>> getMovieStreams(
      {Function(double)? onProgress}) async {
    try {
      final dbHelper = DatabaseHelper.instance;

      // الخطوة 1: حاول جلب البيانات من قاعدة البيانات
      List<StreamModel> localStreams = await dbHelper.getAllMovieStreams();
      if (localStreams.isNotEmpty) {
        // إذا كانت هناك بيانات محلية، استخدمها مباشرة
        return localStreams;
      } else {
        // الخطوة 2: جلب البيانات من API وتخزينها في قاعدة البيانات
        Uri url = Uri.parse(ApiSettings.streamsUrl
            .replaceAll('ThePassword', SharedPrefController().password)
            .replaceAll('TheName', SharedPrefController().name)
            .replaceAll('get_live_streams', 'get_vod_streams'));

        // هنا نستخدم request لإرسال الطلب
        var request = http.Request('GET', url);
        var streamedResponse = await request.send();

        // إجمالي حجم البيانات (content-length)
        int totalBytes = streamedResponse.contentLength ?? 0;
        int receivedBytes = 0;

        // نحتاج لتخزين البايتات المستلمة بشكل جزئي هنا
        StringBuffer responseBody = StringBuffer();

        // متابعة تحميل البيانات من السيرفر
        await for (var chunk in streamedResponse.stream) {
          receivedBytes += chunk.length;
          responseBody.write(utf8.decode(chunk));

          // تحديث نسبة التقدم بناءً على البايتات المستلمة
          if (totalBytes != 0 && onProgress != null) {
            double downloadProgress = (receivedBytes / totalBytes) *
                0.5; // تخصيص 50% للجلب من السيرفر
            onProgress(downloadProgress);
          }
        }

        // بعد اكتمال الاستلام نحول الـ response إلى JSON
        var jsonResponse = jsonDecode(responseBody.toString()) as List;
        var streams = jsonResponse.map((e) => StreamModel.fromJson(e)).toList();

        // إعداد متغيرات نسبة التقدم لتخزين البيانات في قاعدة البيانات
        int totalItems = streams.length;
        int processedItems = 0;

        // حساب نسبة التقدم أثناء تخزين البيانات في قاعدة البيانات
        // for (var stream in streams) {

        await dbHelper.insertMovieStream(streams);
        processedItems++;

        // حساب نسبة التحميل بالنسبة للـ 50% الخاصة بقاعدة البيانات
        double progress = 0.5 + (processedItems / totalItems) * 0.5;

        // تحديث نسبة التحميل باستخدام الدالة المتاحة (إن وجدت)
        if (onProgress != null) {
          onProgress(progress);
        }
        // }

        return streams;
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<CategoryModel>> getSeriesCategories() async {
    try {
      // الخطوة 1: اجلب البيانات من API
      Uri url = Uri.parse(ApiSettings.categoriesUrl
          .replaceAll('ThePassword', SharedPrefController().password)
          .replaceAll('TheName', SharedPrefController().name)
          .replaceAll('get_live_categories', 'get_series_categories'));

      var response = await http.get(url, headers: header);
      var jsonResponse = jsonDecode(response.body) as List;
      var categories =
          jsonResponse.map((e) => CategoryModel.fromJson(e)).toList();

      // الخطوة 2: خزّن البيانات في قاعدة البيانات
      final dbHelper = DatabaseHelper.instance;
      for (var category in categories) {
        await dbHelper.insertSeriesCategory(category);
      }

      // الخطوة 3: استرجع البيانات المخزنة من قاعدة البيانات
      return await dbHelper.getAllSeriesCategories();
    } catch (e) {
      return [];
    }
  }

  Future<List<StreamSeriesModel>> getSeriesStreams({
    Function(double)? onProgress,
  }) async {
    try {
      final dbHelper = DatabaseHelper.instance;

      // الخطوة 1: حاول جلب البيانات من قاعدة البيانات
      List<StreamSeriesModel> localStreams =
          await dbHelper.getAllSeriesStreams();

      final localHasDetails =
          localStreams.any((item) => (item.plot ?? '').trim().isNotEmpty);

      if (localStreams.isNotEmpty && localHasDetails) {
        // إذا كانت هناك بيانات محلية، استخدمها مباشرة
        return localStreams;
      } else {
        if (localStreams.isNotEmpty && !localHasDetails) {
          await dbHelper.clearSeriesStreams();
        }
        // الخطوة 2: جلب البيانات من API وتخزينها في قاعدة البيانات
        Uri url = Uri.parse(ApiSettings.streamsUrl
            .replaceAll('ThePassword', SharedPrefController().password)
            .replaceAll('TheName', SharedPrefController().name)
            .replaceAll('get_live_streams', 'get_series'));
        // هنا نستخدم request لإرسال الطلب
        var request = http.Request('GET', url);
        var streamedResponse = await request.send();

        // إجمالي حجم البيانات (غير متاح دائمًا، لذا نتحقق منه)
        int totalBytes = streamedResponse.contentLength ?? 0;
        int receivedBytes = 0;

        // نحتاج لتخزين البايتات المستلمة بشكل جزئي هنا
        StringBuffer responseBody = StringBuffer();

        // متابعة تحميل البيانات من السيرفر
        await for (var chunk in streamedResponse.stream) {
          receivedBytes += chunk.length;
          responseBody.write(utf8.decode(chunk));

          // تحديث نسبة التقدم بناءً على البايتات المستلمة
          if (totalBytes != 0 && onProgress != null) {
            double downloadProgress = (receivedBytes / totalBytes) *
                0.5; // تخصيص 50% للجلب من السيرفر
            onProgress(downloadProgress);
          }
        }

        // بعد اكتمال الاستلام نحول الـ response إلى JSON
        var jsonResponse = jsonDecode(responseBody.toString()) as List;
        var streams =
            jsonResponse.map((e) => StreamSeriesModel.fromJson(e)).toList();

        // إعداد متغيرات نسبة التقدم لتخزين البيانات في قاعدة البيانات
        int totalItems = streams.length;
        int processedItems = 0;

        // الخطوة 3: تخزين البيانات في قاعدة البيانات مع تحديث نسبة التحميل
        // for (var stream in streams) {
        await dbHelper.insertSeriesStream(streams);
        processedItems++;

        // حساب نسبة التحميل بالنسبة للـ 50% الخاصة بقاعدة البيانات
        double progress = 0.5 + (processedItems / totalItems) * 0.5;

        // تحديث نسبة التحميل باستخدام الدالة المتاحة (إن وجدت)
        if (onProgress != null) {
          onProgress(progress);
        }
        // }

        return streams;
      }
    } catch (e) {
      return [];
    }
  }

  Future<OperatorModel?> getOperator({String code = ''}) async {
    try {
      String version =
          await ApiController().getAppVersion(); // الحصول على الإصدار
      String buildNumber = await ApiController().getBuildNumber();
      Uri uri = Uri.parse(
          '${ApiSettings.operator}?code=$code&version=$version+$buildNumber&paltform=${_platformName()}');
      var response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse is! Map<String, dynamic>) {
        return null;
      }
      return OperatorModel.fromJson(jsonResponse);
    } catch (e) {
      return null;
    }
  }

  Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version; // الإصدار
  }

  Future<String> getBuildNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.buildNumber; // رقم البناء
  }

  String _platformName() {
    return defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
  }

  Future<ContactModel?> getContact() async {
    try {
      Uri uri = Uri.parse(ApiSettings.contact);
      var response = await http.get(uri);
      var jsonResponse = jsonDecode(response.body);
      return ContactModel.fromJson(jsonResponse);
    } catch (e) {
      return null;
    }
  }

  Future<MovieOrSeriesDetails?> getMovieDetails({
    required String id,
    required bool isMovie,
  }) async {
    try {
      Uri uri = Uri.parse(
        '${ApiSettings.movieDetialsUrl}$id'
            .replaceAll('ThePassword', SharedPrefController().password)
            .replaceAll('TheName', SharedPrefController().name)
            .replaceAll(
                'get_vod_info', isMovie ? 'get_vod_info' : 'get_series_info')
            .replaceAll('vod_id=', isMovie ? 'vod_id=' : 'series_id='),
      );

      var response = await http.get(uri, headers: header);
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        final previewLength = response.body.length.clamp(0, 180).toInt();
        debugPrint(
            'getMovieDetails unexpected response: ${response.statusCode} ${response.body.substring(0, previewLength)}');
        return null;
      }
      var jsonResponse = decoded;

      if (isMovie) {
        return MovieOrSeriesDetails(
          movieDetails: MovieDetailsModel.fromJson(jsonResponse),
          seriesDetails: null,
        );
      } else {
        return MovieOrSeriesDetails(
          movieDetails: null,
          seriesDetails: SeriesDetailsModel.fromJson(jsonResponse),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('getMovieDetails failed for id=$id isMovie=$isMovie: $e');
      debugPrint(stackTrace.toString());
      return null;
    }
  }

  // Future<void> getChannels({required String streamId}) async {
  //   try {
  //     Uri url = Uri.parse('${ApiSettings.channelUrl}$streamId');
  //     var response = await http.get(url);
  //     var jsonResponse = jsonDecode(response.body);
  //     // return jsonResponse.map((e) => StreamModel.fromJson(e)).toList();
  //   } catch (e) {
  //     // return [];
  //   }
  // }

  Future<bool> deleteAccount() async {
    try {
      Uri url = Uri.parse(
          '${ApiSettings.baseUrl}deleteAccount?username=${SharedPrefController().name}&password=${SharedPrefController().password}');

      var response = await http.get(url, headers: header);
      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['status'] == true) {
        showMeesage(
          title: jsonResponse['message'] ?? 'تم حذف الحساب بنجاح',
        );
        return true;
      } else {
        showMeesage(
            title: jsonResponse['message'] ?? 'حدث خطا ما !', isError: true);
        return false;
      }
    } catch (e) {
      showMeesage(title: 'حدث خطا ما !', isError: true);
      return false;
    }
  }
}

class MovieOrSeriesDetails {
  final MovieDetailsModel? movieDetails;
  final SeriesDetailsModel? seriesDetails;

  MovieOrSeriesDetails({this.movieDetails, this.seriesDetails});
}
