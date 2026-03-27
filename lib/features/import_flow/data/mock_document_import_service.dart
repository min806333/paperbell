import '../../../core/data/mock_sample_data.dart';
import '../../../core/models/app_enums.dart';
import '../domain/import_result.dart';
import 'document_import_service.dart';

class MockDocumentImportService implements DocumentImportService {
  @override
  Future<ImportResult> importDocument(DocumentSourceType sourceType) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return ImportSuccess(MockSampleData.buildImportedDocument(sourceType));
  }
}
