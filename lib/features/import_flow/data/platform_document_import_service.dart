import '../../../app/localization/app_strings.dart';
import '../../../core/models/app_enums.dart';
import '../domain/import_result.dart';
import 'adapters/image_picker_import_adapter.dart';
import 'adapters/pdf_import_adapter.dart';
import 'document_import_service.dart';

class PlatformDocumentImportService implements DocumentImportService {
  const PlatformDocumentImportService({
    required ImagePickerImportAdapter imageAdapter,
    required PdfDocumentImportAdapter pdfAdapter,
  }) : _imageAdapter = imageAdapter,
       _pdfAdapter = pdfAdapter;

  final ImagePickerImportAdapter _imageAdapter;
  final PdfDocumentImportAdapter _pdfAdapter;

  @override
  Future<ImportResult> importDocument(DocumentSourceType sourceType) {
    return switch (sourceType) {
      DocumentSourceType.camera => _imageAdapter.captureFromCamera(),
      DocumentSourceType.photoLibrary => _imageAdapter.pickFromGallery(),
      DocumentSourceType.pdf => _pdfAdapter.pickPdf(),
      DocumentSourceType.shareSheet =>
        Future.value(ImportFailure(message: AppStrings.current.shareImportNotReadyMessage)),
    };
  }
}
