import 'dart:io';

void main() {
  final file = File('lib/screens/search_screen.dart');
  final bytes = file.readAsBytesSync();
  final cleanBytes = bytes.where((b) => b != 0).toList();
  final str = String.fromCharCodes(cleanBytes)
      .replaceAll('\r\r\n', '\n')
      .replaceAll('\r\n', '\n')
      .replaceAll('﻿', '')
      .replaceAll('ï¿½', '');
      
  file.writeAsStringSync(str);
  print('Done.');
}
