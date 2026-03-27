import '../../core/models/app_enums.dart';
import 'app_strings.dart';
import 'locale_controller.dart';

class AppStringsKo extends AppStrings {
  const AppStringsKo();

  @override
  String get appTitle => '담아알림';

  @override
  String get homeNavLabel => '홈';

  @override
  String get archiveNavLabel => '보관함';

  @override
  String get settingsNavLabel => '설정';

  @override
  String get languageSelectionTitle => '언어를 선택해주세요';

  @override
  String get languageSelectionSubtitle =>
      '처음 사용할 언어를 골라주세요. 선택한 언어는 이 기기에만 저장되며 설정에서 언제든 바꿀 수 있어요.';

  @override
  String get languageSelectionHint =>
      '이 앱은 로컬 우선으로 동작하며, 언어 설정도 기기 안에만 저장됩니다.';

  @override
  String get languageOptionKorean => '🇰🇷 한국어';

  @override
  String get languageOptionEnglish => '🇺🇸 English';

  @override
  String get languageDialogTitle => '앱 언어 선택';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsSubtitle =>
      '기본 알림 방식과 개인정보 관련 안내를 차분히 확인할 수 있어요.';

  @override
  String get settingsStorageBanner =>
      '문서와 알림 정보는 기본적으로 이 기기 안에서만 처리됩니다.';

  @override
  String get settingsDefaultReminderTiming => '기본 알림 시점';

  @override
  String get settingsLanguageTitle => '언어 설정';

  @override
  String settingsLanguageSubtitle(String languageName) => '현재 언어: $languageName';

  @override
  String get settingsAppLockTitle => '앱 잠금';

  @override
  String get settingsAppLockSubtitle =>
      '현재는 안내용 옵션이며, 추후 생체 인증과 연결할 수 있어요.';

  @override
  String settingsLocalStorageSubtitle(int reminderCount) =>
      '현재 $reminderCount개의 일정이 이 기기에 저장되어 있어요.';

  @override
  String get settingsLocalStorageTitle => '로컬 저장 상태';

  @override
  String get settingsDataExportTitle => '데이터 내보내기';

  @override
  String get settingsDataExportSubtitle =>
      'CSV/PDF 내보내기는 다음 단계에서 연결할 예정이에요.';

  @override
  String get aboutSectionTitle => '앱 소개';

  @override
  String get aboutSectionDescription =>
      '담아알림은 문서를 조용히 정리해 알림으로 이어주고, 데이터는 이 기기 안에 머무르도록 돕는 앱이에요.';

  @override
  String get aboutLocalFirstBadge => '로컬 우선';

  @override
  String get aboutPrivacyFirstBadge => '개인정보 우선';

  @override
  String get aboutVersionTitle => '버전';

  @override
  String get aboutContactTitle => '문의 이메일';

  @override
  String get aboutPrivacyEntryLabel => '개인정보 안내 보기';

  @override
  String get saveAction => '저장';

  @override
  String get cancelAction => '취소';

  @override
  String get confirmAction => '확인';

  @override
  String get dontShowAgainAction => '다시 보지 않기';

  @override
  String get addImportAction => '+ 가져오기';

  @override
  String get completeAction => '완료';

  @override
  String get snoozeAction => '미루기';

  @override
  String get viewDetailAction => '상세 보기';

  @override
  String get continueAction => '계속하기';

  @override
  String get editAction => '수정';

  @override
  String get deleteAction => '삭제';

  @override
  String get preparingLabel => '준비 중';

  @override
  String get noAmountLabel => '금액 없음';

  @override
  String get unknownCurrencyLabel => '통화 미설정';

  @override
  String get todayRelativeLabel => '오늘';

  @override
  String get tomorrowRelativeLabel => '내일';

  @override
  String get contactEmailSubject => '[앱 문의]';

  @override
  String get contactEmailBodyTemplate => '사용 중인 기기:\n문제 상황:\n';

  @override
  String languageName(AppLanguage language) {
    return switch (language) {
      AppLanguage.korean => '한국어',
      AppLanguage.english => '영어',
    };
  }

  @override
  String documentSourceLabel(DocumentSourceType sourceType) {
    return switch (sourceType) {
      DocumentSourceType.camera => '카메라로 촬영',
      DocumentSourceType.photoLibrary => '사진에서 선택',
      DocumentSourceType.pdf => 'PDF 가져오기',
      DocumentSourceType.shareSheet => '최근 공유 문서',
    };
  }

  @override
  String documentSourceHelperText(DocumentSourceType sourceType) {
    return switch (sourceType) {
      DocumentSourceType.camera => '고지서나 안내문을 바로 촬영해요',
      DocumentSourceType.photoLibrary => '저장된 사진이나 스크린샷을 불러와요',
      DocumentSourceType.pdf => '계약서나 안내문 PDF를 불러와요',
      DocumentSourceType.shareSheet => '최근에 공유한 문서를 이어서 확인해요',
    };
  }

  @override
  String reminderCategoryLabel(ReminderCategory category) {
    return switch (category) {
      ReminderCategory.utilities => '공과금',
      ReminderCategory.subscription => '구독',
      ReminderCategory.insurance => '보험',
      ReminderCategory.tax => '세금',
      ReminderCategory.medical => '의료',
      ReminderCategory.contractRenewal => '계약갱신',
      ReminderCategory.warranty => '보증/AS',
      ReminderCategory.other => '기타',
    };
  }

  @override
  String reminderStatusLabel(ReminderStatus status) {
    return switch (status) {
      ReminderStatus.upcoming => '예정',
      ReminderStatus.completed => '완료',
      ReminderStatus.archived => '보관',
    };
  }

  @override
  String reminderRepeatRuleLabel(ReminderRepeatRule repeatRule) {
    return switch (repeatRule) {
      ReminderRepeatRule.none => '반복 안 함',
      ReminderRepeatRule.monthly => '매월',
      ReminderRepeatRule.yearly => '매년',
      ReminderRepeatRule.custom => '직접 설정',
    };
  }

  @override
  String reminderLeadTimeLabel(ReminderLeadTime leadTime) {
    return switch (leadTime) {
      ReminderLeadTime.sameDay => '당일 아침',
      ReminderLeadTime.oneDayBefore => '1일 전',
      ReminderLeadTime.threeDaysBefore => '3일 전',
      ReminderLeadTime.sevenDaysBefore => '7일 전',
    };
  }

  @override
  String? extractedFieldStateLabel(ExtractedFieldState state) {
    return switch (state) {
      ExtractedFieldState.suggested => '추천',
      ExtractedFieldState.needsConfirmation => '확인 필요',
      ExtractedFieldState.confirmed => null,
      ExtractedFieldState.missing => '직접 입력',
    };
  }

  @override
  String get localOnlyProcessingBadge => '기기 내부 처리';

  @override
  String get documentPreviewPlaceholderMessage =>
      '실제 이미지 대신 문서 미리보기 자리를 준비해 두었어요.\n'
      '이 영역은 이후 OCR 및 편집 미리보기와 연결될 예정입니다.';

  @override
  String get homeHeroTitle => '다가오는 생활 일정';

  @override
  String get homeHeroSubtitle => '놓치기 쉬운 문서 일정부터 차분히 정리해드릴게요.';

  @override
  String get homeTodayStatTitle => '오늘';

  @override
  String get homeTodayStatSubtitle => '오늘 확인할 일정';

  @override
  String get homeThisWeekStatTitle => '이번 주';

  @override
  String get homeThisWeekStatSubtitle => '이번 주에 예정된 일정';

  @override
  String get homeMonthlyEstimateTitle => '이번 달 예상';

  @override
  String get homeMonthlyEstimateSubtitle => '예상되는 납부 금액 합계';

  @override
  String get homeMonthlyEstimateMixedSubtitle =>
      '통화가 다르거나 미설정된 금액은 따로 보여드려요.';

  @override
  String summaryCountValue(int count) => '$count건';

  @override
  String get filterAllLabel => '전체';

  @override
  String get filterTodayLabel => '오늘';

  @override
  String get filterThisWeekLabel => '이번 주';

  @override
  String get filterCompletedLabel => '완료';

  @override
  String get filterArchivedLabel => '보관';

  @override
  String get filterUtilitiesLabel => '공과금';

  @override
  String get filterSubscriptionLabel => '구독';

  @override
  String get filterInsuranceLabel => '보험';

  @override
  String get homeListViewLabel => '목록';

  @override
  String get homeCalendarViewLabel => '달력';

  @override
  String get homeUpcomingSectionTitle => '다가오는 일정';

  @override
  String get homeUpcomingSectionSubtitle =>
      '자동으로 정리한 일정이에요. 필요하면 바로 수정할 수 있어요.';

  @override
  String get homeCalendarSectionTitle => '날짜로 보기';

  @override
  String get homeCalendarSectionSubtitle =>
      '달력에서 날짜를 누르면 그날의 일정을 아래에서 볼 수 있어요.';

  @override
  String get homeCalendarEmptyTitle => '선택한 날짜에는 일정이 없습니다';

  @override
  String get homeCalendarEmptyDescription =>
      '다른 날짜를 선택하거나 목록 보기로 전체 일정을 살펴보세요.';

  @override
  String homeCalendarSelectedDateSubtitle(int count) => '이 날짜의 일정 $count건';

  @override
  String get homePreviousMonthAction => '이전 달';

  @override
  String get homeNextMonthAction => '다음 달';

  @override
  String get homeGoToTodayAction => '오늘로 이동';

  @override
  String get homeEmptyTitle => '아직 저장된 항목이 없습니다';

  @override
  String get homeEmptyDescription =>
      '문서를 가져오면 날짜와 금액을 정리해 리마인더로 바꿔드릴게요.';

  @override
  String get archiveTitle => '보관함';

  @override
  String get archiveSubtitle =>
      '지난 일정과 저장된 문서를 다시 찾기 쉬운 형태로 모아두었어요.';

  @override
  String get archiveSearchHint => '제목이나 출처로 검색';

  @override
  String get archiveEmptyTitle => '아직 저장된 항목이 없습니다';

  @override
  String get archiveEmptyDescription =>
      '완료했거나 보관한 일정이 생기면 이곳에 차분히 정리됩니다.';

  @override
  String get reminderMarkedCompleteMessage => '일정을 완료로 표시했어요.';

  @override
  String get reminderSnoozedMessage => '일정을 3일 뒤로 미뤘어요.';

  @override
  String reminderSnoozedWithNoticeMessage(String notice) =>
      '일정을 3일 뒤로 미뤘고, $notice';

  @override
  String get reminderSavedMessage => '리마인더를 저장했어요.';

  @override
  String reminderSavedWithNoticeMessage(String notice) =>
      '리마인더를 저장했고, $notice';

  @override
  String get importSheetTitle => '문서를 가져오는 방법';

  @override
  String get importSheetSubtitle => '사진이나 PDF를 불러오면 필요한 정보를 정리해드릴게요.';

  @override
  String get importSheetBanner => '가져온 문서는 기본적으로 이 기기 안에서만 처리됩니다.';

  @override
  String get recentSharedDocumentMissingMessage =>
      '최근에 공유된 문서를 찾지 못했어요. 다시 한 번 공유해주세요.';

  @override
  String get documentReviewTitle => '문서 확인';

  @override
  String get documentReviewHeaderTitle => '가져온 문서를 확인해주세요';

  @override
  String get documentReviewHeaderSubtitle =>
      '페이지를 살펴본 뒤 바로 일정 추출로 이어갈 수 있어요.';

  @override
  String get documentReviewInfoBanner =>
      '회전과 영역 조정 UI는 준비되어 있고, 실제 편집 연결은 다음 단계에서 이어질 예정입니다.';

  @override
  String reviewRotationLabel(int degrees) => '현재 회전 각도: $degrees도';

  @override
  String get cropAdjustmentTitle => '영역 조정';

  @override
  String get rotateAction => '회전';

  @override
  String get retakeAction => '다시 촬영';

  @override
  String get reselectAction => '다시 선택';

  @override
  String get parsingInProgressTitle => '문서를 읽는 중이에요';

  @override
  String get parsingInProgressSubtitle => '날짜와 금액 같은 핵심 정보를 찾고 있어요.';

  @override
  String get cropPlaceholderMessage => '편집 영역 조정 자리를 준비해 두었어요.';

  @override
  String get extractionConfirmTitle => '정보 확인';

  @override
  String get sourcePreviewTitle => '원본 미리보기';

  @override
  String get sourcePreviewSubtitle => '문서를 보면서 필요한 내용을 바로 수정할 수 있어요.';

  @override
  String get missingDateNotice => '날짜를 찾지 못했어요. 직접 선택해주세요.';

  @override
  String get missingAmountNotice => '금액 없이도 저장할 수 있어요.';

  @override
  String get titleFieldLabel => '제목';

  @override
  String get dateFieldLabel => '날짜';

  @override
  String get amountFieldLabel => '금액';

  @override
  String get currencySelectorTitle => '통화 단위';

  @override
  String get currencyKrwLabel => '원화 (KRW)';

  @override
  String get currencyUsdLabel => '달러 (USD)';

  @override
  String get uncertainCurrencyHelper =>
      '금액은 읽었지만 통화 단위를 확실히 판단하지 못했어요.\n원화 또는 달러를 선택해주세요.';

  @override
  String get categoryFieldLabel => '카테고리';

  @override
  String get memoFieldLabel => '메모';

  @override
  String get titleFieldHint => '예: 관리비 납부';

  @override
  String get dateFieldPlaceholder => '날짜를 선택해주세요';

  @override
  String get amountFieldHint => '금액이 없으면 비워두셔도 괜찮아요';

  @override
  String get memoFieldHint => '필요하다면 메모를 남겨주세요';

  @override
  String get repeatSectionTitle => '반복 여부';

  @override
  String get repeatToggleTitle => '반복 일정으로 저장';

  @override
  String get repeatToggleSubtitle => '정기 결제나 갱신 일정이라면 켜주세요.';

  @override
  String get reminderTimingSectionTitle => '알림 시점';

  @override
  String get reparseAction => '다시 인식';

  @override
  String get reparsingAction => '다시 인식 중...';

  @override
  String get defaultReminderTitle => '새 리마인더';

  @override
  String get untitledReminderFallback => '새 일정';

  @override
  String get reminderDetailTitle => '리마인더 상세';

  @override
  String get reminderDetailMissingTitle => '일정을 찾지 못했어요';

  @override
  String get reminderDetailMissingDescription =>
      '이미 삭제했거나 보관 상태가 바뀌었을 수 있어요.';

  @override
  String get sourceDocumentSectionTitle => '원본 문서';

  @override
  String get sourceDocumentSectionSubtitle =>
      '문서와 추출된 정보를 함께 다시 확인할 수 있어요.';

  @override
  String get savedInfoSectionTitle => '저장된 정보';

  @override
  String get savedInfoSectionSubtitle => '필요한 핵심 정보만 빠르게 확인할 수 있어요.';

  @override
  String dueDateSummary(String formattedDate) => '마감 $formattedDate';

  @override
  String get memoSectionTitle => '메모';

  @override
  String get deleteReminderDialogTitle => '이 리마인더를 삭제할까요?';

  @override
  String get deleteReminderDialogContent =>
      '연결된 문서 정보는 그대로 두고, 일정만 목록에서 제거합니다.';

  @override
  String get settingsDataExportPreparingMessage => '데이터 내보내기를 준비하고 있어요.';

  @override
  String get donationTitle => '개발자 응원하기';

  @override
  String get donationDescription =>
      '이 앱은 광고 없이 제공되고 있습니다.\n\n'
      '도움이 되었다면\n'
      '커피 한 잔으로 응원해주세요 ☕\n\n'
      '후원은 선택 사항이며\n'
      '후원하지 않아도 모든 기본 기능을 사용할 수 있습니다.';

  @override
  String get donationOptionOne => '커피 한 잔 후원하기';

  @override
  String get donationOptionTwo => '커피 두 잔 후원하기';

  @override
  String get donationOptionSupport => '든든한 응원 💛';

  @override
  String donationPreparingMessage(String label) =>
      '$label 기능은 준비 중이에요. 마음만으로도 큰 응원이 됩니다.';

  @override
  String get privacyTitle => '개인정보 및 데이터 안내';

  @override
  String get privacyBody =>
      '이 앱은 로그인, 서버 전송, 클라우드 동기화 없이 동작합니다.\n\n'
      '입력한 사진, PDF, 추출 결과, 알림 정보는\n'
      '기기 내부에만 저장되며 외부 서버로 전송되지 않습니다.\n\n'
      '이 앱은 사용자의 정보를 수집하거나\n'
      '외부로 보내는 방식으로 동작하지 않습니다.';

  @override
  String get privacyCaution =>
      '사용자가 직접 가져온 문서에는 개인정보가 포함될 수 있으니\n'
      '기기 보안 관리에 주의해주세요.';

  @override
  String get privacyPolicyActionLabel => '개인정보처리방침 열기';

  @override
  String get privacyPolicyLaunchError =>
      '개인정보처리방침 링크를 열지 못했어요. 잠시 후 다시 시도해주세요.';

  @override
  String get contactTitle => '문의하기';

  @override
  String get contactBody =>
      '앱 사용 중 불편한 점이나 오류, 개선 의견이 있다면 알려주세요.\n'
      '가능한 범위에서 차분히 확인하고 반영하겠습니다.';

  @override
  String get contactSendLabel => '문의 보내기';

  @override
  String get contactLaunchError => '메일 앱을 열지 못했어요. 잠시 후 다시 시도해주세요.';

  @override
  String get cloudOptionTitle => '추후 클라우드 옵션';

  @override
  String get cloudOptionSubtitle =>
      'MVP 범위에는 포함하지 않았어요. 현재는 로컬 우선으로 동작합니다.';

  @override
  String get mvpExcludedLabel => 'MVP 제외';

  @override
  String get clearLocalDataTitle => '모든 로컬 데이터 삭제';

  @override
  String get clearLocalDataSubtitle => '문서와 일정 정보를 이 기기에서 모두 지워요.';

  @override
  String get clearLocalDataDialogTitle => '모든 데이터를 삭제할까요?';

  @override
  String get clearLocalDataDialogContent => '저장된 일정과 문서 정보가 모두 사라집니다.';

  @override
  String get clearedLocalDataMessage => '로컬 데이터를 모두 삭제했어요.';
}
