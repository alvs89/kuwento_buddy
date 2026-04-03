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
  bool _isPaused = false;
  bool _pauseRequested = false;
  bool _pauseInProgress = false;
  bool _ttsEnabled = true;
  String _currentLanguage = 'fil-PH';
  double _speechRate = 0.5;
  double _voiceSpeedMultiplier = 1.0;
  double _pitch = 1.05;
  String _selectedPersonaId = 'kuya_kiko';
  String _voiceOverLanguage = 'fil';
  String? _currentSpeechText;
  String? _currentSpeechLanguage;
  int _currentSpeechStart = 0;
  int _speechBaseOffset = 0;
  String? _pausedSpeechText;
  String? _pausedSpeechLanguage;
  int _pausedSpeechStart = 0;

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
  bool get isPaused => _isPaused;
  bool get isTtsEnabled => _ttsEnabled;
  String get currentLanguage => _currentLanguage;
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
      await _flutterTts.awaitSpeakCompletion(true);

      // Set callbacks
      _flutterTts.setProgressHandler((text, start, end, word) {
        // Only update progress if we're actually speaking (not paused)
        if (_isSpeaking) {
          // Keep an absolute character offset for where speech has reached.
          // Some engines provide weak offsets, so fall back to spoken-word matching.
          final absoluteOffset = _resolveAbsoluteProgressOffset(
            text,
            start,
            end,
            word,
          );
          if (absoluteOffset > _currentSpeechStart) {
            _currentSpeechStart = absoluteOffset;
          }
        }
      });

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        _isPaused = false;
        _pauseRequested = false;
        notifyListeners();
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _isPaused = false;
        _pauseRequested = false;
        _speechBaseOffset = 0;
        _clearSpeechSnapshot();
        notifyListeners();
      });

      _flutterTts.setPauseHandler(() {
        _capturePausedSpeechSnapshot();

        _isSpeaking = false;
        _isPaused = true;
        _pauseRequested = false;
        notifyListeners();
      });

      _flutterTts.setContinueHandler(() {
        _isSpeaking = true;
        _isPaused = false;
        _pauseRequested = false;
        notifyListeners();
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
        final shouldRemainPaused = _pauseRequested || _pauseInProgress;
        if (shouldRemainPaused) {
          _isPaused = true;
        } else {
          _isPaused = false;
          _speechBaseOffset = 0;
          _clearSpeechSnapshot();
        }
        _pauseRequested = false;
        _pauseInProgress = false;
        notifyListeners();
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint('TTS Error: $msg');
        _isSpeaking = false;
        _isPaused = false;
        _pauseRequested = false;
        _speechBaseOffset = 0;
        _clearSpeechSnapshot();
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
    _ttsEnabled = true;
    _currentLanguage = _effectiveVoiceLocale;
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
      await _setVoiceForLocale(accentLocale);
      _currentLanguage = accentLocale;
      final personaBaseRate = _selectedPersona.speechRate;
      final userPreferredRate = _mapSpeedToRate(_voiceSpeedMultiplier);
      _speechRate = ((personaBaseRate + userPreferredRate) / 2).clamp(
        0.28,
        0.70,
      );
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
      await _flutterTts.setLanguage(
        normalized.startsWith('fil') ? 'fil-PH' : 'en-US',
      );
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
      List<dynamic>.from(
        rawVoices,
      ).map((v) => Map<String, dynamic>.from(v as Map)),
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
    }).toList()..sort((a, b) => b.value.compareTo(a.value));

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
    final characterIndex = _personas.indexWhere((c) => c.id == persona.id);
    final pickIndex = characterIndex < 0
        ? 0
        : characterIndex % topCandidates.length;

    return topCandidates[pickIndex];
  }

  bool _matchesGender(Map<String, dynamic> voice, String personaGender) {
    final gender = (voice['gender'] ?? '').toString().toLowerCase();
    final name = (voice['name'] ?? '').toString().toLowerCase();
    final id = (voice['identifier'] ?? voice['id'] ?? '')
        .toString()
        .toLowerCase();

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
    final id = (voice['identifier'] ?? voice['id'] ?? '')
        .toString()
        .toLowerCase();

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
    final id = (voice['identifier'] ?? voice['id'] ?? '')
        .toString()
        .toLowerCase();

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
    final id = (voice['identifier'] ?? voice['id'] ?? '')
        .toString()
        .toLowerCase();

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
    final id = (voice['identifier'] ?? voice['id'] ?? '')
        .toString()
        .toLowerCase();
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
    if (!_ttsEnabled) return;

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

      _currentSpeechText = text;
      _currentSpeechLanguage = playbackVoiceLocale;
      _currentSpeechStart = 0;
      _speechBaseOffset = 0;
      _pauseInProgress = false;
      _clearPausedSpeechSnapshot();
      _isPaused = false;

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

  /// Resume the most recently paused utterance.
  /// Extracts remaining text from saved position and re-speaks it.
  /// Returns true when a resume playback request is started.
  Future<bool> resume() async {
    if (!_isInitialized) await initialize();
    if (!_ttsEnabled || !_isPaused) return false;

    if (_pausedSpeechText == null || _pausedSpeechText!.isEmpty) {
      // Heal stale paused state so callers can fall back to a fresh speak.
      _isPaused = false;
      _pauseRequested = false;
      _pauseInProgress = false;
      _speechBaseOffset = 0;
      notifyListeners();
      return false;
    }

    try {
      final resumeLanguage = _pausedSpeechLanguage ?? _currentLanguage;
      final normalizedLang = _normalizeLocale(resumeLanguage);
      final playbackVoiceLocale = _resolvePlaybackVoiceLocale(normalizedLang);

      // Safely clamp the resume position to valid text boundaries
      final resumeStart = _normalizeResumeStart(
        _pausedSpeechText!,
        _pausedSpeechStart,
      );

      // Extract remaining text from the paused position
      final textToSpeak = resumeStart < _pausedSpeechText!.length
          ? _pausedSpeechText!.substring(resumeStart)
          : '';

      if (textToSpeak.isEmpty) {
        _isSpeaking = false;
        _isPaused = false;
        _pauseRequested = false;
        _pauseInProgress = false;
        _speechBaseOffset = 0;
        _clearPausedSpeechSnapshot();
        notifyListeners();
        return false;
      }

      _currentLanguage = playbackVoiceLocale;
      await _setVoiceForLocale(playbackVoiceLocale);

      // Set state for playback
      _currentSpeechText = _pausedSpeechText;
      _currentSpeechLanguage = playbackVoiceLocale;
      _currentSpeechStart = resumeStart;
      _speechBaseOffset = resumeStart;
      _pauseInProgress = false;
      _isSpeaking = true;
      _isPaused = false;
      notifyListeners();

      // Speak the remaining text from the saved offset
      await _flutterTts.speak(textToSpeak);
      _clearPausedSpeechSnapshot();
      return true;
    } catch (e) {
      debugPrint('TTS resume error: $e');
      _isSpeaking = false;
      _isPaused = false;
      _pauseRequested = false;
      _pauseInProgress = false;
      notifyListeners();
      return false;
    }
  }

  /// Speak with SSML for Filipino pronunciation
  Future<void> speakWithSSML(String ssmlText) async {
    if (!_isInitialized) await initialize();
    if (!_ttsEnabled) return;

    try {
      await stop();

      // Strip SSML tags for basic TTS (SSML support varies by platform)
      final plainText = ssmlText
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      await speak(plainText, language: _currentLanguage);
    } catch (e) {
      debugPrint('TTS SSML speak error: $e');
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      _isPaused = false;
      _pauseRequested = false;
      _speechBaseOffset = 0;
      _pauseInProgress = false;
      _clearSpeechSnapshot();
      notifyListeners();
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
  }

  /// Pause speaking
  Future<void> pause() async {
    try {
      if (!_ttsEnabled || !_isSpeaking) return;
      if (_isPaused) return;

      _pauseInProgress = true;
      _pauseRequested = true;

      // Capture current playback state before pausing
      _capturePausedSpeechSnapshot();

      // Hard stop playback so it cannot continue in the background.
      _isSpeaking = false;
      await _flutterTts.stop();
      _capturePausedSpeechSnapshot();

      _isSpeaking = false;
      _isPaused = true;
      _pauseRequested = false;
      _pauseInProgress = false;

      notifyListeners();
    } catch (e) {
      debugPrint('TTS pause error: $e');
      _isSpeaking = false;
      _isPaused = true;
      _pauseRequested = false;
      _pauseInProgress = false;
      notifyListeners();
    }
  }

  void _capturePausedSpeechSnapshot() {
    _pausedSpeechText = _currentSpeechText;
    _pausedSpeechLanguage = _currentSpeechLanguage ?? _currentLanguage;
    final activeText = _pausedSpeechText;
    if (activeText == null || activeText.isEmpty) {
      _pausedSpeechStart = 0;
      return;
    }
    _pausedSpeechStart = _normalizeResumeStart(activeText, _currentSpeechStart);
  }

  int _resolveAbsoluteProgressOffset(
    String text,
    int start,
    int end,
    String word,
  ) {
    var localOffset = end > start ? end : start;
    final trimmedWord = word.trim();

    if (localOffset <= 0 && trimmedWord.isNotEmpty && text.isNotEmpty) {
      final normalizedText = text.toLowerCase();
      final normalizedWord = trimmedWord.toLowerCase();

      var searchFrom = _currentSpeechStart - _speechBaseOffset;
      if (searchFrom < 0) {
        searchFrom = 0;
      } else if (searchFrom > text.length) {
        searchFrom = text.length;
      }

      var wordIndex = normalizedText.indexOf(normalizedWord, searchFrom);
      if (wordIndex < 0 && searchFrom > 0) {
        wordIndex = normalizedText.indexOf(normalizedWord);
      }

      if (wordIndex >= 0) {
        localOffset = wordIndex + trimmedWord.length;
      }
    }

    final totalLength = _currentSpeechText?.length ?? text.length;
    var absoluteOffset = localOffset + _speechBaseOffset;
    if (absoluteOffset < 0) {
      absoluteOffset = 0;
    } else if (absoluteOffset > totalLength) {
      absoluteOffset = totalLength;
    }

    return absoluteOffset;
  }

  int _normalizeResumeStart(String text, int candidateStart) {
    if (text.isEmpty) return 0;
    return candidateStart.clamp(0, text.length);
  }

  Future<void> setTtsEnabled(bool enabled) async {
    _ttsEnabled = true;
    notifyListeners();
  }

  /// Set language
  Future<void> setLanguage(String language) async {
    await setVoiceOverLanguage(
      _normalizeLocale(language).startsWith('fil') ? 'fil' : 'en',
    );
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

  /// Dispose
  @override
  void dispose() {
    _flutterTts.stop();
    _isInitialized = false;
    super.dispose();
  }

  void _clearSpeechSnapshot() {
    _currentSpeechText = null;
    _currentSpeechLanguage = null;
    _currentSpeechStart = 0;
    _speechBaseOffset = 0;
    _pauseInProgress = false;
  }

  void _clearPausedSpeechSnapshot() {
    _pausedSpeechText = null;
    _pausedSpeechLanguage = null;
    _pausedSpeechStart = 0;
  }
}
