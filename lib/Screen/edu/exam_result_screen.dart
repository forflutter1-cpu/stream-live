import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/edu/exam_screen.dart';
import 'package:iptv/Widget/main_image_widget.dart';
import 'package:iptv/model/edu_question_model.dart';
import 'package:iptv/model/edu_result_model.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ExamResultScreen extends StatelessWidget {
  final EduResult result;
  final List<EduQuestion> questions;
  final Map<int, int> userAnswers;

  const ExamResultScreen({
    super.key,
    required this.result,
    required this.questions,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final isPassed = result.isPassed;
    final color = isPassed ? const Color(0xFF43E97B) : const Color(0xFFEE0979);
    final bgColor = isPassed
        ? const Color(0xFF43E97B).withOpacity(0.1)
        : const Color(0xFFEE0979).withOpacity(0.1);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: Column(
          children: [
            // Result hero section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D2E),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircularPercentIndicator(
                    radius: 80,
                    lineWidth: 12,
                    percent: (result.percentage / 100).clamp(0.0, 1.0),
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${result.percentage.round()}%',
                          style: TextStyle(
                            color: color,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isPassed ? 'ناجح' : 'راسب',
                          style: TextStyle(color: color, fontSize: 13),
                        ),
                      ],
                    ),
                    progressColor: color,
                    backgroundColor: color.withOpacity(0.15),
                    animation: true,
                    animationDuration: 1000,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    result.examName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${result.score.toStringAsFixed(0)} / ${result.totalMarks.toStringAsFixed(0)} درجة',
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon:
                          const Icon(Icons.home_rounded, color: Colors.white54),
                      label: const Text('الرئيسية',
                          style: TextStyle(color: Colors.white54)),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('إعادة',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Get.back();
                        Get.to(() => ExamScreen(
                              examId: result.examId,
                              examName: result.examName,
                            ));
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Review answers
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: questions.length,
                itemBuilder: (ctx, i) => _buildReviewCard(questions[i], i),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(EduQuestion question, int index) {
    final selectedId = userAnswers[question.id];
    final selectedAnswer = selectedId != null
        ? question.answers.firstWhereOrNull((a) => a.id == selectedId)
        : null;
    final correctAnswer = question.answers.firstWhereOrNull((a) => a.isCorrect);
    final isCorrect = selectedAnswer?.isCorrect == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2131),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selectedId == null
              ? Colors.white12
              : isCorrect
                  ? const Color(0xFF43E97B).withOpacity(0.4)
                  : const Color(0xFFEE0979).withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isCorrect
                  ? const Color(0xFF43E97B).withOpacity(0.1)
                  : selectedId == null
                      ? Colors.white.withOpacity(0.05)
                      : const Color(0xFFEE0979).withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: selectedId == null
                      ? Colors.white38
                      : isCorrect
                          ? const Color(0xFF43E97B)
                          : const Color(0xFFEE0979),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'سؤال ${index + 1}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
                Text(
                  isCorrect ? '+${question.marks.toStringAsFixed(0)}' : '0',
                  style: TextStyle(
                    color: isCorrect
                        ? const Color(0xFF43E97B)
                        : const Color(0xFFEE0979),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (question.question.isNotEmpty)
                  Text(question.question,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 14)),
                if (question.questionImage != null &&
                    question.questionImage!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: MainImageWidget(
                        image: question.questionImage,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                if (selectedId == null)
                  _answerChip('لم تجب على هذا السؤال', Colors.white38,
                      Icons.help_outline)
                else if (!isCorrect) ...[
                  _answerChip(
                    'إجابتك: ${selectedAnswer?.answer ?? ""}',
                    const Color(0xFFEE0979),
                    Icons.close,
                  ),
                  const SizedBox(height: 6),
                  _answerChip(
                    'الصحيح: ${correctAnswer?.answer ?? ""}',
                    const Color(0xFF43E97B),
                    Icons.check,
                  ),
                ] else
                  _answerChip(
                    'إجابتك صحيحة: ${selectedAnswer?.answer ?? ""}',
                    const Color(0xFF43E97B),
                    Icons.check_circle,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _answerChip(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: color, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
