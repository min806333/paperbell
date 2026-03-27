import '../../reminders/domain/reminder_item.dart';
import 'document.dart';
import 'extraction_result.dart';

class ImportSession {
  const ImportSession({
    required this.document,
    required this.extraction,
    this.existingReminderId,
    this.existingReminder,
  });

  final Document document;
  final ExtractionResult extraction;
  final String? existingReminderId;
  final ReminderItem? existingReminder;
}
