import 'package:iptv/model/edu_model_parsing.dart';

class EduLevel {
  final int id;
  final String name;
  final int myOrder;
  final bool isGeneral;
  final bool notActive;

  EduLevel({
    required this.id,
    required this.name,
    required this.myOrder,
    required this.isGeneral,
    required this.notActive,
  });

  factory EduLevel.fromJson(Map<String, dynamic> json) {
    return EduLevel(
      id: eduInt(json['id']),
      name: eduString(json['name_ar'] ?? json['name']),
      myOrder: eduInt(json['my_order']),
      isGeneral: eduBool(json['is_general']),
      notActive: eduBool(json['not_active']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'my_order': myOrder,
      'is_general': isGeneral ? 1 : 0,
      'not_active': notActive ? 1 : 0,
    };
  }

  factory EduLevel.fromMap(Map<String, dynamic> map) {
    return EduLevel(
      id: eduInt(map['id']),
      name: eduString(map['name']),
      myOrder: eduInt(map['my_order']),
      isGeneral: eduBool(map['is_general']),
      notActive: eduBool(map['not_active']),
    );
  }
}
