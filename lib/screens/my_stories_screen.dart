import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kuwentobuddy/models/story_model.dart';
import 'package:kuwentobuddy/models/user_model.dart';
import 'package:kuwentobuddy/services/story_service.dart';
import 'package:kuwentobuddy/services/story_launch_service.dart';
import '../services/auth_service.dart';
import 'package:kuwentobuddy/theme.dart';
import '../widgets/story_card.dart';

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
  int _selectedTabIndex = 0;
  List<MapEntry<StoryModel, StoryProgress>> _cachedProgressEntries = [];
  String? _lastProgressScopeKey;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      debugPrint('MyStoriesScreen: Refreshing user from cloud on init');
      context.read<AuthService>().refreshCurrentUserFromCloud().then((_) {
        if (!mounted) return;
        final user = context.read<AuthService>().currentUser;
        debugPrint(
          'MyStoriesScreen: Loaded user with ${user?.storyProgress.length ?? 0} progress entries',
        );
      }).catchError((e) {
        debugPrint('MyStoriesScreen: Refresh failed: $e');
      });
    });
  }

  void _handleTabChange() {
    if (_selectedTabIndex == _tabController.index) return;
    if (_tabController.indexIsChanging) return;
    final newIndex = _tabController.index;
    setState(() {
      _selectedTabIndex = newIndex;
    });
    if (newIndex == 0) {
      debugPrint(
        'MyStoriesScreen: Tab changed to In Progress, refreshing user',
      );
      context.read<AuthService>().refreshCurrentUserFromCloud().then((_) {
        if (!mounted) return;
        debugPrint('MyStoriesScreen: Tab refresh complete');
      });
    }
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
    final progressScopeKey = authService.storyProgressScopeKey;
    final scopeChanged = progressScopeKey != _lastProgressScopeKey;
    final cachedProgressEntries = scopeChanged
        ? const <MapEntry<StoryModel, StoryProgress>>[]
        : _cachedProgressEntries;

    if (scopeChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _lastProgressScopeKey = progressScopeKey;
          _cachedProgressEntries = [];
        });
      });
    }
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
                              color: KuwentoColors.softCoral.withValues(
                                alpha: 0.2,
                              ),
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
                                    '${_countLabel(user.storiesCompleted, 'story', 'stories')} • ${_countLabel(user.totalStars, 'star', 'stars')} • ${_countLabel(favoritesCount, 'favorite', 'favorites')}',
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
                          horizontal: AppSpacing.md,
                        ),
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
                    _buildActiveTabContent(
                      user,
                      authService,
                      cachedProgressEntries,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(
    UserModel? user,
    AuthService authService,
    List<MapEntry<StoryModel, StoryProgress>> cachedProgressEntries,
  ) {
    switch (_selectedTabIndex) {
      case 1:
        return _buildCompletedTab(user);
      case 2:
        return _buildFavoritesTab(user);
      case 0:
      default:
        return _buildInProgressTab(user, authService, cachedProgressEntries);
    }
  }

  Widget _buildAverageScoreCard(BuildContext context, UserModel user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storyProgressEntries = _resolvedStoryProgressEntries(user);

    // Build the exact same completed set logic used by the Completed tab.
    final completedEntries = storyProgressEntries
        .where((entry) => _isStoryCompleted(entry.value, entry.key))
        .toList();

    // Calculate average comprehension score across completed stories.
    int totalScore = 0;
    int completedCount = 0;

    for (final entry in completedEntries) {
      final progress = entry.value;

      // Primary source: answered questions. Fallback: persisted score/stars data
      // for legacy completed records that may not include question counters.
      final hasQuestionMetrics = progress.totalQuestions > 0;
      final hasFallbackMetrics = progress.starsEarned > 0 ||
          progress.correctAnswers > 0 ||
          progress.totalSegments > 0;

      if (hasQuestionMetrics) {
        totalScore += progress.comprehensionScore.round();
        completedCount++;
        continue;
      }

      if (hasFallbackMetrics) {
        final starsBasedScore = (progress.starsEarned.clamp(0, 3) * 100) ~/ 3;
        totalScore += starsBasedScore;
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
        border: Border.all(color: performanceColor.withValues(alpha: 0.3)),
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
              border: Border.all(color: performanceColor, width: 3),
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
                  'Based on ${_countLabel(completedCount, 'completed story', 'completed stories')}',
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
              Icon(Icons.psychology, color: KuwentoColors.pastelBlue, size: 20),
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
    BuildContext context,
    String label,
    double value,
    Color color,
  ) {
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

  Widget _buildInProgressTab(
    UserModel? user,
    AuthService authService,
    List<MapEntry<StoryModel, StoryProgress>> cachedProgressEntries,
  ) {
    final cachedFromUser = _resolvedStoryProgressEntries(user);
    final baseFallback = _dedupeByStoryId([
      ...cachedProgressEntries,
      ...cachedFromUser,
    ]);
    final progressCollection =
        authService.storyProgressCollectionForCurrentScope();

    if (progressCollection != null) {
      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: progressCollection.snapshots(),
        builder: (context, snapshot) {
          // Use cached data to avoid UI flicker while listening.
          if (snapshot.connectionState == ConnectionState.waiting &&
              snapshot.data == null) {
            return _buildInProgressContent(baseFallback);
          }
          if (snapshot.hasError) {
            return _buildInProgressContent(baseFallback);
          }

          final progressEntries = _mapProgressDocsToEntries(
            snapshot.data?.docs ?? [],
          );

          final merged = [
            ...progressEntries,
            ...cachedProgressEntries,
            ...cachedFromUser,
          ];
          final deduped = _dedupeByStoryId(merged);
          _cachedProgressEntries = deduped;

          if (deduped.isNotEmpty) {
            return _buildInProgressContent(deduped);
          }

          // Final fallback: one-time fetch in case snapshots haven't emitted yet.
          return FutureBuilder<List<MapEntry<StoryModel, StoryProgress>>>(
            future: _fetchProgressOnce(progressCollection),
            builder: (context, futureSnap) {
              if (futureSnap.connectionState == ConnectionState.waiting) {
                return _buildInProgressContent(baseFallback);
              }
              final once = futureSnap.data ?? const [];
              final mergedOnce = _dedupeByStoryId([
                ...once,
                ...cachedProgressEntries,
                ...cachedFromUser,
              ]);
              _cachedProgressEntries = mergedOnce;
              return _buildInProgressContent(mergedOnce);
            },
          );
        },
      );
    }

    // Guest or fallback to cached user snapshot.
    _cachedProgressEntries = baseFallback;
    return _buildInProgressContent(baseFallback);
  }

  Widget _buildInProgressContent(
    List<MapEntry<StoryModel, StoryProgress>> entries,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inProgress = entries
        .where((entry) => _isStoryInProgress(entry.value, entry.key))
        .toList()
      ..sort((a, b) => b.value.updatedAt.compareTo(a.value.updatedAt));

    debugPrint(
      'MyStoriesScreen: In Progress tab will show ${inProgress.length} cards',
    );

    if (inProgress.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await context.read<AuthService>().refreshCurrentUserFromCloud();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: _buildEmptyState(
              emoji: '📖',
              title: 'No stories in progress',
              subtitle: 'Pull to refresh or start reading!',
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: inProgress.map((entry) {
          final story = entry.key;
          final progress = entry.value;
          final progressPercent = progress.progressPercent;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: GestureDetector(
              onTap: () {
                openStoryFromCard(context, story);
              },
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
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
                                color: KuwentoColors.pastelBlue.withValues(
                                  alpha: 0.2,
                                ),
                                child: const Icon(
                                  Icons.auto_stories,
                                  color: KuwentoColors.pastelBlue,
                                ),
                              ),
                            ),
                          ),
                        ],
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
                            '${(progressPercent * 100).toInt()}% progress',
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
    final storyProgressEntries = _resolvedStoryProgressEntries(user);

    // Dynamic categorization: completed when final sequence/segment is finished.
    final completedEntries = storyProgressEntries
        .where((entry) => _isStoryCompleted(entry.value, entry.key))
        .toList()
      ..sort((a, b) {
        final aRecent = a.value.completedAt ?? a.value.updatedAt;
        final bRecent = b.value.completedAt ?? b.value.updatedAt;
        final comparison = bRecent.compareTo(aRecent);
        if (comparison != 0) return comparison;
        return a.key.title.compareTo(b.key.title);
      });
    final completed = completedEntries.map((entry) => entry.key).toList();

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
                          onTap: () {
                            openStoryFromCard(context, story);
                          },
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
                                    Icons.star_outline,
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
                  border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
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
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Your Favorite Stories',
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
                              onTap: () {
                                openStoryFromCard(context, story);
                              },
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
                                      color: Colors.black.withValues(
                                        alpha: 0.12,
                                      ),
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
    return progress.isCompleted;
  }

  bool _isStoryInProgress(StoryProgress progress, StoryModel story) {
    // Treat any non-completed story as in-progress, even if still on segment 0.
    // This keeps "opened but not yet advanced" stories visible for resume.
    return !progress.isCompleted;
  }

  List<MapEntry<StoryModel, StoryProgress>> _resolvedStoryProgressEntries(
    UserModel? user,
  ) {
    if (user == null) return <MapEntry<StoryModel, StoryProgress>>[];

    final byStoryId = <String, MapEntry<StoryModel, StoryProgress>>{};
    for (final entry in user.storyProgress.entries) {
      final progress = entry.value;
      final story = _resolveStoryById(entry.key) ??
          _resolveStoryById(progress.storyId) ??
          _resolveStoryById(progress.storyTitle ?? '') ??
          _placeholderStory(progress.storyId, progress.storyTitle);

      final candidate = MapEntry(story, progress);
      final existing = byStoryId[story.id];

      if (existing == null ||
          _shouldReplaceProgress(existing.value, candidate.value)) {
        byStoryId[story.id] = candidate;
      }
    }

    return byStoryId.values.toList();
  }

  List<MapEntry<StoryModel, StoryProgress>> _mapProgressDocsToEntries(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final entries = <MapEntry<StoryModel, StoryProgress>>[];

    for (final doc in docs) {
      final data = doc.data();
      final appStoryId = (data['appStoryId'] as String?) ??
          (data['storyId'] as String?) ??
          doc.id;
      final story = _resolveStoryById(appStoryId) ??
          _resolveStoryById(data['storyTitle'] as String? ?? '') ??
          _resolveStoryById(doc.id) ??
          _placeholderStory(appStoryId, data['storyTitle'] as String?);

      final progress = StoryProgress(
        storyId: appStoryId,
        storyTitle: data['storyTitle'] as String? ?? story.title,
        currentSegmentIndex: _asInt(data['currentSegmentIndex']) ??
            _asInt(data['lastPage']) ??
            0,
        totalSegments: _asInt(data['totalSegments']) ?? story.segments.length,
        isCompleted:
            data['isCompleted'] as bool? ?? data['completed'] as bool? ?? false,
        correctAnswers: _asInt(data['correctAnswers']) ?? 0,
        totalQuestions: _asInt(data['totalQuestions']) ?? 0,
        starsEarned: _asInt(data['starsEarned']) ?? 0,
        skillCorrect: _asStringIntMap(data['skillCorrect']),
        skillTotal: _asStringIntMap(data['skillTotal']),
        startedAt: _asDateTime(data['startedAt']) ?? DateTime.now(),
        completedAt: _asDateTime(data['completedAt']),
        updatedAt: _asDateTime(data['updatedAt']) ?? DateTime.now(),
        hintAttemptsUsed: _asInt(data['hintAttemptsUsed']) ?? 0,
      );

      entries.add(MapEntry(story, progress));
    }

    return entries;
  }

  Future<List<MapEntry<StoryModel, StoryProgress>>> _fetchProgressOnce(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    try {
      final snap = await collection.get();
      return _mapProgressDocsToEntries(snap.docs);
    } catch (e) {
      debugPrint('MyStoriesScreen: one-time progress fetch failed: $e');
      return const [];
    }
  }

  List<MapEntry<StoryModel, StoryProgress>> _dedupeByStoryId(
    List<MapEntry<StoryModel, StoryProgress>> entries,
  ) {
    final byId = <String, MapEntry<StoryModel, StoryProgress>>{};
    for (final entry in entries) {
      final key = _normalizeStoryId(entry.key.id);
      final existing = byId[key];
      if (existing == null ||
          entry.value.updatedAt.isAfter(existing.value.updatedAt)) {
        byId[key] = entry;
      }
    }
    return byId.values.toList();
  }

  bool _shouldReplaceProgress(StoryProgress existing, StoryProgress candidate) {
    // Prefer whichever entry is newer; allow a fresh in-progress write to
    // replace an older completed snapshot so the story reappears under
    // "In Progress" after reopening.
    if (candidate.updatedAt.isAfter(existing.updatedAt)) {
      return true;
    }
    if (existing.updatedAt.isAfter(candidate.updatedAt)) {
      return false;
    }

    // Tie-breaker when timestamps are equal:
    // - in-progress should beat completed (lets users resume)
    // - otherwise, keep the one with deeper segment index.
    if (existing.isCompleted != candidate.isCompleted) {
      return !candidate.isCompleted;
    }

    return candidate.currentSegmentIndex > existing.currentSegmentIndex;
  }

  StoryModel? _resolveStoryById(String storyId) {
    final direct = _storyService.getStoryById(storyId);
    if (direct != null) return direct;

    final normalized = _normalizeStoryId(storyId);
    for (final story in _storyService.getAllStories()) {
      final normalizedStoryId = _normalizeStoryId(story.id);
      final normalizedTitle = _normalizeStoryId(story.title);
      if (normalizedStoryId == normalized ||
          normalizedTitle == normalized ||
          normalizedStoryId.contains(normalized) ||
          normalized.contains(normalizedStoryId) ||
          normalizedTitle.contains(normalized) ||
          normalized.contains(normalizedTitle)) {
        return story;
      }
    }

    return null;
  }

  StoryModel _placeholderStory(String id, String? title) {
    return StoryModel(
      id: id,
      title: title?.trim().isNotEmpty == true ? title!.trim() : id,
      author: 'Kuwento Buddy',
      coverImage: '',
      description: '',
      level: StoryLevel.beginner,
      categories: const [StoryCategory.filipinoTales],
      segments: const [],
      estimatedMinutes: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, int> _asStringIntMap(dynamic value) {
    if (value is! Map) return const <String, int>{};
    final result = <String, int>{};
    value.forEach((key, rawValue) {
      final parsed = _asInt(rawValue);
      if (parsed != null) {
        result[key.toString()] = parsed;
      }
    });
    return result;
  }

  DateTime? _asDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
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
        final normalizedStoryTitle = _normalizeStoryId(story.title);
        if (normalizedStoryId == normalizedFavoriteId ||
            normalizedStoryTitle == normalizedFavoriteId ||
            normalizedStoryId.contains(normalizedFavoriteId) ||
            normalizedFavoriteId.contains(normalizedStoryId) ||
            normalizedStoryTitle.contains(normalizedFavoriteId) ||
            normalizedFavoriteId.contains(normalizedStoryTitle)) {
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

  String _normalizeStoryId(String id) =>
      id.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');

  String _countLabel(int count, String singular, String plural) =>
      '$count ${count == 1 ? singular : plural}';

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
                'To save your stories forever,\ncreate an account! 🌟',
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
