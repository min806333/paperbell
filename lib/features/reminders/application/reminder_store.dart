import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/app_enums.dart';
import '../../import_flow/domain/document.dart';
import '../data/life_admin_repository.dart';
import '../data/mock_life_admin_repository.dart';
import '../domain/reminder_item.dart';
import '../services/reminder_notification_scheduler.dart';

final reminderStoreProvider = NotifierProvider<ReminderStore, AppDataState>(
  ReminderStore.new,
);

class ReminderStore extends Notifier<AppDataState> {
  late final LifeAdminRepository _repository;

  @override
  AppDataState build() {
    _repository = ref.read(lifeAdminRepositoryProvider);
    return _repository.loadInitialState();
  }

  ReminderItem? reminderById(String reminderId) {
    for (final reminder in state.reminders) {
      if (reminder.id == reminderId) {
        return reminder;
      }
    }
    return null;
  }

  Document? documentById(String documentId) => state.documents[documentId];

  Future<String?> saveReminder({
    required ReminderItem reminder,
    required Document document,
  }) async {
    state = await _repository.upsertReminder(
      state,
      reminder: reminder,
      document: document,
    );

    final notificationFeedback = await ref
        .read(reminderNotificationSchedulerProvider)
        .syncReminder(reminder);

    return notificationFeedback.notice;
  }

  Future<void> completeReminder(String reminderId) async {
    final current = reminderById(reminderId);
    if (current == null) {
      return;
    }

    state = await _repository.updateReminder(
      state,
      current.copyWith(
        status: ReminderStatus.completed,
        updatedAt: DateTime.now(),
      ),
    );

    await ref
        .read(reminderNotificationSchedulerProvider)
        .cancelReminder(reminderId);
  }

  Future<void> archiveReminder(String reminderId) async {
    final current = reminderById(reminderId);
    if (current == null) {
      return;
    }

    state = await _repository.updateReminder(
      state,
      current.copyWith(
        status: ReminderStatus.archived,
        updatedAt: DateTime.now(),
      ),
    );

    await ref
        .read(reminderNotificationSchedulerProvider)
        .cancelReminder(reminderId);
  }

  Future<String?> snoozeReminder(
    String reminderId, {
    Duration duration = const Duration(days: 3),
  }) async {
    final current = reminderById(reminderId);
    if (current == null) {
      return null;
    }

    final updatedReminder = current.copyWith(
      dueAt: current.dueAt.add(duration),
      status: ReminderStatus.upcoming,
      updatedAt: DateTime.now(),
    );

    state = await _repository.updateReminder(state, updatedReminder);

    final notificationFeedback = await ref
        .read(reminderNotificationSchedulerProvider)
        .syncReminder(updatedReminder);

    return notificationFeedback.notice;
  }

  Future<void> deleteReminder(String reminderId) async {
    state = await _repository.deleteReminder(state, reminderId);
    await ref
        .read(reminderNotificationSchedulerProvider)
        .cancelReminder(reminderId);
  }

  Future<void> clearAll() async {
    state = await _repository.clearAll();
    await ref.read(reminderNotificationSchedulerProvider).cancelAll();
  }
}
