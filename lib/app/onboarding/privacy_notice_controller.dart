import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/locale_preference_service.dart';

final privacyNoticeControllerProvider =
    NotifierProvider<PrivacyNoticeController, bool>(
      PrivacyNoticeController.new,
    );

class PrivacyNoticeController extends Notifier<bool> {
  late final LocalePreferenceService _preferenceService;

  @override
  bool build() {
    _preferenceService = ref.read(localePreferenceServiceProvider);
    return _preferenceService.loadPrivacyAcknowledged();
  }

  Future<void> dismissForever() async {
    await _preferenceService.savePrivacyAcknowledged(true);
    state = true;
  }
}
