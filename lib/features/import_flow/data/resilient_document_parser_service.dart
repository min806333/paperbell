import '../../../app/localization/app_strings.dart';
import '../domain/document.dart';
import '../domain/extraction_result.dart';
import 'document_parser_service.dart';
import 'parsing/document_text_extraction_normalizer.dart';

class ResilientDocumentParserService implements DocumentParserService {
  ResilientDocumentParserService({
    required DocumentParserService primaryParser,
    required DocumentParserService mockParser,
    DocumentTextExtractionNormalizer? normalizer,
  }) : _primaryParser = primaryParser,
       _mockParser = mockParser,
       _normalizer = normalizer ?? const DocumentTextExtractionNormalizer();

  final DocumentParserService _primaryParser;
  final DocumentParserService _mockParser;
  final DocumentTextExtractionNormalizer _normalizer;

  @override
  Future<ExtractionResult> parseDocument(Document document) async {
    if (_isMockDocument(document)) {
      return _mockParser.parseDocument(document);
    }

    try {
      return await _primaryParser.parseDocument(document);
    } catch (error) {
      return _normalizer.buildFallback(
        document: document,
        primaryHint: _fallbackMessage(document, error),
      );
    }
  }

  bool _isMockDocument(Document document) {
    return document.originalPath.startsWith('/mock/') ||
        document.id.contains('-seed');
  }

  String _fallbackMessage(Document document, Object error) {
    final strings = AppStrings.current;

    if (document.sourceType.name == 'pdf') {
      return strings.parserPdfFallbackHint;
    }

    if (error is UnsupportedError) {
      return strings.parserUnsupportedDeviceHint;
    }

    return strings.parserGenericFallbackHint;
  }
}
