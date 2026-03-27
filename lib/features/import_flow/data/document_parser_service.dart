import '../domain/document.dart';
import '../domain/extraction_result.dart';

abstract class DocumentParserService {
  Future<ExtractionResult> parseDocument(Document document);
}
