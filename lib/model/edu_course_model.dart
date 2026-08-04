import 'package:iptv/model/edu_model_parsing.dart';
import 'package:iptv/model/edu_unit_model.dart';

class EduCourse {
  final int id;
  final String name;
  final int? levelId;
  final int? semesterId;
  final String? image;
  final int myOrder;
  final List<int> unitIds;
  final List<int> examIds;
  final List<EduUnit> units;

  EduCourse({
    required this.id,
    required this.name,
    this.levelId,
    this.semesterId,
    this.image,
    required this.myOrder,
    this.unitIds = const [],
    this.examIds = const [],
    this.units = const [],
  });

  factory EduCourse.fromJson(Map<String, dynamic> json) {
    return EduCourse(
      id: eduInt(json['id']),
      name: eduString(json['name_ar'] ?? json['name']),
      levelId: eduRelatedId(json['level']),
      semesterId: eduRelatedId(json['semester']),
      image: json['image']?.toString(),
      myOrder: eduInt(json['my_order']),
      unitIds: eduIdList(json['units']),
      examIds: eduIdList(json['exams']),
      units: json['units'] is List
          ? (json['units'] as List)
              .whereType<Map<String, dynamic>>()
              .map(EduUnit.fromJson)
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'level_id': levelId,
      'semester_id': semesterId,
      'image': image,
      'my_order': myOrder,
      'unit_ids': unitIds.join(','),
      'exam_ids': examIds.join(','),
    };
  }

  factory EduCourse.fromMap(Map<String, dynamic> map) {
    return EduCourse(
      id: eduInt(map['id']),
      name: eduString(map['name']),
      levelId: eduRelatedId(map['level_id']),
      semesterId: eduRelatedId(map['semester_id']),
      image: map['image']?.toString(),
      myOrder: eduInt(map['my_order']),
      unitIds: eduIdList(map['unit_ids']),
      examIds: eduIdList(map['exam_ids']),
    );
  }
}
