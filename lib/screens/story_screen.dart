import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_flow_provider.dart';
import '../models/app_state.dart';
import '../widgets/buddy_character.dart';
import '../widgets/story_card.dart';
import '../widgets/quiz_panel.dart';
import '../widgets/confetti_celebration.dart';
import '../utils/app_theme.dart';

/// Single-screen kid-friendly layout. Integrates TTS speech control,
/// buddy mood reactions, and dynamic, animated quiz rendering.
class StoryScreen extends ConsumerWidget {
  const StoryScreen({super.key});

  static const String storyContent =
      "Once upon a time, a clever little robot named Pip lost his shiny blue gear in the Whispering Woods...";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // PERFORMANCE OPTIMIZATION:
    // Instead of calling `ref.watch(appFlowProvider)` which rebuilds the entire screen on any state change
    // (such as shake counter increments or minor option taps), we decompose the screen into sub-listeners.
    // By using the `select` syntax, each widget only rebuilds when its specific target value changes.

    return Scaffold(
      body: Stack(
        children: [
          // Background soft pastel gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.backgroundColor,
                  Color(0xFFFFF6E5),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // App Bar / Playful Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Peblo 🤖",
                          style: AppTheme.headingStyle,
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
                          tooltip: "Restart Adventure",
                          onPressed: () => ref.read(appFlowProvider.notifier).resetAppFlow(),
                        ),
                      ],
                    ),
                  ),

                  // 1. Cute Buddy Character
                  // PERFORMANCE OPTIMIZATION: Only rebuilds when the mood changes.
                  Consumer(
                    builder: (context, ref, child) {
                      final mood = ref.watch(appFlowProvider.select((state) => state.mood));
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                        child: BuddyCharacter(mood: mood),
                      );
                    },
                  ),

                  // 2. Story Card
                  const StoryCard(text: storyContent),

                  const SizedBox(height: 20),

                  // 3. Narrative Audio Controller (Play / Loading / Error states)
                  // PERFORMANCE OPTIMIZATION: Rebuilds only when the flow status or error message changes.
                  Consumer(
                    builder: (context, ref, child) {
                      final status = ref.watch(appFlowProvider.select((state) => state.status));
                      final errorMsg = ref.watch(appFlowProvider.select((state) => state.errorMessage));

                      if (status == AppFlowStatus.quizVisible || status == AppFlowStatus.success) {
                        return const SizedBox.shrink();
                      }

                      final isAudioLoading = status == AppFlowStatus.loading;
                      final isAudioPlaying = status == AppFlowStatus.playing;
                      final isAudioError = status == AppFlowStatus.error;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            if (isAudioLoading)
                              const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                                ),
                              ),
                            
                            if (isAudioError) ...[
                              // Clean error UI with warning accent
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.wrongColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.wrongColor, width: 2),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: AppTheme.wrongColor),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Oops! Pip lost his voice connection. ${errorMsg ?? ''}",
                                        style: const TextStyle(
                                          color: AppTheme.textColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().shake(duration: 400.ms),
                              const SizedBox(height: 16),
                            ],

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: (isAudioLoading || isAudioPlaying)
                                    ? null // Disable the button during loading/narration
                                    : () {
                                        ref.read(appFlowProvider.notifier).startNarration(storyContent);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isAudioError ? AppTheme.accentColor : AppTheme.primaryColor,
                                  foregroundColor: isAudioError ? AppTheme.textColor : Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isAudioError ? Icons.replay : Icons.volume_up,
                                      color: isAudioError ? AppTheme.textColor : Colors.white,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      isAudioError ? "Retry Reading" : "Read Me a Story",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // 4. Dynamic Quiz Panel
                  // PERFORMANCE OPTIMIZATION: Only rebuilds when transitioning into/out of quiz visibility.
                  Consumer(
                    builder: (context, ref, child) {
                      final status = ref.watch(appFlowProvider.select((state) => state.status));
                      final isQuizActive = status == AppFlowStatus.quizVisible;

                      if (!isQuizActive) {
                        return const SizedBox.shrink();
                      }

                      // ANIMATION REQUIREMENT: Quiz Reveal (Fade + Slide transition after narration)
                      return const QuizPanel()
                          .animate()
                          .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                          .slideY(begin: 0.15, end: 0.0, duration: 500.ms, curve: Curves.easeOutBack);
                    },
                  ),

                  // 5. Success Card Banner
                  // PERFORMANCE OPTIMIZATION: Only rebuilds when transitioning to success.
                  Consumer(
                    builder: (context, ref, child) {
                      final isSuccess = ref.watch(appFlowProvider.select((state) => state.status == AppFlowStatus.success));

                      if (!isSuccess) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Column(
                          children: [
                            // Show correct answers layout also to let child review their success!
                            const QuizPanel(),
                            const SizedBox(height: 12),
                            // Success celebratory card banner
                            Card(
                              color: AppTheme.correctColor.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.0),
                                side: const BorderSide(color: AppTheme.correctColor, width: 3),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  children: [
                                    const Text(
                                      "🎉 Awesome Job! 🎉",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.correctColor,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      "You found the shiny blue gear for Pip! He is super happy now!",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () => ref.read(appFlowProvider.notifier).resetAppFlow(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.correctColor,
                                        shadowColor: AppTheme.correctColor.withOpacity(0.3),
                                      ),
                                      child: const Text("Play Again"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .bounce(duration: 600.ms)
                          .scale(begin: const Offset(0.85, 0.85));
                    },
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          
          // 6. Confetti celebration particle emitter
          const ConfettiCelebration(),
        ],
      ),
    );
  }
}
