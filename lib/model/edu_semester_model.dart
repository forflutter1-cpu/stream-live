import 'package:iptv/model/edu_model_parsing.dart';

class EduSemester {
  final int id;
  final String name;
  final int myOrder;

  EduSemester({
    required this.id,
    required this.name,
    required this.myOrder,
  });

  factory EduSemester.fromJson(Map<String, dynamic> json) {
    return EduSemester(
      id: eduInt(json['id']),
      name: eduString(json['name_ar'] ?? json['name']),
      myOrder: eduInt(json['my_order']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'my_order': myOrder,
    };
  }

  factory EduSemester.fromMap(Map<String, dynamic> map) {
    return EduSemester(
      id: eduInt(map['id']),
      name: eduString(map['name']),
      myOrder: eduInt(map['my_order']),
    );
  }
}
