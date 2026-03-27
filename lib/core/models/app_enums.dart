import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

enum DocumentSourceType { camera, photoLibrary, pdf, shareSheet }

extension DocumentSourceTypeX on DocumentSourceType {
  String get label => switch (this) {
    DocumentSourceType.camera => '카메라로 촬영',
    DocumentSourceType.photoLibrary => '사진에서 선택',
    DocumentSourceType.pdf => 'PDF 가져오기',
    DocumentSourceType.shareSheet => '최근 공유 문서',
  };

  String get helperText => switch (this) {
    DocumentSourceType.camera => '고지서나 안내문을 바로 촬영해요',
    DocumentSourceType.photoLibrary => '이미 저장한 스크린샷이나 사진을 불러와요',
    DocumentSourceType.pdf => '계약서나 안내문 PDF를 불러와요',
    DocumentSourceType.shareSheet => '최근에 공유한 문서를 이어서 확인해요',
  };

  IconData get icon => switch (this) {
    DocumentSourceType.camera => Icons.camera_alt_outlined,
    DocumentSourceType.photoLibrary => Icons.photo_library_outlined,
    DocumentSourceType.pdf => Icons.picture_as_pdf_outlined,
    DocumentSourceType.shareSheet => Icons.share_outlined,
  };
}

enum ReminderCategory {
  utilities,
  subscription,
  insurance,
  tax,
  medical,
  contractRenewal,
  warranty,
  other,
}

extension ReminderCategoryX on ReminderCategory {
  String get label => switch (this) {
    ReminderCategory.utilities => '공과금',
    ReminderCategory.subscription => '구독',
    ReminderCategory.insurance => '보험',
    ReminderCategory.tax => '세금',
    ReminderCategory.medical => '의료',
    ReminderCategory.contractRenewal => '계약갱신',
    ReminderCategory.warranty => '보증/AS',
    ReminderCategory.other => '기타',
  };

  IconData get icon => switch (this) {
    ReminderCategory.utilities => Icons.apartment_outlined,
    ReminderCategory.subscription => Icons.subscriptions_outlined,
    ReminderCategory.insurance => Icons.shield_outlined,
    ReminderCategory.tax => Icons.receipt_long_outlined,
    ReminderCategory.medical => Icons.medical_services_outlined,
    ReminderCategory.contractRenewal => Icons.description_outlined,
    ReminderCategory.warranty => Icons.verified_user_outlined,
    ReminderCategory.other => Icons.folder_open_outlined,
  };

  Color get backgroundColor => switch (this) {
    ReminderCategory.utilities => const Color(0xFFE6F3EF),
    ReminderCategory.subscription => const Color(0xFFE8F0FA),
    ReminderCategory.insurance => const Color(0xFFEDEAF9),
    ReminderCategory.tax => const Color(0xFFFDF0DF),
    ReminderCategory.medical => const Color(0xFFFDE7EC),
    ReminderCategory.contractRenewal => const Color(0xFFE8F4F6),
    ReminderCategory.warranty => const Color(0xFFF2F5EA),
    ReminderCategory.other => const Color(0xFFF3F4F6),
  };

  Color get foregroundColor => switch (this) {
    ReminderCategory.utilities => AppColors.primary,
    ReminderCategory.subscription => const Color(0xFF355C9C),
    ReminderCategory.insurance => const Color(0xFF5A3FA3),
    ReminderCategory.tax => AppColors.warning,
    ReminderCategory.medical => const Color(0xFFB33B5E),
    ReminderCategory.contractRenewal => const Color(0xFF2E6B73),
    ReminderCategory.warranty => const Color(0xFF55712F),
    ReminderCategory.other => AppColors.textSecondary,
  };
}

enum ReminderStatus { upcoming, completed, archived }

extension ReminderStatusX on ReminderStatus {
  String get label => switch (this) {
    ReminderStatus.upcoming => '예정',
    ReminderStatus.completed => '완료됨',
    ReminderStatus.archived => '보관됨',
  };
}

enum ReminderRepeatRule { none, monthly, yearly, custom }

extension ReminderRepeatRuleX on ReminderRepeatRule {
  String get label => switch (this) {
    ReminderRepeatRule.none => '반복 안 함',
    ReminderRepeatRule.monthly => '매월',
    ReminderRepeatRule.yearly => '매년',
    ReminderRepeatRule.custom => '직접 설정',
  };
}

enum ReminderLeadTime {
  sameDay,
  oneDayBefore,
  threeDaysBefore,
  sevenDaysBefore,
}

extension ReminderLeadTimeX on ReminderLeadTime {
  String get label => switch (this) {
    ReminderLeadTime.sameDay => '당일 오전',
    ReminderLeadTime.oneDayBefore => '1일 전',
    ReminderLeadTime.threeDaysBefore => '3일 전',
    ReminderLeadTime.sevenDaysBefore => '7일 전',
  };

  int get daysBefore => switch (this) {
    ReminderLeadTime.sameDay => 0,
    ReminderLeadTime.oneDayBefore => 1,
    ReminderLeadTime.threeDaysBefore => 3,
    ReminderLeadTime.sevenDaysBefore => 7,
  };

  static ReminderLeadTime fromDays(int value) =>
      ReminderLeadTime.values.firstWhere(
        (leadTime) => leadTime.daysBefore == value,
        orElse: () => ReminderLeadTime.oneDayBefore,
      );
}

enum ExtractedFieldState { suggested, needsConfirmation, confirmed, missing }

extension ExtractedFieldStateX on ExtractedFieldState {
  String? get badgeLabel => switch (this) {
    ExtractedFieldState.suggested => '추천',
    ExtractedFieldState.needsConfirmation => '확인 필요',
    ExtractedFieldState.confirmed => null,
    ExtractedFieldState.missing => '직접 입력',
  };
}
