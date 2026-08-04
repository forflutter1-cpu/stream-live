import 'package:iptv/model/stream_model.dart';
import 'package:iptv/model/stream_series_model.dart';
import 'package:iptv/model/edu_course_model.dart';
import 'package:iptv/model/edu_lesson_model.dart';
import 'package:iptv/model/edu_level_model.dart';
import 'package:iptv/model/edu_unit_model.dart';

String routeSlug(String? value) {
  final source = (value ?? '').trim().toLowerCase();
  final slug = source
      .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06ff]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  return slug.isEmpty ? 'watch' : slug;
}

String liveRoute(StreamModel stream) =>
    '/live/${stream.streamId}/${routeSlug(stream.name)}';

String movieRoute(StreamModel stream) =>
    '/movie/${stream.streamId}/${routeSlug(stream.name)}';

String seriesRoute(StreamSeriesModel stream) =>
    '/series/${stream.streamId}/${routeSlug(stream.name)}';

String seriesRouteFromStream(StreamModel stream) =>
    '/series/${stream.streamId}/${routeSlug(stream.name)}';

String educationRoute() => '/edu';

String eduLevelRoute(EduLevel level) =>
    '/level/${level.id}/${routeSlug(level.name)}';

String eduCourseRoute(EduCourse course) =>
    '/edu/course/${course.id}/${routeSlug(course.name)}';

String eduUnitRoute(EduUnit unit) =>
    '/edu/unit/${unit.id}/${routeSlug(unit.name)}';

String eduLessonRoute(EduLesson lesson) =>
    '/edu/lesson/${lesson.id}/${routeSlug(lesson.name)}';

String eduExamRoute(int examId, String name) =>
    '/edu/exam/$examId/${routeSlug(name)}';
