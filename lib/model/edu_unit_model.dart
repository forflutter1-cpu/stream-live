import 'package:iptv/model/edu_model_parsing.dart';
import 'package:iptv/model/edu_lesson_model.dart';

class EduUnit {
  final int id;
  final String name;
  final int courseId;
  final int myOrder;
  final bool notActive;
  final List<int> examIds;
  final List<int> classIds;
  final List<EduLesson> lessons;

  EduUnit({
    required this.id,
    required this.name,
    required this.courseId,
    required this.myOrder,
    this.notActive = false,
    this.examIds = const [],
    this.classIds = const [],
    this.lessons = const [],
  });

  factory EduUnit.fromJson(Map<String, dynamic> json) {
    return EduUnit(
      id: eduInt(json['id']),
      name: eduString(json['name_ar'] ?? json['name']),
      courseId: eduRelatedId(json['course']) ?? 0,
      myOrder: eduInt(json['my_order']),
      notActive: eduBool(json['not_active']),
      examIds: eduIdList(json['exams']),
      classIds: eduIdList(json['classes']),
      lessons: json['classes'] is List
          ? (json['classes'] as List)
              .whereType<Map<String, dynamic>>()
              .map(EduLesson.fromJson)
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'course_id': courseId,
      'my_order': myOrder,
      'not_active': notActive ? 1 : 0,
      'exam_ids': examIds.join(','),
      'class_ids': classIds.join(','),
    };
  }

  factory EduUnit.fromMap(Map<String, dynamic> map) {
    return EduUnit(
      id: eduInt(map['id']),
      name: eduString(map['name']),
      courseId: eduInt(map['course_id']),
      myOrder: eduInt(map['my_order']),
      notActive: eduBool(map['not_active']),
      examIds: eduIdList(map['exam_ids']),
      classIds: eduIdList(map['class_ids']),
    );
  }
}
