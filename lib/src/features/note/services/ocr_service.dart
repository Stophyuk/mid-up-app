abstract class OcrService {
  Future<String> process(String fileName);
}

/// Default stub for development. Replace with real Vision/OCR implementation.
class StubOcrService implements OcrService {
  @override
  Future<String> process(String fileName) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return '[OCR 미연동] $fileName 처리 완료';
  }
}
