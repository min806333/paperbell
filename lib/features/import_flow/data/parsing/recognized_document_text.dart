class RecognizedLineCandidate {
  const RecognizedLineCandidate({required this.text, this.confidence});

  final String text;
  final double? confidence;
}

class RecognizedDocumentText {
  const RecognizedDocumentText({
    required this.rawText,
    required this.lines,
    this.pageCount,
    this.suggestedTitle,
    this.notices = const [],
  });

  final String rawText;
  final List<RecognizedLineCandidate> lines;
  final int? pageCount;
  final String? suggestedTitle;
  final List<String> notices;

  RecognizedDocumentText copyWith({
    String? rawText,
    List<RecognizedLineCandidate>? lines,
    int? pageCount,
    String? suggestedTitle,
    List<String>? notices,
  }) {
    return RecognizedDocumentText(
      rawText: rawText ?? this.rawText,
      lines: lines ?? this.lines,
      pageCount: pageCount ?? this.pageCount,
      suggestedTitle: suggestedTitle ?? this.suggestedTitle,
      notices: notices ?? this.notices,
    );
  }
}
