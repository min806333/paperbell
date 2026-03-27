import 'package:flutter/material.dart';

abstract final class AppBranding {
  static const String globalAppName = 'PaperBell';
  static const String localizedKoreanAppName = '담아알림';
  static const String defaultStoreTitle = 'PaperBell - Doc Reminder';
  static const String localizedKoreanStoreTitle = '담아알림 - 문서 리마인더';
  static const String contactEmail = 'lup53699@gmail.com';

  // Keep this in sync with pubspec.yaml until runtime package info is added.
  static const String versionLabel = '1.0.0+1';

  // Set these after publishing the privacy policy to a real public URL.
  // Example:
  // https://YOUR-DOMAIN/privacy/en/
  // https://YOUR-DOMAIN/privacy/ko/
  static const String? privacyPolicyKoUrl = null;
  static const String? privacyPolicyEnUrl = null;

  static String appNameForLocale(Locale locale) {
    return switch (locale.languageCode) {
      'ko' => localizedKoreanAppName,
      _ => globalAppName,
    };
  }

  static String storeTitleForLocale(Locale locale) {
    return switch (locale.languageCode) {
      'ko' => localizedKoreanStoreTitle,
      _ => defaultStoreTitle,
    };
  }

  static String? privacyPolicyUrlForLocale(Locale locale) {
    return switch (locale.languageCode) {
      'en' => privacyPolicyEnUrl ?? privacyPolicyKoUrl,
      _ => privacyPolicyKoUrl ?? privacyPolicyEnUrl,
    };
  }
}
