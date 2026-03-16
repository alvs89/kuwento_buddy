import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kuwentobuddy/models/story_model.dart';
import 'package:kuwentobuddy/models/user_model.dart';
import 'package:kuwentobuddy/services/story_service.dart';
import 'package:kuwentobuddy/services/auth_service.dart';
import 'package:kuwentobuddy/services/toast_service.dart';
import 'package:kuwentobuddy/theme.dart';
import 'package:kuwentobuddy/widgets/story_card.dart';
import 'package:kuwentobuddy/widgets/buddy_companion.dart';

/// My Stories screen - Progress Journal like Spotify's Library
class MyStoriesScreen extends StatefulWidget {
  const MyStoriesScreen({super.key});

  @override
  State<MyStoriesScreen> createState() => _MyStoriesScreenState();
}

class _MyStoriesScreenState extends State<MyStoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StoryService _storyService = StoryService();
  final ToastService _toastService = ToastService();
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_selectedTabIndex == _tabController.index) return;
    if (_tabController.indexIsChanging) return;
    setState(() {
      _selectedTabIndex = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;
    final favoritesCount = user?.favoriteStoryIds.toSet().length ?? 0;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: KuwentoColors.softCoral
                                  .withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.menu_book,
                              color: KuwentoColors.softCoral,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'My Library',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : KuwentoColors.textPrimary,
                                      ),
                                ),
                                if (user != null)
                                  Text(
                                    '${user.storiesCompleted} stories • ${user.totalStars} stars • $favoritesCount favorites',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: isDark
                                              ? Colors.white70
                                              : KuwentoColors.textSecondary,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Stats summary for authenticated users
                    if (user != null && user.storyProgress.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md),
                        child: Column(
                          children: [
                            _buildAverageScoreCard(context, user),
                            const SizedBox(height: AppSpacing.sm),
                            _buildSkillMasteryCard(context, user),
                          ],
                        ),
                      ),

                    // Tabs
                    Container(
                      margin: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark
                            ? KuwentoColors.cardDark
                            : KuwentoColors.creamDark.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: KuwentoColors.pastelBlue,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: isDark
                            ? Colors.white70
                            : KuwentoColors.textSecondary,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: 'In Progress'),
                          Tab(text: 'Completed'),
                          Tab(text: 'Favorites'),
                        ],
                      ),
                    ),

                    // Active tab content (single page-level vertical scroll)
                    _buildActiveTabContent(user),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(UserModel? user) {
    switch (_selectedTabIndex) {
      case 1:
        return _buildCompletedTab(user);
      case 2:
        return _buildFavoritesTab(user);
      case 0:
      default:
        return _buildInProgressTab(user);
    }
  }

  Widget _buildAverageScoreCard(BuildContext context, UserModel user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate average comprehension score across all completed stories
    int totalScore = 0;
    int completedCount = 0;

    for (final progress in user.storyProgress.values) {
      if (progress.isCompleted && progress.totalQuestions > 0) {
        totalScore += progress.comprehensionScore.round();
        completedCount++;
      }
    }

    final averageScore =
        completedCount > 0 ? (totalScore / completedCount) : 0.0;

    // Get performance level and color
    String performanceLevel;
    Color performanceColor;
    String performanceEmoji;

    if (averageScore >= 90) {
      performanceLevel = 'Excellent';
      performanceColor = KuwentoColors.buddyHappy;
      performanceEmoji = '🌟';
    } else if (averageScore >= 70) {
      performanceLevel = 'Good';
      performanceColor = KuwentoColors.pastelBlue;
      performanceEmoji = '👍';
    } else if (averageScore >= 50) {
      performanceLevel = 'Keep Practicing';
      performanceColor = KuwentoColors.buddyThinking;
      performanceEmoji = '📚';
    } else {
      performanceLevel = 'Getting Started';
      performanceColor = KuwentoColors.softCoral;
      performanceEmoji = '💪';
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            performanceColor.withValues(alpha: 0.2),
            performanceColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: performanceColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Score circle
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: performanceColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: performanceColor,
                width: 3,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${averageScore.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: performanceColor,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      performanceEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Average Comprehension',
                        maxLines: 2,
                        softWrap: true,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : KuwentoColors.textPrimary,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  performanceLevel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: performanceColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Based on $completedCount completed ${completedCount == 1 ? 'story' : 'stories'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            isDark ? Colors.white54 : KuwentoColors.textMuted,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillMasteryCard(BuildContext context, UserModel user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate overall skill mastery
    int totalInference = 0, correctInference = 0;
    int totalPrediction = 0, correctPrediction = 0;
    int totalEmotion = 0, correctEmotion = 0;

    for (final progress in user.storyProgress.values) {
      totalInference += progress.skillTotal['inference'] ?? 0;
      correctInference += progress.skillCorrect['inference'] ?? 0;
      totalPrediction += progress.skillTotal['prediction'] ?? 0;
      correctPrediction += progress.skillCorrect['prediction'] ?? 0;
      totalEmotion += progress.skillTotal['emotion'] ?? 0;
      correctEmotion += progress.skillCorrect['emotion'] ?? 0;
    }

    final inferenceMastery =
        totalInference > 0 ? (correctInference / totalInference) : 0.0;
    final predictionMastery =
        totalPrediction > 0 ? (correctPrediction / totalPrediction) : 0.0;
    final emotionMastery =
        totalEmotion > 0 ? (correctEmotion / totalEmotion) : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? KuwentoColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: KuwentoColors.pastelBlue,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Comprehension Skills',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : KuwentoColors.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildSkillBar(
                  context,
                  'Inference',
                  inferenceMastery,
                  KuwentoColors.pastelBlue,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildSkillBar(
                  context,
                  'Prediction',
                  predictionMastery,
                  KuwentoColors.buddyHappy,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildSkillBar(
                  context,
                  'Emotion',
                  emotionMastery,
                  KuwentoColors.softCoral,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillBar(
      BuildContext context, String label, double value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          '${(value * 100).toInt()}%',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: isDark ? Colors.white12 : KuwentoColors.creamDark,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isDark ? Colors.white54 : KuwentoColors.textMuted,
              ),
        ),
      ],
    );
  }

  Widget _buildInProgressTab(UserModel? user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dynamic categorization: at least one segment done, but not fully completed.
    final inProgress = user?.storyProgress.entries
            .map((entry) {
              final story = _resolveStoryById(entry.key);
              if (story == null) return null;
              return MapEntry(story, entry.value);
            })
            .whereType<MapEntry<StoryModel, StoryProgress>>()
            .where((entry) => _isStoryInProgress(entry.value, entry.key))
            .map((entry) => entry.key)
            .toList() ??
        [];

    if (inProgress.isEmpty) {
      return _buildEmptyState(
        emoji: '📖',
        title: 'No stories in progress',
        subtitle: 'Start reading to see your progress here',
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: inProgress.map((story) {
          final progress = user?.storyProgress[story.id];
          final progressPercent = progress?.progressPercent ?? 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: GestureDetector(
              onTap: () => context.push('/story/${story.id}'),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? KuwentoColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Hero(
                      tag: 'story_cover_${story.id}',
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          story.coverImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color:
                                KuwentoColors.pastelBlue.withValues(alpha: 0.2),
                            child: const Icon(
                              Icons.auto_stories,
                              color: KuwentoColors.pastelBlue,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            story.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white
                                      : KuwentoColors.textPrimary,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(progressPercent * 100).toInt()}% completed',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? Colors.white70
                                          : KuwentoColors.textSecondary,
                                    ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progressPercent,
                              backgroundColor: isDark
                                  ? Colors.white12
                                  : KuwentoColors.creamDark,
                              valueColor: AlwaysStoppedAnimation(
                                KuwentoColors.pastelBlue,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: KuwentoColors.pastelBlue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: KuwentoColors.pastelBlue,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCompletedTab(UserModel? user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dynamic categorization: completed when final sequence/segment is finished.
    final completed = user?.storyProgress.entries
            .map((entry) {
              final story = _resolveStoryById(entry.key);
              if (story == null) return null;
              return MapEntry(story, entry.value);
            })
            .whereType<MapEntry<StoryModel, StoryProgress>>()
            .where((entry) => _isStoryCompleted(entry.value, entry.key))
            .map((entry) => entry.key)
            .toList() ??
        [];

    if (completed.isEmpty) {
      return _buildEmptyState(
        emoji: '🏆',
        title: 'No completed stories yet',
        subtitle: 'Finish reading a story to see it here',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 840
            ? 3
            : constraints.maxWidth >= 560
                ? 2
                : 1;
        final horizontalPadding = AppSpacing.md;
        final spacing = AppSpacing.md;
        final totalSpacing = spacing * (columns - 1);
        final cardWidth =
            (constraints.maxWidth - (horizontalPadding * 2) - totalSpacing) /
                columns;

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      KuwentoColors.buddyHappy.withValues(alpha: 0.18),
                      KuwentoColors.pastelBlue.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: KuwentoColors.buddyHappy.withValues(alpha: 0.28),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: KuwentoColors.buddyHappy.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        color: KuwentoColors.buddyHappy,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Completed Stories',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : KuwentoColors.textPrimary,
                            ),
                      ),
                    ),
                    Text(
                      '${completed.length}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: KuwentoColors.buddyHappy,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: spacing,
                runSpacing: AppSpacing.lg,
                children: completed.map((story) {
                  final progress = user?.storyProgress[story.id];
                  final stars = progress?.starsEarned ?? 0;

                  return SizedBox(
                    width: cardWidth,
                    child: Stack(
                      children: [
                        StoryCard(
                          story: story,
                          width: cardWidth,
                          onTap: () => context.push('/story/${story.id}'),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: KuwentoColors.buddyHappy,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ...List.generate(
                                  stars,
                                  (i) => const Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                                if (stars == 0)
                                  const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFavoritesTab(UserModel? user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favorites = _resolveFavoriteStories(user);

    if (favorites.isEmpty) {
      return _buildEmptyState(
        emoji: '❤️',
        title: 'No favorites yet',
        subtitle: 'Tap the heart icon to save stories you love',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 840
            ? 3
            : constraints.maxWidth >= 560
                ? 2
                : 1;
        final horizontalPadding = AppSpacing.md;
        final spacing = AppSpacing.md;
        final totalSpacing = spacing * (columns - 1);
        final cardWidth =
            (constraints.maxWidth - (horizontalPadding * 2) - totalSpacing) /
                columns;

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.red.withValues(alpha: 0.14),
                      KuwentoColors.softCoral.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite,
                          color: Colors.red, size: 18),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Your Favorited Stories',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : KuwentoColors.textPrimary,
                            ),
                      ),
                    ),
                    Text(
                      '${favorites.length}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: spacing,
                runSpacing: AppSpacing.lg,
                children: favorites
                    .map(
                      (story) => SizedBox(
                        width: cardWidth,
                        child: Stack(
                          children: [
                            StoryCard(
                              story: story,
                              width: cardWidth,
                              onTap: () => context.push('/story/${story.id}'),
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.12),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isStoryCompleted(StoryProgress progress, StoryModel story) {
    final lastSegmentIndex =
        story.totalSegments > 0 ? story.totalSegments - 1 : 0;
    return progress.isCompleted ||
        progress.currentSegmentIndex >= lastSegmentIndex;
  }

  bool _isStoryInProgress(StoryProgress progress, StoryModel story) {
    return progress.currentSegmentIndex > 0 &&
        !_isStoryCompleted(progress, story);
  }

  StoryModel? _resolveStoryById(String storyId) {
    final direct = _storyService.getStoryById(storyId);
    if (direct != null) return direct;

    final normalized = _normalizeStoryId(storyId);
    for (final story in _storyService.getAllStories()) {
      final normalizedStoryId = _normalizeStoryId(story.id);
      if (normalizedStoryId == normalized ||
          normalizedStoryId.contains(normalized) ||
          normalized.contains(normalizedStoryId)) {
        return story;
      }
    }

    return null;
  }

  List<StoryModel> _resolveFavoriteStories(UserModel? user) {
    final favoriteIds = (user?.favoriteStoryIds ?? []).toSet();
    if (favoriteIds.isEmpty) return const [];

    final allStories = _storyService.getAllStories();
    final storiesByNormalizedId = {
      for (final story in allStories) _normalizeStoryId(story.id): story,
    };

    final resolved = <StoryModel>[];
    for (final favoriteId in favoriteIds) {
      final normalizedFavoriteId = _normalizeStoryId(favoriteId);
      final directMatch = storiesByNormalizedId[normalizedFavoriteId];
      if (directMatch != null) {
        resolved.add(directMatch);
        continue;
      }

      // Fallback matching for legacy IDs that may include separators or casing differences.
      for (final story in allStories) {
        final normalizedStoryId = _normalizeStoryId(story.id);
        if (normalizedStoryId == normalizedFavoriteId ||
            normalizedStoryId.contains(normalizedFavoriteId) ||
            normalizedFavoriteId.contains(normalizedStoryId)) {
          resolved.add(story);
          break;
        }
      }
    }

    final uniqueById = <String, StoryModel>{};
    for (final story in resolved) {
      uniqueById[_normalizeStoryId(story.id)] = story;
    }

    return uniqueById.values.toList();
  }

  String _normalizeStoryId(String id) => id.trim().toLowerCase();

  Widget _buildEmptyState({
    required String emoji,
    required String title,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authService = context.read<AuthService>();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BuddyCompanion(
              state: BuddyState.idle,
              size: 80,
              showSpeechBubble: false,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color:
                        isDark ? Colors.white70 : KuwentoColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white54 : KuwentoColors.textMuted,
                  ),
            ),
            if (authService.isGuest) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Magaling! To save your stories forever,\ncreate an account! 🌟',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: KuwentoColors.pastelBlue,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () => context.push('/login?mode=signin'),
                child: Text(
                  'Sign In',
                  style: TextStyle(color: KuwentoColors.pastelBlue),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
