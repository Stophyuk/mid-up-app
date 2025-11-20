import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../domain/problem_attachment.dart';
import '../services/fake_ai_service.dart';
import '../services/fake_ocr_service.dart';
import 'tool_workspace_state.dart';

final fakeOcrServiceProvider = Provider((_) => FakeOcrService());
final fakeAiServiceProvider = Provider((_) => FakeAiService());

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
      fileName: type == AttachmentType.photo ? '촬영_${DateTime.now().millisecondsSinceEpoch}.jpg' : '업로드_${DateTime.now().millisecondsSinceEpoch}.pdf',
      createdAt: DateTime.now(),
      status: AttachmentStatus.processing,
    );
    state = state.copyWith(
      attachments: [...state.attachments, attachment],
    );

    final ocrService = ref.read(fakeOcrServiceProvider);
    try {
      final text = await ocrService.process(attachment.fileName);
      _updateAttachment(
        attachment.id,
        attachment.copyWith(
          status: AttachmentStatus.completed,
          ocrText: text,
        ),
      );
    } catch (_) {
      _updateAttachment(
        attachment.id,
        attachment.copyWith(status: AttachmentStatus.failed),
      );
    }
  }

  Future<void> askQuestion(String question) async {
    if (question.trim().isEmpty) return;
    state = state.copyWith(isBusy: true, lastQuestion: question, lastAnswer: null);
    final aiService = ref.read(fakeAiServiceProvider);
    final answer = await aiService.answerQuestion(
      question,
      state.attachments.where((a) => a.ocrText != null).map((a) => a.ocrText!).join('\n'),
    );
    state = state.copyWith(isBusy: false, lastAnswer: answer);
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
