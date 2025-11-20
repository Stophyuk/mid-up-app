import 'dart:async';

class FakeAiService {
  Future<String> answerQuestion(String question, String context) async {
    await Future.delayed(const Duration(seconds: 1));
    return '질문: $question\n\n컨텍스트 요약: ${context.isEmpty ? '제공된 OCR 데이터가 없습니다.' : context.substring(0, context.length.clamp(0, 120))}\n\nAI: 우선 인수분해를 통한 근 찾기를 연습해보면 좋아요.';
  }
}
