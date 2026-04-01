import 'package:flutter/foundation.dart';

class AppLanguageService extends ChangeNotifier {
  AppLanguageService({String initialLanguageCode = 'fil'})
      : _languageCode = initialLanguageCode;

  String _languageCode;

  String get languageCode => _languageCode;

  bool get isFilipino => _languageCode == 'fil';

  void setLanguage(String languageCode) {
    if (_languageCode == languageCode) return;
    _languageCode = languageCode;
    notifyListeners();
  }
}