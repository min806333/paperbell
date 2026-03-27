import 'package:flutter_test/flutter_test.dart';
import 'package:life_admin_assistant/core/models/app_enums.dart';
import 'package:life_admin_assistant/features/import_flow/data/parsing/document_text_extraction_normalizer.dart';
import 'package:life_admin_assistant/features/import_flow/data/parsing/recognized_document_text.dart';
import 'package:life_admin_assistant/features/import_flow/domain/document.dart';
import 'package:life_admin_assistant/features/import_flow/domain/document_page.dart';

void main() {
  const normalizer = DocumentTextExtractionNormalizer();

  Document buildDocument({
    required String id,
    required DocumentSourceType sourceType,
    required String title,
    required String path,
  }) {
    return Document(
      id: id,
      sourceType: sourceType,
      title: title,
      createdAt: DateTime(2026, 3, 25),
      originalPath: path,
      containsSensitive: true,
      pages: const [
        DocumentPage(
          id: 'page-1',
          pageNumber: 1,
          previewLabel: '문서',
          helperText: '1페이지',
        ),
      ],
    );
  }

  test('관리비 안내문에서 날짜와 금액을 정규화한다', () {
    final document = buildDocument(
      id: 'doc-ocr-1',
      sourceType: DocumentSourceType.camera,
      title: '촬영한 문서',
      path: '/tmp/utility_bill.jpg',
    );

    final result = normalizer.normalize(
      document: document,
      rawText: '관리비 납부 안내\n납부기한 2026년 4월 25일\n납부금액 87,000원',
      lines: const [
        RecognizedLineCandidate(text: '관리비 납부 안내', confidence: 0.91),
        RecognizedLineCandidate(text: '납부기한 2026년 4월 25일', confidence: 0.88),
        RecognizedLineCandidate(text: '납부금액 87,000원', confidence: 0.86),
      ],
    );

    expect(result.title.value, '관리비 납부 안내');
    expect(result.dueAt.value, DateTime(2026, 4, 25));
    expect(result.amount.value, 87000);
    expect(result.category.value, ReminderCategory.utilities);
    expect(result.repeatRule, ReminderRepeatRule.monthly);
  });

  test('보험 갱신 문서에서 갱신일과 보험료를 우선 찾는다', () {
    final document = buildDocument(
      id: 'doc-insurance-1',
      sourceType: DocumentSourceType.pdf,
      title: '보험 갱신 안내',
      path: '/tmp/insurance_notice.pdf',
    );

    final result = normalizer.normalize(
      document: document,
      rawText: '보험 갱신 안내\n만료일 2026년 9월 12일\n갱신일 2026년 9월 30일\n보험료 128,400원',
      lines: const [
        RecognizedLineCandidate(text: '보험 갱신 안내'),
        RecognizedLineCandidate(text: '만료일 2026년 9월 12일'),
        RecognizedLineCandidate(text: '갱신일 2026년 9월 30일'),
        RecognizedLineCandidate(text: '보험료 128,400원'),
      ],
    );

    expect(result.dueAt.value, DateTime(2026, 9, 30));
    expect(result.amount.value, 128400);
    expect(result.category.value, ReminderCategory.insurance);
    expect(result.repeatRule, ReminderRepeatRule.yearly);
  });

  test('총액과 청구금액이 있으면 요약 금액을 우선 선택한다', () {
    final document = buildDocument(
      id: 'doc-medical-1',
      sourceType: DocumentSourceType.photoLibrary,
      title: '진료비 안내',
      path: '/tmp/medical_bill.png',
    );

    final result = normalizer.normalize(
      document: document,
      rawText: '진료비 안내\n공급가액 20,000원\n부가세 2,000원\n총액 22,000원',
      lines: const [
        RecognizedLineCandidate(text: '진료비 안내'),
        RecognizedLineCandidate(text: '공급가액 20,000원'),
        RecognizedLineCandidate(text: '부가세 2,000원'),
        RecognizedLineCandidate(text: '총액 22,000원'),
      ],
    );

    expect(result.amount.value, 22000);
    expect(result.category.value, ReminderCategory.medical);
  });

  test('멤버십과 자동결제 문구를 구독 카테고리로 분류한다', () {
    final document = buildDocument(
      id: 'doc-subscription-1',
      sourceType: DocumentSourceType.pdf,
      title: '넷플릭스 멤버십',
      path: '/tmp/netflix.pdf',
    );

    final result = normalizer.normalize(
      document: document,
      rawText: '넷플릭스 멤버십 안내\n결제일 2026.05.15\n결제금액 17,000원\n자동결제 등록됨',
      lines: const [
        RecognizedLineCandidate(text: '넷플릭스 멤버십 안내'),
        RecognizedLineCandidate(text: '결제일 2026.05.15'),
        RecognizedLineCandidate(text: '결제금액 17,000원'),
        RecognizedLineCandidate(text: '자동결제 등록됨'),
      ],
    );

    expect(result.category.value, ReminderCategory.subscription);
    expect(result.dueAt.value, DateTime(2026, 5, 15));
    expect(result.repeatRule, ReminderRepeatRule.monthly);
  });

  test('보증기간과 사용기한 문구를 보증 카테고리로 분류한다', () {
    final document = buildDocument(
      id: 'doc-warranty-1',
      sourceType: DocumentSourceType.pdf,
      title: '정수기 필터 교체 안내',
      path: '/tmp/filter.pdf',
    );

    final result = normalizer.normalize(
      document: document,
      rawText: '정수기 필터 교체 안내\n사용기한 2026년 6월 10일\n보증기간 1년',
      lines: const [
        RecognizedLineCandidate(text: '정수기 필터 교체 안내'),
        RecognizedLineCandidate(text: '사용기한 2026년 6월 10일'),
        RecognizedLineCandidate(text: '보증기간 1년'),
      ],
    );

    expect(result.category.value, ReminderCategory.warranty);
    expect(result.dueAt.value, DateTime(2026, 6, 10));
  });

  test('모호한 날짜 정보만 있으면 낮은 신뢰도로 남기지 않는다', () {
    final document = buildDocument(
      id: 'doc-ambiguous-1',
      sourceType: DocumentSourceType.pdf,
      title: '안내문',
      path: '/tmp/notice.pdf',
    );

    final result = normalizer.normalize(
      document: document,
      rawText: '안내문\n발행일 2026년 4월 1일\n문의 02-123-4567',
      lines: const [
        RecognizedLineCandidate(text: '안내문'),
        RecognizedLineCandidate(text: '발행일 2026년 4월 1일'),
        RecognizedLineCandidate(text: '문의 02-123-4567'),
      ],
    );

    expect(result.dueAt.value, isNull);
    expect(result.category.value, isNull);
    expect(result.dueAt.state, ExtractedFieldState.missing);
  });

  test('fallback은 수동 보정을 위한 기본값을 남긴다', () {
    final document = buildDocument(
      id: 'doc-fallback-1',
      sourceType: DocumentSourceType.pdf,
      title: '보험 갱신 안내문',
      path: '/tmp/insurance_notice.pdf',
    );

    final result = normalizer.buildFallback(
      document: document,
      primaryHint: 'PDF는 아직 핵심 정보만 먼저 확인하고 있어요. 필요한 항목만 직접 확인해 주세요.',
    );

    expect(result.title.value, '보험 갱신 안내문');
    expect(result.dueAt.value, isNull);
    expect(result.amount.value, isNull);
    expect(result.category.value, ReminderCategory.insurance);
    expect(result.hints.first, contains('PDF'));
  });
  test('KRW와 USD 통화 표기를 함께 인식한다', () {
    final krwDocument = buildDocument(
      id: 'doc-currency-krw',
      sourceType: DocumentSourceType.camera,
      title: '관리비 안내',
      path: '/tmp/krw.jpg',
    );
    final usdDocument = buildDocument(
      id: 'doc-currency-usd',
      sourceType: DocumentSourceType.pdf,
      title: 'Payment notice',
      path: '/tmp/usd.pdf',
    );

    final krwResult = normalizer.normalize(
      document: krwDocument,
      rawText: '납부금액 ₩87,000',
      lines: const [
        RecognizedLineCandidate(text: '납부금액 ₩87,000', confidence: 0.94),
      ],
    );
    final usdResult = normalizer.normalize(
      document: usdDocument,
      rawText: 'Amount USD 79.99',
      lines: const [
        RecognizedLineCandidate(text: 'Amount USD 79.99', confidence: 0.93),
      ],
    );

    expect(krwResult.amountValue.value, 87000);
    expect(krwResult.currencyCode.value, 'KRW');
    expect(usdResult.amountValue.value, 79.99);
    expect(usdResult.currencyCode.value, 'USD');
  });

  test('금액은 읽었지만 통화 표기가 없으면 통화를 비워 둔다', () {
    final document = buildDocument(
      id: 'doc-currency-unclear',
      sourceType: DocumentSourceType.pdf,
      title: '결제 안내',
      path: '/tmp/unclear.pdf',
    );

    final result = normalizer.normalize(
      document: document,
      rawText: '결제금액 79.99',
      lines: const [
        RecognizedLineCandidate(text: '결제금액 79.99', confidence: 0.9),
      ],
    );

    expect(result.amountValue.value, 79.99);
    expect(result.currencyCode.value, isNull);
    expect(result.currencyCode.state, ExtractedFieldState.missing);
  });
}
