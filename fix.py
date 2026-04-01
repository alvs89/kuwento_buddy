import codecs
path = 'lib/screens/search_screen.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

text = text.replace("emoji: '('',", "emoji: '??',")
text = text.replace("/*StoryCategory.nature: _CategoryMeta(", "  ")
text = text.replace(",\n    route: 'nature',\n    ),\n*/", " ")
text = text.replace("/*StoryCategory.quickReads: _CategoryMeta(", " ")
text = text.replace(",\n    route: 'quick_reads',\n    ),\n*/", "\n  };\n\n")

# there was an issue with _CategoryMeta missing? 
# "The method '_CategoryMeta' isn't defined for the type '_SearchScreenState'"
# That is because the inner class _CategoryMeta was perhaps missing at the bottom?

with codecs.open('lib/screens/story_session_screen.dart', 'r', 'utf-8') as f:
    story = f.read()

# Fix story_session_screen.dart
import re
story = story.replace("r'\'", r"'\'")
with codecs.open('lib/screens/story_session_screen.dart', 'w', 'utf-8') as f:
    f.write(story)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

