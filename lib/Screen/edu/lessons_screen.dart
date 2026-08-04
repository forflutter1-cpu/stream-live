import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/edu/lesson_player_screen.dart';
import 'package:iptv/controller/edu_controller.dart';
import 'package:iptv/database/database_helper.dart';
import 'package:iptv/model/edu_lesson_model.dart';
import 'package:iptv/model/edu_unit_model.dart';
import 'package:iptv/utils/friendly_routes.dart';
import 'package:shimmer/shimmer.dart';

class LessonsScreen extends StatefulWidget {
  final EduUnit unit;
  const LessonsScreen({super.key, required this.unit});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  late EduController _edu;
  final _db = DatabaseHelper.instance;
  Timer? _loadingTimer;
  List<EduLesson> _screenLessons = const <EduLesson>[];
  bool _screenLoading = true;
  bool _loadingTimedOut = false;
  int _loadRun = 0;

  @override
  void initState() {
    super.initState();
    _edu = Get.isRegistered<EduController>()
        ? Get.find<EduController>()
        : Get.put(EduController());
    _loadLessons();
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLessons() async {
    final run = ++_loadRun;
    _loadingTimer?.cancel();
    setState(() {
      _loadingTimedOut = false;
      _screenLoading = true;
      _screenLessons = widget.unit.lessons
          .where((lesson) => lesson.unitId == widget.unit.id)
          .toList();
    });

    _loadingTimer = Timer(const Duration(seconds: 8), () {
      if (!mounted) return;
      final hasLessons = _currentUnitLessons().isNotEmpty;
      if (_edu.isLoadingLessons.value && !hasLessons) {
        _edu.isLoadingLessons.value = false;
        setState(() {
          _screenLoading = false;
          _loadingTimedOut = true;
        });
      }
    });

    try {
      final local = await _db.getEduLessons(unitId: widget.unit.id).timeout(
            const Duration(seconds: 2),
            onTimeout: () => <EduLesson>[],
          );
      if (!mounted || run != _loadRun) return;
      if (local.isNotEmpty) {
        setState(() {
          _screenLessons = local;
          _screenLoading = false;
        });
        unawaited(_edu
            .loadLessons(unitId: widget.unit.id)
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {},
            )
            .catchError((_) {}));
        return;
      }

      await _edu.loadLessons(unitId: widget.unit.id).timeout(
            const Duration(seconds: 10),
            onTimeout: () {},
          );
      if (!mounted || run != _loadRun) return;
      final controllerLessons = _edu.lessons
          .where((lesson) => lesson.unitId == widget.unit.id)
          .toList();
      setState(() {
        _screenLessons = controllerLessons;
        _screenLoading = false;
        _loadingTimedOut = controllerLessons.isEmpty;
      });
    } catch (_) {
      if (!mounted || run != _loadRun) return;
      setState(() {
        _screenLoading = false;
        _loadingTimedOut = _screenLessons.isEmpty;
      });
    } finally {
      _loadingTimer?.cancel();
    }
  }

  List<EduLesson> _currentUnitLessons() {
    if (_screenLessons.isNotEmpty) return _screenLessons;

    final controllerLessons =
        _edu.lessons.where((l) => l.unitId == widget.unit.id).toList();
    if (controllerLessons.isNotEmpty) return controllerLessons;

    final nestedLessons =
        widget.unit.lessons.where((l) => l.unitId == widget.unit.id).toList();
    if (nestedLessons.isNotEmpty) return nestedLessons;

    return const <EduLesson>[];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D2E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.unit.name,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Obx(() {
        final unitLessons = _currentUnitLessons();
        if ((_screenLoading || _edu.isLoadingLessons.value) &&
            unitLessons.isEmpty) {
          return _buildShimmer();
        }
        if (unitLessons.isEmpty) {
          return _buildEmpty(timedOut: _loadingTimedOut);
        }
        final watched = unitLessons.where((l) => l.isWatched).length;

        return Column(
          children: [
            // Progress header
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E2131), Color(0xFF2A2D3E)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: unitLessons.isEmpty
                              ? 0
                              : watched / unitLessons.length,
                          backgroundColor: Colors.white12,
                          color: const Color(0xFF43E97B),
                          strokeWidth: 6,
                        ),
                      ),
                      Text(
                        '${unitLessons.isEmpty ? 0 : ((watched / unitLessons.length) * 100).round()}%',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('التقدم في الوحدة',
                            style:
                                TextStyle(color: Colors.white60, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          '$watched من ${unitLessons.length} درس مكتمل',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Lessons list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: unitLessons.length,
                itemBuilder: (ctx, i) =>
                    _buildLessonCard(unitLessons[i], i, unitLessons),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLessonCard(
      EduLesson lesson, int index, List<EduLesson> allLessons) {
    final isYt = lesson.isYoutube;
    final hasVideo = lesson.videoFile != null && lesson.videoFile!.isNotEmpty;

    return GestureDetector(
      onTap: () async {
        final initialIndex =
            allLessons.indexWhere((item) => item.id == lesson.id);
        await Get.to(
          () => LessonPlayerScreen(
            lesson: lesson,
            allLessons: allLessons,
            initialIndex: initialIndex >= 0 ? initialIndex : index,
          ),
          routeName: eduLessonRoute(lesson),
          arguments: lesson,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: lesson.isWatched
              ? const Color(0xFF1A2E1A)
              : const Color(0xFF1E2131),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: lesson.isWatched
                ? const Color(0xFF43E97B).withValues(alpha: 0.3)
                : Colors.white12,
          ),
        ),
        child: Row(
          children: [
            // Number / play icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: lesson.isWatched
                      ? [const Color(0xFF43E97B), const Color(0xFF0F9B58)]
                      : isYt
                          ? [const Color(0xFFFF0000), const Color(0xFF8B0000)]
                          : [const Color(0xFF6C63FF), const Color(0xFF3F3D8E)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                lesson.isWatched
                    ? Icons.check_rounded
                    : isYt
                        ? Icons.play_arrow_rounded
                        : hasVideo
                            ? Icons.videocam_rounded
                            : Icons.open_in_new,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.name,
                    style: TextStyle(
                      color: lesson.isWatched
                          ? const Color(0xFF43E97B)
                          : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _typeBadge(isYt
                          ? 'YouTube'
                          : hasVideo
                              ? 'فيديو'
                              : 'رابط'),
                      if (lesson.downloadLink != null &&
                          lesson.downloadLink!.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.download_rounded,
                            size: 12, color: Colors.white38),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '${index + 1}',
              style: const TextStyle(color: Colors.white24, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: const TextStyle(color: Colors.white38, fontSize: 10)),
    );
  }

  Widget _buildShimmer() {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final itemCount = isLandscape ? 3 : 6;
    final itemHeight = isLandscape ? 48.0 : 68.0;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      itemCount: itemCount + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                'جاري تحميل الدروس...',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }

        final rowIndex = index - 1;
        return Shimmer.fromColors(
          baseColor: const Color(0xFF202331),
          highlightColor: const Color(0xFF343849),
          child: Container(
            height: itemHeight,
            margin: const EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(isLandscape ? 8 : 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: isLandscape ? 34 : 42,
                  height: isLandscape ? 34 : 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FractionallySizedBox(
                        widthFactor: rowIndex.isEven ? 0.62 : 0.78,
                        alignment: AlignmentDirectional.centerEnd,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FractionallySizedBox(
                        widthFactor: 0.28,
                        alignment: AlignmentDirectional.centerEnd,
                        child: Container(
                          height: 7,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmpty({bool timedOut = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            timedOut ? Icons.cloud_off_rounded : Icons.videocam_off_rounded,
            size: 64,
            color: Colors.white24,
          ),
          const SizedBox(height: 12),
          Text(
            timedOut ? 'تعذر تحميل الدروس حالياً' : 'لا توجد دروس لهذه الوحدة',
            style: const TextStyle(color: Colors.white54),
          ),
          if (timedOut) ...[
            const SizedBox(height: 8),
            const Text(
              'تحقق من الاتصال أو أعد المحاولة',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _loadLessons,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF6C63FF),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('إعادة تحميل'),
            ),
          ],
        ],
      ),
    );
  }
}
