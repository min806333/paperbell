class DocumentPage {
  const DocumentPage({
    required this.id,
    required this.pageNumber,
    required this.previewLabel,
    required this.helperText,
  });

  final String id;
  final int pageNumber;
  final String previewLabel;
  final String helperText;

  DocumentPage copyWith({
    String? id,
    int? pageNumber,
    String? previewLabel,
    String? helperText,
  }) {
    return DocumentPage(
      id: id ?? this.id,
      pageNumber: pageNumber ?? this.pageNumber,
      previewLabel: previewLabel ?? this.previewLabel,
      helperText: helperText ?? this.helperText,
    );
  }
}
