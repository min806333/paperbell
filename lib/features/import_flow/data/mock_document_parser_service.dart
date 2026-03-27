import '../../../app/localization/app_strings.dart';
import '../../../core/data/mock_sample_data.dart';
import '../domain/document.dart';
import '../domain/extraction_result.dart';
import 'document_parser_service.dart';

class MockDocumentParserService implements DocumentParserService {
  @override
  Future<ExtractionResult> parseDocument(Document document) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    final result = MockSampleData.extractionForDocument(document);
    final strings = AppStrings.current;

    final localizedHints = result.hints.map((hint) {
      if (hint.contains('자동으로 찾은 정보')) {
        return strings.parserAutoDetectedHint;
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
      return hint;
    }).toSet().toList();

    return result.copyWith(hints: localizedHints);
  }
}
