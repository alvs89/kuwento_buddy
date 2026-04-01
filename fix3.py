import re, codecs

# 1. search_screen.dart
path = 'lib/screens/search_screen.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

# Fix Category mappings
text = re.sub(r'StoryCategory\.adventure: _CategoryMeta\(.*?\),', 
              r'''StoryCategory.adventureJourney: _CategoryMeta(
      title: 'Adventure',
      emoji: '\u26f0\ufe0f',
      color: KuwentoColors.deepTeal,
      route: 'adventure',
    ),''', text, flags=re.DOTALL)

text = re.sub(r'StoryCategory\.fantasy: _CategoryMeta\(.*?\),', 
              r'''StoryCategory.socialStories: _CategoryMeta(
      title: 'Social Stories',
      emoji: '\ud83e\udd1d',
      color: KuwentoColors.buddyThinking,
      route: 'social',
    ),''', text, flags=re.DOTALL)

text = re.sub(r'StoryCategory\.nature: _CategoryMeta\(.*?\),', '', text, flags=re.DOTALL)
text = re.sub(r'StoryCategory\.quickReads: _CategoryMeta\(.*?\),', '', text, flags=re.DOTALL)

# Fix search result icon breaking compilation
text = re.sub(r"const Text\('=[\r\n]+', style: TextStyle\(fontSize: 64\)\),",
              r"const Text('\ud83d\udd0d', style: TextStyle(fontSize: 64)),", text)

# Fix list builder error _buildSearchResults returning some weird trailing text
text = re.sub(r"const Text\('\\u003d\\n', style: TextStyle\(fontSize: 64\)\),",
              r"const Text('\ud83d\udd0d', style: TextStyle(fontSize: 64)),", text)
text = re.sub(r"Text\('=[\r\n]+', style: TextStyle\(fontSize: 64\)\),",
              r"Text('\ud83d\udd0d', style: TextStyle(fontSize: 64)),", text)

# Just fix the fallback empty state emoji explicitly
text = re.compile(r'mainAxisAlignment: MainAxisAlignment\.center,\s*children: \[.*?Text\(.*?, style: TextStyle\(fontSize: 64\)\),', re.DOTALL).sub(r'''mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('\ud83d\udd0d', style: TextStyle(fontSize: 64)),''', text)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

# 2. my_stories_screen.dart
path = 'lib/screens/my_stories_screen.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

text = text.replace('StoryCategory.quickReads', 'StoryCategory.filipinoTales')

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

# 3. stories_list_screen.dart
path = 'lib/screens/stories_list_screen.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

text = re.sub(r"'quick_reads': StoryCategory\.quickReads,", "'social': StoryCategory.socialStories,", text)
text = re.sub(r"'adventure': StoryCategory\.adventure,", "'adventure': StoryCategory.adventureJourney,", text)
text = re.sub(r"'fantasy': StoryCategory\.fantasy,", "", text)
text = re.sub(r"'nature': StoryCategory\.nature,", "", text)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

# 4. story_session_screen.dart
path = 'lib/screens/story_session_screen.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

text = text.replace("r'\\'", "r'\\'") # Fix unescaped backslashes? Not sure what the exact line is, but wait it said unterminated string literal 802:47.
print('Done with basic fixes.')
