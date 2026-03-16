import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:kuwentobuddy/models/user_model.dart';

class VoicePersona {
  final String id;
  final String name;
  final String description;
  final String accentLabel;
  final String accentLocale;
  final String gender; // 'male' or 'female'
  final List<String> preferredHints;
  final double pitch;
  final double speechRate;

  const VoicePersona({
    required this.id,
    required this.name,
    required this.description,
    required this.accentLabel,
    required this.accentLocale,
    required this.gender,
    required this.preferredHints,
    required this.pitch,
    required this.speechRate,
  });
}

/// Text-to-Speech service with bilingual support
class TTSService extends ChangeNotifier {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  String _currentLanguage = 'fil-PH';
  String _voiceGender = 'male';
  double _speechRate = 0.5;
  double _voiceSpeedMultiplier = 1.0;
  double _pitch = 1.05;
  String _selectedPersonaId = 'kuya_kiko';
  String _voiceOverLanguage = 'fil';

  static const List<VoicePersona> _personas = [
    VoicePersona(
      id: 'kuya_kiko',
      name: 'Kuya Kiko',
      description: 'Friendly kuya with clear, upbeat tone.',
      accentLabel: 'Filipino-English (Male)',
      accentLocale: 'en-US',
      gender: 'male',
      preferredHints: [
        'male',
        'kiko',
        'david',
        'james',
        'guy',
        'filipino',
        'tagalog',
      ],
      pitch: 0.98,
      speechRate: 0.48,
    ),
    VoicePersona(
      id: 'ate_aya',
      name: 'Ate Aya',
      description: 'Warm, encouraging ate storyteller.',
      accentLabel: 'Filipino-English (Female)',
      accentLocale: 'en-GB',
      gender: 'female',
      preferredHints: [
        'female',
        'aya',
        'samantha',
        'zira',
        'girl',
        'filipino',
        'tagalog',
      ],
      pitch: 1.05,
      speechRate: 0.46,
    ),
  ];

  bool get isSpeaking => _isSpeaking;
  String get currentLanguage => _currentLanguage;
  String get voiceGender => _voiceGender;
  String get selectedPersonaId => _selectedPersonaId;
  String get voiceOverLanguage => _voiceOverLanguage;
  double get voiceSpeedMultiplier => _voiceSpeedMultiplier;
  List<VoicePersona> get voicePersonas => _personas;

  // Backward-compatible getters for existing UI binding.
  String get selectedFemaleCharacterId => selectedPersonaId;
  List<VoicePersona> get femaleVoiceCharacters => voicePersonas;

  /// Initialize TTS
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setSharedInstance(true);

      // Set callbacks
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        notifyListeners();
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint('TTS Error: $msg');
        _isSpeaking = false;
        notifyListeners();
      });

      await _applySettings();
      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS initialization error: $e');
    }
  }

  /// Apply TTS settings from preferences
  Future<void> applyPreferences(UserPreferences preferences) async {
    _voiceSpeedMultiplier = _clampVoiceSpeed(preferences.voiceSpeed);
    _voiceOverLanguage = preferences.language == 'en' ? 'en' : 'fil';
    _currentLanguage = _effectiveVoiceLocale;
    _voiceGender = _selectedPersona.gender;
    await _applySettings();
    notifyListeners();
  }

  double _clampVoiceSpeed(double speed) {
    return speed.clamp(0.5, 2.0);
  }

  double _mapSpeedToRate(double speed) {
    // Map 0.5-2.0x UI speed to a stable flutter_tts rate range.
    final normalized = (_clampVoiceSpeed(speed) - 0.5) / 1.5;
    return 0.28 + (normalized * 0.42);
  }

  Future<void> _applySettings() async {
    try {
      final accentLocale = _effectiveVoiceLocale;
      _voiceGender = _selectedPersona.gender;
      await _setVoiceForLocale(accentLocale);
      _currentLanguage = accentLocale;
      final personaBaseRate = _selectedPersona.speechRate;
      final userPreferredRate = _mapSpeedToRate(_voiceSpeedMultiplier);
      _speechRate = ((personaBaseRate + userPreferredRate) / 2).clamp(0.28, 0.70);
      await _flutterTts.setSpeechRate(_speechRate);
      _pitch = _selectedPersona.pitch;
      await _flutterTts.setPitch(_pitch);
    } catch (e) {
      debugPrint('Error applying TTS settings: $e');
      await _applySystemFallbackVoice(_effectiveVoiceLocale);
    }
  }

  VoicePersona get _selectedPersona {
    return _personas.firstWhere(
      (c) => c.id == _selectedPersonaId,
      orElse: () => _personas.first,
    );
  }

  String get _effectiveVoiceLocale {
    if (_voiceOverLanguage == 'fil') {
      return 'fil-PH';
    }
    return _selectedPersona.accentLocale;
  }

  String _resolvePlaybackVoiceLocale(String normalizedRequestedLanguage) {
    if (normalizedRequestedLanguage.startsWith('fil')) {
      return 'fil-PH';
    }

    if (normalizedRequestedLanguage.startsWith('en-')) {
      return normalizedRequestedLanguage;
    }

    return 'en-US';
  }

  Future<void> _setVoiceForLocale(String locale) async {
    final selected = await _findVoiceForLocale(
      locale,
      persona: _selectedPersona,
    );
    if (selected == null) {
      await _applySystemFallbackVoice(locale);
      return;
    }

    final selectedLocale = (selected['locale'] ?? '').toString();
    try {
      if (selectedLocale.isNotEmpty) {
        await _flutterTts.setLanguage(selectedLocale);
      }
      await _flutterTts.setVoice({
        'name': selected['name'],
        'locale': selected['locale'],
      });
    } catch (e) {
      debugPrint('Failed to apply selected voice. Falling back: $e');
      await _applySystemFallbackVoice(locale);
    }
  }

  Future<void> _applySystemFallbackVoice(String preferredLocale) async {
    final normalized = _normalizeLocale(preferredLocale);
    try {
      await _flutterTts
          .setLanguage(normalized.startsWith('fil') ? 'fil-PH' : 'en-US');
    } catch (_) {
      await _flutterTts.setLanguage('en-US');
    }
  }

  Future<Map<String, dynamic>?> _findVoiceForLocale(
    String locale, {
    required VoicePersona persona,
  }) async {
    final rawVoices = await _flutterTts.getVoices;
    if (rawVoices == null) return null;

    final voices = List<Map<String, dynamic>>.from(
      List<dynamic>.from(rawVoices)
          .map((v) => Map<String, dynamic>.from(v as Map)),
    );

    final genderMatched = voices.where(
      (voice) => _matchesGender(voice, persona.gender),
    );

    // If no explicit gender match, try manual marker matching for persona gender before falling back.
    final manualGenderMatched = genderMatched.isEmpty
        ? voices.where(
            (voice) => _matchesGenderByMarkersOnly(voice, persona.gender),
          )
        : <Map<String, dynamic>>[];

    final candidates = genderMatched.isNotEmpty
        ? genderMatched.toList()
        : manualGenderMatched.isNotEmpty
            ? manualGenderMatched.toList()
            : voices; // ultimate fallback if device voices lack gender labels

    final normalizedLocale = _normalizeLocale(locale);

    final scored = candidates.map((voice) {
      return MapEntry(
        voice,
        _scoreCharacterVoice(
          voice: voice,
          normalizedLocale: normalizedLocale,
          persona: persona,
        ),
      );
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (scored.isEmpty) return null;

    final topScore = scored.first.value;
    final topCandidates = scored
        .where((entry) => entry.value == topScore)
        .map((entry) => entry.key)
        .toList();

    if (topCandidates.isEmpty) return scored.first.key;

    // Safety: if persona demands a gender and the top candidate(s) are the wrong gender, pick the first matching gender voice available.
    if (!_matchesGender(topCandidates.first, persona.gender)) {
      final strictGender = _firstVoiceByGender(voices, persona.gender);
      if (strictGender != null) return strictGender;
    }

    // Keep character choices distinct when multiple voices score equally.
    final characterIndex = _personas.indexWhere(
      (c) => c.id == persona.id,
    );
    final pickIndex =
        characterIndex < 0 ? 0 : characterIndex % topCandidates.length;

    return topCandidates[pickIndex];
  }

  bool _matchesGender(Map<String, dynamic> voice, String personaGender) {
    final gender = (voice['gender'] ?? '').toString().toLowerCase();
    final name = (voice['name'] ?? '').toString().toLowerCase();
    final id =
        (voice['identifier'] ?? voice['id'] ?? '').toString().toLowerCase();

    final target = personaGender.toLowerCase();
    if (target == 'male') {
      return gender == 'male' ||
          name.contains('male') ||
          id.contains('male') ||
          _looksMale(voice);
    }

    if (target == 'female') {
      if (gender == 'female' ||
          name.contains('female') ||
          id.contains('female')) {
        return true;
      }
      return !_looksMale(voice);
    }

    return true;
  }

  bool _matchesGenderByMarkersOnly(
    Map<String, dynamic> voice,
    String personaGender,
  ) {
    final name = (voice['name'] ?? '').toString().toLowerCase();
    final id =
        (voice['identifier'] ?? voice['id'] ?? '').toString().toLowerCase();

    const maleMarkers = [
      'male',
      'david',
      'james',
      'john',
      'michael',
      'george',
      'guy',
      'tom',
      'daniel',
      'paul',
      'ben',
      'ryan',
      'bryan',
      'kiko',
      'alex',
      'adam',
      'henry',
    ];

    const femaleMarkers = [
      'female',
      'samantha',
      'zira',
      'girl',
      'amy',
      'linda',
      'mary',
      'sarah',
      'kate',
      'olivia',
      'emma',
      'ava',
      'isabella',
      'sofia',
      'ava',
      'aya',
    ];

    if (personaGender.toLowerCase() == 'male') {
      return maleMarkers.any((m) => name.contains(m) || id.contains(m));
    }

    if (personaGender.toLowerCase() == 'female') {
      return femaleMarkers.any((m) => name.contains(m) || id.contains(m));
    }

    return false;
  }

  Map<String, dynamic>? _firstVoiceByGender(
    List<Map<String, dynamic>> voices,
    String personaGender,
  ) {
    final target = personaGender.toLowerCase();
    final gendered = voices.firstWhere(
      (voice) => _matchesGender(voice, target),
      orElse: () => <String, dynamic>{},
    );
    return gendered.isEmpty ? null : gendered;
  }

  bool _looksMale(Map<String, dynamic> voice) {
    final name = (voice['name'] ?? '').toString().toLowerCase();
    final gender = (voice['gender'] ?? '').toString().toLowerCase();
    final id =
        (voice['identifier'] ?? voice['id'] ?? '').toString().toLowerCase();

    const maleMarkers = [
      'male',
      'david',
      'james',
      'john',
      'michael',
      'george',
      'guy',
      'tom',
      'daniel',
      'paul',
      'ben',
      'ryan',
      'bryan',
      'kiko',
    ];

    return gender == 'male' ||
        maleMarkers.any((m) => name.contains(m) || id.contains(m));
  }

  bool _isFilipinoFluentVoice(Map<String, dynamic> voice) {
    final locale = _normalizeLocale((voice['locale'] ?? '').toString());
    final name = (voice['name'] ?? '').toString().toLowerCase();
    final id =
        (voice['identifier'] ?? voice['id'] ?? '').toString().toLowerCase();

    return locale.startsWith('fil') ||
        locale.startsWith('tl') ||
        name.contains('filipino') ||
        name.contains('tagalog') ||
        id.contains('filipino') ||
        id.contains('tagalog');
  }

  int _scoreCharacterVoice({
    required Map<String, dynamic> voice,
    required String normalizedLocale,
    required VoicePersona persona,
  }) {
    final locale = _normalizeLocale((voice['locale'] ?? '').toString());
    final name = (voice['name'] ?? '').toString().toLowerCase();
    final id =
        (voice['identifier'] ?? voice['id'] ?? '').toString().toLowerCase();
    final languagePrefix = normalizedLocale.split('-').first;

    var score = 0;

    if (locale == normalizedLocale) {
      score += 50;
    } else if (locale.startsWith('$languagePrefix-')) {
      score += 25;
    }

    if (normalizedLocale == 'fil-ph' && _isFilipinoFluentVoice(voice)) {
      score += 40;
    }

    for (final hint in persona.preferredHints) {
      final normalizedHint = hint.toLowerCase();
      if (name.contains(normalizedHint) ||
          id.contains(normalizedHint) ||
          locale.contains(normalizedHint)) {
        score += 18;
      }
    }

    final genderMatch = _matchesGender(voice, persona.gender);
    if (genderMatch) {
      score += 80; // Strongly prefer matching gender over locale when needed
    }

    return score;
  }

  String _normalizeLocale(String locale) {
    return locale.trim().toLowerCase().replaceAll('_', '-');
  }

  /// Speak text with automatic language detection
  Future<void> speak(String text, {String? language}) async {
    if (!_isInitialized) await initialize();

    try {
      if (_isSpeaking) {
        await stop();
      }

      // Story-provided language always takes precedence.
      final lang = language ?? _effectiveVoiceLocale;
      final normalizedLang = _normalizeLocale(lang);

      final playbackVoiceLocale = _resolvePlaybackVoiceLocale(normalizedLang);
      _currentLanguage = playbackVoiceLocale;
      await _setVoiceForLocale(playbackVoiceLocale);

      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TTS speak error: $e');
      try {
        await _applySystemFallbackVoice(_effectiveVoiceLocale);
        await _flutterTts.speak(text);
      } catch (fallbackError) {
        debugPrint('TTS fallback speak also failed: $fallbackError');
      }
    }
  }

  /// Speak with SSML for Filipino pronunciation
  Future<void> speakWithSSML(String ssmlText) async {
    if (!_isInitialized) await initialize();

    try {
      await stop();

      // Strip SSML tags for basic TTS (SSML support varies by platform)
      final plainText = ssmlText
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      await _flutterTts.speak(plainText);
    } catch (e) {
      debugPrint('TTS SSML speak error: $e');
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      notifyListeners();
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
  }

  /// Pause speaking
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
      _isSpeaking = false;
      notifyListeners();
    } catch (e) {
      debugPrint('TTS pause error: $e');
    }
  }

  /// Set language
  Future<void> setLanguage(String language) async {
    await setVoiceOverLanguage(
        _normalizeLocale(language).startsWith('fil') ? 'fil' : 'en');
  }

  Future<void> setVoiceOverLanguage(String languageCode) async {
    _voiceOverLanguage = languageCode == 'en' ? 'en' : 'fil';
    _currentLanguage = _effectiveVoiceLocale;
    await _setVoiceForLocale(_effectiveVoiceLocale);
    notifyListeners();
  }

  /// Set selected voice persona.
  Future<void> setVoicePersona(String personaId) async {
    final exists = _personas.any((c) => c.id == personaId);
    if (!exists) return;

    _selectedPersonaId = personaId;
    _voiceGender = _selectedPersona.gender;
    await _applySettings();
    notifyListeners();
  }

  Future<void> setVoiceSpeed(double speed) async {
    _voiceSpeedMultiplier = _clampVoiceSpeed(speed);
    await _applySettings();
    notifyListeners();
  }

  // Backward-compatible wrapper used by current settings UI.
  Future<void> setFemaleVoiceCharacter(String characterId) async {
    await setVoicePersona(characterId);
  }

  Future<void> setVoiceGender(String gender) async {
    _voiceGender = gender.toLowerCase() == 'male' ? 'male' : 'female';
    await _applySettings();
    notifyListeners();
  }

  /// Dispose
  @override
  void dispose() {
    _flutterTts.stop();
    _isInitialized = false;
    super.dispose();
  }
}
