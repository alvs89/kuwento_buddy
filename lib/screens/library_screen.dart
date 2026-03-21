import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kuwentobuddy/models/story_model.dart';
import 'package:kuwentobuddy/services/story_service.dart';
import 'package:kuwentobuddy/services/auth_service.dart';
import 'package:kuwentobuddy/theme.dart';
import 'package:kuwentobuddy/widgets/story_card.dart';

/// Leveled Library Screen - Spotify-Home style layout
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final StoryService _storyService = StoryService();
  final Random _random = Random();
  StoryModel? _featuredStory;
  StoryLevel? _selectedLevel; // null == all levels
  List<StoryModel> _recommendedStories = const [];

  @override
  void initState() {
    super.initState();
    _featuredStory = _pickRandomFeaturedStory();
    _recommendedStories = _shuffleRecommended();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;

    final recommended = _recommendedStories.isNotEmpty
        ? _recommendedStories
        : _shuffleRecommended();
    final filipinoTales = _storyService.getFilipinoTales();
    final quickReads = _storyService.getQuickReads();
    final allStories = _storyService.getAllStories();
    final filteredStories = _selectedLevel == null
        ? allStories
        : allStories.where((s) => s.level == _selectedLevel).toList();

    final featuredStory =
        _featuredStory ?? (recommended.isNotEmpty ? recommended.first : null);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshHome,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      // Avatar
                      GestureDetector(
                        onTap: () => context.push('/settings'),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                KuwentoColors.pastelBlue,
                                KuwentoColors.pastelBlueLight,
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: user?.photoUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    user!.photoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kumusta, ${user?.firstName ?? 'Reader'}!',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? Colors.white70
                                        : KuwentoColors.textSecondary,
                                  ),
                            ),
                            Text(
                              'Ready to Read? 📚',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : KuwentoColors.textPrimary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      // Stars count
                      if (user != null && user.totalStars > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: KuwentoColors.buddyThinking
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 18,
                                color: KuwentoColors.buddyThinking,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${user.totalStars}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: KuwentoColors.buddyThinking,
                                ),
                              ),
                            ],
                          ),
                        ),
                      IconButton(
                        onPressed: () => context.push('/settings'),
                        icon: Icon(
                          Icons.settings_outlined,
                          color: isDark
                              ? Colors.white70
                              : KuwentoColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Guest prompt banner
              if (user?.isGuest == true)
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: GestureDetector(
                      onTap: () => context.push('/login?mode=signin'),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color:
                              KuwentoColors.pastelBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color:
                                KuwentoColors.pastelBlue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.cloud_sync,
                              color: KuwentoColors.pastelBlue,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'Sign in to save your progress across devices!',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: KuwentoColors.pastelBlue,
                                    ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: KuwentoColors.pastelBlue,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Featured Story
              if (featuredStory != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: FeaturedStoryCard(
                      story: featuredStory,
                      onTap: () => _navigateToStory(featuredStory),
                    ),
                  ),
                ),

              // Continue Reading Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xl),
                  child: StoryRow(
                    title: 'Recommended for You',
                    emoji: '⭐',
                    stories: recommended,
                    onStoryTap: _navigateToStory,
                    onSeeAll: () {
                      final ids = recommended.map((s) => s.id).join(',');
                      context.push('/stories/category/recommended?ids=$ids');
                    },
                  ),
                ),
              ),

              // Level-filtered stories under continue reading
              if (filteredStories.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: StoryRow(
                      title: _selectedLevel == null
                          ? 'All Levels'
                          : '${_selectedLevel!.name[0].toUpperCase()}${_selectedLevel!.name.substring(1)} Stories',
                      emoji: _selectedLevel == null
                          ? '🧭'
                          : switch (_selectedLevel!) {
                              StoryLevel.beginner => '🌱',
                              StoryLevel.intermediate => '🌿',
                              StoryLevel.advanced => '🌳',
                            },
                      stories: filteredStories,
                      onStoryTap: _navigateToStory,
                      onSeeAll: () => context.push(
                        '/stories/level/${_selectedLevel?.name ?? 'all'}',
                      ),
                      titleAddon: _buildLevelDropdown(context, isDark),
                    ),
                  ),
                )
              else if (_selectedLevel != null)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: AppSpacing.lg,
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                    ),
                    child: Text(
                      'No stories available for this level yet.',
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),

              // Filipino Tales Section
              if (filipinoTales.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: StoryRow(
                      title: 'Filipino Tales',
                      emoji: '🇵🇭',
                      stories: filipinoTales,
                      onStoryTap: _navigateToStory,
                      onSeeAll: () =>
                          context.push('/stories/category/filipino_tales'),
                    ),
                  ),
                ),

              // Quick Reads Section
              if (quickReads.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: StoryRow(
                      title: 'Quick Reads',
                      emoji: '⚡',
                      stories: quickReads,
                      onStoryTap: _navigateToStory,
                      onSeeAll: () =>
                          context.push('/stories/category/quick_reads'),
                    ),
                  ),
                ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshHome() async {
    if (!mounted) return;
    setState(() {
      _featuredStory = _pickRandomFeaturedStory();
      _recommendedStories = _shuffleRecommended();
    });
  }

  StoryModel? _pickRandomFeaturedStory() {
    // Featured pool is intentionally limited to the current home story set.
    final stories = _storyService.getRecommendedStories();
    if (stories.isEmpty) return null;
    if (stories.length == 1) return stories.first;

    StoryModel next = stories[_random.nextInt(stories.length)];
    if (_featuredStory != null && stories.length > 1) {
      while (next.id == _featuredStory!.id) {
        next = stories[_random.nextInt(stories.length)];
      }
    }
    return next;
  }

  List<StoryModel> _shuffleRecommended() {
    final stories = List<StoryModel>.from(_storyService.getAllStories());
    stories.shuffle(_random);
    if (stories.length > 5) {
      return stories.sublist(0, 5);
    }
    return stories;
  }

  void _navigateToStory(StoryModel story) {
    context.push('/story/${story.id}');
  }

  Widget _buildLevelDropdown(BuildContext context, bool isDark) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : KuwentoColors.textPrimary,
        );

    return PopupMenuButton<StoryLevel?>(
      tooltip: 'Select level',
      color: isDark ? KuwentoColors.cardDark : Colors.white,
      iconSize: 28,
      constraints: const BoxConstraints(minWidth: 0),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: isDark ? Colors.white70 : KuwentoColors.textSecondary,
      ),
      onSelected: (level) {
        setState(() {
          _selectedLevel = level;
        });
      },
      itemBuilder: (_) => [
        PopupMenuItem<StoryLevel?>(
          value: null,
          child: Row(
            children: [
              const Text('🧭'),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'All Levels',
                  style: textStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        ...StoryLevel.values.map(
          (level) => PopupMenuItem<StoryLevel?>(
            value: level,
            child: Row(
              children: [
                Text(_levelEmoji(level)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _levelDisplay(level),
                    style: textStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _levelDisplay(StoryLevel level) {
    switch (level) {
      case StoryLevel.beginner:
        return 'Beginner';
      case StoryLevel.intermediate:
        return 'Intermediate';
      case StoryLevel.advanced:
        return 'Advanced';
    }
  }

  String _levelEmoji(StoryLevel level) {
    switch (level) {
      case StoryLevel.beginner:
        return '🌱';
      case StoryLevel.intermediate:
        return '🌿';
      case StoryLevel.advanced:
        return '🌳';
    }
  }
}
