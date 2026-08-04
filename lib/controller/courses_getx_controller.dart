import 'package:get/get.dart';
import 'package:iptv/api/api_controller/courses_api_controller.dart';
import 'package:iptv/model/courses_model.dart' as co;
import 'package:iptv/model/levels_model.dart';
import 'package:iptv/model/semester_model.dart' as se;

class CoursesGetxController extends GetxController {
  RxList<Results> results = <Results>[].obs;
  RxList<se.Results> seResults = <se.Results>[].obs;
  RxList<co.Results> coResults = <co.Results>[].obs;

  RxBool coLoading = false.obs;
  RxBool leLoading = false.obs;
  RxBool seLoading = false.obs;
  RxInt selectedLevelId = (-1).obs;
  RxInt selectedSemesterId = (-1).obs;

  void getLevels() async {
    leLoading.value = true;
    LevelsModel? levelsModel = await CoursesApiController().getLevels();
    if (levelsModel != null) {
      results.addAll(levelsModel.results!);
    }
    leLoading.value = false;
  }

  void getSemester() async {
    seLoading.value = true;
    se.SemesterModel? semesterModel =
        await CoursesApiController().getSemester();
    if (semesterModel != null) {
      seResults.addAll(semesterModel.results!);
    }
    seLoading.value = false;
  }

  void getCourses({String id = '', String semesterId = ''}) async {
    coLoading.value = true;
    co.CoursesModel? coursesModel =
        await CoursesApiController().getCourses(id: id, semesterId: semesterId);
    if (coursesModel != null) {
      coResults.clear();
      coResults.addAll(coursesModel.results!);
    }
    coLoading.value = false;
  }

  void changeSelectedLevel(int id) {
    Future.delayed(const Duration(milliseconds: 500), () {
    selectedLevelId.value = id;
    getCourses(
        id: selectedLevelId.value >= 0 ? selectedLevelId.value.toString() : '',
        semesterId: selectedSemesterId.value >= 0
            ? selectedSemesterId.value.toString()
            : '');
    });
  }

  void changeSelectedSemester(int id, {bool doGetCourse = true}) {
    Future.delayed(const Duration(milliseconds: 500), () {
    selectedSemesterId.value = id;
    if (doGetCourse) {
      getCourses(
          id: selectedLevelId.value >= 0
              ? selectedLevelId.value.toString()
              : '',
          semesterId: selectedSemesterId.value >= 0
              ? selectedSemesterId.value.toString()
              : '');
    }
    });
  }
}
