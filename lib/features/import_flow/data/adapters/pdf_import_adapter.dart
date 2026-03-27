import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

import '../../../../app/localization/app_strings.dart';
import '../../domain/import_result.dart';
import '../imported_document_factory.dart';
import 'pdf_text_document_parser_adapter.dart';

abstract interface class PdfDocumentImportAdapter {
  Future<ImportResult> pickPdf();
}

class PlaceholderPdfDocumentImportAdapter implements PdfDocumentImportAdapter {
  const PlaceholderPdfDocumentImportAdapter();

  @override
  Future<ImportResult> pickPdf() async {
    return ImportFailure(message: AppStrings.current.pdfImportUnsupportedMessage);
  }
}

class FilePickerPdfDocumentImportAdapter implements PdfDocumentImportAdapter {
  const FilePickerPdfDocumentImportAdapter({
    PdfTextDocumentParserAdapter? parserAdapter,
  }) : _parserAdapter = parserAdapter;

  final PdfTextDocumentParserAdapter? _parserAdapter;

  @override
  Future<ImportResult> pickPdf() async {
    final strings = AppStrings.current;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        allowMultiple: false,
        withData: false,
      );

      if (result == null || result.files.isEmpty) {
        return const ImportFailure(message: '', cancelled: true);
      }

      final file = result.files.single;
      final path = file.path;
      if (path == null || path.isEmpty) {
        return ImportFailure(message: strings.pdfImportMissingPathMessage);
      }

      PdfDocumentInspection? inspection;
      if (_parserAdapter != null) {
        try {
          inspection = await _parserAdapter.inspectDocument(path);
        } catch (_) {
          inspection = null;
        }
      }

      return ImportSuccess(
        ImportedDocumentFactory.fromPdfPath(
          path: path,
          fileName: file.name,
          pageCount: inspection?.pageCount,
          titleOverride: inspection?.title,
        ),
      );
    } on PlatformException {
      return ImportFailure(message: strings.pdfImportFailedMessage);
    }
  }
}
