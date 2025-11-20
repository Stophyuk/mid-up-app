import 'dart:io';

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

/// Example of how a real OCR service would access an API key.
/// In production, load from env vars or a secure store; do not hardcode.
class EnvBackedOcrService implements OcrService {
  EnvBackedOcrService({required this.endpoint});

  final String endpoint;

  @override
  Future<String> process(String fileName) async {
    final apiKey = Platform.environment['OCR_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('OCR_API_KEY is not set');
    }
    // TODO: Invoke real OCR API using [endpoint] and [apiKey].
    throw UnimplementedError('Connect OCR API here');
  }
}
