import '../../core/models/app_enums.dart';
import 'app_strings.dart';
import 'locale_controller.dart';

class AppStringsEn extends AppStrings {
  const AppStringsEn();

  @override
  String get appTitle => 'PaperBell';

  @override
  String get homeNavLabel => 'Home';

  @override
  String get archiveNavLabel => 'Archive';

  @override
  String get settingsNavLabel => 'Settings';

  @override
  String get languageSelectionTitle => 'Choose your language';

  @override
  String get languageSelectionSubtitle =>
      'Pick the language you would like to use first. Your choice stays on this device, and you can change it anytime in Settings.';

  @override
  String get languageSelectionHint =>
      'This app is local-first, and the language setting is also stored only on this device.';

  @override
  String get languageOptionKorean => '🇰🇷 한국어';

  @override
  String get languageOptionEnglish => '🇺🇸 English';

  @override
  String get languageDialogTitle => 'Choose app language';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle =>
      'Review reminder defaults and privacy-related information here.';

  @override
  String get settingsStorageBanner =>
      'Documents and reminder data stay on this device by default.';

  @override
  String get settingsDefaultReminderTiming => 'Default reminder timing';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String settingsLanguageSubtitle(String languageName) =>
      'Current language: $languageName';

  @override
  String get settingsAppLockTitle => 'App lock';

  @override
  String get settingsAppLockSubtitle =>
      'This is informational for now and can be connected to biometric auth later.';

  @override
  String settingsLocalStorageSubtitle(int reminderCount) =>
      '$reminderCount reminders are currently stored on this device.';

  @override
  String get settingsLocalStorageTitle => 'Local storage';

  @override
  String get settingsDataExportTitle => 'Export data';

  @override
  String get settingsDataExportSubtitle =>
      'CSV/PDF export is planned for a later step.';

  @override
  String get aboutSectionTitle => 'About this app';

  @override
  String get aboutSectionDescription =>
      'PaperBell quietly turns saved documents into reminders while keeping data on this device.';

  @override
  String get aboutLocalFirstBadge => 'Local-first';

  @override
  String get aboutPrivacyFirstBadge => 'Privacy-first';

  @override
  String get aboutVersionTitle => 'Version';

  @override
  String get aboutContactTitle => 'Contact email';

  @override
  String get aboutPrivacyEntryLabel => 'View privacy notice';

  @override
  String get saveAction => 'Save';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get confirmAction => 'OK';

  @override
  String get dontShowAgainAction => "Don't show again";

  @override
  String get addImportAction => '+ Import';

  @override
  String get completeAction => 'Complete';

  @override
  String get snoozeAction => 'Snooze';

  @override
  String get viewDetailAction => 'View details';

  @override
  String get continueAction => 'Continue';

  @override
  String get editAction => 'Edit';

  @override
  String get deleteAction => 'Delete';

  @override
  String get preparingLabel => 'Preparing';

  @override
  String get noAmountLabel => 'No amount';

  @override
  String get unknownCurrencyLabel => 'Currency not set';

  @override
  String get todayRelativeLabel => 'Today';

  @override
  String get tomorrowRelativeLabel => 'Tomorrow';

  @override
  String get contactEmailSubject => '[App Inquiry]';

  @override
  String get contactEmailBodyTemplate => 'Device in use:\nIssue details:\n';

  @override
  String languageName(AppLanguage language) {
    return switch (language) {
      AppLanguage.korean => 'Korean',
      AppLanguage.english => 'English',
    };
  }

  @override
  String documentSourceLabel(DocumentSourceType sourceType) {
    return switch (sourceType) {
      DocumentSourceType.camera => 'Take a photo',
      DocumentSourceType.photoLibrary => 'Choose from photos',
      DocumentSourceType.pdf => 'Import PDF',
      DocumentSourceType.shareSheet => 'Recent shared document',
    };
  }

  @override
  String documentSourceHelperText(DocumentSourceType sourceType) {
    return switch (sourceType) {
      DocumentSourceType.camera => 'Capture a notice or bill right away.',
      DocumentSourceType.photoLibrary => 'Bring in a saved photo or screenshot.',
      DocumentSourceType.pdf => 'Open a contract or notice PDF.',
      DocumentSourceType.shareSheet =>
        'Continue with the document you shared most recently.',
    };
  }

  @override
  String reminderCategoryLabel(ReminderCategory category) {
    return switch (category) {
      ReminderCategory.utilities => 'Utilities',
      ReminderCategory.subscription => 'Subscription',
      ReminderCategory.insurance => 'Insurance',
      ReminderCategory.tax => 'Tax',
      ReminderCategory.medical => 'Medical',
      ReminderCategory.contractRenewal => 'Renewal',
      ReminderCategory.warranty => 'Warranty / A/S',
      ReminderCategory.other => 'Other',
    };
  }

  @override
  String reminderStatusLabel(ReminderStatus status) {
    return switch (status) {
      ReminderStatus.upcoming => 'Upcoming',
      ReminderStatus.completed => 'Completed',
      ReminderStatus.archived => 'Archived',
    };
  }

  @override
  String reminderRepeatRuleLabel(ReminderRepeatRule repeatRule) {
    return switch (repeatRule) {
      ReminderRepeatRule.none => 'No repeat',
      ReminderRepeatRule.monthly => 'Monthly',
      ReminderRepeatRule.yearly => 'Yearly',
      ReminderRepeatRule.custom => 'Custom',
    };
  }

  @override
  String reminderLeadTimeLabel(ReminderLeadTime leadTime) {
    return switch (leadTime) {
      ReminderLeadTime.sameDay => 'Morning of the same day',
      ReminderLeadTime.oneDayBefore => '1 day before',
      ReminderLeadTime.threeDaysBefore => '3 days before',
      ReminderLeadTime.sevenDaysBefore => '7 days before',
    };
  }

  @override
  String? extractedFieldStateLabel(ExtractedFieldState state) {
    return switch (state) {
      ExtractedFieldState.suggested => 'Suggested',
      ExtractedFieldState.needsConfirmation => 'Review needed',
      ExtractedFieldState.confirmed => null,
      ExtractedFieldState.missing => 'Enter manually',
    };
  }

  @override
  String get localOnlyProcessingBadge => 'On-device only';

  @override
  String get documentPreviewPlaceholderMessage =>
      'A placeholder for the document preview is ready here instead of the real image.\n'
      'This area can be connected to OCR and editing previews later.';

  @override
  String get homeHeroTitle => 'Upcoming admin tasks';

  @override
  String get homeHeroSubtitle =>
      'A calm view of the paperwork and deadlines that need your attention.';

  @override
  String get homeTodayStatTitle => 'Today';

  @override
  String get homeTodayStatSubtitle => 'Need attention today';

  @override
  String get homeThisWeekStatTitle => 'This week';

  @override
  String get homeThisWeekStatSubtitle => 'Planned for this week';

  @override
  String get homeMonthlyEstimateTitle => 'This month';

  @override
  String get homeMonthlyEstimateSubtitle => 'Estimated total to pay';

  @override
  String get homeMonthlyEstimateMixedSubtitle =>
      'Amounts are shown separately when currencies are mixed or unclear.';

  @override
  String summaryCountValue(int count) => '$count';

  @override
  String get filterAllLabel => 'All';

  @override
  String get filterTodayLabel => 'Today';

  @override
  String get filterThisWeekLabel => 'This week';

  @override
  String get filterCompletedLabel => 'Completed';

  @override
  String get filterArchivedLabel => 'Archived';

  @override
  String get filterUtilitiesLabel => 'Utilities';

  @override
  String get filterSubscriptionLabel => 'Subscription';

  @override
  String get filterInsuranceLabel => 'Insurance';

  @override
  String get homeListViewLabel => 'List';

  @override
  String get homeCalendarViewLabel => 'Calendar';

  @override
  String get homeUpcomingSectionTitle => 'Upcoming reminders';

  @override
  String get homeUpcomingSectionSubtitle =>
      'These were organized automatically, and you can adjust them anytime.';

  @override
  String get homeCalendarSectionTitle => 'Browse by date';

  @override
  String get homeCalendarSectionSubtitle =>
      'Tap a date to see the reminders scheduled for that day below.';

  @override
  String get homeCalendarEmptyTitle => 'No reminders on this date';

  @override
  String get homeCalendarEmptyDescription =>
      'Choose another date or switch back to the list view to browse everything.';

  @override
  String homeCalendarSelectedDateSubtitle(int count) =>
      count == 1 ? '1 reminder on this date' : '$count reminders on this date';

  @override
  String get homePreviousMonthAction => 'Previous month';

  @override
  String get homeNextMonthAction => 'Next month';

  @override
  String get homeGoToTodayAction => 'Go to today';

  @override
  String get homeEmptyTitle => 'No saved items yet';

  @override
  String get homeEmptyDescription =>
      'Import a document and the key dates and amounts will be turned into reminders for you.';

  @override
  String get archiveTitle => 'Archive';

  @override
  String get archiveSubtitle =>
      'Past reminders and saved documents are gathered here for quick access.';

  @override
  String get archiveSearchHint => 'Search by title or source';

  @override
  String get archiveEmptyTitle => 'No saved items yet';

  @override
  String get archiveEmptyDescription =>
      'Completed or archived reminders will be organized here.';

  @override
  String get reminderMarkedCompleteMessage => 'Marked the reminder as complete.';

  @override
  String get reminderSnoozedMessage => 'Moved the reminder back by 3 days.';

  @override
  String reminderSnoozedWithNoticeMessage(String notice) =>
      'Moved the reminder back by 3 days, and $notice';

  @override
  String get reminderSavedMessage => 'Reminder saved.';

  @override
  String reminderSavedWithNoticeMessage(String notice) =>
      'Reminder saved, and $notice';

  @override
  String get importSheetTitle => 'How would you like to import a document?';

  @override
  String get importSheetSubtitle =>
      'Bring in a photo or PDF, and the app will organize the important details.';

  @override
  String get importSheetBanner =>
      'Imported documents are handled on this device by default.';

  @override
  String get recentSharedDocumentMissingMessage =>
      'No recently shared document was found. Please share it once more.';

  @override
  String get documentReviewTitle => 'Review document';

  @override
  String get documentReviewHeaderTitle => 'Please review the imported document';

  @override
  String get documentReviewHeaderSubtitle =>
      'Look through the pages, then continue to extraction when you are ready.';

  @override
  String get documentReviewInfoBanner =>
      'Rotate and crop controls are prepared here. Wiring them to real editing can come in the next step.';

  @override
  String reviewRotationLabel(int degrees) => 'Current rotation: $degrees°';

  @override
  String get cropAdjustmentTitle => 'Crop area';

  @override
  String get rotateAction => 'Rotate';

  @override
  String get retakeAction => 'Retake';

  @override
  String get reselectAction => 'Choose again';

  @override
  String get parsingInProgressTitle => 'Reading the document';

  @override
  String get parsingInProgressSubtitle =>
      'Looking for key details like dates and amounts.';

  @override
  String get cropPlaceholderMessage => 'A placeholder for crop adjustment is ready here.';

  @override
  String get extractionConfirmTitle => 'Review details';

  @override
  String get sourcePreviewTitle => 'Source preview';

  @override
  String get sourcePreviewSubtitle =>
      'You can check the document and adjust the extracted details right away.';

  @override
  String get missingDateNotice => 'No date was found. Please choose one manually.';

  @override
  String get missingAmountNotice => 'You can still save it without an amount.';

  @override
  String get titleFieldLabel => 'Title';

  @override
  String get dateFieldLabel => 'Date';

  @override
  String get amountFieldLabel => 'Amount';

  @override
  String get currencySelectorTitle => 'Currency';

  @override
  String get currencyKrwLabel => 'KRW';

  @override
  String get currencyUsdLabel => 'USD';

  @override
  String get uncertainCurrencyHelper =>
      'The amount was read, but the currency could not be determined with confidence.\nPlease choose KRW or USD.';

  @override
  String get categoryFieldLabel => 'Category';

  @override
  String get memoFieldLabel => 'Memo';

  @override
  String get titleFieldHint => 'Example: Utility bill payment';

  @override
  String get dateFieldPlaceholder => 'Choose a date';

  @override
  String get amountFieldHint => 'You can leave this blank if there is no amount';

  @override
  String get memoFieldHint => 'Leave a note if you need one';

  @override
  String get repeatSectionTitle => 'Repeat';

  @override
  String get repeatToggleTitle => 'Save as a repeating reminder';

  @override
  String get repeatToggleSubtitle =>
      'Turn this on for recurring payments or renewals.';

  @override
  String get reminderTimingSectionTitle => 'Reminder timing';

  @override
  String get reparseAction => 'Scan again';

  @override
  String get reparsingAction => 'Scanning again...';

  @override
  String get defaultReminderTitle => 'New reminder';

  @override
  String get untitledReminderFallback => 'Untitled reminder';

  @override
  String get reminderDetailTitle => 'Reminder details';

  @override
  String get reminderDetailMissingTitle => 'Could not find that reminder';

  @override
  String get reminderDetailMissingDescription =>
      'It may already have been deleted or moved to a different state.';

  @override
  String get sourceDocumentSectionTitle => 'Source document';

  @override
  String get sourceDocumentSectionSubtitle =>
      'Review the document and extracted details together again.';

  @override
  String get savedInfoSectionTitle => 'Saved details';

  @override
  String get savedInfoSectionSubtitle =>
      'Only the key information is shown here for quick review.';

  @override
  String dueDateSummary(String formattedDate) => 'Due $formattedDate';

  @override
  String get memoSectionTitle => 'Memo';

  @override
  String get deleteReminderDialogTitle => 'Delete this reminder?';

  @override
  String get deleteReminderDialogContent =>
      'The linked document will stay, and only this reminder will be removed from the list.';

  @override
  String get settingsDataExportPreparingMessage =>
      'Data export is still being prepared.';

  @override
  String get donationTitle => 'Support the developer';

  @override
  String get donationDescription =>
      'This app is provided without ads.\n\n'
      'If it has been helpful,\n'
      'please cheer it on with a cup of coffee ☕\n\n'
      'Support is optional,\n'
      'and all core features remain available even without it.';

  @override
  String get donationOptionOne => 'Buy one coffee';

  @override
  String get donationOptionTwo => 'Buy two coffees';

  @override
  String get donationOptionSupport => 'Big support 💛';

  @override
  String donationPreparingMessage(String label) =>
      '$label is not connected yet. Your support already means a lot.';

  @override
  String get privacyTitle => 'Privacy and data notice';

  @override
  String get privacyBody =>
      'This app works without login, server transfer, or cloud sync.\n\n'
      'Imported photos, PDFs, extracted results, and reminder information\n'
      'are stored only on the device and are not sent to external servers.\n\n'
      'This app does not collect user information\n'
      'or operate by sending it elsewhere.';

  @override
  String get privacyCaution =>
      'Documents you import yourself may contain personal information,\n'
      'so please take care of device security.';

  @override
  String get privacyPolicyActionLabel => 'Open privacy policy';

  @override
  String get privacyPolicyLaunchError =>
      'Could not open the privacy policy link. Please try again in a moment.';

  @override
  String get contactTitle => 'Contact';

  @override
  String get contactBody =>
      'If you run into a problem or have an idea to improve the app, please let me know.\n'
      'I will review it calmly and do my best to reflect it.';

  @override
  String get contactSendLabel => 'Send inquiry';

  @override
  String get contactLaunchError =>
      'Could not open the mail app. Please try again in a moment.';

  @override
  String get cloudOptionTitle => 'Future cloud options';

  @override
  String get cloudOptionSubtitle =>
      'This is outside the MVP scope. The app currently works local-first.';

  @override
  String get mvpExcludedLabel => 'Outside MVP';

  @override
  String get clearLocalDataTitle => 'Delete all local data';

  @override
  String get clearLocalDataSubtitle =>
      'Remove all documents and reminder data from this device.';

  @override
  String get clearLocalDataDialogTitle => 'Delete all data?';

  @override
  String get clearLocalDataDialogContent =>
      'Saved reminders and document data will all be removed.';

  @override
  String get clearedLocalDataMessage => 'All local data has been deleted.';
}
