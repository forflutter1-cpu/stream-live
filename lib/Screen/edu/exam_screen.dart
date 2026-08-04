import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/edu/exam_result_screen.dart';
import 'package:iptv/Widget/main_image_widget.dart';
import 'package:iptv/controller/edu_controller.dart';
import 'package:iptv/model/edu_question_model.dart';
import 'package:shimmer/shimmer.dart';

class ExamScreen extends StatefulWidget {
  final int examId;
  final String examName;

  const ExamScreen({super.key, required this.examId, required this.examName});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late EduController _edu;
  final Map<int, int> _userAnswers = {}; // questionId → answerId
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _edu = Get.isRegistered<EduController>()
        ? Get.find<EduController>()
        : Get.put(EduController());
    _edu.loadExam(examId: widget.examId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectAnswer(int questionId, int answerId) {
    setState(() {
      _userAnswers[questionId] = answerId;
    });
  }

  void _submitExam() async {
    final questions = _edu.examQuestions;
    // Check unanswered
    final unanswered =
        questions.where((q) => !_userAnswers.containsKey(q.id)).length;

    if (unanswered > 0) {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: const Color(0xFF1E2131),
          title: const Text('أسئلة غير محلولة',
              style: TextStyle(color: Colors.white)),
          content: Text(
            'تبقى $unanswered سؤال بدون إجابة. هل تريد تسليم الاختبار الآن؟',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child:
                  const Text('تراجع', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF7971E)),
              onPressed: () => Get.back(result: true),
              child: const Text('تسليم'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    final result = await _edu.submitExam(
      examId: widget.examId,
      examName: widget.examName,
      userAnswers: _userAnswers,
    );

    Get.off(() => ExamResultScreen(
          result: result,
          questions: _edu.examQuestions.toList(),
          userAnswers: _userAnswers,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D2E),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.examName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Obx(() {
              final total = _edu.examQuestions.length;
              if (total == 0) return const SizedBox();
              return Text(
                'سؤال ${_currentPage + 1} من $total',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              );
            }),
          ],
        ),
        actions: [
          Obx(() {
            final answered = _userAnswers.length;
            final total = _edu.examQuestions.length;
            return Center(
              child: Container(
                margin: const EdgeInsets.only(left: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7971E).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFF7971E).withOpacity(0.4)),
                ),
                child: Text(
                  '$answered/$total',
                  style: const TextStyle(
                      color: Color(0xFFF7971E), fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (_edu.isLoadingExam.value) {
          return _buildShimmer();
        }
        if (_edu.examQuestions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.quiz_outlined,
                      color: Colors.white38, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'لا توجد أسئلة لهذا الاختبار',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'جرّب تحديث البيانات التعليمية أو العودة لاختيار اختبار آخر.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _edu.loadExam(examId: widget.examId),
                    icon: const Icon(Icons.refresh),
                    label: const Text('تحديث'),
                  ),
                ],
              ),
            ),
          );
        }
        return Column(
          children: [
            // Progress bar
            _buildProgressBar(),
            // Questions pager
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _edu.examQuestions.length,
                itemBuilder: (ctx, i) =>
                    _buildQuestionPage(_edu.examQuestions[i], i),
              ),
            ),
            // Bottom navigation
            _buildBottomNav(),
          ],
        );
      }),
    );
  }

  Widget _buildProgressBar() {
    return Obx(() {
      final total = _edu.examQuestions.length;
      final answered = _userAnswers.length;
      return LinearProgressIndicator(
        value: total > 0 ? answered / total : 0,
        backgroundColor: Colors.white12,
        color: const Color(0xFF43E97B),
        minHeight: 4,
      );
    });
  }

  Widget _buildQuestionPage(EduQuestion question, int index) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;
        final questionContent = _buildQuestionContent(question, index);
        final answers = _buildAnswersList(question);

        if (isWide) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: questionContent),
                const SizedBox(width: 16),
                Expanded(flex: 6, child: answers),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              questionContent,
              const SizedBox(height: 18),
              answers,
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestionContent(EduQuestion question, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.4)),
          ),
          child: Text(
            'السؤال ${index + 1} • ${question.marks.toStringAsFixed(0)} درجة',
            style: const TextStyle(
                color: Color(0xFF6C63FF),
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        if (question.question.isNotEmpty)
          Text(
            question.question,
            style:
                const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
          )
        else
          const Text(
            'نص السؤال غير متوفر، راجع الصورة أو الخيارات بالأسفل.',
            style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.5),
          ),
        if (question.questionImage != null &&
            question.questionImage!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: MainImageWidget(
                image: question.questionImage,
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAnswersList(EduQuestion question) {
    if (question.answers.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2131),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: const Text(
          'لا توجد خيارات لهذا السؤال حالياً.',
          style: TextStyle(color: Colors.white60, fontSize: 13),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: question.answers
          .map((answer) => _buildAnswerOption(question, answer))
          .toList(),
    );
  }

  Widget _buildAnswerOption(EduQuestion question, EduAnswer answer) {
    final isSelected = _userAnswers[question.id] == answer.id;
    return GestureDetector(
      onTap: () => _selectAnswer(question.id, answer.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6C63FF).withOpacity(0.2)
              : const Color(0xFF1E2131),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF6C63FF) : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFF6C63FF) : Colors.white38,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (answer.answer.isNotEmpty)
                    Text(
                      answer.answer,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  if (answer.answerImage != null &&
                      answer.answerImage!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: MainImageWidget(
                          image: answer.answerImage,
                          height: 120,
                          fit: BoxFit.contain,
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
  }

  Widget _buildBottomNav() {
    final total = _edu.examQuestions.length;
    final isLast = _currentPage == total - 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1D2E),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.arrow_forward_ios,
                    color: Colors.white54, size: 14),
                label: const Text('السابق',
                    style: TextStyle(color: Colors.white54)),
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: isLast
                ? ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7971E),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('تسليم الاختبار',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    onPressed: _submitExam,
                  )
                : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.arrow_back_ios, size: 14),
                    label: const Text('التالي',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    onPressed: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1E2131),
      highlightColor: const Color(0xFF2A2D3E),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
              height: 30,
              width: 120,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12)),
          Container(
              height: 60,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 20)),
          ...List.generate(
              4,
              (_) => Container(
                  height: 60,
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 10))),
        ],
      ),
    );
  }
}
