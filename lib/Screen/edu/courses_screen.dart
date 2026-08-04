import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/edu/exam_screen.dart';
import 'package:iptv/Screen/edu/units_screen.dart';
import 'package:iptv/controller/edu_controller.dart';
import 'package:iptv/model/edu_course_model.dart';
import 'package:iptv/model/edu_exam_model.dart';
import 'package:iptv/model/edu_level_model.dart';
import 'package:iptv/model/edu_semester_model.dart';
import 'package:iptv/utils/friendly_routes.dart';
import 'package:shimmer/shimmer.dart';

class CoursesScreen extends StatefulWidget {
  final EduLevel level;
  const CoursesScreen({super.key, required this.level});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  late EduController _edu;
  int _selectedSemesterId = -1;
  int _selectedExamSemesterId = -1;
  int _selectedExamCourseId = -1;
  bool _showUnclassifiedExams = false;

  @override
  void initState() {
    super.initState();
    _edu = Get.isRegistered<EduController>()
        ? Get.find<EduController>()
        : Get.put(EduController());
    if (_edu.semesters.isEmpty || _edu.levels.isEmpty) {
      _edu.loadLevels();
    }
    _edu.loadCourses(levelId: widget.level.id);
  }

  List<EduCourse> get _filteredCourses {
    final source = _selectedSemesterId == -1
        ? _edu.courses
        : _edu.courses
            .where((c) => c.semesterId == _selectedSemesterId)
            .toList();
    if (_selectedSemesterId != -1) return source;
    return _mergeRepeatedCourses(source);
  }

  List<EduCourse> _mergeRepeatedCourses(List<EduCourse> source) {
    final grouped = <String, List<EduCourse>>{};
    for (final course in source) {
      final key = _courseMergeKey(course.name);
      grouped.putIfAbsent(key, () => <EduCourse>[]).add(course);
    }

    final merged = grouped.values.map((items) {
      if (items.length == 1) return items.first;
      items.sort((a, b) => a.myOrder.compareTo(b.myOrder));
      final first = items.first;
      final unitIds = <int>{
        for (final item in items) ...item.unitIds,
      }.toList();
      final examIds = <int>{
        for (final item in items) ...item.examIds,
      }.toList();
      return EduCourse(
        id: first.id,
        name: first.name,
        levelId: first.levelId,
        semesterId: null,
        image: first.image,
        myOrder: first.myOrder,
        unitIds: unitIds,
        examIds: examIds,
        units: [
          for (final item in items) ...item.units,
        ],
      );
    }).toList()
      ..sort((a, b) => a.myOrder.compareTo(b.myOrder));

    return merged;
  }

  String _courseMergeKey(String name) {
    return name
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(' - ', '-')
        .toLowerCase();
  }

  bool get _isExamMode {
    final semester =
        _edu.semesters.firstWhereOrNull((sem) => sem.id == _selectedSemesterId);
    return semester != null &&
        (semester.id == 48 || semester.name.contains('امتحانات'));
  }

  void _loadFilteredExamIndex() {
    _edu.loadMinisterExams(
      levelId: _showUnclassifiedExams ? null : widget.level.id,
      semesterId: _showUnclassifiedExams || _selectedExamSemesterId == -1
          ? null
          : _selectedExamSemesterId,
      courseId: _showUnclassifiedExams || _selectedExamCourseId == -1
          ? null
          : _selectedExamCourseId,
      force: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF1A1D2E),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            title: Text(
              widget.level.name,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white70),
                onPressed: () => _edu.refreshCourses(levelId: widget.level.id),
              ),
            ],
          ),
          SliverToBoxAdapter(child: _buildSemesterChips()),
          Obx(() {
            if (_isExamMode) return _buildExamSliver();

            if (_edu.isLoadingCourses.value) {
              return SliverToBoxAdapter(child: _buildShimmer());
            }
            final courses = _filteredCourses;
            if (courses.isEmpty) {
              return SliverToBoxAdapter(child: _buildEmpty());
            }
            return SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  final isLandscape = MediaQuery.of(context).orientation ==
                      Orientation.landscape;
                  final compactCards = isLandscape && width >= 560;
                  final columns = width >= 1100
                      ? 5
                      : width >= 820
                          ? 4
                          : width >= 560
                              ? 3
                              : 2;
                  return SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _buildCourseCard(courses[i], i),
                      childCount: courses.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      mainAxisExtent: compactCards ? 150 : null,
                      childAspectRatio: width >= 560 ? 1.05 : 0.92,
                    ),
                  );
                },
              ),
            );
          }),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildSemesterChips() {
    return Obx(() {
      if (_edu.semesters.isEmpty) return const SizedBox();
      final sems = <EduSemester?>[null, ..._edu.semesters];
      return Container(
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: sems.length,
          itemBuilder: (ctx, i) {
            final sem = sems[i];
            final selected = sem == null
                ? _selectedSemesterId == -1
                : _selectedSemesterId == sem.id;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedSemesterId = sem == null ? -1 : sem.id;
                if (_isExamMode) {
                  _showUnclassifiedExams = false;
                  _loadFilteredExamIndex();
                }
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(left: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF3F3D8E)])
                      : null,
                  color: selected ? null : const Color(0xFF1E2131),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: selected ? const Color(0xFF6C63FF) : Colors.white24,
                  ),
                ),
                child: Text(
                  sem == null ? 'الكل' : sem.name,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white60,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildCourseCard(EduCourse course, int index) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final headerHeight = isLandscape ? 62.0 : 86.0;
    final colors = [
      [const Color(0xFF6C63FF), const Color(0xFF3F3D8E)],
      [const Color(0xFF00C9FF), const Color(0xFF0072B5)],
      [const Color(0xFF43E97B), const Color(0xFF0F9B58)],
      [const Color(0xFFF7971E), const Color(0xFFDA5B11)],
      [const Color(0xFFEE0979), const Color(0xFF8B0049)],
      [const Color(0xFF4776E6), const Color(0xFF8E54E9)],
    ];
    final gradColors = colors[index % colors.length];

    return GestureDetector(
      onTap: () => Get.to(
        () => UnitsScreen(course: course),
        routeName: eduCourseRoute(course),
        arguments: course,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E2131),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course image / gradient header
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              child: course.image != null && course.image!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: course.image!,
                      height: headerHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          _courseGradientHeader(gradColors, headerHeight),
                    )
                  : _courseGradientHeader(gradColors, headerHeight),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      course.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _badge(Icons.layers, '${course.unitIds.length} وحدة'),
                        const Icon(Icons.arrow_forward_ios,
                            size: 12, color: Colors.white30),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamSliver() {
    return SliverToBoxAdapter(
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildExamFilters(),
            if (_edu.isLoadingMinisterExams.value)
              _buildShimmer()
            else if (_edu.ministerExams.isEmpty)
              _buildExamEmpty()
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final columns = width >= 1100
                      ? 5
                      : width >= 820
                          ? 4
                          : width >= 560
                              ? 3
                              : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: _edu.ministerExams.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: width >= 560 ? 1.35 : 1.15,
                    ),
                    itemBuilder: (context, i) =>
                        _buildExamCard(_edu.ministerExams[i], i),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamFilters() {
    final examSemesters =
        _edu.semesters.where((sem) => sem.id != 48).toList(growable: false);
    final courses = _filteredExamCourses;
    final isFiltered = !_showUnclassifiedExams &&
        (_selectedExamSemesterId != -1 || _selectedExamCourseId != -1);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF171A26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _filterLabel('الصف', widget.level.name),
                _filterLabel(
                  _showUnclassifiedExams ? 'النوع' : 'النتائج',
                  _showUnclassifiedExams
                      ? 'اختبارات عامة'
                      : '${_edu.ministerExams.length} اختبار',
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 720;
                final fieldWidth = wide
                    ? (constraints.maxWidth - 24) / 3
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  alignment: WrapAlignment.end,
                  children: [
                    SizedBox(
                      width: fieldWidth,
                      child: _filterDropdown(
                        title: 'الفصل',
                        value: _selectedExamSemesterId,
                        allLabel: 'كل الفصول',
                        items: examSemesters
                            .map((s) => MapEntry(s.id, s.name))
                            .toList(),
                        onChanged: (id) {
                          setState(() {
                            _showUnclassifiedExams = false;
                            _selectedExamSemesterId = id;
                            _selectedExamCourseId = -1;
                          });
                          _loadFilteredExamIndex();
                        },
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: _filterDropdown(
                        title: 'المادة',
                        value: _selectedExamCourseId,
                        allLabel: 'كل المواد',
                        items: courses
                            .map((c) => MapEntry(c.id, _courseLabel(c)))
                            .toList(),
                        onChanged: (id) {
                          setState(() {
                            _showUnclassifiedExams = false;
                            _selectedExamCourseId = id;
                          });
                          _loadFilteredExamIndex();
                        },
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: isFiltered
                                ? const Color(0xFF6C63FF)
                                : Colors.white24,
                          ),
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _showUnclassifiedExams = false;
                            _selectedExamSemesterId = -1;
                            _selectedExamCourseId = -1;
                          });
                          _loadFilteredExamIndex();
                        },
                        icon: const Icon(Icons.filter_alt_off_rounded),
                        label: const Text('إعادة ضبط الفلاتر'),
                      ),
                    ),
                  ],
                );
              },
            ),
            if (_showUnclassifiedExams) ...[
              const SizedBox(height: 10),
              _noticeChip(
                'يتم عرض بنك الاختبارات العام غير المصنف حسب الصف أو المادة.',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _filterDropdown({
    required String title,
    required int value,
    required String allLabel,
    required List<MapEntry<int, String>> items,
    required ValueChanged<int> onChanged,
  }) {
    final options = [MapEntry(-1, allLabel), ...items];
    final safeValue = options.any((option) => option.key == value) ? value : -1;

    return DropdownButtonFormField<int>(
      initialValue: safeValue,
      isExpanded: true,
      dropdownColor: const Color(0xFF1E2131),
      iconEnabledColor: Colors.white70,
      decoration: InputDecoration(
        labelText: title,
        labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF1E2131),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6C63FF)),
        ),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 13),
      items: options
          .map(
            (option) => DropdownMenuItem<int>(
              value: option.key,
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                option.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
          )
          .toList(),
      onChanged: (id) {
        if (id != null) onChanged(id);
      },
    );
  }

  List<EduCourse> get _filteredExamCourses {
    final courses = _selectedExamSemesterId == -1
        ? _edu.courses
        : _edu.courses
            .where((course) => course.semesterId == _selectedExamSemesterId)
            .toList();

    final seen = <String>{};
    return courses.where((course) {
      final key = '${course.semesterId}:${course.name.trim()}';
      return seen.add(key);
    }).toList();
  }

  String _courseLabel(EduCourse course) {
    if (_selectedExamSemesterId != -1) return course.name;

    final semester =
        _edu.semesters.firstWhereOrNull((item) => item.id == course.semesterId);
    return semester == null ? course.name : '${course.name} - ${semester.name}';
  }

  Widget _buildExamEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.quiz_outlined, size: 64, color: Colors.white24),
            const SizedBox(height: 12),
            const Text(
              'لا توجد اختبارات مرتبطة بهذه الفلاتر من المصدر حالياً',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                setState(() => _showUnclassifiedExams = true);
                _loadFilteredExamIndex();
              },
              icon: const Icon(Icons.public_rounded),
              label: const Text('عرض الاختبارات العامة غير المصنفة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterLabel(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2131),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white12),
          ),
          child: Text('$title: $value',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _noticeChip(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2347),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: Color(0xFFB8B2FF), size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Color(0xFFCDC9FF), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamCard(EduExam exam, int index) {
    final colors = [
      [const Color(0xFF6C63FF), const Color(0xFF3F3D8E)],
      [const Color(0xFF00C9FF), const Color(0xFF0072B5)],
      [const Color(0xFF43E97B), const Color(0xFF0F9B58)],
      [const Color(0xFFF7971E), const Color(0xFFDA5B11)],
      [const Color(0xFFEE0979), const Color(0xFF8B0049)],
      [const Color(0xFF4776E6), const Color(0xFF8E54E9)],
    ][index % 6];

    return GestureDetector(
      onTap: () => Get.to(
        () => ExamScreen(examId: exam.id, examName: exam.name),
        routeName: eduExamRoute(exam.id, exam.name),
        arguments: {'examId': exam.id, 'examName': exam.name},
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.quiz_rounded, color: Colors.white, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (exam.courseName != null &&
                    exam.courseName!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    exam.courseName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _badge(Icons.help_outline_rounded,
                        '${exam.questionCount} سؤال'),
                    if (exam.classification == 'auto')
                      _badge(Icons.auto_awesome_rounded, 'مصنف')
                    else
                      _badge(Icons.public_rounded, 'عام'),
                    const Icon(Icons.arrow_forward_ios,
                        size: 12, color: Colors.white70),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _courseGradientHeader(List<Color> colors, [double height = 86]) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
      ),
      child: const Center(
        child: Icon(Icons.book, color: Colors.white54, size: 36),
      ),
    );
  }

  Widget _badge(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.white38),
        const SizedBox(width: 3),
        Text(text, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }

  Widget _buildShimmer() {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final itemHeight = isLandscape ? 74.0 : 104.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              'جاري تحميل المواد...',
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
                  height: itemHeight,
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
                        width: itemHeight - 24,
                        height: itemHeight - 24,
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
                              widthFactor: index.isEven ? 0.58 : 0.76,
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
                              widthFactor: index.isEven ? 0.34 : 0.45,
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

  Widget _buildEmpty({
    IconData icon = Icons.menu_book,
    String text = 'لا توجد مواد',
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(icon, size: 64, color: Colors.white24),
            const SizedBox(height: 12),
            Text(text, style: const TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}
