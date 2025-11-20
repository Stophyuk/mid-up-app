import '../domain/problem_attachment.dart';

class ToolWorkspaceState {
  const ToolWorkspaceState({
    this.attachments = const [],
    this.lastQuestion,
    this.lastAnswer,
    this.isBusy = false,
  });

  final List<ProblemAttachment> attachments;
  final String? lastQuestion;
  final String? lastAnswer;
  final bool isBusy;

  ToolWorkspaceState copyWith({
    List<ProblemAttachment>? attachments,
    String? lastQuestion,
    String? lastAnswer,
    bool? isBusy,
  }) {
    return ToolWorkspaceState(
      attachments: attachments ?? this.attachments,
      lastQuestion: lastQuestion ?? this.lastQuestion,
      lastAnswer: lastAnswer ?? this.lastAnswer,
      isBusy: isBusy ?? this.isBusy,
    );
  }
}
