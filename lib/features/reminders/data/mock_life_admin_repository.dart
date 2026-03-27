import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/mock_sample_data.dart';
import '../../import_flow/domain/document.dart';
import 'life_admin_repository.dart';
import '../domain/reminder_item.dart';

final lifeAdminRepositoryProvider = Provider<LifeAdminRepository>(
  (ref) => MockLifeAdminRepository(),
);

class MockLifeAdminRepository implements LifeAdminRepository {
  @override
  AppDataState loadInitialState() {
    return AppDataState(
      reminders: MockSampleData.seededReminders(),
      documents: MockSampleData.seededDocuments(),
    );
  }

  @override
  Future<AppDataState> upsertReminder(
    AppDataState current, {
    required ReminderItem reminder,
    required Document document,
  }) async {
    final reminders = [...current.reminders];
    final index = reminders.indexWhere((item) => item.id == reminder.id);

    if (index == -1) {
      reminders.insert(0, reminder);
    } else {
      reminders[index] = reminder;
    }

    final documents = {...current.documents, document.id: document};

    return current.copyWith(reminders: reminders, documents: documents);
  }

  @override
  Future<AppDataState> updateReminder(
    AppDataState current,
    ReminderItem reminder,
  ) async {
    final reminders = current.reminders
        .map((item) => item.id == reminder.id ? reminder : item)
        .toList();
    return current.copyWith(reminders: reminders);
  }

  @override
  Future<AppDataState> deleteReminder(
    AppDataState current,
    String reminderId,
  ) async {
    final reminders = current.reminders
        .where((item) => item.id != reminderId)
        .toList();
    return current.copyWith(reminders: reminders);
  }

  @override
  Future<AppDataState> clearAll() async {
    return const AppDataState(reminders: [], documents: {});
  }
}
