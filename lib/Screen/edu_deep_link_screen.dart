import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/SplashScreen.dart';
import 'package:iptv/Screen/edu/courses_screen.dart';
import 'package:iptv/Screen/edu/exam_screen.dart';
import 'package:iptv/Screen/edu/lesson_player_screen.dart';
import 'package:iptv/Screen/edu/lessons_screen.dart';
import 'package:iptv/Screen/edu/teach_screen.dart';
import 'package:iptv/Screen/edu/units_screen.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/app_material/app_styles.dart';
import 'package:iptv/controller/edu_controller.dart';
import 'package:iptv/database/database_helper.dart';
import 'package:iptv/model/edu_course_model.dart';
import 'package:iptv/model/edu_lesson_model.dart';
import 'package:iptv/model/edu_level_model.dart';
import 'package:iptv/model/edu_unit_model.dart';
import 'package:iptv/shared_preferences/shared_pref_controller.dart';
import 'package:iptv/utils/circal_animated.dart';
import 'package:iptv/utils/deep_link_redirect.dart';

class EduDeepLinkScreen extends StatefulWidget {
  final String type;
  final String id;

  const EduDeepLinkScreen({
    super.key,
    required this.type,
    required this.id,
  });

  @override
  State<EduDeepLinkScreen> createState() => _EduDeepLinkScreenState();
}

class _EduDeepLinkScreenState extends State<EduDeepLinkScreen> {
  late final Future<Widget> _targetFuture;

  @override
  void initState() {
    super.initState();
    _targetFuture = _resolveTarget();
  }

  Future<Widget> _resolveTarget() async {
    if (SharedPrefController().name.isEmpty ||
        SharedPrefController().password.isEmpty) {
      await saveCurrentRouteAsPending();
      return const SplashScreen();
    }

    final edu = Get.isRegistered<EduController>()
        ? Get.find<EduController>()
        : Get.put(EduController());
    final db = DatabaseHelper.instance;
    final id = int.tryParse(widget.id);

    if (widget.type == 'home') {
      return const TeachScreen();
    }
    if (id == null) {
      return const _EduNotFoundScreen();
    }

    switch (widget.type) {
      case 'level':
        var level = Get.arguments is EduLevel
            ? Get.arguments as EduLevel
            : await edu.getLevelDetails(id);
        if (level == null) {
          await edu.loadLevels();
          level = await db.getEduLevelById(id);
        }
        return level == null
            ? const _EduNotFoundScreen()
            : CoursesScreen(level: level);

      case 'course':
        final course = Get.arguments is EduCourse
            ? Get.arguments as EduCourse
            : await edu.getCourseDetails(id);
        return course == null
            ? const _EduNotFoundScreen()
            : UnitsScreen(course: course);

      case 'unit':
        final unit = Get.arguments is EduUnit
            ? Get.arguments as EduUnit
            : await edu.getUnitDetails(id);
        return unit == null
            ? const _EduNotFoundScreen()
            : LessonsScreen(unit: unit);

      case 'lesson':
        final lesson = Get.arguments is EduLesson
            ? Get.arguments as EduLesson
            : await edu.getLessonDetails(id);
        if (lesson == null) return const _EduNotFoundScreen();
        final lessons = await db.getEduLessons(unitId: lesson.unitId);
        final index = lessons.indexWhere((item) => item.id == lesson.id);
        return LessonPlayerScreen(
          lesson: lesson,
          allLessons: lessons.isEmpty ? [lesson] : lessons,
          initialIndex: index >= 0 ? index : 0,
        );

      case 'exam':
        if (Get.arguments is Map) {
          final args = Get.arguments as Map;
          final examId = int.tryParse(args['examId'].toString()) ?? id;
          final examName = args['examName']?.toString() ?? 'اختبار';
          return ExamScreen(examId: examId, examName: examName);
        }
        final exam = await edu.getExamDetails(id);
        return ExamScreen(examId: id, examName: exam?.name ?? 'اختبار');
    }

    return const _EduNotFoundScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _targetFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        }
        if (snapshot.hasError) {
          return const _EduNotFoundScreen();
        }
        return const Scaffold(
          backgroundColor: Color(0xFF0F1117),
          body: Center(child: AnimatedCircle()),
        );
      },
    );
  }
}

class _EduNotFoundScreen extends StatelessWidget {
  const _EduNotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.link_off, color: AppColors.redColor, size: 56),
              const SizedBox(height: 16),
              Text(
                'الرابط التعليمي غير متوفر حالياً',
                textAlign: TextAlign.center,
                style: AppStyles().font18(
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.offAllNamed('/edu'),
                child: const Text('التعليم'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
