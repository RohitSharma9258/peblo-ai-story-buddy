import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/story_screen.dart';
import 'utils/app_theme.dart';

void main() {
  // Ensure widget bindings are initialized before running tasks
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    // ProviderScope manages the lifecycle of Riverpod states
    const ProviderScope(
      child: PebloApp(),
    ),
  );
}

class PebloApp extends StatelessWidget {
  const PebloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peblo - AI Story Buddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.kidTheme,
      home: const StoryScreen(),
    );
  }
}
