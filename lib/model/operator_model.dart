class OperatorModel {
  late Data? data;
  late String? type;
  late String? testType;
  late String android;
  late String? testAndroid;
  late String? testTypeAndroid;
  late String ios;
  late String? testIos;
  late String? appUrl;

  OperatorModel({this.data, this.type});

  OperatorModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    testType = json['test_type'];
    type = json['type'];
    android = json['android'];
    testAndroid = json['test_android'];
    testIos = json['test_ios'];
    testTypeAndroid = json['test_type_android'];
    ios = json['ios'];
    appUrl = json['app_url']; 
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['type'] = type;
    data['test_type'] = testType;
    data['android'] = android;
    data['test_android'] = testAndroid;
    data['test_type_android'] = testTypeAndroid;
    data['test_ios'] = testIos;
    data['ios'] = ios;
    data['app_url'] = appUrl;
    return data;
  }
}

class Data {
  late int? id;
  late int? code;
  late String? name;
  late String? url;
  late String? logo;
  late String title;
  late String description;
  late String phone;
  late String email;
  late String website;
  late String whatsapp;
  late String telegram;
  late String facebook;
  late String instagram;
  late String twitter;
  late String? createdAt;
  late String? updatedAt;

  Data(
      {this.id,
      this.code,
      this.name,
      this.url,
      this.logo,
      this.title = '',
      this.description = '',
      this.phone = '',
      this.email = '',
      this.website = '',
      this.whatsapp = '',
      this.telegram = '',
      this.facebook = '',
      this.instagram = '',
      this.twitter = '',
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    url = json['url'];
    logo = json['logo'];
    title = json['title'];
    description = json['description'];
    phone = json['phone'];
    email = json['email'];
    website = json['website'];
    whatsapp = json['whatsapp'];
    telegram = json['telegram'];
    facebook = json['facebook'];
    instagram = json['instagram'];
    twitter = json['twitter'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['name'] = name;
    data['url'] = url;
    data['logo'] = logo;
    data['title'] = title;
    data['description'] = description;
    data['phone'] = phone;
    data['email'] = email;
    data['website'] = website;
    data['whatsapp'] = whatsapp;
    data['telegram'] = telegram;
    data['facebook'] = facebook;
    data['instagram'] = instagram;
    data['twitter'] = twitter;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
