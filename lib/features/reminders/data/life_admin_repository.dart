import '../../import_flow/domain/document.dart';
import '../domain/reminder_item.dart';

class AppDataState {
  const AppDataState({required this.reminders, required this.documents});

  final List<ReminderItem> reminders;
  final Map<String, Document> documents;

  AppDataState copyWith({
    List<ReminderItem>? reminders,
    Map<String, Document>? documents,
  }) {
    return AppDataState(
      reminders: reminders ?? this.reminders,
      documents: documents ?? this.documents,
    );
  }
}

abstract class LifeAdminRepository {
  AppDataState loadInitialState();

  Future<AppDataState> upsertReminder(
    AppDataState current, {
    required ReminderItem reminder,
    required Document document,
  });

  Future<AppDataState> updateReminder(
    AppDataState current,
    ReminderItem reminder,
  );

  Future<AppDataState> deleteReminder(AppDataState current, String reminderId);

  Future<AppDataState> clearAll();
}
