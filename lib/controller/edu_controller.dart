import 'package:get/get.dart';
import 'package:iptv/api/api_controller/edu_api_controller.dart';
import 'package:iptv/database/database_helper.dart';
import 'package:iptv/model/edu_course_model.dart';
import 'package:iptv/model/edu_exam_model.dart';
import 'package:iptv/model/edu_lesson_model.dart';
import 'package:iptv/model/edu_level_model.dart';
import 'package:iptv/model/edu_question_model.dart';
import 'package:iptv/model/edu_result_model.dart';
import 'package:iptv/model/edu_semester_model.dart';
import 'package:iptv/model/edu_unit_model.dart';
import 'package:iptv/shared_preferences/shared_pref_controller.dart';

class EduController extends GetxController {
  static EduController get to => Get.find();

  final _db = DatabaseHelper.instance;
  final _api = EduApiController();

  // ---- State ----
  final RxList<EduLevel> levels = <EduLevel>[].obs;
  final RxList<EduSemester> semesters = <EduSemester>[].obs;
  final RxList<EduCourse> courses = <EduCourse>[].obs;
  final RxList<EduUnit> units = <EduUnit>[].obs;
  final RxList<EduLesson> lessons = <EduLesson>[].obs;
  final RxList<EduExam> ministerExams = <EduExam>[].obs;
  final RxList<EduQuestion> examQuestions = <EduQuestion>[].obs;
  final RxList<EduResult> myResults = <EduResult>[].obs;

  final RxBool isLoadingLevels = false.obs;
  final RxBool isLoadingCourses = false.obs;
  final RxBool isLoadingUnits = false.obs;
  final RxBool isLoadingLessons = false.obs;
  final RxBool isLoadingExam = false.obs;
  final RxBool isLoadingMinisterExams = false.obs;

  final Rx<EduExam?> currentExam = Rx<EduExam?>(null);
  final RxInt selectedLevelId = (-1).obs;
  final RxInt selectedSemesterId = (-1).obs;

  Future<void> _cacheNestedCourseData(List<EduCourse> courseList) async {
    final nestedUnits = courseList.expand((course) => course.units).toList();
    if (nestedUnits.isEmpty) return;
    await _db.upsertEduUnits(nestedUnits);
    await _cacheNestedUnitData(nestedUnits);
  }

  Future<void> _cacheNestedUnitData(List<EduUnit> unitList) async {
    final nestedLessons = unitList.expand((unit) => unit.lessons).toList();
    if (nestedLessons.isNotEmpty) {
      await _db.upsertEduLessons(nestedLessons);
    }
  }

  // ---- Levels & Semesters ----
  Future<void> loadLevels() async {
    isLoadingLevels.value = true;
    // Try local first
    final local = await _db.getEduLevels();
    if (local.isNotEmpty) {
      levels.value = local;
    } else {
      final remote = await _api.fetchLevels();
      if (remote.isNotEmpty) {
        await _db.upsertEduLevels(remote);
        levels.value = remote;
      }
    }
    isLoadingLevels.value = false;

    // Load semesters too
    final localSem = await _db.getEduSemesters();
    if (localSem.isNotEmpty) {
      semesters.value = localSem;
    } else {
      final remoteSem = await _api.fetchSemesters();
      if (remoteSem.isNotEmpty) {
        await _db.upsertEduSemesters(remoteSem);
        semesters.value = remoteSem;
      }
    }
  }

  Future<EduLevel?> getLevelDetails(int levelId) async {
    final local = await _db.getEduLevelById(levelId);
    if (local != null) return local;

    final remote = await _api.fetchLevel(levelId);
    if (remote != null) {
      await _db.upsertEduLevels([remote]);
    }
    return remote;
  }

  Future<void> refreshLevels() async {
    final remote = await _api.fetchLevels();
    if (remote.isNotEmpty) {
      await _db.upsertEduLevels(remote);
      levels.value = remote;
    }
    final remoteSem = await _api.fetchSemesters();
    if (remoteSem.isNotEmpty) {
      await _db.upsertEduSemesters(remoteSem);
      semesters.value = remoteSem;
    }
  }

  // ---- Courses ----
  Future<void> loadCourses({required int levelId, int? semesterId}) async {
    isLoadingCourses.value = true;
    selectedLevelId.value = levelId;
    if (semesterId != null) selectedSemesterId.value = semesterId;
    courses.clear();

    try {
      final local =
          await _db.getEduCourses(levelId: levelId, semesterId: semesterId);
      if (local.isNotEmpty) {
        courses.value = local;
        return;
      }

      final remote =
          await _api.fetchCourses(levelId: levelId, semesterId: semesterId);
      if (remote.isNotEmpty) {
        await _db.upsertEduCourses(remote);
        await _cacheNestedCourseData(remote);
        courses.value = remote;
      }
    } finally {
      isLoadingCourses.value = false;
    }
  }

  Future<EduCourse?> getCourseDetails(int courseId) async {
    final local = await _db.getEduCourseById(courseId);
    if (local != null) return local;

    final remote = await _api.fetchCourse(courseId);
    if (remote != null) {
      await _db.upsertEduCourses([remote]);
      await _cacheNestedCourseData([remote]);
    }
    return remote;
  }

  Future<void> refreshCourses({required int levelId, int? semesterId}) async {
    isLoadingCourses.value = true;
    try {
      final remote =
          await _api.fetchCourses(levelId: levelId, semesterId: semesterId);
      if (remote.isNotEmpty) {
        await _db.upsertEduCourses(remote);
        await _cacheNestedCourseData(remote);
        courses.value = remote;
      }
    } finally {
      isLoadingCourses.value = false;
    }
  }

  // ---- Units ----
  Future<void> loadUnits({required int courseId}) async {
    isLoadingUnits.value = true;
    units.clear();

    try {
      final local = await _db.getEduUnits(courseId: courseId);
      if (local.isNotEmpty) {
        units.value = local;
        return;
      }

      final remote = await _api.fetchUnits(courseId: courseId);
      if (remote.isNotEmpty) {
        await _db.upsertEduUnits(remote);
        await _cacheNestedUnitData(remote);
        units.value = remote;
      }
    } finally {
      isLoadingUnits.value = false;
    }
  }

  Future<void> loadCourseUnits(EduCourse course) async {
    isLoadingUnits.value = true;
    units.clear();

    try {
      if (course.unitIds.isNotEmpty) {
        final local = await _db.getEduUnitsByIds(course.unitIds);
        if (local.isNotEmpty) {
          units.value = local;
          return;
        }
      }

      await loadUnits(courseId: course.id);
    } finally {
      isLoadingUnits.value = false;
    }
  }

  Future<EduUnit?> getUnitDetails(int unitId) async {
    final local = await _db.getEduUnitById(unitId);
    if (local != null) return local;

    final remote = await _api.fetchUnit(unitId);
    if (remote != null) {
      await _db.upsertEduUnits([remote]);
      await _cacheNestedUnitData([remote]);
    }
    return remote;
  }

  // ---- Lessons ----
  Future<void> loadLessons({required int unitId}) async {
    isLoadingLessons.value = true;
    lessons.clear();

    try {
      final local = await _db.getEduLessons(unitId: unitId);
      if (local.isNotEmpty) {
        lessons.value = local;
        return;
      }

      final remote = await _api.fetchLessons(unitId: unitId).timeout(
            const Duration(seconds: 16),
            onTimeout: () => <EduLesson>[],
          );
      if (remote.isNotEmpty) {
        await _db.upsertEduLessons(remote);
        lessons.value = remote;
      } else {
        final nestedLocal = await _db.getEduLessons(unitId: unitId);
        if (nestedLocal.isNotEmpty) lessons.value = nestedLocal;
      }
    } finally {
      isLoadingLessons.value = false;
    }
  }

  Future<EduLesson?> getLessonDetails(int lessonId) async {
    final local = await _db.getEduLessonById(lessonId);
    if (local != null) return local;

    final remote = await _api.fetchLesson(lessonId);
    if (remote != null) {
      await _db.upsertEduLessons([remote]);
    }
    return remote;
  }

  Future<void> markLessonWatched(int lessonId) async {
    await _db.markLessonWatched(lessonId, true);
    final idx = lessons.indexWhere((l) => l.id == lessonId);
    if (idx >= 0) {
      lessons[idx].isWatched = true;
      lessons.refresh();
    }
  }

  // ---- Exam & Questions ----
  Future<void> loadExam({required int examId}) async {
    isLoadingExam.value = true;
    examQuestions.clear();
    currentExam.value = null;

    try {
      var exam = await _db.getEduExam(examId);
      if (exam == null) {
        final remoteExam = await _api.fetchExam(examId);
        if (remoteExam != null) {
          await _db.upsertEduExam(remoteExam);
          exam = remoteExam;
        }
      }
      exam ??= EduExam.fallback(examId);
      currentExam.value = exam;

      // Check local first
      final localQ = await _db.getEduQuestions(examId: examId);
      if (localQ.isNotEmpty) {
        for (final q in localQ) {
          q.answers = await _db.getEduAnswers(questionId: q.id);
        }
        examQuestions.value = localQ;
      } else {
        // Fetch from API
        final remote = await _api.fetchExamWithAnswers(examId: examId);
        if (remote.isNotEmpty) {
          await _db.upsertEduExam(exam);
          await _db.upsertEduQuestions(remote);
          for (final q in remote) {
            await _db.upsertEduAnswers(q.answers);
          }
          examQuestions.value = remote;
        }
      }
    } finally {
      isLoadingExam.value = false;
    }
  }

  Future<EduExam?> getExamDetails(int examId) async {
    final local = await _db.getEduExam(examId);
    if (local != null) return local;

    final remote = await _api.fetchExam(examId);
    if (remote != null) {
      await _db.upsertEduExam(remote);
      return remote;
    }

    final fallback = EduExam.fallback(examId);
    await _db.upsertEduExam(fallback);
    return fallback;
  }

  Future<void> loadMinisterExams({
    int? levelId,
    int? semesterId,
    int? courseId,
    bool force = false,
  }) async {
    if (!force && ministerExams.isNotEmpty) return;
    isLoadingMinisterExams.value = true;
    try {
      final remote = await _api.fetchExamIndex(
        levelId: levelId,
        semesterId: semesterId,
        courseId: courseId,
      );
      ministerExams.value = remote
          .where((exam) => exam.questionCount > 0)
          .toList()
        ..sort((a, b) => a.id.compareTo(b.id));
    } finally {
      isLoadingMinisterExams.value = false;
    }
  }

  // ---- Submit Exam & Save Result ----
  Future<EduResult> submitExam({
    required int examId,
    required String examName,
    required Map<int, int> userAnswers, // questionId → answerId
  }) async {
    double score = 0;
    double totalMarks = 0;

    for (final q in examQuestions) {
      totalMarks += q.marks;
      final selectedAnswerId = userAnswers[q.id];
      if (selectedAnswerId != null) {
        final correct =
            q.answers.any((a) => a.id == selectedAnswerId && a.isCorrect);
        if (correct) score += q.marks;
      }
    }

    final percentage = totalMarks > 0 ? (score / totalMarks) * 100 : 0.0;
    final userId = SharedPrefController().name.isNotEmpty
        ? SharedPrefController().name
        : 'guest';

    final result = EduResult(
      userId: userId,
      examId: examId,
      examName: examName,
      score: score,
      totalMarks: totalMarks,
      percentage: percentage,
      dateTaken: DateTime.now().toIso8601String(),
      userAnswers: userAnswers,
    );

    await _db.saveEduResult(result);
    await loadMyResults();
    return result;
  }

  // ---- Results ----
  Future<void> loadMyResults() async {
    final userId = SharedPrefController().name.isNotEmpty
        ? SharedPrefController().name
        : 'guest';
    myResults.value = await _db.getEduResults(userId: userId);
  }

  // ---- Progress helpers ----
  int watchedLessonsCount(int unitId) {
    return lessons.where((l) => l.unitId == unitId && l.isWatched).length;
  }

  double lessonProgress(int unitId) {
    final unitLessons = lessons.where((l) => l.unitId == unitId).toList();
    if (unitLessons.isEmpty) return 0;
    return unitLessons.where((l) => l.isWatched).length / unitLessons.length;
  }
}
