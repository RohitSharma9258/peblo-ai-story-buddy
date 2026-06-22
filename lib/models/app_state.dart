import 'package:flutter/foundation.dart';
import 'quiz_model.dart';

/// Represents the global flow status of the application
enum AppFlowStatus {
  idle,         // Story screen loaded, waiting for narration start
  loading,      // TTS engine preparing speech
  playing,      // Speech audio is actively playing
  quizVisible,  // Audio narration finished; multiple-choice quiz is revealed
  success,      // Quiz correct answer selected; showing happy animations
  error,        // TTS or quiz loading error occurred
}

/// Represents the emotional expression state of Peblo (Pip the Robot)
enum BuddyMood {
  idle,      // Default float animation
  speaking,  // Lips/mouth/ears moving to voice
  happy,     // Joyful bounce & spin celebration
  sad,       // Concerned tilt/shake expression on wrong selection or error
}

/// Immutable state container representing the global state of the Peblo application
@immutable
class AppState {
  final AppFlowStatus status;
  final BuddyMood mood;
  final QuizModel? quiz;
  final String? selectedAnswer;
  final int shakeTriggerCount;
  final String? errorMessage;

  const AppState({
    required this.status,
    required this.mood,
    this.quiz,
    this.selectedAnswer,
    required this.shakeTriggerCount,
    this.errorMessage,
  });

  /// Factory constructors for creating initial states
  factory AppState.initial() {
    return const AppState(
      status: AppFlowStatus.idle,
      mood: BuddyMood.idle,
      quiz: null,
      selectedAnswer: null,
      shakeTriggerCount: 0,
      errorMessage: null,
    );
  }

  /// Copies the state object with modified parameters
  AppState copyWith({
    AppFlowStatus? status,
    BuddyMood? mood,
    QuizModel? quiz,
    String? selectedAnswer,
    int? shakeTriggerCount,
    String? errorMessage,
  }) {
    return AppState(
      status: status ?? this.status,
      mood: mood ?? this.mood,
      quiz: quiz ?? this.quiz,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      shakeTriggerCount: shakeTriggerCount ?? this.shakeTriggerCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppState &&
        other.status == status &&
        other.mood == mood &&
        other.quiz == quiz &&
        other.selectedAnswer == selectedAnswer &&
        other.shakeTriggerCount == shakeTriggerCount &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(
        status,
        mood,
        quiz,
        selectedAnswer,
        shakeTriggerCount,
        errorMessage,
      );
}
