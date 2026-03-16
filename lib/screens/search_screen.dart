import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwentobuddy/models/story_model.dart';
import 'package:kuwentobuddy/services/story_service.dart';
import 'package:kuwentobuddy/theme.dart';

/// Search screen for finding stories
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final StoryService _storyService = StoryService();
  final TextEditingController _searchController = TextEditingController();
  List<StoryModel> _searchResults = [];
  bool _hasSearched = false;

  static const Map<StoryCategory, _CategoryMeta> _categoryMeta = {
    StoryCategory.filipinoTales: _CategoryMeta(
      title: 'Filipino Tales',
      emoji: '🇵🇭',
      color: KuwentoColors.softCoral,
      route: 'filipino_tales',
    ),
    StoryCategory.adventure: _CategoryMeta(
      title: 'Adventure',
      emoji: '🗺️',
      color: KuwentoColors.deepTeal,
      route: 'adventure',
    ),
    StoryCategory.fantasy: _CategoryMeta(
      title: 'Fantasy',
      emoji: '✨',
      color: KuwentoColors.buddyThinking,
      route: 'fantasy',
    ),
    StoryCategory.nature: _CategoryMeta(
      title: 'Nature',
      emoji: '🌿',
      color: KuwentoColors.buddyHappy,
      route: 'nature',
    ),
    StoryCategory.quickReads: _CategoryMeta(
      title: 'Quick Reads',
      emoji: '⚡',
      color: KuwentoColors.buddyEncouraging,
      route: 'quick_reads',
    ),
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _hasSearched = query.isNotEmpty;
      _searchResults = query.isEmpty ? [] : _storyService.searchStories(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLibraryStories = _storyService.getRecommendedStories();

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      KuwentoColors.backgroundDark,
                      KuwentoColors.backgroundDark,
                    ]
                  : [
                      KuwentoColors.deepTeal.withValues(alpha: 0.08),
                      KuwentoColors.backgroundLight,
                    ],
            ),
          ),
          child: Column(
            children: [
              _buildHeader(isDark),
              Expanded(
                child: _hasSearched
                    ? _buildSearchResults()
                    : _buildBrowseCategories(currentLibraryStories),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : KuwentoColors.textPrimary,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Find stories by title, author, or explore by genre.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : KuwentoColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: isDark ? KuwentoColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: isDark
                    ? KuwentoColors.deepTealLight.withValues(alpha: 0.3)
                    : KuwentoColors.deepTeal.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              style: TextStyle(
                color: isDark ? Colors.white : KuwentoColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search stories, authors...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : KuwentoColors.textMuted,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark
                      ? KuwentoColors.deepTealLight
                      : KuwentoColors.deepTeal,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color:
                              isDark ? Colors.white54 : KuwentoColors.textMuted,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 64)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No stories found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color:
                        isDark ? Colors.white70 : KuwentoColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try a different search term',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white54 : KuwentoColors.textMuted,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final story = _searchResults[index];
        return _buildSearchResultItem(story);
      },
    );
  }

  Widget _buildSearchResultItem(StoryModel story) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/story/${story.id}'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 360;
          final horizontalPadding =
              constraints.maxWidth < 340 ? AppSpacing.sm : AppSpacing.md;
          final imageSize =
              (constraints.maxWidth * 0.22).clamp(56.0, 80.0).toDouble();
          final contentGap = constraints.maxWidth < 340 ? 8.0 : AppSpacing.md;
          final showChevron = constraints.maxWidth >= 390;

          return Container(
            clipBehavior: Clip.antiAlias,
            padding: EdgeInsets.all(horizontalPadding),
            decoration: BoxDecoration(
              color: isDark ? KuwentoColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'story_cover_${story.id}',
                  child: Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      story.coverImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: KuwentoColors.deepTeal.withValues(alpha: 0.2),
                        child: const Icon(
                          Icons.auto_stories,
                          color: KuwentoColors.deepTeal,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: contentGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : KuwentoColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        story.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? Colors.white70
                                  : KuwentoColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  KuwentoColors.deepTeal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              '${story.levelEmoji} ${story.levelDisplay}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: KuwentoColors.deepTeal,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 12,
                                color: isDark
                                    ? Colors.white54
                                    : KuwentoColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${story.estimatedMinutes} min',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: isDark
                                          ? Colors.white54
                                          : KuwentoColors.textMuted,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (showChevron) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.chevron_right,
                    color: isDark ? Colors.white54 : KuwentoColors.textMuted,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBrowseCategories(List<StoryModel> currentLibraryStories) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryStoryCounts =
        _buildCategoryStoryCounts(currentLibraryStories);
    final categories = categoryStoryCounts.keys.toList()
      ..sort(
          (a, b) => _categoryMeta[a]!.title.compareTo(_categoryMeta[b]!.title));

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 600
                ? 2
                : 1;

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                0,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Browse Categories',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : KuwentoColors.textPrimary,
                                  ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: KuwentoColors.deepTeal.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        child: Text(
                          '${currentLibraryStories.length} stories',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: KuwentoColors.deepTeal,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ]),
              ),
            ),
            if (categories.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverToBoxAdapter(
                  child: _buildEmptyCategoriesCard(isDark),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.xxl,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: crossAxisCount == 1 ? 2.6 : 1.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = categories[index];
                      final meta = _categoryMeta[category]!;
                      final totalStories = categoryStoryCounts[category] ?? 0;
                      return _buildCategoryCard(meta, totalStories);
                    },
                    childCount: categories.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyCategoriesCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? KuwentoColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark
              ? KuwentoColors.deepTealLight.withValues(alpha: 0.24)
              : KuwentoColors.deepTeal.withValues(alpha: 0.12),
        ),
      ),
      child: Text(
        'No categories available in the current library yet.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white70 : KuwentoColors.textSecondary,
            ),
      ),
    );
  }

  Widget _buildCategoryCard(_CategoryMeta meta, int totalStories) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        context.push('/stories/category/${meta.route}?scope=current');
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              meta.color,
              meta.color.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: meta.color.withValues(alpha: isDark ? 0.25 : 0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(meta.emoji, style: const TextStyle(fontSize: 26)),
            const Spacer(),
            Text(
              meta.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _formatStoryCount(totalStories),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<StoryCategory, int> _buildCategoryStoryCounts(List<StoryModel> stories) {
    final counts = <StoryCategory, int>{};
    for (final story in stories) {
      for (final category in story.categories) {
        if (!_categoryMeta.containsKey(category)) continue;
        counts[category] = (counts[category] ?? 0) + 1;
      }
    }

    return counts;
  }

  String _formatStoryCount(int count) {
    return '$count ${count == 1 ? 'story' : 'stories'}';
  }
}

class _CategoryMeta {
  final String title;
  final String emoji;
  final Color color;
  final String route;

  const _CategoryMeta({
    required this.title,
    required this.emoji,
    required this.color,
    required this.route,
  });
}
