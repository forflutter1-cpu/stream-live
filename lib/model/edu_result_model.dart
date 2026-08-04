import 'package:iptv/model/edu_model_parsing.dart';

class EduResult {
  final int? id;
  final String userId;
  final int examId;
  final String examName;
  final double score;
  final double totalMarks;
  final double percentage;
  final String dateTaken;
  final Map<int, int> userAnswers; // questionId → answerId

  EduResult({
    this.id,
    required this.userId,
    required this.examId,
    required this.examName,
    required this.score,
    required this.totalMarks,
    required this.percentage,
    required this.dateTaken,
    required this.userAnswers,
  });

  bool get isPassed => percentage >= 50;

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'exam_id': examId,
      'exam_name': examName,
      'score': score,
      'total_marks': totalMarks,
      'percentage': percentage,
      'date_taken': dateTaken,
      'user_answers':
          userAnswers.entries.map((e) => '${e.key}:${e.value}').join(','),
    };
  }

  factory EduResult.fromMap(Map<String, dynamic> map) {
    final answersStr = map['user_answers'] ?? '';
    final userAnswers = <int, int>{};
    if (answersStr.isNotEmpty) {
      for (final pair in answersStr.toString().split(',')) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          userAnswers[int.tryParse(parts[0]) ?? 0] =
              int.tryParse(parts[1]) ?? 0;
        }
      }
    }
    return EduResult(
      id: eduRelatedId(map['id']),
      userId: eduString(map['user_id']),
      examId: eduInt(map['exam_id']),
      examName: eduString(map['exam_name']),
      score: eduDouble(map['score']),
      totalMarks: eduDouble(map['total_marks']),
      percentage: eduDouble(map['percentage']),
      dateTaken: eduString(map['date_taken']),
      userAnswers: userAnswers,
    );
  }
}
