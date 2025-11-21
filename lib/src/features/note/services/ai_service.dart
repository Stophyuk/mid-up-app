import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/env/env_loader.dart';

abstract class AiService {
  Future<String> answerQuestion({
    required String question,
    required String context,
  });
}

/// Default stub for development. Replace with real GPT/Vision integration.
class StubAiService implements AiService {
  @override
  Future<String> answerQuestion({
    required String question,
    required String context,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    final summary = context.isEmpty
        ? '컨텍스트 없음'
        : context.substring(0, context.length.clamp(0, 160));
    return '[AI 미연동]\n질문: $question\n컨텍스트: $summary\n응답: 실제 API 연결 후 대체 예정입니다.';
  }
}

class EnvBackedAiService implements AiService {
  EnvBackedAiService({
    required this.endpoint,
    EnvLoader? loader,
  }) : _loader = loader ?? EnvLoader();

  final String endpoint;
  final EnvLoader _loader;
  static const _model = 'gpt-4o-mini';

  @override
  Future<String> answerQuestion({
    required String question,
    required String context,
  }) async {
    final apiKey = _loader.get('AI_API_KEY');
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('AI_API_KEY is not set');
    }
    final uri = Uri.parse(endpoint);
    final client = http.Client();
    try {
      final response = await client.post(
        uri,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a gentle math coach for struggling Korean students. Keep answers short and encouraging.',
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text':
                      '문맥:\n${context.isEmpty ? "없음" : context.substring(0, context.length.clamp(0, 2000))}\n\n질문:\n$question',
                }
              ],
            },
          ],
          'temperature': 0.2,
        }),
      );

      if (response.statusCode >= 400) {
        throw StateError('AI 호출 실패(${response.statusCode}): ${response.body}');
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>? ?? [];
      if (choices.isEmpty) throw StateError('AI 응답이 비었어요');
      final message = choices.first['message'] as Map<String, dynamic>? ?? {};
      final content = message['content'];
      if (content is String) return content.trim();
      if (content is List) {
        final textParts = content
            .whereType<Map<String, dynamic>>()
            .where((m) => m['type'] == 'text')
            .map((m) => m['text'] as String? ?? '')
            .join('\n')
            .trim();
        if (textParts.isNotEmpty) return textParts;
      }
      return 'AI 응답을 이해하지 못했어요. 잠시 후 다시 시도해주세요.';
    } finally {
      client.close();
    }
  }
}
