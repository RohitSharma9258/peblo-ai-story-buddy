import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_flow_provider.dart';
import '../models/app_state.dart';
import '../utils/app_theme.dart';

/// Dynamic quiz panel that renders the questions and choices dynamically.
/// Automatically supports 3, 4, 5 or more options without code modifications.
class QuizPanel extends ConsumerWidget {
  const QuizPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // PERFORMANCE OPTIMIZATION: We selectively read only the values needed to rebuild.
    // However, since the quiz panel is small, we watch the global state.
    final appState = ref.watch(appFlowProvider);
    final quiz = appState.quiz;

    if (quiz == null) {
      return const SizedBox.shrink();
    }

    final isCorrectAnswerFound = appState.status == AppFlowStatus.success;

    // PERFORMANCE OPTIMIZATION: Map options to widgets dynamically without hardcoding.
    // This scales automatically to support any list length.
    final optionWidgets = quiz.options.map((option) {
      final isSelected = appState.selectedAnswer == option;
      final isOptionCorrect = quiz.isCorrect(option);
      
      Color buttonBgColor = Colors.white;
      Color borderOutlineColor = const Color(0xFFE8DFD8);
      Widget suffixIcon = const SizedBox.shrink();

      if (isCorrectAnswerFound && isOptionCorrect) {
        // Highlight correct option in green
        buttonBgColor = AppTheme.correctColor.withOpacity(0.15);
        borderOutlineColor = AppTheme.correctColor;
        suffixIcon = const Icon(Icons.check_circle, color: AppTheme.correctColor, size: 26);
      } else if (isSelected) {
        if (appState.mood == BuddyMood.sad) {
          // Highlight incorrect selection in red
          buttonBgColor = AppTheme.wrongColor.withOpacity(0.15);
          borderOutlineColor = AppTheme.wrongColor;
          suffixIcon = const Icon(Icons.cancel, color: AppTheme.wrongColor, size: 26);
        } else if (isCorrectAnswerFound) {
          buttonBgColor = AppTheme.correctColor.withOpacity(0.15);
          borderOutlineColor = AppTheme.correctColor;
          suffixIcon = const Icon(Icons.check_circle, color: AppTheme.correctColor, size: 26);
        }
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: InkWell(
          onTap: isCorrectAnswerFound
              ? null // Block clicking further once the question is answered correctly
              : () => ref.read(appFlowProvider.notifier).submitAnswer(option),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: buttonBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderOutlineColor,
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  offset: Offset(0, 4),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    option,
                    style: AppTheme.optionStyle,
                  ),
                ),
                suffixIcon,
              ],
            ),
          ),
        ),
      );
    }).toList();

    Widget quizBody = Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: AppTheme.accentColor,
          width: 3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text("🤔", style: TextStyle(fontSize: 26)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  quiz.question,
                  style: AppTheme.questionStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...optionWidgets,
        ],
      ),
    );

    // Apply shake animation if the mood is sad (indicates wrong answer feedback)
    return Animate(
      key: ValueKey(appState.shakeTriggerCount),
      effects: appState.mood == BuddyMood.sad
          ? [
              const ShakeEffect(
                duration: Duration(milliseconds: 500),
                hz: 10,
                offset: Offset(8, 0),
              )
            ]
          : [],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: quizBody,
      ),
    );
  }
}
