import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_strings.dart';
import 'locale_preference_service.dart';

enum AppLanguage {
  korean('ko', Locale('ko', 'KR')),
  english('en', Locale('en', 'US'));

  const AppLanguage(this.code, this.locale);

  final String code;
  final Locale locale;

  static AppLanguage? fromCode(String? code) {
    return switch (code) {
      'ko' => AppLanguage.korean,
      'en' => AppLanguage.english,
      _ => null,
    };
  }
}

class AppLocaleState {
  const AppLocaleState({
    required this.language,
    required this.hasSelectedLanguage,
  });

  final AppLanguage language;
  final bool hasSelectedLanguage;

  Locale get locale => language.locale;
}

final appLocaleControllerProvider =
    NotifierProvider<AppLocaleController, AppLocaleState>(
      AppLocaleController.new,
    );

class AppLocaleController extends Notifier<AppLocaleState> {
  late final LocalePreferenceService _preferenceService;

  @override
  AppLocaleState build() {
    _preferenceService = ref.read(localePreferenceServiceProvider);
    final savedLanguage = AppLanguage.fromCode(
      _preferenceService.loadLanguageCode(),
    );
    final fallbackLanguage =
        AppLanguage.fromCode(PlatformDispatcher.instance.locale.languageCode) ??
        AppLanguage.korean;

    final state = AppLocaleState(
      language: savedLanguage ?? fallbackLanguage,
      hasSelectedLanguage: savedLanguage != null,
    );
    AppStringsRuntime.setLocale(state.locale);
    return state;
  }

  Future<void> selectLanguage(AppLanguage language) async {
    await _preferenceService.saveLanguageCode(language.code);
    state = AppLocaleState(language: language, hasSelectedLanguage: true);
    AppStringsRuntime.setLocale(state.locale);
  }
}
