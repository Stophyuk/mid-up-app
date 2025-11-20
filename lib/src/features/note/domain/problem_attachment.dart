enum AttachmentType { photo, pdf }

enum AttachmentStatus { pending, processing, completed, failed }

class ProblemAttachment {
  const ProblemAttachment({
    required this.id,
    required this.type,
    required this.fileName,
    required this.createdAt,
    this.status = AttachmentStatus.pending,
    this.ocrText,
    this.errorMessage,
  });

  final String id;
  final AttachmentType type;
  final String fileName;
  final DateTime createdAt;
  final AttachmentStatus status;
  final String? ocrText;
  final String? errorMessage;

  ProblemAttachment copyWith({
    AttachmentStatus? status,
    String? ocrText,
    String? errorMessage,
  }) {
    return ProblemAttachment(
      id: id,
      type: type,
      fileName: fileName,
      createdAt: createdAt,
      status: status ?? this.status,
      ocrText: ocrText ?? this.ocrText,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
