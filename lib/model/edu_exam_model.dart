import 'package:iptv/model/edu_model_parsing.dart';

class EduExam {
  final int id;
  final String name;
  final int? levelId;
  final int? semesterId;
  final int? courseId;
  final int? unitId;
  final int? lessonId;
  final int questionCount;
  final String? courseName;
  final String? unitName;
  final String? lessonName;
  final String classification;

  EduExam({
    required this.id,
    required this.name,
    this.levelId,
    this.semesterId,
    this.courseId,
    this.unitId,
    this.lessonId,
    this.questionCount = 0,
    this.courseName,
    this.unitName,
    this.lessonName,
    this.classification = 'general',
  });

  factory EduExam.fallback(int id) {
    return EduExam(id: id, name: 'اختبار $id');
  }

  factory EduExam.fromJson(Map<String, dynamic> json) {
    return EduExam(
      id: eduInt(json['id']),
      name: eduString(
          json['name_ar'] ?? json['name'], 'اختبار ${eduInt(json['id'])}'),
      levelId: eduRelatedId(json['level']),
      semesterId: eduRelatedId(json['semester']),
      courseId: eduRelatedId(json['course']),
      unitId: eduRelatedId(json['unit']),
      lessonId: eduRelatedId(json['lesson']),
      questionCount: eduInt(json['question_count']),
      courseName: json['course_name']?.toString(),
      unitName: json['unit_name']?.toString(),
      lessonName: json['lesson_name']?.toString(),
      classification: eduString(json['classification'], 'general'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'course_id': courseId,
      'unit_id': unitId,
      'lesson_id': lessonId,
    };
  }

  factory EduExam.fromMap(Map<String, dynamic> map) {
    return EduExam(
      id: eduInt(map['id']),
      name: eduString(map['name']),
      courseId: eduRelatedId(map['course_id']),
      unitId: eduRelatedId(map['unit_id']),
      lessonId: eduRelatedId(map['lesson_id']),
    );
  }
}
