import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../domain/problem_attachment.dart';
import '../../../core/env/env_loader.dart';
import '../services/ai_service.dart';
import '../services/ocr_service.dart';
import 'tool_workspace_state.dart';

final _env = EnvLoader();

final ocrServiceProvider = Provider<OcrService>((_) {
  final hasApiKey = (_env.get('OCR_API_KEY') ?? '').isNotEmpty;
  final hasCredFile = (_env.get('OCR_CREDENTIALS_PATH') ?? '').isNotEmpty;
  if (hasApiKey || hasCredFile) {
    final endpoint = _env.get('OCR_ENDPOINT') ??
        'https://vision.googleapis.com/v1/images:annotate';
    return EnvBackedOcrService(endpoint: endpoint, loader: _env);
  }
  return StubOcrService();
});

final aiServiceProvider = Provider<AiService>((_) {
  final hasKey = (_env.get('AI_API_KEY') ?? '').isNotEmpty;
  if (hasKey) {
    final endpoint = _env.get('AI_API_ENDPOINT') ??
        'https://api.openai.com/v1/chat/completions';
    return EnvBackedAiService(endpoint: endpoint, loader: _env);
  }
  return StubAiService();
});

final toolWorkspaceControllerProvider =
    NotifierProvider<ToolWorkspaceController, ToolWorkspaceState>(
  ToolWorkspaceController.new,
);

class ToolWorkspaceController extends Notifier<ToolWorkspaceState> {
  ToolWorkspaceController();

  final _uuid = const Uuid();

  @override
  ToolWorkspaceState build() => const ToolWorkspaceState();

  Future<void> addAttachment(AttachmentType type) async {
    final attachment = ProblemAttachment(
      id: _uuid.v4(),
      type: type,
      fileName: type == AttachmentType.photo
          ? '촬영_${DateTime.now().millisecondsSinceEpoch}.jpg'
          : '업로드_${DateTime.now().millisecondsSinceEpoch}.pdf',
      createdAt: DateTime.now(),
      status: AttachmentStatus.processing,
    );
    state = state.copyWith(
      attachments: [...state.attachments, attachment],
    );

    try {
      final ocrText =
          await ref.read(ocrServiceProvider).process(attachment.fileName);
      _updateAttachment(
        attachment.id,
        attachment.copyWith(
          status: AttachmentStatus.completed,
          ocrText: ocrText,
          errorMessage: null,
        ),
      );
    } catch (e) {
      _updateAttachment(
        attachment.id,
        attachment.copyWith(
          status: AttachmentStatus.failed,
          errorMessage: 'OCR 처리 실패: $e',
        ),
      );
    }
  }

  Future<void> askQuestion(String question) async {
    if (question.trim().isEmpty) return;
    state =
        state.copyWith(isBusy: true, lastQuestion: question, lastAnswer: null);
    try {
      final context = state.attachments
          .where((a) => a.ocrText != null)
          .map((a) => a.ocrText!)
          .join('\n');
      final answer = await ref.read(aiServiceProvider).answerQuestion(
            question: question,
            context: context,
          );
      state = state.copyWith(
        isBusy: false,
        lastAnswer: answer,
      );
    } catch (e) {
      state = state.copyWith(
        isBusy: false,
        lastAnswer: 'AI 응답 실패: $e',
      );
    }
  }

  Future<void> retryAttachment(String attachmentId) async {
    final target = state.attachments.firstWhere(
      (a) => a.id == attachmentId,
      orElse: () => ProblemAttachment(
        id: '',
        type: AttachmentType.photo,
        fileName: '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );
    if (target.id.isEmpty) return;
    _updateAttachment(
      target.id,
      target.copyWith(
        status: AttachmentStatus.processing,
        errorMessage: null,
      ),
    );
    try {
      final ocrText =
          await ref.read(ocrServiceProvider).process(target.fileName);
      _updateAttachment(
        target.id,
        target.copyWith(
          status: AttachmentStatus.completed,
          ocrText: ocrText,
          errorMessage: null,
        ),
      );
    } catch (e) {
      _updateAttachment(
        target.id,
        target.copyWith(
          status: AttachmentStatus.failed,
          errorMessage: 'OCR 처리 실패: $e',
        ),
      );
    }
  }

  void _updateAttachment(String id, ProblemAttachment updated) {
    final list = state.attachments.map((attachment) {
      if (attachment.id == id) {
        return updated;
      }
      return attachment;
    }).toList();
    state = state.copyWith(attachments: list);
  }
}
