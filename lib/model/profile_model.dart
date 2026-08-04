class ProfileModel {
  late UserInfo? userInfo;
  late ServerInfo? serverInfo;

  ProfileModel({this.userInfo, this.serverInfo});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    userInfo =
        json['user_info'] != null ? UserInfo.fromJson(json['user_info']) : null;
    serverInfo = json['server_info'] != null
        ? ServerInfo.fromJson(json['server_info'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (userInfo != null) {
      data['user_info'] = userInfo!.toJson();
    }
    if (serverInfo != null) {
      data['server_info'] = serverInfo!.toJson();
    }
    return data;
  }
}

class UserInfo {
  late String? username;
  late String? password;
  late String? message;
  late num? auth;
  late String? status;
  late String? email;
  late String? mobile;
  late dynamic expDate;
  late dynamic isTrial;
  late String? activeCons;
  late String? createdAt;
  late String? maxConnections;
  late String? emailVerifiedAt;
  late String? mobileVerifiedAt;
  late bool? download;
  // late List<String>? allowedOutputFormats;

  UserInfo({
    this.username,
    this.password,
    this.message,
    this.auth,
    this.status,
    this.expDate,
    this.isTrial,
    this.activeCons,
    this.createdAt,
    this.maxConnections,
    this.emailVerifiedAt,
    this.mobileVerifiedAt,
    this.download,
    this.email,
    this.mobile,
    // this.allowedOutputFormats
  });

  UserInfo.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    password = json['password'];
    message = json['message'];
    auth = json['auth'];
    download = json['download'];
    email = json['email'];
    mobile = json['mobile'];
    status = json['status'];
    expDate = json['exp_date'];
    isTrial = json['is_trial'];
    activeCons = json['active_cons'];
    createdAt = json['created_at'];
    emailVerifiedAt = json['email_verified_at'];
    mobileVerifiedAt = json['mobile_verified_at'];
    maxConnections = json['max_connections'];
    // allowedOutputFormats = json['allowed_output_formats'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['password'] = password;
    data['message'] = message;
    data['auth'] = auth;
    data['email'] = email;
    data['mobile'] = mobile;
    data['download'] = download;
    data['status'] = status;
    data['exp_date'] = expDate;
    data['is_trial'] = isTrial;
    data['active_cons'] = activeCons;
    data['created_at'] = createdAt;
    data['max_connections'] = maxConnections;
    data['email_verified_at'] = emailVerifiedAt;
    data['mobile_verified_at'] = mobileVerifiedAt;
    // data['allowed_output_formats'] = allowedOutputFormats;
    return data;
  }
}

class ServerInfo {
  late String? url;
  late String? port;
  late String? httpsPort;
  late String? serverProtocol;
  late String? rtmpPort;
  late String? timezone;
  late num? timestampNow;
  late String? timeNow;

  ServerInfo(
      {this.url,
      this.port,
      this.httpsPort,
      this.serverProtocol,
      this.rtmpPort,
      this.timezone,
      this.timestampNow,
      this.timeNow});

  ServerInfo.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    port = json['port'];
    httpsPort = json['https_port'];
    serverProtocol = json['server_protocol'];
    rtmpPort = json['rtmp_port'];
    timezone = json['timezone'];
    timestampNow = json['timestamp_now'];
    timeNow = json['time_now'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['port'] = port;
    data['https_port'] = httpsPort;
    data['server_protocol'] = serverProtocol;
    data['rtmp_port'] = rtmpPort;
    data['timezone'] = timezone;
    data['timestamp_now'] = timestampNow;
    data['time_now'] = timeNow;
    return data;
  }
}
