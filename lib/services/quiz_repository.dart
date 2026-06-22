import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quiz_model.dart';

/// Abstract definition for the Quiz data layer
abstract class QuizRepository {
  Future<QuizModel> fetchQuiz();
}

/// Loads the quiz JSON from Flutter assets with safety fallbacks
class AssetQuizRepository implements QuizRepository {
  final String _assetPath;

  const AssetQuizRepository({String assetPath = 'assets/data/quiz.json'})
      : _assetPath = assetPath;

  @override
  Future<QuizModel> fetchQuiz() async {
    try {
      // Load raw JSON string from the asset bundle
      final jsonString = await rootBundle.loadString(_assetPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return QuizModel.fromJson(jsonData);
    } catch (e) {
      // Fallback data structure to ensure app never crashes
      return const QuizModel(
        question: "What colour was Pip the Robot's lost gear?",
        options: ["Red", "Green", "Blue", "Yellow"],
        answer: "Blue",
      );
    }
  }
}
