import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/edu/courses_screen.dart';
import 'package:iptv/Screen/edu/exam_history_screen.dart';
import 'package:iptv/controller/edu_controller.dart';
import 'package:iptv/model/edu_level_model.dart';
import 'package:iptv/utils/friendly_routes.dart';
import 'package:shimmer/shimmer.dart';

class TeachScreen extends StatefulWidget {
  const TeachScreen({super.key});

  @override
  State<TeachScreen> createState() => _TeachScreenState();
}

class _TeachScreenState extends State<TeachScreen> {
  late EduController _edu;

  // ألوان متدرجة لكل صف
  static const List<List<Color>> _levelGradients = [
    [Color(0xFF6C63FF), Color(0xFF3F3D8E)],
    [Color(0xFF00C9FF), Color(0xFF0072B5)],
    [Color(0xFF43E97B), Color(0xFF0F9B58)],
    [Color(0xFFF7971E), Color(0xFFDA5B11)],
    [Color(0xFFEE0979), Color(0xFF8B0049)],
    [Color(0xFF4776E6), Color(0xFF8E54E9)],
    [Color(0xFF11998E), Color(0xFF38EF7D)],
    [Color(0xFFFC5C7D), Color(0xFF6A3093)],
    [Color(0xFFF953C6), Color(0xFF8B2FC9)],
    [Color(0xFF3494E6), Color(0xFFEC6EAD)],
    [Color(0xFF0F3443), Color(0xFF34E89E)],
    [Color(0xFFDAE2F8), Color(0xFF6979F8)],
  ];

  static const List<IconData> _levelIcons = [
    Icons.looks_one_rounded,
    Icons.looks_two_rounded,
    Icons.looks_3_rounded,
    Icons.looks_4_rounded,
    Icons.looks_5_rounded,
    Icons.looks_6_rounded,
    Icons.filter_7_rounded,
    Icons.filter_8_rounded,
    Icons.filter_9_rounded,
    Icons.school,
    Icons.star,
    Icons.workspace_premium,
  ];

  @override
  void initState() {
    super.initState();
    _edu = Get.put(EduController());
    _edu.loadLevels();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isLandscape = media.orientation == Orientation.landscape;
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildSemesterFilter()),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  16, isLandscape ? 2 : 8, 16, isLandscape ? 2 : 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'اختر صفك الدراسي',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isLandscape ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => Get.to(() => const ExamHistoryScreen()),
                    icon: const Icon(Icons.history,
                        color: Color(0xFF6C63FF), size: 18),
                    label: const Text('نتائجي',
                        style: TextStyle(color: Color(0xFF6C63FF))),
                  ),
                ],
              ),
            ),
          ),
          Obx(() {
            if (_edu.isLoadingLevels.value) {
              return SliverToBoxAdapter(child: _buildShimmer());
            }
            if (_edu.levels.isEmpty) {
              return SliverToBoxAdapter(child: _buildEmpty());
            }
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  final compactCards = isLandscape && width >= 620;
                  final columns = width >= 1100
                      ? 6
                      : width >= 820
                          ? 5
                          : width >= 620
                              ? 4
                              : width >= 420
                                  ? 3
                                  : 2;
                  return SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _buildLevelCard(_edu.levels[i], i),
                      childCount: _edu.levels.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      mainAxisExtent: compactCards ? 108 : null,
                      childAspectRatio: width >= 620 ? 1.55 : 1.35,
                    ),
                  );
                },
              ),
            );
          }),
          SliverToBoxAdapter(child: SizedBox(height: isLandscape ? 14 : 32)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final media = MediaQuery.of(context);
    final isLandscape = media.orientation == Orientation.landscape;
    final expandedHeight = isLandscape ? 86.0 : 176.0;
    return SliverAppBar(
      expandedHeight: expandedHeight,
      toolbarHeight: isLandscape ? 44 : kToolbarHeight,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF1A1D2E),
      title: const Text(
        'التعليم',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        expandedTitleScale: 1,
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1D2E), Color(0xFF6C63FF)],
                ),
              ),
            ),
            Positioned(
              right: -40,
              top: -30,
              child: Container(
                width: isLandscape ? 150 : 200,
                height: isLandscape ? 150 : 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -40,
              child: Container(
                width: isLandscape ? 96 : 150,
                height: isLandscape ? 96 : 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: isLandscape ? 8 : 36,
              left: 16,
              right: 16,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _statChip(Icons.school, '18 صف'),
                  _statChip(Icons.book, '181 مادة'),
                  _statChip(Icons.quiz, 'اختبارات'),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => _edu.refreshLevels(),
          tooltip: 'تحديث',
        ),
      ],
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSemesterFilter() {
    return Obx(() {
      if (_edu.semesters.isEmpty) return const SizedBox();
      final isLandscape =
          MediaQuery.of(context).orientation == Orientation.landscape;
      return Container(
        height: isLandscape ? 38 : 50,
        margin: EdgeInsets.symmetric(vertical: isLandscape ? 4 : 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: _edu.semesters.length + 1,
          itemBuilder: (ctx, i) {
            final isAll = i == 0;
            final sem = isAll ? null : _edu.semesters[i - 1];
            final selected = isAll
                ? _edu.selectedSemesterId.value == -1
                : _edu.selectedSemesterId.value == sem!.id;
            return GestureDetector(
              onTap: () {
                _edu.selectedSemesterId.value = isAll ? -1 : sem!.id;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(left: 8),
                padding: EdgeInsets.symmetric(
                    horizontal: isLandscape ? 14 : 18,
                    vertical: isLandscape ? 5 : 8),
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
                  isAll ? 'الكل' : sem!.name,
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

  Widget _buildLevelCard(EduLevel level, int index) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final gradColors = _levelGradients[index % _levelGradients.length];
    final icon = _levelIcons[index % _levelIcons.length];
    return GestureDetector(
      onTap: () => Get.to(
        () => CoursesScreen(level: level),
        routeName: eduLevelRoute(level),
        arguments: level,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradColors,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: gradColors[0].withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -15,
              top: -15,
              child: Container(
                width: isLandscape ? 48 : 80,
                height: isLandscape ? 48 : 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isLandscape ? 8 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: Colors.white, size: isLandscape ? 20 : 26),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'ادخل للمواد',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1E2131),
      highlightColor: const Color(0xFF2A2D3E),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        itemCount: 6,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width >= 620 ? 4 : 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio:
              MediaQuery.of(context).size.width >= 620 ? 1.55 : 1.35,
        ),
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(Icons.wifi_off, size: 64, color: Colors.white30),
            SizedBox(height: 16),
            Text(
              'تعذّر تحميل المستويات\nتأكد من الاتصال بالإنترنت',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
