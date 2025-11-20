import 'dart:async';

class FakeOcrService {
  Future<String> process(String fileName) async {
    await Future.delayed(const Duration(seconds: 1));
    return '[OCR:$fileName] (x² + 5x + 6 = 0) 같은 형식의 문제가 감지되었습니다.';
  }
}
