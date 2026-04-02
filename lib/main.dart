import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:kuwentobuddy/firebase_options.dart';
import 'package:kuwentobuddy/theme.dart';
import 'package:kuwentobuddy/nav.dart';
import 'package:kuwentobuddy/services/auth_service.dart';
import 'package:kuwentobuddy/services/app_language_service.dart';
import 'package:kuwentobuddy/services/story_service.dart';
import 'package:kuwentobuddy/services/tts_service.dart';
import 'package:kuwentobuddy/controllers/profile_controller.dart';

/// KuwentoBuddy - Interactive Reading Comprehension App
///
/// A Spotify-inspired reading app that implements the
/// "Read-Think-Continue" interactive module for reading
/// comprehension development.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase must be ready before creating AuthService/FirebaseAuth instances.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  final authService = AuthService();
  final ttsService = TTSService();
  final storyService = StoryService();

  await storyService.initialize(preferFirestore: true);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider.value(value: ttsService),
        ChangeNotifierProvider(create: (_) => AppLanguageService()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
      ],
      child: const KuwentoBuddyApp(),
    ),
  );

  // Bootstrap heavy startup work in background so splash renders immediately.
  unawaited(_bootstrapServices(authService, ttsService, storyService));
}

Future<void> _bootstrapServices(
  AuthService authService,
  TTSService ttsService,
  StoryService storyService,
) async {
  try {
    await authService.initialize();
    await ttsService.initialize();
    try {
      await storyService.seedStoriesToFirestoreIfMissing();
    } catch (e) {
      debugPrint('Story seeding skipped: $e');
    }

    final currentUser = authService.currentUser;
    if (currentUser != null) {
      await ttsService.applyPreferences(currentUser.preferences);
    }
  } catch (e) {
    debugPrint('App bootstrap failed: $e');
  }
}

class KuwentoBuddyApp extends StatelessWidget {
  const KuwentoBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'KuwentoBuddy',
      debugShowCheckedModeBanner: false,

      // Theme configuration with soft pastel blues
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,

      // Router configuration
      routerConfig: AppRouter.router,
    );
  }
}
