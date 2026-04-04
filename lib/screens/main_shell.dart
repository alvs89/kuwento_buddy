import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwentobuddy/theme.dart';
import 'package:kuwentobuddy/widgets/buddy_companion.dart';

/// Main shell with bottom navigation - Spotify-style layout
class MainShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  static const String _searchBuddyMessage =
      'Browse the genres for quick picks.';

  const MainShell({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  (BuddyState, String) _buddyContextByTab() {
    switch (currentIndex) {
      case 0:
        return (
          BuddyState.happy,
          'Welcome back! Tap a story card to start reading and earn stars.',
        );
      case 1:
        return (
          BuddyState.thinking,
          _searchBuddyMessage,
        );
      case 2:
        return (
          BuddyState.encouraging,
          'Welcome to your library! Revisit favorites, completed stories, or continue where you left off.',
        );
      default:
        return (BuddyState.idle, 'Hi! I am here if you need reading tips.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final media = MediaQuery.of(context);
    final bottomInset = media.padding.bottom;
    final keyboardInset = media.viewInsets.bottom;
    final buddySize = media.size.width < 360 ? 60.0 : 78.0;
    final buddyBottomOffset = media.size.width < 360 ? 62.0 : 58.0;
    final (buddyState, buddyMessage) = _buddyContextByTab();

    return Scaffold(
      body: Stack(
        children: [
          child,
          if (keyboardInset == 0)
            Positioned(
              right: AppSpacing.md,
              bottom: AppSpacing.sm + bottomInset + buddyBottomOffset,
              child: BuddyCompanion(
                state: buddyState,
                tapMessage: buddyMessage,
                size: buddySize,
                showSpeechBubble: true,
                enableTapSpeechBubble: true,
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? KuwentoColors.cardDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  isActive: currentIndex == 0,
                  onTap: () => context.go('/'),
                ),
                _NavItem(
                  icon: Icons.search_outlined,
                  activeIcon: Icons.search,
                  label: 'Search',
                  isActive: currentIndex == 1,
                  onTap: () => context.go('/search'),
                ),
                _NavItem(
                  icon: Icons.library_books_outlined,
                  activeIcon: Icons.library_books,
                  label: 'My Library',
                  isActive: currentIndex == 2,
                  onTap: () => context.go('/my-stories'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? KuwentoColors.deepTeal.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive
                  ? KuwentoColors.deepTeal
                  : (isDark ? Colors.white54 : KuwentoColors.textMuted),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? KuwentoColors.deepTeal
                    : (isDark ? Colors.white54 : KuwentoColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
