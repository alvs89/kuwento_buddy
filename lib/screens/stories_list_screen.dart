import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kuwentobuddy/models/story_model.dart';
import 'package:kuwentobuddy/services/story_service.dart';
import 'package:kuwentobuddy/services/auth_service.dart';
import 'package:kuwentobuddy/services/story_launch_service.dart';
import 'package:kuwentobuddy/theme.dart';
import 'package:kuwentobuddy/widgets/story_card.dart';

/// Unified screen for displaying filtered stories by category or level
class StoriesListScreen extends StatelessWidget {
  final String? category;
  final String? level;
  final String title;
  final bool currentLibraryOnly;
  final List<String> recommendedStoryIds;

  static const Map<String, StoryCategory> _categoryByRoute = {
    'filipino_tales': StoryCategory.filipinoTales,
    'filipino-tales': StoryCategory.filipinoTales,
    'adventure': StoryCategory.adventureJourney,
    'adventure-journey': StoryCategory.adventureJourney,
    'social': StoryCategory.socialStories,
    'social-stories': StoryCategory.socialStories,
  };

  static const Map<String, StoryLevel> _levelByRoute = {
    'beginner': StoryLevel.beginner,
    'intermediate': StoryLevel.intermediate,
    'advanced': StoryLevel.advanced,
  };

  const StoriesListScreen({
    super.key,
    this.category,
    this.level,
    required this.title,
    this.currentLibraryOnly = false,
    this.recommendedStoryIds = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storyService = StoryService();
    context.watch<AuthService>();

    final baseStories = currentLibraryOnly
        ? storyService.getRecommendedStories()
        : storyService.getAllStories();

    List<StoryModel> stories;

    if (level != null) {
      final selectedLevel = _levelByRoute[level ?? ''];
      stories = selectedLevel == null
          ? baseStories
          : baseStories.where((s) => s.level == selectedLevel).toList();
    } else if (category != null) {
      if (category == 'recommended') {
        if (recommendedStoryIds.isEmpty) {
          stories = baseStories;
        } else {
          final byId = <String, StoryModel>{
            for (final story in baseStories) story.id: story,
          };
          stories = recommendedStoryIds
              .map((id) => byId[id])
              .whereType<StoryModel>()
              .toList();
        }
      } else {
        final selectedCategory = _categoryByRoute[category ?? ''];
        if (selectedCategory == StoryCategory.filipinoTales) {
          stories = storyService.getFilipinoTales();
        } else {
          stories = selectedCategory == null
              ? baseStories
              : baseStories
                  .where((s) => s.categories.contains(selectedCategory))
                  .toList();
        }
      }
    } else {
      stories = baseStories;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : KuwentoColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : KuwentoColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: stories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📚', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No stories found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isDark
                              ? Colors.white70
                              : KuwentoColors.textSecondary,
                        ),
                  ),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                const minCardWidth = 150.0;
                final columns =
                    (constraints.maxWidth / (minCardWidth + AppSpacing.md))
                        .floor()
                        .clamp(1, 4);
                final spacing = AppSpacing.md;
                final totalSpacing = spacing * (columns - 1);
                final cardWidth = (constraints.maxWidth -
                        (AppSpacing.md * 2) -
                        totalSpacing) /
                    columns;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Wrap(
                    spacing: spacing,
                    runSpacing: AppSpacing.lg,
                    children: stories
                        .map(
                          (story) => SizedBox(
                            width: cardWidth,
                            child: StoryCard(
                              story: story,
                              width: cardWidth,
                              enableHero: false,
                              onTap: () {
                                openStoryFromCard(context, story);
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
    );
  }
}
