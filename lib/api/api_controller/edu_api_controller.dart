import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iptv/model/edu_course_model.dart';
import 'package:iptv/model/edu_exam_model.dart';
import 'package:iptv/model/edu_lesson_model.dart';
import 'package:iptv/model/edu_level_model.dart';
import 'package:iptv/model/edu_question_model.dart';
import 'package:iptv/model/edu_semester_model.dart';
import 'package:iptv/model/edu_unit_model.dart';

class EduApiController {
  static const String _base = 'https://streams.alkmal.com/edu-api';
  static const Duration _timeout = Duration(seconds: 30);

  List<dynamic> _results(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final results = data['results'];
      return results is List ? results : const [];
    }
    return const [];
  }

  Map<String, dynamic>? _object(dynamic data) {
    return data is Map<String, dynamic> && data['status'] != false
        ? data
        : null;
  }

  // ---- Levels ----
  Future<List<EduLevel>> fetchLevels() async {
    try {
      final url = Uri.parse('$_base/levels?format=json');
      final res = await http.get(url).timeout(_timeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final results = _results(data);
        return results.map((e) => EduLevel.fromJson(e)).toList()
          ..sort((a, b) => a.myOrder.compareTo(b.myOrder));
      }
    } catch (_) {}
    return [];
  }

  Future<EduLevel?> fetchLevel(int levelId) async {
    try {
      final url = Uri.parse('$_base/levels/$levelId?format=json');
      final res = await http.get(url).timeout(_timeout);
      if (res.statusCode == 200) {
        final data = _object(jsonDecode(res.body));
        return data == null ? null : EduLevel.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  // ---- Semesters ----
  Future<List<EduSemester>> fetchSemesters() async {
    try {
      final url = Uri.parse('$_base/semesters?format=json');
      final res = await http.get(url).timeout(_timeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final results = _results(data);
        return results.map((e) => EduSemester.fromJson(e)).toList()
          ..sort((a, b) => a.myOrder.compareTo(b.myOrder));
      }
    } catch (_) {}
    return [];
  }

  // ---- Courses ----
  Future<List<EduCourse>> fetchCourses({int? levelId, int? semesterId}) async {
    try {
      String query = '?format=json&page_size=200';
      if (levelId != null) query += '&level=$levelId';
      if (semesterId != null) query += '&semester=$semesterId';
      final url = Uri.parse('$_base/courses$query');
      final res = await http.get(url).timeout(_timeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final results = _results(data);
        return results.map((e) => EduCourse.fromJson(e)).toList()
          ..sort((a, b) => a.myOrder.compareTo(b.myOrder));
      }
    } catch (_) {}
    return [];
  }

  Future<EduCourse?> fetchCourse(int courseId) async {
    try {
      final url = Uri.parse('$_base/courses/$courseId?format=json');
      final res = await http.get(url).timeout(_timeout);
      if (res.statusCode == 200) {
        final data = _object(jsonDecode(res.body));
        return data == null ? null : EduCourse.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  // ---- Units ----
  Future<List<EduUnit>> fetchUnits({required int courseId}) async {
    try {
      final url =
          Uri.parse('$_base/units?format=json&course=$courseId&page_size=200');
      final res = await http.get(url).timeout(_timeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final results = _results(data);
        return results.map((e) => EduUnit.fromJson(e)).toList()
          ..sort((a, b) => a.myOrder.compareTo(b.myOrder));
      }
    } catch (_) {}
    return [];
  }

  Future<EduUnit?> fetchUnit(int unitId) async {
    try {
      final url = Uri.parse('$_base/units/$unitId?format=json');
      final res = await http.get(url).timeout(_timeout);
      if (res.statusCode == 200) {
        final data = _object(jsonDecode(res.body));
        return data == null ? null : EduUnit.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  // ---- Lessons (Classes) ----
  Future<List<EduLesson>> fetchLessons({required int unitId}) async {
    try {
      final allLessons = <EduLesson>[];
      int page = 1;
      const maxPages = 20;
      while (true) {
        final url = Uri.parse(
            '$_base/classes?format=json&unit=$unitId&page=$page&page_size=100');
        final res = await http.get(url).timeout(const Duration(seconds: 12));
        if (res.statusCode != 200) break;
        final data = jsonDecode(res.body);
        final results = _results(data);
        if (results.isEmpty) break;
        allLessons.addAll(results.map((e) => EduLesson.fromJson(e)));
        if (data is! Map<String, dynamic> ||
            data['next'] == null ||
            page >= maxPages) {
          break;
        }
        page++;
      }
      allLessons.sort((a, b) => a.myOrder.compareTo(b.myOrder));
      return allLessons;
    } catch (_) {}
    return [];
  }

  Future<EduLesson?> fetchLesson(int lessonId) async {
    try {
      final url = Uri.parse('$_base/classes/$lessonId?format=json');
      final res = await http.get(url).timeout(_timeout);
      if (res.statusCode == 200) {
        final data = _object(jsonDecode(res.body));
        return data == null ? null : EduLesson.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  // ---- Exams ----
  Future<EduExam?> fetchExam(int examId) async {
    try {
      final url = Uri.parse('$_base/exams/$examId?format=json');
      final res = await http.get(url).timeout(_timeout);
      if (res.statusCode == 200) {
        final data = _object(jsonDecode(res.body));
        return data == null ? null : EduExam.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  Future<List<EduExam>> fetchExamIndex({
    int? levelId,
    int? semesterId,
    int? courseId,
  }) async {
    try {
      final params = <String, String>{'format': 'json'};
      if (levelId != null) params['level'] = levelId.toString();
      if (semesterId != null) params['semester'] = semesterId.toString();
      if (courseId != null) params['course'] = courseId.toString();
      final url =
          Uri.parse('$_base/exam-index').replace(queryParameters: params);
      final res = await http.get(url).timeout(_timeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final results = _results(data);
        return results.map((e) => EduExam.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  // ---- Questions for an exam ----
  Future<List<EduQuestion>> fetchQuestions({required int examId}) async {
    try {
      final allQuestions = <EduQuestion>[];
      int page = 1;
      while (true) {
        final url = Uri.parse(
            '$_base/questions?format=json&exam=$examId&page=$page&page_size=100');
        final res = await http.get(url).timeout(_timeout);
        if (res.statusCode != 200) break;
        final data = jsonDecode(res.body);
        final results = _results(data);
        allQuestions.addAll(results.map((e) => EduQuestion.fromJson(e)));
        if (data is! Map<String, dynamic> || data['next'] == null) break;
        page++;
      }
      return allQuestions;
    } catch (_) {}
    return [];
  }

  // ---- Answers for a question ----
  Future<List<EduAnswer>> fetchAnswers({required int questionId}) async {
    try {
      final url = Uri.parse(
          '$_base/answers?format=json&question=$questionId&page_size=20');
      final res = await http.get(url).timeout(_timeout);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final results = _results(data);
        return results.map((e) => EduAnswer.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  // ---- Fetch full exam with questions and answers ----
  Future<List<EduQuestion>> fetchExamWithAnswers({required int examId}) async {
    final questions = await fetchQuestions(examId: examId);
    for (final question in questions) {
      question.answers = await fetchAnswers(questionId: question.id);
    }
    return questions;
  }
}
