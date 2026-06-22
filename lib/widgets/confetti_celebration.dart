import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_flow_provider.dart';
import '../models/app_state.dart';

/// Overlay widget that monitors [appFlowProvider] and plays a confetti celebration on success.
class ConfettiCelebration extends ConsumerStatefulWidget {
  const ConfettiCelebration({super.key});

  @override
  ConsumerState<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends ConsumerState<ConfettiCelebration> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to changes in the App Flow state to trigger/stop particles
    ref.listen<AppState>(appFlowProvider, (previous, current) {
      if (current.status == AppFlowStatus.success) {
        _confettiController.play();
      } else {
        _confettiController.stop();
      }
    });

    // PERFORMANCE OPTIMIZATION:
    // Confetti particles are drawn dynamically on a Canvas at 60 FPS.
    // Wrapping it in a [RepaintBoundary] ensures that the high-frequency rendering
    // of individual color rectangles/circles does not trigger layout recalculations
    // or repaint events on the underlying page structure, maintaining a smooth 60 FPS.
    return RepaintBoundary(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConfettiWidget(
          confettiController: _confettiController,
          blastDirection: pi / 2, // Cast downward
          maxBlastForce: 15,
          minBlastForce: 5,
          emissionFrequency: 0.05,
          numberOfParticles: 20,
          gravity: 0.15,
          shouldLoop: false,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple,
            Colors.yellow,
          ],
        ),
      ),
    );
  }
}
