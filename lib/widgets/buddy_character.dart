import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/app_state.dart';
import '../utils/app_theme.dart';

/// Renders the AI Buddy (Pip the Robot) that dynamically responds with kids-oriented
/// micro-animations depending on its current [BuddyMood].
class BuddyCharacter extends StatelessWidget {
  final BuddyMood mood;

  const BuddyCharacter({
    super.key,
    required this.mood,
  });

  @override
  Widget build(BuildContext context) {
    // PERFORMANCE OPTIMIZATION:
    // We wrap the animated character inside a [RepaintBoundary].
    // High-frequency animations (floating, pulsing, spinning, and bouncing) trigger repaint requests.
    // By separating this widget into its own render layer, Flutter does not repaint the rest of the
    // static screen (like the card, text, and scaffold background) at 60 FPS, reducing CPU/GPU overhead
    // and memory bandwidth on mid-range/3GB RAM Android devices.
    return RepaintBoundary(
      child: SizedBox(
        width: 140,
        height: 140,
        child: _buildAnimatedBody(context),
      ),
    );
  }

  Widget _buildAnimatedBody(BuildContext context) {
    final robotVisuals = _buildRobotVisuals();

    // Apply micro-animations based on BuddyMood state
    switch (mood) {
      case BuddyMood.speaking:
        // Speaking state: Pulses antenna and bounces up and down to match storytelling cadence
        return robotVisuals
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scaleXY(begin: 0.98, end: 1.02, duration: 400.ms, curve: Curves.easeInOut)
            .slideY(begin: 0, end: -0.04, duration: 400.ms, curve: Curves.easeInOut);
      case BuddyMood.happy:
        // Happy state: Jumps, bounces, and does a celebration spin
        return robotVisuals
            .animate()
            .slideY(begin: 0, end: -0.2, duration: 300.ms, curve: Curves.easeOut)
            .then()
            .slideY(begin: -0.2, end: 0, duration: 300.ms, curve: Curves.bounceOut)
            .animate(onPlay: (controller) => controller.repeat(reverse: false))
            .rotate(begin: 0, end: 1.0, duration: 800.ms, curve: Curves.easeInOutCubic);
      case BuddyMood.sad:
        // Sad state: Droops down and shakes side-to-side (wrong answer response)
        return robotVisuals
            .animate()
            .slideY(begin: 0, end: 0.06, duration: 400.ms, curve: Curves.easeIn)
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .shake(hz: 2, amount: 0.03, duration: 1000.ms);
      case BuddyMood.idle:
      default:
        // Idle state: Slow, smooth floating effect simulating life
        return robotVisuals
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .slideY(begin: -0.03, end: 0.03, duration: 1500.ms, curve: Curves.easeInOut);
    }
  }

  Widget _buildRobotVisuals() {
    // Attempt to load the asset image. If it fails (errorBuilder) or is missing,
    // automatically fall back to the vector-drawn robot.
    return Image.asset(
      'assets/images/robot_buddy.png',
      fit: const BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback Vector Robot Layout (never crashes the app!)
        return Stack(
          alignment: Alignment.center,
          children: [
            // Left Ear
            Positioned(
              left: 2,
              child: _buildEar(),
            ),
            // Right Ear
            Positioned(
              right: 2,
              child: _buildEar(),
            ),
            // Antenna
            Positioned(
              top: 2,
              child: _buildAntenna(),
            ),
            // Head / Main body
            Positioned(
              bottom: 6,
              child: _buildHead(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEar() {
    return Container(
      width: 14,
      height: 24,
      decoration: BoxDecoration(
        color: AppTheme.accentColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
      ),
    );
  }

  Widget _buildAntenna() {
    Color glowColor = mood == BuddyMood.speaking ? AppTheme.primaryColor : AppTheme.accentColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Antenna Light
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: glowColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.6),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scaleXY(begin: 0.9, end: 1.25, duration: 500.ms),
        // Antenna shaft
        Container(
          width: 6,
          height: 18,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildHead() {
    Color bodyColor = AppTheme.secondaryColor;
    Widget faceWidget;

    switch (mood) {
      case BuddyMood.speaking:
        faceWidget = const _SpeakingFace();
        break;
      case BuddyMood.happy:
        faceWidget = const _HappyFace();
        bodyColor = AppTheme.correctColor; // Turns green on success
        break;
      case BuddyMood.sad:
        faceWidget = const _SadFace();
        bodyColor = AppTheme.textColor.withOpacity(0.6); // Greyish concern color
        break;
      case BuddyMood.idle:
      default:
        faceWidget = const _IdleFace();
        break;
    }

    return Container(
      width: 110,
      height: 96,
      decoration: BoxDecoration(
        color: bodyColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white,
          width: 4,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x15000000),
            offset: Offset(0, 8),
            blurRadius: 8,
          ),
        ],
      ),
      child: faceWidget,
    );
  }
}

// Facials expressions classes

class _IdleFace extends StatelessWidget {
  const _IdleFace();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Left Eye (Blinking effect)
        _buildEye()
            .animate(onPlay: (controller) => controller.repeat())
            .scaleY(begin: 1, end: 0.1, delay: 3000.ms, duration: 150.ms)
            .then()
            .scaleY(begin: 0.1, end: 1, duration: 150.ms),
        // Mouth
        Container(
          width: 24,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        // Right Eye (Blinking effect)
        _buildEye()
            .animate(onPlay: (controller) => controller.repeat())
            .scaleY(begin: 1, end: 0.1, delay: 3000.ms, duration: 150.ms)
            .then()
            .scaleY(begin: 0.1, end: 1, duration: 150.ms),
      ],
    );
  }

  Widget _buildEye() {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SpeakingFace extends StatelessWidget {
  const _SpeakingFace();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Text("👀", style: TextStyle(fontSize: 24)),
        // Speaking pulsing mouth
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scaleY(begin: 0.2, end: 1.2, duration: 250.ms, curve: Curves.easeInOut),
      ],
    );
  }
}

class _HappyFace extends StatelessWidget {
  const _HappyFace();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSmilingEye(),
            _buildSmilingEye(),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: 32,
          height: 16,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmilingEye() {
    return CustomPaint(
      size: const Size(18, 10),
      painter: _SmileEyePainter(),
    );
  }
}

class _SadFace extends StatelessWidget {
  const _SadFace();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("🥺", style: TextStyle(fontSize: 28)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: 24,
          height: 12,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

class _SmileEyePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(size.width / 2, 0, size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
