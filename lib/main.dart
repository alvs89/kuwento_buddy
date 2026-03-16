import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:kuwentobuddy/firebase_options.dart';
import 'package:kuwentobuddy/theme.dart';
import 'package:kuwentobuddy/nav.dart';
import 'package:kuwentobuddy/services/auth_service.dart';
import 'package:kuwentobuddy/services/tts_service.dart';

/// KuwentoBuddy - Interactive Reading Comprehension App
///
/// A Spotify-inspired reading app that implements the
/// "Read-Think-Continue" interactive module for reading
/// comprehension development.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
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

  // Initialize services
  final authService = AuthService();
  await authService.initialize();

  final ttsService = TTSService();
  await ttsService.initialize();

  final currentUser = authService.currentUser;
  if (currentUser != null) {
    await ttsService.applyPreferences(currentUser.preferences);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider.value(value: ttsService),
      ],
      child: const KuwentoBuddyApp(),
    ),
  );
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
