import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Card displaying the story text with engaging styles and highlighted keywords.
class StoryCard extends StatelessWidget {
  final String text;

  const StoryCard({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.0),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFFFFDF9),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Narrative icon header
            Row(
              children: [
                const Icon(
                  Icons.auto_stories,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  "Pip's Big Adventure",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const Divider(
              color: Color(0xFFF7ECE1),
              thickness: 1.5,
              height: 24,
            ),
            // Story text with customized rich spans for children
            RichText(
              text: TextSpan(
                style: AppTheme.storyStyle,
                children: const [
                  TextSpan(text: "Once upon a time, a "),
                  TextSpan(
                    text: "clever little robot named Pip ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  TextSpan(text: "lost his "),
                  TextSpan(
                    text: "shiny blue gear ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                  TextSpan(text: "in the "),
                  TextSpan(
                    text: "Whispering Woods...",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.correctColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
