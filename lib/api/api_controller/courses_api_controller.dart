import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:iptv/api/api_helper.dart';
import 'package:iptv/model/courses_model.dart';
import 'package:iptv/model/levels_model.dart';
import 'package:iptv/model/semester_model.dart';

class CoursesApiController with ApiHelper {
  Future<CoursesModel?> getCourses(
      {String id = '', String semesterId = ''}) async {
    try {
      Uri url = Uri.parse(
          'https://islamic-uni.joacademy.net/courses/?format=json&semester=$semesterId&level=$id&teacher=');
      var response = await http.get(url);
      // فك تشفير النصوص باستخدام utf8
      String body = utf8.decode(response.bodyBytes);

      var jsonResponse = jsonDecode(body);
      return CoursesModel.fromJson(jsonResponse);
    } catch (e) {
      return null;
    }
  }

  Future<LevelsModel?> getLevels() async {
    try {
      Uri url =
          Uri.parse('https://islamic-uni.joacademy.net/levels/?format=json');
      var response = await http.get(url);
      // فك تشفير النصوص باستخدام utf8
      String body = utf8.decode(response.bodyBytes);

      var jsonResponse = jsonDecode(body);
      return LevelsModel.fromJson(jsonResponse);
    } catch (e) {
      return null;
    }
  }

  Future<SemesterModel?> getSemester() async {
    try {
      Uri url =
          Uri.parse('https://islamic-uni.joacademy.net/semesters/?format=json');
      var response = await http.get(url);
      // فك تشفير النصوص باستخدام utf8
      String body = utf8.decode(response.bodyBytes);

      var jsonResponse = jsonDecode(body);
      return SemesterModel.fromJson(jsonResponse);
    } catch (e) {
      return null;
    }
  }
}
