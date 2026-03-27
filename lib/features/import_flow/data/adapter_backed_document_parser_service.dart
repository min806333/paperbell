import '../../../app/localization/app_strings.dart';
import '../../../core/models/app_enums.dart';
import '../domain/document.dart';
import '../domain/extraction_result.dart';
import 'adapters/mlkit_document_parser_adapter.dart';
import 'adapters/pdf_text_document_parser_adapter.dart';
import 'document_parser_service.dart';
import 'parsing/document_text_extraction_normalizer.dart';
import 'parsing/recognized_document_text.dart';

class AdapterBackedDocumentParserService implements DocumentParserService {
  AdapterBackedDocumentParserService({
    required MlKitDocumentParserAdapter imageParserAdapter,
    required PdfTextDocumentParserAdapter pdfParserAdapter,
    DocumentTextExtractionNormalizer? normalizer,
  }) : _imageParserAdapter = imageParserAdapter,
       _pdfParserAdapter = pdfParserAdapter,
       _normalizer = normalizer ?? const DocumentTextExtractionNormalizer();

  final MlKitDocumentParserAdapter _imageParserAdapter;
  final PdfTextDocumentParserAdapter _pdfParserAdapter;
  final DocumentTextExtractionNormalizer _normalizer;

  @override
  Future<ExtractionResult> parseDocument(Document document) async {
    final extractedText = switch (document.sourceType) {
      DocumentSourceType.pdf => await _pdfParserAdapter.extractDocumentText(
        document,
      ),
      _ => await _imageParserAdapter.extractDocumentText(document),
    };

    return _normalizeDocumentText(document, extractedText);
  }

  ExtractionResult _normalizeDocumentText(
    Document document,
    RecognizedDocumentText extractedText,
  ) {
    final normalized = _normalizer.normalize(
      document: document,
      rawText: extractedText.rawText,
      lines: extractedText.lines,
      suggestedTitle: extractedText.suggestedTitle,
    );

    final localizedHints = [
      ...extractedText.notices,
      ...normalized.hints,
    ].map(_localizeHint).toSet().toList();

    return normalized.copyWith(hints: localizedHints);
  }

  String _localizeHint(String hint) {
    final strings = AppStrings.current;

    if (hint.contains('자동으로 찾은 정보')) {
      return strings.parserAutoDetectedHint;
    }
    if (hint.contains('날짜를 찾지 못했')) {
      return strings.parserMissingDateHint;
    }
    if (hint.contains('금액 없이도 저장')) {
      return strings.parserMissingAmountHint;
    }
    if (hint.contains('서류와 한 번 더')) {
      return strings.parserAmountReviewHint;
    }
    if (hint.contains('자동 결제 전 금액')) {
      return strings.parserRecurringQuickCheckHint;
    }
    if (hint.contains('기존 리마인더를 수정')) {
      return strings.mockExistingReminderHint;
    }
    if (hint.contains('PDF') && hint.contains('충분히 읽')) {
      return strings.parserPdfFallbackHint;
    }
    if (hint.contains('자동 인식에 제한')) {
      return strings.parserUnsupportedDeviceHint;
    }
    if (hint.contains('원본 문서로 이어서')) {
      return strings.preprocessingImageFallbackNotice;
    }
    if (hint.contains('원본 기준으로 이어서')) {
      return strings.preprocessingPdfFallbackNotice;
    }
    if (hint.contains('이미지 기준으로 다시 읽')) {
      return strings.preprocessingPdfOcrNotice;
    }
    if (hint.contains('원본 PDF 텍스트')) {
      return strings.preprocessingPdfTextFallbackNotice;
    }
    if (hint.contains('문서를 완전히 읽지 못했')) {
      return strings.parserGenericFallbackHint;
    }

    return hint;
  }
}
