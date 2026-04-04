import 'package:flutter/material.dart';
import 'package:kuwentobuddy/models/story_model.dart';
import 'package:kuwentobuddy/theme.dart';

/// Story card widget - like Spotify album art
class StoryCard extends StatelessWidget {
  final StoryModel story;
  final VoidCallback? onTap;
  final double width;
  final bool showDetails;
  final bool enableHero;

  const StoryCard({
    super.key,
    required this.story,
    this.onTap,
    this.width = 160,
    this.showDetails = true,
    this.enableHero = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final card = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StoryCover(story: story, width: width),
        if (showDetails) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            story.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : KuwentoColors.textPrimary,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            story.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.72)
                      : KuwentoColors.textSecondary,
                ),
          ),
        ],
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: enableHero
            ? Hero(tag: 'story_cover_${story.id}', child: card)
            : card,
      ),
    );
  }
}

class _StoryCover extends StatelessWidget {
  final StoryModel story;
  final double width;

  const _StoryCover({required this.story, required this.width});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: width,
          height: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                story.coverImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: KuwentoColors.deepTeal.withValues(alpha: 0.2),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    size: 48,
                    color: KuwentoColors.deepTeal,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    '${story.levelEmoji} ${story.levelDisplay}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${story.estimatedMinutes} min',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Large featured story card for hero sections
class FeaturedStoryCard extends StatelessWidget {
  final StoryModel story;
  final VoidCallback? onTap;
  final bool enableHero;

  const FeaturedStoryCard({
    super.key,
    required this.story,
    this.onTap,
    this.enableHero = true,
  });

  @override
  Widget build(BuildContext context) {
    final cover = Image.asset(
      story.coverImage,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: KuwentoColors.deepTeal,
      ),
    );

    final image =
        enableHero ? Hero(tag: 'story_cover_${story.id}', child: cover) : cover;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: KuwentoColors.deepTeal.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            image,
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 340;
                  final badgeVertical = compact ? 5.0 : 6.0;
                  final badgeHorizontal = compact ? 10.0 : 12.0;
                  final iconSize = compact ? 13.0 : 14.0;
                  final badgeFontSize = compact ? 11.0 : 12.0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: badgeHorizontal,
                          vertical: badgeVertical,
                        ),
                        decoration: BoxDecoration(
                          color: KuwentoColors.deepTeal.withValues(alpha: 0.78),
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: iconSize,
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
                            const SizedBox(width: 6),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Featured Story',
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: badgeFontSize,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            story.title,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.visible,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        story.description,
                        maxLines: 3,
                        softWrap: true,
                        overflow: TextOverflow.clip,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal scrolling story row - like Spotify playlists
class StoryRow extends StatelessWidget {
  final String title;
  final String? emoji;
  final List<StoryModel> stories;
  final void Function(StoryModel story)? onStoryTap;
  final VoidCallback? onSeeAll;
  final Widget? titleAddon;

  const StoryRow({
    super.key,
    required this.title,
    this.emoji,
    required this.stories,
    this.onStoryTap,
    this.onSeeAll,
    this.titleAddon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              if (emoji != null) ...[
                Text(emoji!, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.visible,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : KuwentoColors.textPrimary,
                                  ),
                        ),
                      ),
                    ),
                    if (titleAddon != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 40),
                        child: titleAddon!,
                      ),
                    ],
                  ],
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: onSeeAll,
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: KuwentoColors.deepTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: stories.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) => StoryCard(
              story: stories[index],
              enableHero: false,
              onTap: () => onStoryTap?.call(stories[index]),
            ),
          ),
        ),
      ],
    );
  }
}
