import 'dart:convert';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart' as gauth;
import 'package:http/http.dart' as http;

import '../../../core/env/env_loader.dart';

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

class EnvBackedOcrService implements OcrService {
  EnvBackedOcrService({
    required this.endpoint,
    EnvLoader? loader,
  }) : _loader = loader ?? EnvLoader();

  final String endpoint;
  final EnvLoader _loader;

  Future<http.Client> _buildAuthClient() async {
    final apiKey = _loader.get('OCR_API_KEY');
    if (apiKey != null && apiKey.isNotEmpty) {
      return http.Client();
    }
    final credentialsPath =
        _loader.get('OCR_CREDENTIALS_PATH') ?? 'ocr_key.json';
    if (!(credentialsPath.isNotEmpty && File(credentialsPath).existsSync())) {
      throw StateError('OCR credentials not found');
    }
    final credsJson = File(credentialsPath).readAsStringSync();
    final credentials = gauth.ServiceAccountCredentials.fromJson(
        jsonDecode(credsJson) as Map<String, dynamic>);
    final scopes = ['https://www.googleapis.com/auth/cloud-platform'];
    return gauth.clientViaServiceAccount(credentials, scopes);
  }

  @override
  Future<String> process(String fileName) async {
    final apiKey = _loader.get('OCR_API_KEY');
    final credentialsPath =
        _loader.get('OCR_CREDENTIALS_PATH') ?? 'ocr_key.json';
    if ((apiKey == null || apiKey.isEmpty) &&
        !(credentialsPath.isNotEmpty && File(credentialsPath).existsSync())) {
      throw StateError('OCR_API_KEY or OCR_CREDENTIALS_PATH must be set');
    }

    List<int> imageBytes = [];
    final file = File(fileName);
    if (file.existsSync()) {
      imageBytes = await file.readAsBytes();
    } else {
      imageBytes = utf8.encode('text:$fileName');
    }

    final requestPayload = {
      'requests': [
        {
          'image': {'content': base64Encode(imageBytes)},
          'features': [
            {'type': 'DOCUMENT_TEXT_DETECTION'}
          ]
        }
      ]
    };

    final uri = apiKey != null && apiKey.isNotEmpty
        ? Uri.parse('$endpoint?key=$apiKey')
        : Uri.parse(endpoint);

    final client = await _buildAuthClient();
    try {
      final response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestPayload),
      );

      if (response.statusCode >= 400) {
        throw StateError('OCR 호출 실패(${response.statusCode}): ${response.body}');
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final responses = data['responses'] as List<dynamic>? ?? [];
      if (responses.isEmpty) {
        throw StateError('OCR 응답이 비었어요');
      }
      final first = responses.first as Map<String, dynamic>;
      final fullText =
          (first['fullTextAnnotation']?['text'] as String?)?.trim() ?? '';
      if (fullText.isNotEmpty) return fullText;
      final annotations = first['textAnnotations'] as List<dynamic>? ?? [];
      if (annotations.isNotEmpty) {
        final desc = (annotations.first as Map<String, dynamic>)['description']
                as String? ??
            '';
        if (desc.isNotEmpty) return desc.trim();
      }
      return 'OCR 완료했지만 텍스트를 찾지 못했어요.';
    } finally {
      client.close();
    }
  }
}
