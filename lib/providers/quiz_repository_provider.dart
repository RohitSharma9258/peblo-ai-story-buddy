import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/quiz_repository.dart';

/// Provider exposing the concrete implementation of [QuizRepository]
final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return const AssetQuizRepository();
});
