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
  });

  final String id;
  final AttachmentType type;
  final String fileName;
  final DateTime createdAt;
  final AttachmentStatus status;
  final String? ocrText;

  ProblemAttachment copyWith({
    AttachmentStatus? status,
    String? ocrText,
  }) {
    return ProblemAttachment(
      id: id,
      type: type,
      fileName: fileName,
      createdAt: createdAt,
      status: status ?? this.status,
      ocrText: ocrText ?? this.ocrText,
    );
  }
}
