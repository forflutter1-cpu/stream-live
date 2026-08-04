class ContactModel {
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

  ContactModel();

  ContactModel.fromJson(Map<String, dynamic> json) {
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
    return data;
  }
}
