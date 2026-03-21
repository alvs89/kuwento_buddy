import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwentobuddy/screens/splash_screen.dart';
import 'package:kuwentobuddy/screens/library_screen.dart';
import 'package:kuwentobuddy/screens/search_screen.dart';
import 'package:kuwentobuddy/screens/my_stories_screen.dart';
import 'package:kuwentobuddy/screens/story_session_screen.dart';
import 'package:kuwentobuddy/screens/stories_list_screen.dart';
import 'package:kuwentobuddy/screens/main_shell.dart';
import 'package:kuwentobuddy/screens/login_screen.dart';
import 'package:kuwentobuddy/screens/settings_screen.dart';
import 'package:kuwentobuddy/screens/sequence_activity_screen.dart';
import 'package:kuwentobuddy/services/auth_service.dart';
import 'package:kuwentobuddy/theme.dart';
import 'package:kuwentobuddy/widgets/buddy_companion.dart';

/// GoRouter configuration for KuwentoBuddy navigation
///
/// Uses ShellRoute for bottom navigation persistence
/// and standard routes for story sessions
class AppRouter {
  static Widget _withFloatingBuddy(
    Widget child, {
    double extraBottomOffset = 0,
    double extraRightOffset = 0,
    double? size,
    bool animateFloatingBuddy = false,
    String? speechMessage,
    bool allowInteraction = false,
  }) {
    return Builder(
      builder: (context) {
        final media = MediaQuery.of(context);
        final bottomInset = media.padding.bottom;
        final keyboardInset = media.viewInsets.bottom;
        final buddySize = size ?? (media.size.width < 360 ? 60.0 : 68.0);
        final overlayBuddy = BuddyCompanion(
          state: BuddyState.happy,
          size: buddySize,
          showSpeechBubble: speechMessage != null,
          enableTapSpeechBubble: speechMessage != null,
          message: speechMessage,
        );
        final buddyWidget = animateFloatingBuddy
            ? AnimatedFloatingBuddy(child: overlayBuddy)
            : overlayBuddy;

        return Stack(
          children: [
            child,
            if (keyboardInset == 0)
              Positioned(
                right: AppSpacing.md + extraRightOffset,
                bottom: AppSpacing.md + bottomInset + extraBottomOffset,
                child: IgnorePointer(
                  ignoring: !allowInteraction,
                  child: buddyWidget,
                ),
              ),
          ],
        );
      },
    );
  }

  static CustomTransitionPage<void> _buildLoginTransitionPage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final authService = AuthService();
      final isAuthenticated = authService.status == AuthStatus.authenticated;
      final isGuest = authService.status == AuthStatus.guest;
      final canAccessApp = isAuthenticated || isGuest;
      final isLoginRoute = state.uri.path == AppRoutes.login;
      final isSplashRoute = state.uri.path == AppRoutes.splash;

      // Allow splash to handle its own forward navigation.
      if (isSplashRoute) {
        return null;
      }

      // If not logged in and not on login page, redirect to login
      if (!canAccessApp &&
          !isLoginRoute &&
          authService.status != AuthStatus.unknown) {
        return AppRoutes.login;
      }

      return null;
    },
    routes: [
      // Splash route
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // Login route
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => _buildLoginTransitionPage(
          state: state,
          child: _withFloatingBuddy(
            LoginScreen(
              mode: state.uri.queryParameters['mode'] ?? 'signin',
            ),
            extraBottomOffset: 24,
            extraRightOffset: 2,
            size: 80,
            animateFloatingBuddy: true,
            speechMessage:
                'Welcome! Sign in or create an account to start your reading adventure!',
            allowInteraction: true,
          ),
        ),
      ),

      // Shell route for bottom navigation screens
      ShellRoute(
        builder: (context, state, child) {
          // Determine current tab index based on location
          final location = state.uri.path;
          int currentIndex = 0;
          if (location.startsWith('/search')) {
            currentIndex = 1;
          } else if (location.startsWith('/my-stories')) {
            currentIndex = 2;
          }

          return MainShell(
            currentIndex: currentIndex,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const LibraryScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: AppRoutes.search,
            name: 'search',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const SearchScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: AppRoutes.myStories,
            name: 'my-stories',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const MyStoriesScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
        ],
      ),

      // Story session route (outside shell for full-screen experience)
      GoRoute(
        path: AppRoutes.storySession,
        name: 'story-session',
        pageBuilder: (context, state) {
          final storyId = state.pathParameters['storyId'] ?? '';
          return CustomTransitionPage(
            child: StorySessionScreen(storyId: storyId),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
          );
        },
      ),

      // Sequence activity route
      GoRoute(
        path: AppRoutes.sequenceActivity,
        name: 'sequence-activity',
        pageBuilder: (context, state) {
          final storyId = state.pathParameters['storyId'] ?? '';
          return CustomTransitionPage(
            child: _withFloatingBuddy(
              SequenceActivityScreen(storyId: storyId),
              extraBottomOffset: 108,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
          );
        },
      ),

      // Settings route
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SettingsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),

      // Stories by level route
      GoRoute(
        path: AppRoutes.storiesByLevel,
        name: 'stories-by-level',
        pageBuilder: (context, state) {
          final level = state.pathParameters['level'] ?? '';
          final levelName = level[0].toUpperCase() + level.substring(1);
          return CustomTransitionPage(
            child: _withFloatingBuddy(
              StoriesListScreen(level: level, title: '$levelName Stories'),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
          );
        },
      ),

      // Stories by category route
      GoRoute(
        path: AppRoutes.storiesByCategory,
        name: 'stories-by-category',
        pageBuilder: (context, state) {
          final category = state.pathParameters['category'] ?? '';
          final scope = state.uri.queryParameters['scope'];
          final idsParam = state.uri.queryParameters['ids'];
          final recommendedStoryIds = idsParam == null || idsParam.isEmpty
              ? const <String>[]
              : idsParam
                  .split(',')
                  .where((id) => id.trim().isNotEmpty)
                  .map((id) => id.trim())
                  .toList();
          final currentLibraryOnly = scope == 'current';
          final title = _getCategoryTitle(category);
          return CustomTransitionPage(
            child: _withFloatingBuddy(
              StoriesListScreen(
                category: category,
                title: title,
                currentLibraryOnly: currentLibraryOnly,
                recommendedStoryIds: recommendedStoryIds,
              ),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
          );
        },
      ),
    ],
  );

  static String _getCategoryTitle(String category) {
    switch (category) {
      case 'filipino_tales':
        return 'Filipino Tales 🇵🇭';
      case 'quick_reads':
        return 'Quick Reads ⚡';
      case 'adventure':
        return 'Adventure 🗺️';
      case 'fantasy':
        return 'Fantasy ✨';
      case 'nature':
        return 'Nature 🌿';
      case 'recommended':
        return 'Recommended for You ⭐';
      default:
        return 'All Stories 📚';
    }
  }
}

/// Route path constants
class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/';
  static const String search = '/search';
  static const String myStories = '/my-stories';
  static const String storySession = '/story/:storyId';
  static const String sequenceActivity = '/activity/:storyId';
  static const String settings = '/settings';
  static const String login = '/login';
  static const String storiesByLevel = '/stories/level/:level';
  static const String storiesByCategory = '/stories/category/:category';
}

/// Small helper to animate the floating buddy overlay in the login screen
class AnimatedFloatingBuddy extends StatefulWidget {
  final Widget child;

  const AnimatedFloatingBuddy({super.key, required this.child});

  @override
  State<AnimatedFloatingBuddy> createState() => _AnimatedFloatingBuddyState();
}

class _AnimatedFloatingBuddyState extends State<AnimatedFloatingBuddy> {
  bool _floatUp = true;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: _floatUp ? -5 : 5,
        end: _floatUp ? 5 : -5,
      ),
      duration: const Duration(milliseconds: 3200),
      curve: Curves.easeInOut,
      onEnd: () {
        if (!mounted) return;
        setState(() => _floatUp = !_floatUp);
      },
      builder: (context, value, child) {
        final scale = 1 + (value.abs() / 130);
        return Transform.translate(
          offset: Offset(0, value),
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
