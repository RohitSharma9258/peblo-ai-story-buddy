import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_state.dart';
import '../models/quiz_model.dart';
import '../services/tts_service.dart';
import '../services/quiz_repository.dart';
import '../utils/haptic_feedback_helper.dart';
import 'quiz_repository_provider.dart';

/// Provider for the [TtsService] dependency.
final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = AppTtsService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// StateNotifier that acts as the single controller for the application flow.
/// It coordinates audio narration (TTS) and the interactive quiz gameplay.
class AppFlowNotifier extends StateNotifier<AppState> {
  final TtsService _ttsService;
  final QuizRepository _quizRepository;

  AppFlowNotifier({
    required TtsService ttsService,
    required QuizRepository quizRepository,
  })  : _ttsService = ttsService,
        _quizRepository = quizRepository,
        super(AppState.initial()) {
    _initializeTtsCallbacks();
    _loadQuizAsset();
  }

  /// Sets up callbacks for the TTS speech execution flow
  void _initializeTtsCallbacks() {
    _ttsService.setCallbacks(
      onStart: () {
        // Transition: preparing ➔ active speech
        state = state.copyWith(
          status: AppFlowStatus.playing,
          mood: BuddyMood.speaking,
          errorMessage: null,
        );
      },
      onComplete: () {
        // Transition: narration finished ➔ show quiz dynamically
        state = state.copyWith(
          status: AppFlowStatus.quizVisible,
          mood: BuddyMood.idle,
          selectedAnswer: null,
        );
      },
      onError: (errorMsg) {
        // Transition: error occured ➔ show error state & sad buddy
        state = state.copyWith(
          status: AppFlowStatus.error,
          mood: BuddyMood.sad,
          errorMessage: errorMsg,
        );
      },
    );
  }

  /// Loads the quiz JSON content asynchronously from the Repository
  Future<void> _loadQuizAsset() async {
    try {
      final quizData = await _quizRepository.fetchQuiz();
      state = state.copyWith(quiz: quizData);
    } catch (e) {
      state = state.copyWith(
        status: AppFlowStatus.error,
        mood: BuddyMood.sad,
        errorMessage: "Could not load quiz questions: $e",
      );
    }
  }

  /// Initiates story reading
  Future<void> startNarration(String storyText) async {
    // Ensure quiz data is loaded before starting
    if (state.quiz == null) {
      await _loadQuizAsset();
    }

    state = state.copyWith(
      status: AppFlowStatus.loading,
      mood: BuddyMood.idle,
      errorMessage: null,
    );

    // Speak story via the service layer
    await _ttsService.speak(storyText);
  }

  /// Stops TTS speech playback and resets state to idle
  Future<void> stopNarration() async {
    await _ttsService.stop();
    state = state.copyWith(
      status: AppFlowStatus.idle,
      mood: BuddyMood.idle,
      selectedAnswer: null,
    );
  }

  /// Validates user selection in the quiz
  Future<void> submitAnswer(String selectedOption) async {
    final quiz = state.quiz;
    if (quiz == null || state.status == AppFlowStatus.success) return;

    state = state.copyWith(selectedAnswer: selectedOption);

    if (quiz.isCorrect(selectedOption)) {
      // Correct selection: Trigger haptic success feedback and transition status to success
      await HapticFeedbackHelper.success();
      state = state.copyWith(
        status: AppFlowStatus.success,
        mood: BuddyMood.happy,
      );
    } else {
      // Incorrect selection: Trigger haptic failure, increment shake counts, and update mood
      await HapticFeedbackHelper.failure();
      state = state.copyWith(
        mood: BuddyMood.sad,
        shakeTriggerCount: state.shakeTriggerCount + 1,
      );

      // Revert the Buddy back to a neutral/idle mood after a brief delay so the child can try again
      Future.delayed(const Duration(milliseconds: 1600), () {
        // Ensure the status hasn't transitioned to success or idle in the meantime
        if (state.status == AppFlowStatus.quizVisible) {
          state = state.copyWith(mood: BuddyMood.idle);
        }
      });
    }
  }

  /// Resets the game to start over
  void resetAppFlow() {
    _ttsService.stop();
    state = state.copyWith(
      status: AppFlowStatus.idle,
      mood: BuddyMood.idle,
      selectedAnswer: null,
      errorMessage: null,
    );
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }
}

/// Global provider exposing the unified app flow state
final appFlowProvider = StateNotifierProvider<AppFlowNotifier, AppState>((ref) {
  final ttsService = ref.watch(ttsServiceProvider);
  final quizRepository = ref.watch(quizRepositoryProvider);
  return AppFlowNotifier(
    ttsService: ttsService,
    quizRepository: quizRepository,
  );
});
