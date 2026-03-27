import '../../../core/models/app_enums.dart';
import 'document_page.dart';
import 'document_preprocessing.dart';

class Document {
  const Document({
    required this.id,
    required this.sourceType,
    required this.title,
    required this.createdAt,
    required this.originalPath,
    required this.containsSensitive,
    required this.pages,
    this.preprocessing = const DocumentPreprocessing(),
  });

  final String id;
  final DocumentSourceType sourceType;
  final String title;
  final DateTime createdAt;
  final String originalPath;
  final bool containsSensitive;
  final List<DocumentPage> pages;
  final DocumentPreprocessing preprocessing;

  Document copyWith({
    String? id,
    DocumentSourceType? sourceType,
    String? title,
    DateTime? createdAt,
    String? originalPath,
    bool? containsSensitive,
    List<DocumentPage>? pages,
    DocumentPreprocessing? preprocessing,
  }) {
    return Document(
      id: id ?? this.id,
      sourceType: sourceType ?? this.sourceType,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      originalPath: originalPath ?? this.originalPath,
      containsSensitive: containsSensitive ?? this.containsSensitive,
      pages: pages ?? this.pages,
      preprocessing: preprocessing ?? this.preprocessing,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'sourceType': sourceType.name,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'originalPath': originalPath,
      'containsSensitive': containsSensitive ? 1 : 0,
      'rotationQuarterTurns': preprocessing.normalizedRotationQuarterTurns,
      'cropInsetRatio': preprocessing.normalizedCropInsetRatio,
    };
  }
}
