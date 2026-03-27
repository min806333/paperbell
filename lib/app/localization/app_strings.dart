import 'package:flutter/material.dart';

import '../../core/models/app_enums.dart';
import 'locale_controller.dart';
import 'strings_en.dart';
import 'strings_ko.dart';

abstract final class AppStringsRuntime {
  static Locale _locale = const Locale('ko', 'KR');

  static Locale get locale => _locale;

  static void setLocale(Locale locale) {
    _locale = locale;
  }
}

abstract class AppStrings {
  const AppStrings();

  static AppStrings forLocale(Locale locale) {
    return switch (locale.languageCode) {
      'en' => const AppStringsEn(),
      _ => const AppStringsKo(),
    };
  }

  static AppStrings get current => forLocale(AppStringsRuntime.locale);

  String get appTitle;
  String get homeNavLabel;
  String get archiveNavLabel;
  String get settingsNavLabel;

  String get languageSelectionTitle;
  String get languageSelectionSubtitle;
  String get languageSelectionHint;
  String get languageOptionKorean;
  String get languageOptionEnglish;
  String get languageDialogTitle;

  String get settingsTitle;
  String get settingsSubtitle;
  String get settingsStorageBanner;
  String get settingsDefaultReminderTiming;
  String get settingsLanguageTitle;
  String settingsLanguageSubtitle(String languageName);
  String get settingsAppLockTitle;
  String get settingsAppLockSubtitle;
  String settingsLocalStorageSubtitle(int reminderCount);
  String get settingsLocalStorageTitle;
  String get settingsDataExportTitle;
  String get settingsDataExportSubtitle;
  String get aboutSectionTitle;
  String get aboutSectionDescription;
  String get aboutLocalFirstBadge;
  String get aboutPrivacyFirstBadge;
  String get aboutVersionTitle;
  String get aboutContactTitle;
  String get aboutPrivacyEntryLabel;

  String get saveAction;
  String get cancelAction;
  String get confirmAction;
  String get dontShowAgainAction;
  String get addImportAction;
  String get completeAction;
  String get snoozeAction;
  String get viewDetailAction;
  String get continueAction;
  String get editAction;
  String get deleteAction;
  String get preparingLabel;

  String get noAmountLabel;
  String get unknownCurrencyLabel;
  String get todayRelativeLabel;
  String get tomorrowRelativeLabel;

  String get contactEmailSubject;
  String get contactEmailBodyTemplate;

  String languageName(AppLanguage language);
  String documentSourceLabel(DocumentSourceType sourceType);
  String documentSourceHelperText(DocumentSourceType sourceType);
  String reminderCategoryLabel(ReminderCategory category);
  String reminderStatusLabel(ReminderStatus status);
  String reminderRepeatRuleLabel(ReminderRepeatRule repeatRule);
  String reminderLeadTimeLabel(ReminderLeadTime leadTime);
  String? extractedFieldStateLabel(ExtractedFieldState state);

  String get localOnlyProcessingBadge;
  String get documentPreviewPlaceholderMessage;

  String get homeHeroTitle;
  String get homeHeroSubtitle;
  String get homeTodayStatTitle;
  String get homeTodayStatSubtitle;
  String get homeThisWeekStatTitle;
  String get homeThisWeekStatSubtitle;
  String get homeMonthlyEstimateTitle;
  String get homeMonthlyEstimateSubtitle;
  String get homeMonthlyEstimateMixedSubtitle;
  String summaryCountValue(int count);
  String get filterAllLabel;
  String get filterTodayLabel;
  String get filterThisWeekLabel;
  String get filterCompletedLabel;
  String get filterArchivedLabel;
  String get filterUtilitiesLabel;
  String get filterSubscriptionLabel;
  String get filterInsuranceLabel;
  String get homeListViewLabel;
  String get homeCalendarViewLabel;
  String get homeUpcomingSectionTitle;
  String get homeUpcomingSectionSubtitle;
  String get homeCalendarSectionTitle;
  String get homeCalendarSectionSubtitle;
  String get homeCalendarEmptyTitle;
  String get homeCalendarEmptyDescription;
  String homeCalendarSelectedDateSubtitle(int count);
  String get homePreviousMonthAction;
  String get homeNextMonthAction;
  String get homeGoToTodayAction;
  String get homeEmptyTitle;
  String get homeEmptyDescription;

  String get archiveTitle;
  String get archiveSubtitle;
  String get archiveSearchHint;
  String get archiveEmptyTitle;
  String get archiveEmptyDescription;

  String get reminderMarkedCompleteMessage;
  String get reminderSnoozedMessage;
  String reminderSnoozedWithNoticeMessage(String notice);
  String get reminderSavedMessage;
  String reminderSavedWithNoticeMessage(String notice);

  String get importSheetTitle;
  String get importSheetSubtitle;
  String get importSheetBanner;
  String get recentSharedDocumentMissingMessage;

  String get documentReviewTitle;
  String get documentReviewHeaderTitle;
  String get documentReviewHeaderSubtitle;
  String get documentReviewInfoBanner;
  String reviewRotationLabel(int degrees);
  String reviewCropLabel(int percent) {
    if (this is AppStringsEn) {
      return 'Trim outer margin: $percent%';
    }
    return '현재 가장자리 정리: $percent%';
  }
  String get reviewProcessingInfoBanner {
    if (this is AppStringsEn) {
      return 'Rotation and trim adjustments are applied only to recognition, and the original file stays untouched.';
    }
    return '회전과 영역 조정은 인식에만 반영되고, 원본 파일은 그대로 유지돼요. 필요할 때만 가볍게 조정해 주세요.';
  }
  String get reviewCropHelperMessage {
    if (this is AppStringsEn) {
      return 'Trim only the outer margin if it helps make the document easier to read.';
    }
    return '필요한 경우 바깥 여백만 조금 줄여서 읽기 쉬운 상태로 맞출 수 있어요.';
  }
  String get cropAdjustmentTitle;
  String get rotateAction;
  String get retakeAction;
  String get reselectAction;
  String get parsingInProgressTitle;
  String get parsingInProgressSubtitle;
  String get cropPlaceholderMessage;

  String get extractionConfirmTitle;
  String get sourcePreviewTitle;
  String get sourcePreviewSubtitle;
  String get missingDateNotice;
  String get missingAmountNotice;
  String get titleFieldLabel;
  String get dateFieldLabel;
  String get amountFieldLabel;
  String get currencySelectorTitle;
  String get currencyKrwLabel;
  String get currencyUsdLabel;
  String get uncertainCurrencyHelper;
  String get categoryFieldLabel;
  String get memoFieldLabel;
  String get titleFieldHint;
  String get dateFieldPlaceholder;
  String get amountFieldHint;
  String get memoFieldHint;
  String get repeatSectionTitle;
  String get repeatToggleTitle;
  String get repeatToggleSubtitle;
  String get reminderTimingSectionTitle;
  String get reparseAction;
  String get reparsingAction;
  String get defaultReminderTitle;
  String get untitledReminderFallback;

  String get reminderDetailTitle;
  String get reminderDetailMissingTitle;
  String get reminderDetailMissingDescription;
  String get sourceDocumentSectionTitle;
  String get sourceDocumentSectionSubtitle;
  String get savedInfoSectionTitle;
  String get savedInfoSectionSubtitle;
  String dueDateSummary(String formattedDate);
  String get memoSectionTitle;
  String get deleteReminderDialogTitle;
  String get deleteReminderDialogContent;

  String get settingsDataExportPreparingMessage;
  String get donationTitle;
  String get donationDescription;
  String get donationOptionOne;
  String get donationOptionTwo;
  String get donationOptionSupport;
  String donationPreparingMessage(String label);
  String get donationStoreLoadingMessage =>
      this is AppStringsEn ? 'Checking the store...' : '스토어 준비 상태를 확인하고 있어요.';
  String get donationStoreUnavailableMessage => this is AppStringsEn
      ? 'The store is not available right now. You can keep using the app as usual.'
      : '스토어를 지금 사용할 수 없어요. 앱은 그대로 계속 사용할 수 있어요.';
  String donationProductUnavailableMessage(String label) => this is AppStringsEn
      ? '$label is not ready in the store yet.'
      : '$label 상품이 아직 스토어에 준비되지 않았어요.';
  String donationPendingMessage(String label) => this is AppStringsEn
      ? '$label is being processed. Please wait a moment.'
      : '$label 결제를 확인하고 있어요. 잠시만 기다려 주세요.';
  String donationSuccessMessage(String label) => this is AppStringsEn
      ? 'Thank you for supporting with $label.'
      : '$label으로 응원해 주셔서 정말 고맙습니다.';
  String get donationCancelledMessage => this is AppStringsEn
      ? 'The support purchase was cancelled.'
      : '후원 결제가 취소되었어요.';
  String donationFailedMessage([String? detail]) {
    final base = this is AppStringsEn
        ? 'The support purchase could not be completed.'
        : '후원 결제를 완료하지 못했어요.';
    if (detail == null || detail.trim().isEmpty) {
      return base;
    }
    return '$base ${detail.trim()}';
  }
  String donationStartFailedMessage(String label) => this is AppStringsEn
      ? '$label could not be started from the store.'
      : '$label 결제를 스토어에서 시작하지 못했어요.';
  String get privacyTitle;
  String get privacyBody;
  String get privacyCaution;
  String get privacyPolicyActionLabel;
  String get privacyPolicyLaunchError;
  String get contactTitle;
  String get contactBody;
  String get contactSendLabel;
  String get contactLaunchError;
  String get cloudOptionTitle;
  String get cloudOptionSubtitle;
  String get mvpExcludedLabel;
  String get clearLocalDataTitle;
  String get clearLocalDataSubtitle;
  String get clearLocalDataDialogTitle;
  String get clearLocalDataDialogContent;
  String get clearedLocalDataMessage;

  String documentPageHelperText(int pageNumber) {
    if (this is AppStringsEn) {
      return 'Page $pageNumber';
    }
    return '$pageNumber페이지';
  }

  String pdfPreviewLabel({
    required int pageNumber,
    required int totalPages,
  }) {
    if (this is AppStringsEn) {
      return totalPages == 1 ? 'PDF document' : 'PDF page $pageNumber';
    }
    return totalPages == 1 ? 'PDF 문서' : 'PDF $pageNumber';
  }

  String importedDocumentFallbackTitle(DocumentSourceType sourceType) {
    if (this is AppStringsEn) {
      return switch (sourceType) {
        DocumentSourceType.camera => 'Captured document',
        DocumentSourceType.photoLibrary => 'Imported photo document',
        DocumentSourceType.pdf => 'Imported PDF document',
        DocumentSourceType.shareSheet => 'Shared document',
      };
    }

    return switch (sourceType) {
      DocumentSourceType.camera => '촬영한 문서',
      DocumentSourceType.photoLibrary => '가져온 사진 문서',
      DocumentSourceType.pdf => '가져온 PDF 문서',
      DocumentSourceType.shareSheet => '공유한 문서',
    };
  }

  String get parserAutoDetectedHint {
    if (this is AppStringsEn) {
      return 'These details were found automatically. Please give them one calm review.';
    }
    return '자동으로 찾은 정보예요. 한 번만 확인해 주세요.';
  }

  String get parserMissingDateHint {
    if (this is AppStringsEn) {
      return 'No date was found. Please choose one manually.';
    }
    return '날짜를 찾지 못했어요. 직접 선택해 주세요.';
  }

  String get parserMissingAmountHint {
    if (this is AppStringsEn) {
      return 'You can still save this without an amount.';
    }
    return '금액 없이도 저장할 수 있어요.';
  }

  String get parserAmountReviewHint {
    if (this is AppStringsEn) {
      return 'Please compare the amount with the document once more.';
    }
    return '금액은 서류와 한 번 더 맞춰 보시는 걸 권해요.';
  }

  String get parserRecurringQuickCheckHint {
    if (this is AppStringsEn) {
      return 'You can quickly review the amount and renewal date before the next recurring payment.';
    }
    return '자동 결제 전 금액과 갱신일을 빠르게 확인할 수 있어요.';
  }

  String get parserGenericFallbackHint {
    if (this is AppStringsEn) {
      return 'The document could not be read fully. Please review only the details you need.';
    }
    return '문서를 완전히 읽지 못했어요. 필요한 항목만 직접 확인해 주세요.';
  }

  String get parserPdfFallbackHint {
    if (this is AppStringsEn) {
      return 'The PDF could not be read clearly enough. Please review only the details you need.';
    }
    return 'PDF 내용을 충분히 읽지 못했어요. 필요한 항목만 직접 확인해 주세요.';
  }

  String get parserUnsupportedDeviceHint {
    if (this is AppStringsEn) {
      return 'Automatic reading is limited on this device, so please review the needed details manually.';
    }
    return '이 기기에서는 자동 인식에 제한이 있어 필요한 항목만 직접 확인해 주세요.';
  }

  String get preprocessingImageFallbackNotice {
    if (this is AppStringsEn) {
      return 'The edit could not be applied to reading, so the original document will be checked instead.';
    }
    return '편집 내용을 문서 읽기에 반영하지 못했어요. 원본 문서로 이어서 확인할게요.';
  }

  String get preprocessingPdfFallbackNotice {
    if (this is AppStringsEn) {
      return 'The PDF edit could not be fully applied, so the original page image will be checked as-is.';
    }
    return '편집한 회전이나 영역을 PDF 인식에 완전히 반영하지 못했어요. 원본 기준으로 이어서 읽어볼게요.';
  }

  String get preprocessingPdfOcrNotice {
    if (this is AppStringsEn) {
      return 'The PDF was reread from page images so your rotation and trim adjustments could be reflected.';
    }
    return '회전하거나 다듬은 내용이 인식에 반영되도록 PDF를 이미지 기준으로 다시 읽었어요.';
  }

  String get preprocessingPdfTextFallbackNotice {
    if (this is AppStringsEn) {
      return 'Not enough text was found in the edited area, so the original PDF text was also checked.';
    }
    return '편집한 영역으로는 충분한 글자를 찾지 못해 원본 PDF 텍스트도 함께 확인했어요.';
  }

  String sourceSubtitleFallback(String documentTitle) {
    if (documentTitle.trim().isNotEmpty) {
      return documentTitle;
    }
    return this is AppStringsEn ? 'Imported document' : '가져온 문서';
  }

  String fallbackTitleForCategory(ReminderCategory category) {
    if (this is AppStringsEn) {
      return switch (category) {
        ReminderCategory.utilities => 'Utility payment',
        ReminderCategory.subscription => 'Subscription payment',
        ReminderCategory.insurance => 'Insurance notice',
        ReminderCategory.tax => 'Tax notice',
        ReminderCategory.medical => 'Medical reminder',
        ReminderCategory.contractRenewal => 'Contract renewal',
        ReminderCategory.warranty => 'Warranty check',
        ReminderCategory.other => defaultReminderTitle,
      };
    }

    return switch (category) {
      ReminderCategory.utilities => '관리비 납부',
      ReminderCategory.subscription => '구독 결제',
      ReminderCategory.insurance => '보험 안내',
      ReminderCategory.tax => '세금 안내',
      ReminderCategory.medical => '의료 일정',
      ReminderCategory.contractRenewal => '계약 갱신',
      ReminderCategory.warranty => '보증 확인',
      ReminderCategory.other => defaultReminderTitle,
    };
  }

  String get sourceSubtitleSubscriptionNotice =>
      this is AppStringsEn ? 'Recurring payment notice' : '정기 결제 안내';
  String get sourceSubtitleManagementOffice =>
      this is AppStringsEn ? 'Management office' : '관리사무소';
  String get sourceSubtitleInsuranceNotice =>
      this is AppStringsEn ? 'Insurance notice' : '보험 안내문';
  String get sourceSubtitleMedicalNotice =>
      this is AppStringsEn ? 'Medical notice' : '의료 안내문';
  String get sourceSubtitleMaintenanceNotice =>
      this is AppStringsEn ? 'Maintenance notice' : '관리 안내문';
  String get sourceSubtitleContractNotice =>
      this is AppStringsEn ? 'Contract notice' : '계약 안내문';

  String get notificationChannelName =>
      this is AppStringsEn ? 'Life admin reminders' : '생활 행정 알림';
  String get notificationChannelDescription => this is AppStringsEn
      ? 'Upcoming reminders and due-date alerts'
      : '다가오는 생활 일정과 마감 알림';
  String get notificationPermissionDeniedNotice => this is AppStringsEn
      ? 'Notifications are turned off, so alerts may not be delivered.'
      : '알림 권한이 꺼져 있어 알림은 보내지 못할 수 있어요.';
  String notificationBody(String sourceSubtitle) => this is AppStringsEn
      ? 'A reminder from $sourceSubtitle is coming up.'
      : '$sourceSubtitle 일정이 가까워졌어요.';

  String get shareImportNotReadyMessage => this is AppStringsEn
      ? 'Share import will be connected a little more calmly in a follow-up step.'
      : '공유 문서 연동은 다음 단계에서 차분하게 이어 붙일게요.';
  String get unsupportedSharedPayloadMessage => this is AppStringsEn
      ? 'Only images or PDFs can be imported from sharing right now. Please share the file once more.'
      : '이미지나 PDF만 차분하게 가져올 수 있어요. 다시 한 번 공유해 주세요.';
  String get sharedDocumentMissingMessage => this is AppStringsEn
      ? 'The shared document could not be found. Please send it once more.'
      : '공유한 문서를 찾지 못했어요. 다시 한 번 보내 주세요.';

  String get cameraImportUnsupportedMessage => this is AppStringsEn
      ? 'Camera import is only available on supported mobile devices.'
      : '카메라 가져오기는 모바일 기기에서 사용할 수 있어요.';
  String get galleryImportUnsupportedMessage => this is AppStringsEn
      ? 'Photo import is only available on supported mobile devices.'
      : '사진 가져오기는 모바일 기기에서 사용할 수 있어요.';
  String get pdfImportUnsupportedMessage => this is AppStringsEn
      ? 'PDF import is not available on this device yet.'
      : 'PDF 가져오기는 이 기기에서 아직 지원하지 않아요.';
  String get cameraPermissionDeniedPermanentlyMessage => this is AppStringsEn
      ? 'Camera access is turned off. Please allow it in Settings.'
      : '카메라 권한이 꺼져 있어요. 설정에서 허용해 주세요.';
  String get cameraPermissionRequiredMessage => this is AppStringsEn
      ? 'Camera access is needed to turn a photo into a reminder right away.'
      : '카메라 권한이 필요해요. 촬영 후 바로 일정으로 정리해 드릴게요.';
  String get galleryPermissionDeniedPermanentlyMessage => this is AppStringsEn
      ? 'Photo access is turned off. Please allow it in Settings.'
      : '사진 접근 권한이 꺼져 있어요. 설정에서 허용해 주세요.';
  String get galleryPermissionRequiredMessage => this is AppStringsEn
      ? 'Photo access is needed to organize the document into a reminder.'
      : '사진 접근 권한이 필요해요. 저장된 문서를 일정으로 정리해 드릴게요.';
  String get cameraImportFailedMessage => this is AppStringsEn
      ? 'The captured document could not be loaded. Please try once more.'
      : '촬영한 문서를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.';
  String get galleryImportFailedMessage => this is AppStringsEn
      ? 'The photo document could not be loaded. Please try once more.'
      : '사진 문서를 불러오지 못했어요. 다시 한 번 시도해 주세요.';
  String get pdfImportMissingPathMessage => this is AppStringsEn
      ? 'The selected PDF could not be opened. Please try once more.'
      : '선택한 PDF를 열지 못했어요. 다시 시도해 주세요.';
  String get pdfImportFailedMessage => this is AppStringsEn
      ? 'The PDF could not be loaded. Please try again in a moment.'
      : 'PDF를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.';

  String get mockExistingReminderHint => this is AppStringsEn
      ? 'You are editing an existing reminder.'
      : '기존 리마인더를 수정하는 화면이에요.';
}
