import 'dart:io';

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
    final summary = context.isEmpty ? '컨텍스트 없음' : context.substring(0, context.length.clamp(0, 160));
    return '[AI 미연동]\n질문: $question\n컨텍스트: $summary\n응답: 실제 API 연결 후 대체 예정입니다.';
  }
}

/// Example of loading an API key from environment variables (e.g., .env or IDE run config).
class EnvBackedAiService implements AiService {
  EnvBackedAiService({required this.endpoint});

  final String endpoint;

  @override
  Future<String> answerQuestion({
    required String question,
    required String context,
  }) async {
    final apiKey = Platform.environment['AI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('AI_API_KEY is not set');
    }
    // TODO: Invoke real AI API with [apiKey] and [endpoint].
    throw UnimplementedError('Connect AI API here');
  }
}
