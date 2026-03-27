import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class LocalePreferenceService {
  String? loadLanguageCode();

  Future<void> saveLanguageCode(String languageCode);

  bool loadPrivacyAcknowledged();

  Future<void> savePrivacyAcknowledged(bool acknowledged);
}

class SharedPreferencesLocalePreferenceService
    implements LocalePreferenceService {
  SharedPreferencesLocalePreferenceService(this._preferences);

  static const languageCodeKey = 'app_language_code';
  static const privacyAcknowledgedKey = 'privacy_acknowledged';

  final SharedPreferences _preferences;

  @override
  String? loadLanguageCode() => _preferences.getString(languageCodeKey);

  @override
  Future<void> saveLanguageCode(String languageCode) async {
    await _preferences.setString(languageCodeKey, languageCode);
  }

  @override
  bool loadPrivacyAcknowledged() =>
      _preferences.getBool(privacyAcknowledgedKey) ?? false;

  @override
  Future<void> savePrivacyAcknowledged(bool acknowledged) async {
    await _preferences.setBool(privacyAcknowledgedKey, acknowledged);
  }
}

class InMemoryLocalePreferenceService implements LocalePreferenceService {
  String? _languageCode;
  bool _privacyAcknowledged = false;

  @override
  String? loadLanguageCode() => _languageCode;

  @override
  Future<void> saveLanguageCode(String languageCode) async {
    _languageCode = languageCode;
  }

  @override
  bool loadPrivacyAcknowledged() => _privacyAcknowledged;

  @override
  Future<void> savePrivacyAcknowledged(bool acknowledged) async {
    _privacyAcknowledged = acknowledged;
  }
}

final localePreferenceServiceProvider = Provider<LocalePreferenceService>(
  (ref) => InMemoryLocalePreferenceService(),
);
