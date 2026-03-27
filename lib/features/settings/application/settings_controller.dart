import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/app_enums.dart';

class SettingsState {
  const SettingsState({
    required this.defaultLeadTime,
    required this.appLockEnabled,
  });

  final ReminderLeadTime defaultLeadTime;
  final bool appLockEnabled;

  SettingsState copyWith({
    ReminderLeadTime? defaultLeadTime,
    bool? appLockEnabled,
  }) {
    return SettingsState(
      defaultLeadTime: defaultLeadTime ?? this.defaultLeadTime,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
    );
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);

class SettingsController extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    return const SettingsState(
      defaultLeadTime: ReminderLeadTime.oneDayBefore,
      appLockEnabled: false,
    );
  }

  void updateLeadTime(ReminderLeadTime leadTime) {
    state = state.copyWith(defaultLeadTime: leadTime);
  }

  void toggleAppLock(bool enabled) {
    state = state.copyWith(appLockEnabled: enabled);
  }
}
