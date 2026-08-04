import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/edu/exam_screen.dart';
import 'package:iptv/Screen/edu/lessons_screen.dart';
import 'package:iptv/controller/edu_controller.dart';
import 'package:iptv/model/edu_course_model.dart';
import 'package:iptv/model/edu_exam_model.dart';
import 'package:iptv/model/edu_unit_model.dart';
import 'package:iptv/utils/friendly_routes.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shimmer/shimmer.dart';

class UnitsScreen extends StatefulWidget {
  final EduCourse course;
  const UnitsScreen({super.key, required this.course});

  @override
  State<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends State<UnitsScreen> {
  late EduController _edu;

  @override
  void initState() {
    super.initState();
    _edu = Get.isRegistered<EduController>()
        ? Get.find<EduController>()
        : Get.put(EduController());
    _edu.loadCourseUnits(widget.course);
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
          widget.course.name,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Obx(() {
        if (_edu.isLoadingUnits.value) return _buildShimmer();
        if (_edu.units.isEmpty) return _buildEmpty();
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;
            if (!isWide) {
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _edu.units.length,
                itemBuilder: (ctx, i) => _buildUnitCard(_edu.units[i], i),
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _edu.units.length,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: constraints.maxWidth >= 1100 ? 420 : 360,
                mainAxisExtent: 150,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (ctx, i) => _buildUnitCard(_edu.units[i], i),
            );
          },
        );
      }),
    );
  }

  Future<void> _openExam(EduUnit unit) async {
    if (unit.examIds.isEmpty) return;

    if (unit.examIds.length == 1) {
      final examId = unit.examIds.first;
      final exam = await _edu.getExamDetails(examId);
      _goToExam(examId, exam?.name ?? unit.name);
      return;
    }

    Get.bottomSheet(
      _ExamPickerSheet(
        unitName: unit.name,
        examIds: unit.examIds,
        loadExam: _edu.getExamDetails,
        onSelected: _goToExam,
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void _goToExam(int examId, String examName) {
    Get.to(
      () => ExamScreen(examId: examId, examName: examName),
      routeName: eduExamRoute(examId, examName),
      arguments: {
        'examId': examId,
        'examName': examName,
      },
    );
  }

  Widget _buildUnitCard(EduUnit unit, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2131),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(12, 6, 8, 2),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF3F3D8E)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),
            title: Text(
              unit.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  if (unit.classIds.isNotEmpty)
                    _infoBadge(Icons.play_circle_outline,
                        '${unit.classIds.length} درس'),
                  if (unit.examIds.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _infoBadge(
                        Icons.quiz_outlined, '${unit.examIds.length} اختبار'),
                  ],
                ],
              ),
            ),
          ),
          // Progress bar placeholder
          Obx(() {
            final progress = _edu.lessonProgress(unit.id);
            if (progress == 0) return const SizedBox();
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: LinearPercentIndicator(
                percent: progress.clamp(0.0, 1.0),
                lineHeight: 6,
                backgroundColor: Colors.white12,
                progressColor: const Color(0xFF43E97B),
                barRadius: const Radius.circular(4),
                padding: EdgeInsets.zero,
                trailing: Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ),
            );
          }),
          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: _actionButton(
                    icon: Icons.play_arrow_rounded,
                    label: 'الدروس',
                    color: const Color(0xFF6C63FF),
                    onTap: () => Get.to(
                      () => LessonsScreen(unit: unit),
                      routeName: eduUnitRoute(unit),
                      arguments: unit,
                    ),
                  ),
                ),
                if (unit.examIds.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _actionButton(
                      icon: Icons.quiz_rounded,
                      label: unit.examIds.length > 1 ? 'الاختبارات' : 'اختبار',
                      color: const Color(0xFFF7971E),
                      onTap: () => _openExam(unit),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.white38),
        const SizedBox(width: 3),
        Text(text, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              'جاري تحميل الوحدات...',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Shimmer.fromColors(
            baseColor: const Color(0xFF202331),
            highlightColor: const Color(0xFF343849),
            child: Column(
              children: List.generate(
                isLandscape ? 4 : 5,
                (index) => Container(
                  height: isLandscape ? 78 : 112,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
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
                              widthFactor: index.isEven ? 0.54 : 0.74,
                              alignment: AlignmentDirectional.centerEnd,
                              child: Container(
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            FractionallySizedBox(
                              widthFactor: 0.36,
                              alignment: AlignmentDirectional.centerEnd,
                              child: Container(
                                height: 9,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: Colors.white24),
          SizedBox(height: 12),
          Text('لا توجد وحدات لهذه المادة',
              style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}

class _ExamPickerSheet extends StatelessWidget {
  final String unitName;
  final List<int> examIds;
  final Future<EduExam?> Function(int examId) loadExam;
  final void Function(int examId, String examName) onSelected;

  const _ExamPickerSheet({
    required this.unitName,
    required this.examIds,
    required this.loadExam,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1D2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.quiz_rounded,
                      color: Color(0xFFF7971E), size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'اختبارات $unitName',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.close, color: Colors.white54),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                itemCount: examIds.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final examId = examIds[index];
                  return FutureBuilder<EduExam?>(
                    future: loadExam(examId),
                    builder: (context, snapshot) {
                      final name = snapshot.data?.name ?? 'اختبار ${index + 1}';
                      return InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          Get.back();
                          onSelected(examId, name);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F1117),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7971E)
                                      .withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.assignment_rounded,
                                    color: Color(0xFFF7971E), size: 18),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'رقم الاختبار $examId',
                                      style: const TextStyle(
                                        color: Colors.white38,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded,
                                  color: Colors.white24, size: 14),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
