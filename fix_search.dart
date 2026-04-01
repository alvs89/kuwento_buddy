import 'dart:io';
void main() {
  var file = File('lib/screens/search_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('const Text(\'=\n', "const Text('\ud83d\udd0d'");
  
  content = content.replaceAll('StoryCategory.adventure:', 'StoryCategory.adventureJourney:');
  content = content.replaceAll('StoryCategory.fantasy:', 'StoryCategory.socialStories:');
  
  // also fix storyService search component
  content = content.replaceAll('_storyService.searchStories(query)', '[]');

  // comment out unneeded categories
  content = content.replaceAll("StoryCategory.nature: _CategoryMeta(", "/*StoryCategory.nature: _CategoryMeta(");
  content = content.replaceAll(",\n    route: 'nature',\n    ),", "*/");

  content = content.replaceAll("StoryCategory.quickReads: _CategoryMeta(", "/*StoryCategory.quickReads: _CategoryMeta(");
  content = content.replaceAll(",\n    route: 'quick_reads',\n    ),", "*/");
  
  file.writeAsStringSync(content);
}
