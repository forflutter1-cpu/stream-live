import 'package:iptv/model/edu_model_parsing.dart';

class EduQuestion {
  final int id;
  final String question;
  final String questionType; // 'TX'=Text, 'IM'=Image
  final String? questionImage;
  final double marks;
  final int examId;
  final int? parentQuestionId;
  List<EduAnswer> answers;

  EduQuestion({
    required this.id,
    required this.question,
    required this.questionType,
    this.questionImage,
    required this.marks,
    required this.examId,
    this.parentQuestionId,
    List<EduAnswer>? answers,
  }) : answers = answers ?? [];

  factory EduQuestion.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'];
    return EduQuestion(
      id: eduInt(json['id']),
      question: eduString(json['question']),
      questionType: eduString(json['question_type'], 'TX'),
      questionImage: json['question_image']?.toString(),
      marks: eduDouble(json['marks'], 1),
      examId: eduRelatedId(json['exam']) ?? 0,
      parentQuestionId: eduRelatedId(json['parent_question']),
      answers: rawAnswers is List
          ? rawAnswers
              .whereType<Map<String, dynamic>>()
              .map(EduAnswer.fromJson)
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'question_type': questionType,
      'question_image': questionImage,
      'marks': marks,
      'exam_id': examId,
      'parent_question_id': parentQuestionId,
    };
  }

  factory EduQuestion.fromMap(Map<String, dynamic> map) {
    return EduQuestion(
      id: eduInt(map['id']),
      question: eduString(map['question']),
      questionType: eduString(map['question_type'], 'TX'),
      questionImage: map['question_image']?.toString(),
      marks: eduDouble(map['marks'], 1),
      examId: eduInt(map['exam_id']),
      parentQuestionId: eduRelatedId(map['parent_question_id']),
    );
  }
}

class EduAnswer {
  final int id;
  final String answer;
  final String? answerImage;
  final String answerType; // 'TX'=Text, 'IM'=Image
  final bool isCorrect;
  final int questionId;
  final String? hintText;

  EduAnswer({
    required this.id,
    required this.answer,
    this.answerImage,
    required this.answerType,
    required this.isCorrect,
    required this.questionId,
    this.hintText,
  });

  factory EduAnswer.fromJson(Map<String, dynamic> json) {
    return EduAnswer(
      id: eduInt(json['id']),
      answer: eduString(json['answer']),
      answerImage: json['answer_image']?.toString(),
      answerType: eduString(json['answer_type'], 'TX'),
      isCorrect: eduBool(json['is_correct']),
      questionId: eduRelatedId(json['question']) ?? 0,
      hintText: json['hint_text']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'answer': answer,
      'answer_image': answerImage,
      'answer_type': answerType,
      'is_correct': isCorrect ? 1 : 0,
      'question_id': questionId,
      'hint_text': hintText,
    };
  }

  factory EduAnswer.fromMap(Map<String, dynamic> map) {
    return EduAnswer(
      id: eduInt(map['id']),
      answer: eduString(map['answer']),
      answerImage: map['answer_image']?.toString(),
      answerType: eduString(map['answer_type'], 'TX'),
      isCorrect: eduBool(map['is_correct']),
      questionId: eduInt(map['question_id']),
      hintText: map['hint_text']?.toString(),
    );
  }
}
