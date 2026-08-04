import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iptv/controller/edu_controller.dart';
import 'package:iptv/model/edu_result_model.dart';

class ExamHistoryScreen extends StatefulWidget {
  const ExamHistoryScreen({super.key});

  @override
  State<ExamHistoryScreen> createState() => _ExamHistoryScreenState();
}

class _ExamHistoryScreenState extends State<ExamHistoryScreen> {
  late EduController _edu;

  @override
  void initState() {
    super.initState();
    _edu = Get.isRegistered<EduController>()
        ? Get.find<EduController>()
        : Get.put(EduController());
    _edu.loadMyResults();
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
        title: const Text('أرشيف نتائجي',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Obx(() {
        if (_edu.myResults.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined,
                    size: 72, color: Colors.white24),
                SizedBox(height: 16),
                Text(
                  'لم تؤدِ أي اختبار حتى الآن',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'نتائجك ستظهر هنا بعد تأدية الاختبارات',
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          );
        }

        // Stats summary
        final results = _edu.myResults;
        final passed = results.where((r) => r.isPassed).length;
        final avgPct = results.isEmpty
            ? 0.0
            : results.map((r) => r.percentage).reduce((a, b) => a + b) /
                results.length;

        return Column(
          children: [
            // Stats header
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem(
                      '${results.length}', 'اختبار', const Color(0xFF6C63FF)),
                  _divider(),
                  _statItem('$passed', 'ناجح', const Color(0xFF43E97B)),
                  _divider(),
                  _statItem('${results.length - passed}', 'راسب',
                      const Color(0xFFEE0979)),
                  _divider(),
                  _statItem(
                      '${avgPct.round()}%', 'المعدل', const Color(0xFFF7971E)),
                ],
              ),
            ),
            // Results list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: results.length,
                itemBuilder: (ctx, i) => _buildResultCard(results[i]),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _statItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40, color: Colors.white12);
  }

  Widget _buildResultCard(EduResult result) {
    final isPassed = result.isPassed;
    final color = isPassed ? const Color(0xFF43E97B) : const Color(0xFFEE0979);
    final date = _formatDate(result.dateTaken);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2131),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Score circle
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Text(
                '${result.percentage.round()}%',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.examName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${result.score.toStringAsFixed(0)}/${result.totalMarks.toStringAsFixed(0)} درجة',
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    Text(date,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              isPassed ? 'ناجح' : 'راسب',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }
}
