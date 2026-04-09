import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwentobuddy/models/story_model.dart';
import 'package:kuwentobuddy/services/story_service.dart';
import 'package:kuwentobuddy/services/story_launch_service.dart';
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

  static final List<_BrowseGenreMeta> _browseGenres = [
    _BrowseGenreMeta(
      title: 'Filipino Legends & Myths',
      emoji: '🇵🇭',
      color: KuwentoColors.softCoral,
      subtitle: 'Origin legends and mythic Filipino stories',
      matches: (story) => _containsAnyTitle(story, const [
        'pinya',
        'parol',
        'bulkang mayon',
      ]),
    ),
    _BrowseGenreMeta(
      title: 'Filipino Folklore & Nature Tales',
      emoji: '🌿',
      color: KuwentoColors.buddyThinking,
      subtitle: 'Gentle folklore, symbols, and nature-inspired stories',
      matches: (story) => _containsAnyTitle(story, const [
        'huni ng duyan',
        'butil ng tala',
      ]),
    ),
    _BrowseGenreMeta(
      title: 'Filipino Family & Heritage Tales',
      emoji: '🏠',
      color: KuwentoColors.pastelBlue,
      subtitle: 'Homecoming, memory, and healing across generations',
      matches: (story) => _containsAnyTitle(story, const [
        'ang pamana ng lumang duyan',
        'pamana ng lumang duyan',
      ]),
    ),
    _BrowseGenreMeta(
      title: 'Ocean & Travel Adventures',
      emoji: '🌊',
      color: KuwentoColors.deepTeal,
      subtitle: 'Sea journeys, compass trails, and frozen expeditions',
      matches: (story) => _containsAnyTitle(story, const [
        'lia and the map of whispering waves',
        'the lost compass of lisbon',
        'the silent ship of the arctic night',
      ]),
    ),
    _BrowseGenreMeta(
      title: 'Fantasy Quests & Discovery',
      emoji: '🪄',
      color: KuwentoColors.buddyHappy,
      subtitle: 'Magic paths, strange lands, and wonder-filled quests',
      matches: (story) => _containsAnyTitle(story, const [
        'the clockmaker',
        'the journey of alice in the strange land',
      ]),
    ),
    _BrowseGenreMeta(
      title: 'School & Friendship Stories',
      emoji: '🏫',
      color: KuwentoColors.pastelBlue,
      subtitle: 'Classroom moments, welcome, and everyday kindness',
      matches: (story) => _containsAnyTitle(story, const [
        'the empty seat by the window',
      ]),
    ),
    _BrowseGenreMeta(
      title: 'Everyday Kindness & Responsibility',
      emoji: '🤲',
      color: KuwentoColors.buddyEncouraging,
      subtitle: 'Honesty, helpfulness, and small daily choices',
      matches: (story) => _containsAnyTitle(story, const [
        'the saturday market list',
        'a day in the helpful town',
        'the day maya handled the missing wallet',
      ]),
    ),
    _BrowseGenreMeta(
      title: 'Ethics & Future Worlds',
      emoji: '🤖',
      color: KuwentoColors.buddyThinking,
      subtitle: 'Future settings, rules, and big moral decisions',
      matches: (story) => _containsAnyTitle(story, const [
        'the ethics protocol of raven station',
      ]),
    ),
  ];

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
    final allStories = _storyService.getAllStories();

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
              _buildHeader(isDark, allStories.length),
              Expanded(
                child: _hasSearched
                    ? _buildSearchResults()
                    : _buildBrowseCategories(allStories, allStories.length),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, int totalStories) {
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
            'Find stories by title, author, or synopsis.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : KuwentoColors.textSecondary,
                  fontSize: 12,
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
                hintText: 'Search title, author, synopsis',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : KuwentoColors.textMuted,
                  fontSize: 14,
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
      onTap: () {
        openStoryFromCard(context, story);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
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
                Column(
                  mainAxisSize: MainAxisSize.min,
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
                            color:
                                KuwentoColors.deepTeal.withValues(alpha: 0.2),
                            child: const Icon(
                              Icons.auto_stories,
                              color: KuwentoColors.deepTeal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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

  Widget _buildBrowseCategories(
      List<StoryModel> allStories, int totalStoryCount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final genres = _browseGenres
        .map((genre) {
          final stories = allStories.where(genre.matches).toList();
          return _BrowseGenreGroup(meta: genre, stories: stories);
        })
        .where((group) => group.stories.isNotEmpty)
        .toList();

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
                          'Browse Genres',
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
                          '$totalStoryCount stories',
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
            if (genres.isEmpty)
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
                    mainAxisExtent: crossAxisCount == 1
                        ? 176
                        : crossAxisCount == 2
                            ? 168
                            : 162,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final group = genres[index];
                      return _buildGenreCard(group);
                    },
                    childCount: genres.length,
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

  Widget _buildGenreCard(_BrowseGenreGroup group) {
    final meta = group.meta;
    final stories = group.stories;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        final ids = stories.map((story) => story.id).join(',');
        final uri = Uri(
          path: '/stories/category/recommended',
          queryParameters: {
            'ids': ids,
            'title': meta.title,
          },
        );
        context.push(uri.toString());
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
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(meta.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  meta.title,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    height: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatStoryCount(stories.length),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              meta.subtitle,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.clip,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: 11,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatStoryCount(int count) {
    return '$count ${count == 1 ? 'story' : 'stories'}';
  }
}

bool _containsAnyTitle(StoryModel story, List<String> needles) {
  final title = story.title.toLowerCase();
  return needles.any((needle) => title.contains(needle.toLowerCase()));
}

class _BrowseGenreMeta {
  final String title;
  final String emoji;
  final Color color;
  final String subtitle;
  final bool Function(StoryModel story) matches;

  const _BrowseGenreMeta({
    required this.title,
    required this.emoji,
    required this.color,
    required this.subtitle,
    required this.matches,
  });
}

class _BrowseGenreGroup {
  final _BrowseGenreMeta meta;
  final List<StoryModel> stories;

  const _BrowseGenreGroup({required this.meta, required this.stories});
}
