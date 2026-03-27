import '../../../core/models/app_enums.dart';
import '../domain/import_result.dart';

abstract class DocumentImportService {
  Future<ImportResult> importDocument(DocumentSourceType sourceType);
}
