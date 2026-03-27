import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../app/localization/app_strings.dart';
import '../../../core/models/app_enums.dart';
import '../domain/document.dart';
import '../domain/document_page.dart';

class ImportedDocumentFactory {
  ImportedDocumentFactory._();

  static const _uuid = Uuid();

  static Document fromImagePath({
    required String path,
    required DocumentSourceType sourceType,
    String? fileName,
  }) {
    final title = _buildTitle(
      sourceType: sourceType,
      path: path,
      fileName: fileName,
    );
    final now = DateTime.now();
    final documentId = 'doc-${sourceType.name}-${_uuid.v4()}';

    return Document(
      id: documentId,
      sourceType: sourceType,
      title: title,
      createdAt: now,
      originalPath: path,
      containsSensitive: true,
      pages: [
        DocumentPage(
          id: '$documentId-page-1',
          pageNumber: 1,
          previewLabel: title,
          helperText: AppStrings.current.documentPageHelperText(1),
        ),
      ],
    );
  }

  static Document fromPdfPath({
    required String path,
    String? fileName,
    int? pageCount,
    String? titleOverride,
  }) {
    final title = _buildTitle(
      sourceType: DocumentSourceType.pdf,
      path: path,
      fileName: titleOverride?.trim().isNotEmpty == true
          ? titleOverride
          : fileName,
    );
    final now = DateTime.now();
    final documentId = 'doc-pdf-${_uuid.v4()}';
    final totalPages = pageCount != null && pageCount > 0 ? pageCount : 1;

    return Document(
      id: documentId,
      sourceType: DocumentSourceType.pdf,
      title: title,
      createdAt: now,
      originalPath: path,
      containsSensitive: true,
      pages: [
        for (var pageNumber = 1; pageNumber <= totalPages; pageNumber++)
          DocumentPage(
            id: '$documentId-page-$pageNumber',
            pageNumber: pageNumber,
            previewLabel: AppStrings.current.pdfPreviewLabel(
              pageNumber: pageNumber,
              totalPages: totalPages,
            ),
            helperText: AppStrings.current.documentPageHelperText(pageNumber),
          ),
      ],
    );
  }

  static String _buildTitle({
    required DocumentSourceType sourceType,
    required String path,
    String? fileName,
  }) {
    final rawName = fileName ?? p.basename(path);
    final withoutExtension = rawName.contains('.')
        ? rawName.substring(0, rawName.lastIndexOf('.'))
        : rawName;
    final cleaned = withoutExtension
        .replaceAll(RegExp(r'[_\-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleaned.isNotEmpty &&
        cleaned != 'image' &&
        cleaned != 'document' &&
        cleaned != 'photo') {
      return cleaned;
    }

    return AppStrings.current.importedDocumentFallbackTitle(sourceType);
  }
}
