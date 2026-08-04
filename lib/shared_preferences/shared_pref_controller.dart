import 'dart:async';

import 'package:iptv/model/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefController {
  static SharedPrefController? _instance;
  late SharedPreferences _sharedPreferences;

  SharedPrefController._();

  factory SharedPrefController() {
    return _instance ??= SharedPrefController._();
  }

  Future<void> initPreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<void> saveUserData({
    required ProfileModel profileModel,
    required bool isLogined,
  }) async {
    await _sharedPreferences.setBool('is_logined', isLogined);
    await _sharedPreferences.setString(
        'username', profileModel.userInfo?.username ?? '');
    await _sharedPreferences.setString(
        'password', profileModel.userInfo?.password ?? '');
    await _sharedPreferences.setString(
        'is_trial', profileModel.userInfo?.isTrial?.toString() ?? '1');
    if (profileModel.userInfo?.expDate != null) {
      await _sharedPreferences.setString(
          'expDate', profileModel.userInfo?.expDate.toString() ?? '');
    }
    if (profileModel.userInfo?.createdAt != null) {
      await _sharedPreferences.setString(
          'created_at', profileModel.userInfo!.createdAt!);
    }
    if (profileModel.userInfo?.download != null) {
      await _sharedPreferences.setBool(
          'download', profileModel.userInfo!.download!);
    }
    if (profileModel.userInfo?.emailVerifiedAt != null) {
      await _sharedPreferences.setString(
          'email_verified_at', profileModel.userInfo!.emailVerifiedAt!);
    }
    if (profileModel.userInfo?.email != null) {
      await _sharedPreferences.setString(
          'email', profileModel.userInfo!.email!);
    }
    if (profileModel.userInfo?.mobile != null) {
      await _sharedPreferences.setString(
          'mobile', profileModel.userInfo!.mobile!);
    }
    if (profileModel.userInfo?.mobileVerifiedAt != null) {
      await _sharedPreferences.setString(
          'mobile_verified_at', profileModel.userInfo!.mobileVerifiedAt!);
    }
    await _sharedPreferences.setString(
        'status', profileModel.userInfo?.status ?? '');
    await _sharedPreferences.setString(
        'active_cons', profileModel.userInfo?.activeCons ?? '');
    await _sharedPreferences.setString(
        'max_connections', profileModel.userInfo?.maxConnections ?? '');
    await _sharedPreferences.setString(
        'message', profileModel.userInfo?.message ?? '');
    await _sharedPreferences.setInt(
        'auth', profileModel.userInfo?.auth?.toInt() ?? 00000);
    await _sharedPreferences.setString(
        'url', profileModel.serverInfo?.url ?? '');
    await _sharedPreferences.setString(
        'port', profileModel.serverInfo?.port ?? '');
    await _sharedPreferences.setString(
        'https_port', profileModel.serverInfo?.httpsPort ?? '');
    await _sharedPreferences.setString(
        'server_protocol', profileModel.serverInfo?.serverProtocol ?? '');
  }

  Future<void> updateLogin({required bool isLogined}) async {
    await _sharedPreferences.setBool('is_logined', isLogined);
  }

  Future<void> updateFirst({required bool isFirst}) async {
    await _sharedPreferences.setBool('is_first', isFirst);
  }

  Future<void> updateBaseUrl({required String baseUrl}) async {
    await _sharedPreferences.setString('base_url', baseUrl);
  }

  Future<void> updateOperator({required String operator}) async {
    await _sharedPreferences.setString('operator', operator);
  }

  Future<void> updateMobileVerifiedAt(
      {required String mobileVerifiedAt}) async {
    await _sharedPreferences.setString('mobile_verified_at', mobileVerifiedAt);
  }

  Future<void> updateEmailVerifiedAt({required String emailVerifiedAt}) async {
    await _sharedPreferences.setString('email_verified_at', emailVerifiedAt);
  }

  Future<void> updateTypeOperator({required String typeOperator}) async {
    await _sharedPreferences.setString('type_operator', typeOperator);
  }

  Future<void> updateLang({required String lang}) async {
    await _sharedPreferences.setString('lang', lang);
  }

  Future<void> updateLastUrl({required String lastUrl}) async {
    await _sharedPreferences.setString('last_url', lastUrl);
  }

  Future<void> updateSelectedCategoryIndex(
      {required int selectedCategoryIndex}) async {
    await _sharedPreferences.setInt(
        'selected_category_index', selectedCategoryIndex);
  }

  Future<void> updateStreamName({required String streamName}) async {
    await _sharedPreferences.setString('stream_name', streamName);
  }

  Future<void> updatePendingRoute({required String pendingRoute}) async {
    await _sharedPreferences.setString('pending_route', pendingRoute);
  }

  Future<void> clearPendingRoute() async {
    await _sharedPreferences.remove('pending_route');
  }

  Future<void> updateRole({required String role}) async {
    await _sharedPreferences.setString('role', role);
  }

  Future<void> updateDeviceId({required String deviceId}) async {
    await _sharedPreferences.setString('device_id', deviceId);
  }

  Future<void> updateLastDataUpdata({required String lastDataUpdate}) async {
    await _sharedPreferences.setString('last_data_update', lastDataUpdate);
  }

  Future<void> updateStorePending({required int lenght}) async {
    await _sharedPreferences.setInt('store_pending', lenght);
  }

  Future<void> updateDriverStatus({required int lenght}) async {
    await _sharedPreferences.setInt('driver_status', lenght);
  }

  Future<void> saveDownloadState(
      String taskId, String fileName, int progress) async {
    await _sharedPreferences.setString('downloadTaskId', taskId);
    await _sharedPreferences.setString('downloadFileName', fileName);
    await _sharedPreferences.setInt('downloadProgress', progress);
  }

  bool get isLogined {
    return _sharedPreferences.getBool('is_logined') ?? false;
  }

  bool get download {
    return _sharedPreferences.getBool('download') ?? false;
  }

  bool get isFirst {
    return _sharedPreferences.getBool('is_first') ?? true;
  }

  int get storePending {
    return _sharedPreferences.getInt('store_pending') ?? 0;
  }

  int get driverStatus {
    return _sharedPreferences.getInt('driver_status') ?? 0;
  }

  String get name {
    return _sharedPreferences.getString('username') ?? '';
  }

  String get password {
    return _sharedPreferences.getString('password') ?? '';
  }

  String get activeCons {
    return _sharedPreferences.getString('active_cons') ?? '1';
  }

  String get maxConnections {
    return _sharedPreferences.getString('max_connections') ?? '1';
  }

  String get status {
    return _sharedPreferences.getString('status') ?? '';
  }

  String get serverProtocol {
    return _sharedPreferences.getString('server_protocol') ?? '';
  }

  String? get createdAt {
    return _sharedPreferences.getString('created_at');
  }

  String? get expDate {
    return _sharedPreferences.getString('expDate');
  }

  String get isTrial {
    return _sharedPreferences.getString('is_trial') ?? '1';
  }

  String get url {
    return _sharedPreferences.getString('url') ?? '';
  }

  String? get lastUrl {
    return _sharedPreferences.getString('last_url');
  }

  String? get lastDataUpdate {
    return _sharedPreferences.getString('last_data_update');
  }

  String? get downloadTaskId {
    return _sharedPreferences.getString('downloadTaskId');
  }

  // دالة لاسترجاع اسم الملف للتحميل
  String? get downloadFileName {
    return _sharedPreferences.getString('downloadFileName');
  }

  // دالة لاسترجاع نسبة التقدم للتحميل
  int get downloadProgress {
    return _sharedPreferences.getInt('downloadProgress') ?? 0;
  }

  int get selectedCategoryIndex {
    return _sharedPreferences.getInt('selected_category_index') ?? 0;
  }

  String? get streamName {
    return _sharedPreferences.getString('stream_name');
  }

  String? get pendingRoute {
    return _sharedPreferences.getString('pending_route');
  }

  String get port {
    return _sharedPreferences.getString('port') ?? '';
  }

  String get httpsPort {
    return _sharedPreferences.getString('https_port') ?? '';
  }

  String get phone {
    return _sharedPreferences.getString('mobile') ?? '';
  }

  int get userId {
    return _sharedPreferences.getInt('id') ?? 0;
  }

  int get points {
    return _sharedPreferences.getInt('points') ?? 0;
  }

  String get email {
    return _sharedPreferences.getString('email') ?? '';
  }

  String? get deviceId {
    return _sharedPreferences.getString('device_id');
  }

  String get cityId {
    return _sharedPreferences.getString('city_id') ?? '';
  }

  String get countryId {
    return _sharedPreferences.getString('country_id') ?? '';
  }

  String get token {
    return _sharedPreferences.getString('api_token') ?? '';
  }

  String? get emailVerifiedAt {
    return _sharedPreferences.getString('email_verified_at');
  }

  String? get mobileVerifiedAt {
    return _sharedPreferences.getString('mobile_verified_at');
  }

  String? get baseUrl {
    return _sharedPreferences.getString('base_url');
  }

  String? get operator {
    return _sharedPreferences.getString('operator');
  }

  String? get typeOperator {
    return _sharedPreferences.getString('type_operator');
  }

  String? get lang {
    return _sharedPreferences.getString('lang');
  }

  String get image {
    return _sharedPreferences.getString('image') ?? 'images/person.png';
  }

  String get role {
    return _sharedPreferences.getString('role') ?? '';
  }

  List<String> get roles {
    return _sharedPreferences.getStringList('roles') ?? [];
  }

  Future<bool> clear() async => _sharedPreferences.clear();
}
