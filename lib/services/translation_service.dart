import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Runtime translation service using a free Google Translate endpoint.
class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  static const String _apiHost = 'translate.googleapis.com';
  static const String _apiPath = '/translate_a/single';
  static const int _maxChunkLength = 750;
  static const Map<String, String> _targetedTranslationOverrides = {
    'en->tl::Correct! Returning the extra change protected the trust placed in Jun.':
        'Tama! Sa pagbabalik ni Jun ng sobrang sukli, napangalagaan niya ang tiwalang ibinigay sa kanya.',
  };

  final Map<String, String> _cache = {};

  bool get isConfigured => true;

  Future<String> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    bool preferFemaleSubject = false,
  }) async {
    final cleanedText = text.trim();
    if (cleanedText.isEmpty || sourceLanguage == targetLanguage) {
      return text;
    }

    final cacheKey =
        '$sourceLanguage->$targetLanguage${preferFemaleSubject ? '::female' : ''}::$cleanedText';
    final cached = _cache[cacheKey];
    if (cached != null) {
      return _finalizeTranslatedText(
        translatedText: cached,
        originalText: cleanedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        preferFemaleSubject: preferFemaleSubject,
      );
    }

    if (cleanedText.length > _maxChunkLength) {
      final translated = await _translateChunkedText(
        text: cleanedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        preferFemaleSubject: preferFemaleSubject,
      );
      if (translated.trim().isNotEmpty && translated.trim() != cleanedText) {
        _cache[cacheKey] = _finalizeTranslatedText(
          translatedText: translated,
          originalText: cleanedText,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
          preferFemaleSubject: preferFemaleSubject,
        );
      }
      return _finalizeTranslatedText(
        translatedText: translated,
        originalText: cleanedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        preferFemaleSubject: preferFemaleSubject,
      );
    }

    final translated = await _translateSingleChunk(
      text: cleanedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      preferFemaleSubject: preferFemaleSubject,
    );

    if (translated.trim().isNotEmpty) {
      _cache[cacheKey] = _finalizeTranslatedText(
        translatedText: translated,
        originalText: cleanedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        preferFemaleSubject: preferFemaleSubject,
      );
    }

    return _finalizeTranslatedText(
      translatedText: translated,
      originalText: cleanedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      preferFemaleSubject: preferFemaleSubject,
    );
  }

  Future<String> _translateChunkedText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    bool preferFemaleSubject = false,
  }) async {
    final paragraphBlocks = text.split(RegExp(r'\n\s*\n'));
    final translatedBlocks = <String>[];

    for (final block in paragraphBlocks) {
      final trimmedBlock = block.trim();
      if (trimmedBlock.isEmpty) {
        translatedBlocks.add('');
        continue;
      }

      if (trimmedBlock.length <= _maxChunkLength) {
        translatedBlocks.add(
          await _translateSingleChunk(
            text: trimmedBlock,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            preferFemaleSubject: preferFemaleSubject,
          ),
        );
        continue;
      }

      final sentenceChunks = _splitIntoChunks(trimmedBlock);
      final translatedSentences = <String>[];

      for (final chunk in sentenceChunks) {
        translatedSentences.add(
          await _translateSingleChunk(
            text: chunk,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            preferFemaleSubject: preferFemaleSubject,
          ),
        );
      }

      translatedBlocks.add(translatedSentences.join(' '));
    }

    final translated = translatedBlocks.join('\n\n').trim();
    return translated.isEmpty ? text : _decodeHtmlEntities(translated);
  }

  List<String> _splitIntoChunks(String text) {
    final sentenceLikeParts = text.split(RegExp(r'(?<=[.!?])\s+'));
    final chunks = <String>[];
    var buffer = StringBuffer();

    void flushBuffer() {
      final content = buffer.toString().trim();
      if (content.isNotEmpty) {
        chunks.add(content);
      }
      buffer = StringBuffer();
    }

    for (final part in sentenceLikeParts) {
      final trimmedPart = part.trim();
      if (trimmedPart.isEmpty) continue;

      if (trimmedPart.length > _maxChunkLength) {
        flushBuffer();
        chunks.addAll(_splitVeryLongText(trimmedPart));
        continue;
      }

      if (buffer.isEmpty) {
        buffer.write(trimmedPart);
        continue;
      }

      if (buffer.length + 1 + trimmedPart.length <= _maxChunkLength) {
        buffer.write(' ');
        buffer.write(trimmedPart);
      } else {
        flushBuffer();
        buffer.write(trimmedPart);
      }
    }

    flushBuffer();
    return chunks;
  }

  List<String> _splitVeryLongText(String text) {
    final words = text.split(RegExp(r'\s+'));
    final chunks = <String>[];
    final buffer = StringBuffer();

    for (final word in words) {
      if (word.isEmpty) continue;
      if (buffer.isEmpty) {
        buffer.write(word);
        continue;
      }

      if (buffer.length + 1 + word.length <= _maxChunkLength) {
        buffer.write(' ');
        buffer.write(word);
      } else {
        chunks.add(buffer.toString().trim());
        buffer.clear();
        buffer.write(word);
      }
    }

    final remainder = buffer.toString().trim();
    if (remainder.isNotEmpty) {
      chunks.add(remainder);
    }

    return chunks;
  }

  Future<String> _translateSingleChunk({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    bool preferFemaleSubject = false,
  }) async {
    final cleanedText = text.trim();
    if (cleanedText.isEmpty || sourceLanguage == targetLanguage) {
      return text;
    }

    final cacheKey =
        '$sourceLanguage->$targetLanguage${preferFemaleSubject ? '::female' : ''}::$cleanedText';
    final cached = _cache[cacheKey];
    if (cached != null) {
      return cached;
    }

    final apiSourceLanguage = _normalizeLanguageCode(sourceLanguage);
    final apiTargetLanguage = _normalizeLanguageCode(targetLanguage);

    try {
      final uri = Uri.https(_apiHost, _apiPath, {
        'client': 'gtx',
        'sl': apiSourceLanguage,
        'tl': apiTargetLanguage,
        'dt': 't',
        'q': cleanedText,
      });

      final response = await http.get(
        uri,
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint(
          'Translation request failed: ${response.statusCode} ${response.body}',
        );
        return text;
      }

      final decoded = jsonDecode(response.body) as List<dynamic>;
      final translationChunks = decoded.isNotEmpty && decoded.first is List
          ? decoded.first as List<dynamic>
          : const <dynamic>[];

      final buffer = StringBuffer();
      for (final chunk in translationChunks) {
        if (chunk is List && chunk.isNotEmpty) {
          final piece = chunk.first?.toString() ?? '';
          if (piece.isNotEmpty) {
            buffer.write(piece);
          }
        }
      }

      final translated = buffer.toString();

      if (translated.trim().isEmpty) {
        return text;
      }

      final normalized = _decodeHtmlEntities(translated.trim());
      final adjusted = _finalizeTranslatedText(
        translatedText: normalized,
        originalText: cleanedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        preferFemaleSubject: preferFemaleSubject,
      );
      _cache[cacheKey] = adjusted;
      return adjusted;
    } catch (e) {
      debugPrint('Translation error: $e');
      return text;
    }
  }

  String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }

  String _normalizeLanguageCode(String languageCode) {
    switch (languageCode) {
      case 'fil':
        return 'tl';
      default:
        return languageCode;
    }
  }

  String _applyPronounPreference({
    required String translatedText,
    required String originalText,
    required String sourceLanguage,
    required String targetLanguage,
    required bool preferFemaleSubject,
  }) {
    if (!preferFemaleSubject) return translatedText;
    if (!_isFilipinoToEnglish(sourceLanguage, targetLanguage)) {
      return translatedText;
    }

    return _swapToFemalePronouns(translatedText);
  }

  String _finalizeTranslatedText({
    required String translatedText,
    required String originalText,
    required String sourceLanguage,
    required String targetLanguage,
    required bool preferFemaleSubject,
  }) {
    var adjusted = _applyPronounPreference(
      translatedText: translatedText,
      originalText: originalText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      preferFemaleSubject: preferFemaleSubject,
    );
    adjusted = _applyTargetedOverride(
      translatedText: adjusted,
      originalText: originalText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );
    adjusted = _restoreKnownNames(
      translatedText: adjusted,
      originalText: originalText,
    );
    return adjusted;
  }

  String _applyTargetedOverride({
    required String translatedText,
    required String originalText,
    required String sourceLanguage,
    required String targetLanguage,
  }) {
    final normalizedSource = _normalizeLanguageCode(sourceLanguage);
    final normalizedTarget = _normalizeLanguageCode(targetLanguage);
    final override = _targetedTranslationOverrides[
        '$normalizedSource->$normalizedTarget::$originalText'];
    return override ?? translatedText;
  }

  String _restoreKnownNames({
    required String translatedText,
    required String originalText,
  }) {
    var adjusted = translatedText;

    if (RegExp(r'\bJun\b').hasMatch(originalText)) {
      adjusted = adjusted.replaceAllMapped(
        RegExp(r'\bHun\b', caseSensitive: false),
        (match) => _matchCasing(match.group(0) ?? 'Hun', 'Jun'),
      );
    }

    return adjusted;
  }

  bool _isFilipinoToEnglish(String source, String target) {
    final normalizedSource = _normalizeLanguageCode(source);
    final normalizedTarget = _normalizeLanguageCode(target);
    return normalizedSource == 'tl' && normalizedTarget == 'en';
  }

  String _swapToFemalePronouns(String text) {
    const replacements = {
      'he': 'she',
      'him': 'her',
      'his': 'her',
      'himself': 'herself',
      'boy': 'girl',
      'boys': 'girls',
      'son': 'daughter',
      'sons': 'daughters',
      'grandfather': 'grandmother',
      'grandpa': 'grandma',
    };

    return text.replaceAllMapped(
      RegExp(
        r'\b(he|him|his|himself|boy|boys|son|sons|grandfather|grandpa)\b',
        caseSensitive: false,
      ),
      (match) {
        final original = match.group(0)!;
        final lower = original.toLowerCase();
        final replacement = replacements[lower] ?? original;

        if (_isAllCaps(original)) return replacement.toUpperCase();
        if (_isCapitalized(original)) {
          return replacement[0].toUpperCase() + replacement.substring(1);
        }
        return replacement;
      },
    );
  }

  bool _isAllCaps(String value) {
    return value.isNotEmpty &&
        value.toUpperCase() == value &&
        value.toLowerCase() != value;
  }

  bool _isCapitalized(String value) {
    return value.isNotEmpty && value[0].toUpperCase() == value[0];
  }

  String _matchCasing(String original, String replacement) {
    if (_isAllCaps(original)) return replacement.toUpperCase();
    if (_isCapitalized(original)) {
      return replacement[0].toUpperCase() + replacement.substring(1);
    }
    return replacement.toLowerCase();
  }
}
