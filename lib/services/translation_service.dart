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

  final Map<String, String> _cache = {};

  bool get isConfigured => true;

  Future<String> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final cleanedText = text.trim();
    if (cleanedText.isEmpty || sourceLanguage == targetLanguage) {
      return text;
    }

    final cacheKey = '$sourceLanguage->$targetLanguage::$cleanedText';
    final cached = _cache[cacheKey];
    if (cached != null) {
      return cached;
    }

    try {
      final uri = Uri.https(_apiHost, _apiPath, {
        'client': 'gtx',
        'sl': sourceLanguage,
        'tl': targetLanguage,
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
      _cache[cacheKey] = normalized;
      return normalized;
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
}
