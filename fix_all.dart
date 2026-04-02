import 'dart:io';

void main() {
  var file = File('lib/screens/my_stories_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(
    'StoryCategory.quickReads',
    'StoryCategory.filipinoTales',
  );
  file.writeAsStringSync(content);

  file = File('lib/screens/stories_list_screen.dart');
  content = file.readAsStringSync();
  content = content.replaceAll(
    "'quick_reads': StoryCategory.quickReads,",
    "'social': StoryCategory.socialStories,",
  );
  content = content.replaceAll(
    "'adventure': StoryCategory.adventure,",
    "'adventure': StoryCategory.adventureJourney,",
  );
  content = content.replaceAll("'fantasy': StoryCategory.fantasy,", "");
  content = content.replaceAll("'nature': StoryCategory.nature,", "");
  file.writeAsStringSync(content);

  stdout.writeln('Done quick edits');
}
