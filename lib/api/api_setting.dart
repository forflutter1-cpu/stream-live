import 'package:iptv/shared_preferences/shared_pref_controller.dart';

class ApiSettings {
  static String get baseUrl {
    String url = SharedPrefController().baseUrl ?? 'https://streams.alkmal.com/';
    if (!url.endsWith('/')) {
      url += '/';
    }
    return url;
  }

  static String get setDataUrl => '${baseUrl}setData';
  static String get loginUrl => '${baseUrl}player_api.php?';
  static String get sendVerifyUrl => '${baseUrl}api/send_verify?';
  static String get checkVerifyUrl => '${baseUrl}api/check_verify?';
  static String get changePasswordUrl => '${baseUrl}changePassword?';
  static String get updateProfileUrl => '${baseUrl}updateProfile?';
  static String get checkProfileUrl => '${baseUrl}player_api.php?';
  static String get categoriesUrl =>
      '${baseUrl}player_api.php?password=ThePassword&username=TheName&action=get_live_categories';
  static String get streamsUrl =>
      '${baseUrl}player_api.php?password=ThePassword&username=TheName&action=get_live_streams';

  static String get movieDetialsUrl =>
      '${baseUrl}player_api.php?password=ThePassword&username=TheName&action=get_vod_info&vod_id=';

  static const String channelUrl = 'dynamicBaseUrllive/theName/ThePassword/';

  static String get contact => '${baseUrl}contact';
  static String get operator => '${baseUrl}operator';

  static String get appleUrl => '${baseUrl}auth/apple/callback';
  static String get googleUrl => '${baseUrl}auth/google/callback?access_token=';
}
