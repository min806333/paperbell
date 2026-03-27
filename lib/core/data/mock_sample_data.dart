import '../../app/localization/app_strings.dart';
import '../../features/import_flow/domain/document.dart';
import '../../features/import_flow/domain/document_page.dart';
import '../../features/import_flow/domain/extracted_field.dart';
import '../../features/import_flow/domain/extraction_result.dart';
import '../../features/import_flow/domain/import_session.dart';
import '../../features/reminders/domain/reminder_item.dart';
import '../models/app_enums.dart';

abstract final class MockSampleData {
  static List<ReminderItem> seededReminders() {
    final now = DateTime.now();

    return [
      ReminderItem(
        id: 'reminder-utility-seed',
        documentId: 'doc-utility-seed',
        title: '관리비 납부',
        category: ReminderCategory.utilities,
        dueAt: now.add(const Duration(days: 1)),
        amount: 87000,
        currency: 'KRW',
        note: '자동이체 전 금액만 확인해 주세요.',
        repeatRule: ReminderRepeatRule.monthly,
        status: ReminderStatus.upcoming,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        sourceSubtitle: '관리사무소',
        reminderLeadDays: 3,
      ),
      ReminderItem(
        id: 'reminder-netflix-seed',
        documentId: 'doc-netflix-seed',
        title: '넷플릭스 결제',
        category: ReminderCategory.subscription,
        dueAt: now.add(const Duration(days: 4)),
        amount: 17000,
        currency: 'KRW',
        note: '가족 공유 플랜 갱신일',
        repeatRule: ReminderRepeatRule.monthly,
        status: ReminderStatus.upcoming,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 1)),
        sourceSubtitle: '넷플릭스',
        reminderLeadDays: 1,
      ),
      ReminderItem(
        id: 'reminder-insurance-seed',
        documentId: 'doc-insurance-seed',
        title: '보험 갱신',
        category: ReminderCategory.insurance,
        dueAt: now.add(const Duration(days: 10)),
        amount: 129000,
        currency: 'KRW',
        note: '보장 내역 변경 여부를 같이 확인해 주세요.',
        repeatRule: ReminderRepeatRule.yearly,
        status: ReminderStatus.upcoming,
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(days: 2)),
        sourceSubtitle: '보험 안내문',
        reminderLeadDays: 7,
      ),
      ReminderItem(
        id: 'reminder-filter-seed',
        documentId: 'doc-filter-seed',
        title: '정수기 필터 교체',
        category: ReminderCategory.warranty,
        dueAt: now.subtract(const Duration(days: 2)),
        amount: null,
        currency: 'KRW',
        note: '셀프 교체 가능 여부 확인',
        repeatRule: ReminderRepeatRule.none,
        status: ReminderStatus.completed,
        createdAt: now.subtract(const Duration(days: 16)),
        updatedAt: now.subtract(const Duration(days: 2)),
        sourceSubtitle: '정수기 관리 안내',
        reminderLeadDays: 1,
      ),
      ReminderItem(
        id: 'reminder-health-seed',
        documentId: 'doc-health-seed',
        title: '건강검진 예약',
        category: ReminderCategory.medical,
        dueAt: now.add(const Duration(days: 15)),
        amount: null,
        currency: 'KRW',
        note: '예약 링크가 있는 문자도 함께 보관',
        repeatRule: ReminderRepeatRule.none,
        status: ReminderStatus.archived,
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now.subtract(const Duration(days: 5)),
        sourceSubtitle: '건강검진 안내',
        reminderLeadDays: 3,
      ),
    ];
  }

  static Map<String, Document> seededDocuments() {
    final documents = <Document>[
      _document(
        id: 'doc-utility-seed',
        sourceType: DocumentSourceType.camera,
        title: '4월 관리비 고지서',
        pageLabels: const ['관리비 명세'],
        originalPath: '/mock/camera/utility_bill.jpg',
      ),
      _document(
        id: 'doc-netflix-seed',
        sourceType: DocumentSourceType.shareSheet,
        title: '넷플릭스 결제 안내',
        pageLabels: const ['결제 예정 안내'],
        originalPath: '/mock/shared/netflix_notice.png',
      ),
      _document(
        id: 'doc-insurance-seed',
        sourceType: DocumentSourceType.pdf,
        title: '보험 갱신 안내문',
        pageLabels: const ['갱신 조건', '보험료 안내'],
        originalPath: '/mock/pdf/insurance_renewal.pdf',
      ),
      _document(
        id: 'doc-filter-seed',
        sourceType: DocumentSourceType.photoLibrary,
        title: '정수기 필터 교체 안내',
        pageLabels: const ['교체 일정'],
        originalPath: '/mock/gallery/filter_notice.png',
      ),
      _document(
        id: 'doc-health-seed',
        sourceType: DocumentSourceType.photoLibrary,
        title: '건강검진 예약 안내',
        pageLabels: const ['검진 일정', '유의사항'],
        originalPath: '/mock/gallery/health_notice.png',
      ),
    ];

    return {for (final document in documents) document.id: document};
  }

  static Document buildImportedDocument(DocumentSourceType sourceType) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;

    return switch (sourceType) {
      DocumentSourceType.camera => _document(
        id: 'doc-camera-$timestamp',
        sourceType: sourceType,
        title: '4월 관리비 고지서',
        pageLabels: const ['관리비 명세'],
        originalPath: '/mock/camera/utility_bill_$timestamp.jpg',
      ),
      DocumentSourceType.photoLibrary => _document(
        id: 'doc-gallery-$timestamp',
        sourceType: sourceType,
        title: '건강검진 안내문',
        pageLabels: const ['검진 일정', '준비 사항'],
        originalPath: '/mock/gallery/health_notice_$timestamp.png',
      ),
      DocumentSourceType.pdf => _document(
        id: 'doc-pdf-$timestamp',
        sourceType: sourceType,
        title: '보험 갱신 안내문',
        pageLabels: const ['갱신 요약', '보험료 안내', '유의 사항'],
        originalPath: '/mock/pdf/insurance_renewal_$timestamp.pdf',
      ),
      DocumentSourceType.shareSheet => _document(
        id: 'doc-share-$timestamp',
        sourceType: sourceType,
        title: '넷플릭스 결제 안내',
        pageLabels: const ['결제 예정 안내'],
        originalPath: '/mock/share/netflix_notice_$timestamp.png',
      ),
    };
  }

  static ExtractionResult extractionForDocument(Document document) {
    final now = DateTime.now();

    return switch (document.sourceType) {
      DocumentSourceType.camera => ExtractionResult(
        documentId: document.id,
        title: const ExtractedField(
          value: '관리비 납부',
          state: ExtractedFieldState.suggested,
        ),
        dueAt: ExtractedField(
          value: DateTime(now.year, now.month, now.day + 1),
          state: ExtractedFieldState.suggested,
          rawText: '납부기한 4월 26일',
        ),
        amount: const ExtractedField(
          value: 87000,
          state: ExtractedFieldState.suggested,
        ),
        category: const ExtractedField(
          value: ReminderCategory.utilities,
          state: ExtractedFieldState.suggested,
        ),
        note: const ExtractedField(
          value: '가상계좌와 자동이체 여부를 함께 확인해 주세요.',
          state: ExtractedFieldState.confirmed,
        ),
        sourceSubtitle: '관리사무소',
        repeatRule: ReminderRepeatRule.monthly,
        reminderLeadTime: ReminderLeadTime.threeDaysBefore,
        hints: const ['자동으로 찾은 정보예요. 한 번만 확인해 주세요'],
      ),
      DocumentSourceType.photoLibrary => ExtractionResult(
        documentId: document.id,
        title: const ExtractedField(
          value: '건강검진 예약',
          state: ExtractedFieldState.needsConfirmation,
        ),
        dueAt: ExtractedField(
          value: DateTime(now.year, now.month, now.day + 14),
          state: ExtractedFieldState.needsConfirmation,
          rawText: '예약 권장 기간 2주 이내',
        ),
        amount: const ExtractedField(
          value: null,
          state: ExtractedFieldState.missing,
        ),
        category: const ExtractedField(
          value: ReminderCategory.medical,
          state: ExtractedFieldState.suggested,
        ),
        note: const ExtractedField(
          value: '금식 여부와 준비 서류를 다시 확인해 주세요.',
          state: ExtractedFieldState.confirmed,
        ),
        sourceSubtitle: '건강검진 안내',
        repeatRule: ReminderRepeatRule.none,
        reminderLeadTime: ReminderLeadTime.oneDayBefore,
        hints: const ['금액 없이도 저장할 수 있어요'],
      ),
      DocumentSourceType.pdf => ExtractionResult(
        documentId: document.id,
        title: const ExtractedField(
          value: '보험 갱신',
          state: ExtractedFieldState.suggested,
        ),
        dueAt: ExtractedField(
          value: DateTime(now.year, now.month + 1, 5),
          state: ExtractedFieldState.suggested,
          rawText: '갱신일 5월 5일',
        ),
        amount: const ExtractedField(
          value: 129000,
          state: ExtractedFieldState.needsConfirmation,
        ),
        category: const ExtractedField(
          value: ReminderCategory.insurance,
          state: ExtractedFieldState.suggested,
        ),
        note: const ExtractedField(
          value: '특약 변경 사항이 있으면 메모해 두세요.',
          state: ExtractedFieldState.confirmed,
        ),
        sourceSubtitle: '보험 안내문',
        repeatRule: ReminderRepeatRule.yearly,
        reminderLeadTime: ReminderLeadTime.sevenDaysBefore,
        hints: const ['금액은 서류와 한 번 더 맞춰 보시는 걸 권해요'],
      ),
      DocumentSourceType.shareSheet => ExtractionResult(
        documentId: document.id,
        title: const ExtractedField(
          value: '넷플릭스 결제',
          state: ExtractedFieldState.suggested,
        ),
        dueAt: ExtractedField(
          value: DateTime(now.year, now.month, now.day + 4),
          state: ExtractedFieldState.suggested,
        ),
        amount: const ExtractedField(
          value: 17000,
          state: ExtractedFieldState.suggested,
        ),
        category: const ExtractedField(
          value: ReminderCategory.subscription,
          state: ExtractedFieldState.suggested,
        ),
        note: const ExtractedField(
          value: '요금제 변경 여부를 함께 확인해 주세요.',
          state: ExtractedFieldState.confirmed,
        ),
        sourceSubtitle: '넷플릭스',
        repeatRule: ReminderRepeatRule.monthly,
        reminderLeadTime: ReminderLeadTime.oneDayBefore,
        hints: const ['자동 결제 전 금액과 갱신일을 빠르게 확인할 수 있어요'],
      ),
    };
  }

  static ImportSession sessionFromReminder({
    required ReminderItem reminder,
    required Document document,
  }) {
    return ImportSession(
      document: document,
      extraction: ExtractionResult(
        documentId: document.id,
        title: ExtractedField(
          value: reminder.title,
          state: ExtractedFieldState.confirmed,
          isAutoSuggested: false,
        ),
        dueAt: ExtractedField(
          value: reminder.dueAt,
          state: ExtractedFieldState.confirmed,
          isAutoSuggested: false,
        ),
        amount: ExtractedField(
          value: reminder.amount,
          state: reminder.amount == null
              ? ExtractedFieldState.missing
              : ExtractedFieldState.confirmed,
          isAutoSuggested: false,
        ),
        category: ExtractedField(
          value: reminder.category,
          state: ExtractedFieldState.confirmed,
          isAutoSuggested: false,
        ),
        note: ExtractedField(
          value: reminder.note,
          state: ExtractedFieldState.confirmed,
          isAutoSuggested: false,
        ),
        sourceSubtitle: reminder.sourceSubtitle,
        repeatRule: reminder.repeatRule,
        reminderLeadTime: ReminderLeadTimeX.fromDays(reminder.reminderLeadDays),
        hints: const ['기존 리마인더를 수정하는 화면이에요'],
      ),
      existingReminderId: reminder.id,
      existingReminder: reminder,
    );
  }

  static Document _document({
    required String id,
    required DocumentSourceType sourceType,
    required String title,
    required List<String> pageLabels,
    required String originalPath,
  }) {
    final pages = <DocumentPage>[
      for (int index = 0; index < pageLabels.length; index++)
        DocumentPage(
          id: '$id-page-$index',
          pageNumber: index + 1,
          previewLabel: pageLabels[index],
          helperText: AppStrings.current.documentPageHelperText(index + 1),
        ),
    ];

    return Document(
      id: id,
      sourceType: sourceType,
      title: title,
      createdAt: DateTime.now(),
      originalPath: originalPath,
      containsSensitive: true,
      pages: pages,
    );
  }
}
