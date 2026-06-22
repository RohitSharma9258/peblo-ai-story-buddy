import 'dart:convert';

/// Model representing a Quiz question with its options and correct answer.
class QuizModel {
  final String question;
  final List<String> options;
  final String answer;

  const QuizModel({
    required this.question,
    required this.options,
    required this.answer,
  });

  /// Factory constructor to parse [QuizModel] from a JSON map.
  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      answer: json['answer'] as String,
    );
  }

  /// Helper factory to parse [QuizModel] from a JSON string.
  factory QuizModel.fromJsonString(String jsonStr) {
    final Map<String, dynamic> data = json.decode(jsonStr) as Map<String, dynamic>;
    return QuizModel.fromJson(data);
  }

  /// Converts the [QuizModel] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'answer': answer,
    };
  }

  /// Validates whether a given option is the correct answer.
  bool isCorrect(String selectedOption) {
    return selectedOption.trim().toLowerCase() == answer.trim().toLowerCase();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizModel &&
        other.question == question &&
        other.answer == answer &&
        other.options.length == options.length;
  }

  @override
  int get hashCode => Object.hash(question, answer, options);
}
