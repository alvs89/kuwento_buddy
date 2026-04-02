import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kuwentobuddy/models/story_model.dart';
import 'package:kuwentobuddy/services/auth_service.dart';
import 'package:kuwentobuddy/theme.dart';

enum _StoryLaunchChoice { continueReading, startFromBeginning }

Future<void> openStoryFromCard(BuildContext context, StoryModel story) async {
  final authService = context.read<AuthService>();
  final progress = authService.currentUser?.storyProgress[story.id];
  final shouldPrompt = progress != null &&
      !progress.isCompleted &&
      progress.currentSegmentIndex > 0;

  if (!shouldPrompt) {
    if (!context.mounted) return;
    context.push('/story/${story.id}');
    return;
  }

  final pageNumber = progress.currentSegmentIndex + 1;
  final choice = await showDialog<_StoryLaunchChoice>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      final isDark = Theme.of(dialogContext).brightness == Brightness.dark;

      return AlertDialog(
        backgroundColor: isDark ? KuwentoColors.cardDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        titlePadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        contentPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        title: Row(
          children: [
            const Icon(
              Icons.menu_book_rounded,
              color: KuwentoColors.deepTeal,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Continue reading?',
                style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : KuwentoColors.textPrimary,
                    ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are already on page $pageNumber. Would you like to continue where you left off or start from the opening page?',
              style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                    height: 1.35,
                    color:
                        isDark ? Colors.white70 : KuwentoColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 340;

                Widget buildActionButton(Widget button) {
                  return isCompact
                      ? SizedBox(width: double.infinity, child: button)
                      : IntrinsicWidth(child: button);
                }

                return Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildActionButton(
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.of(dialogContext)
                                .pop(_StoryLaunchChoice.continueReading);
                          },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: const Text(
                              'Continue Reading',
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: KuwentoColors.deepTeal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.md,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      buildActionButton(
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(dialogContext)
                                .pop(_StoryLaunchChoice.startFromBeginning);
                          },
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: const Text(
                              'Start from Opening Page',
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: KuwentoColors.deepTeal,
                            side:
                                const BorderSide(color: KuwentoColors.deepTeal),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.md,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      buildActionButton(
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: isDark
                                ? Colors.white70
                                : KuwentoColors.textSecondary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.md,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Cancel',
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );

  if (!context.mounted || choice == null) return;

  if (choice == _StoryLaunchChoice.continueReading) {
    context.push('/story/${story.id}?resume=true');
  } else {
    context.push('/story/${story.id}');
  }
}
