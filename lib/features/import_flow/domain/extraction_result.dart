import '../../../core/models/app_enums.dart';
import 'extracted_field.dart';

class ExtractionResult {
  const ExtractionResult({
    required this.documentId,
    required this.title,
    required this.dueAt,
    required this.amount,
    this.currencyCode = const ExtractedField<String?>(
      value: null,
      state: ExtractedFieldState.missing,
    ),
    required this.category,
    required this.note,
    required this.sourceSubtitle,
    required this.repeatRule,
    required this.reminderLeadTime,
    required this.hints,
  });

  final String documentId;
  final ExtractedField<String> title;
  final ExtractedField<DateTime> dueAt;
  final ExtractedField<double> amount;
  final ExtractedField<String?> currencyCode;
  final ExtractedField<ReminderCategory> category;
  final ExtractedField<String> note;
  final String sourceSubtitle;
  final ReminderRepeatRule repeatRule;
  final ReminderLeadTime reminderLeadTime;
  final List<String> hints;

  ExtractedField<double> get amountValue => amount;

  ExtractionResult copyWith({
    String? documentId,
    ExtractedField<String>? title,
    ExtractedField<DateTime>? dueAt,
    ExtractedField<double>? amount,
    ExtractedField<String?>? currencyCode,
    ExtractedField<ReminderCategory>? category,
    ExtractedField<String>? note,
    String? sourceSubtitle,
    ReminderRepeatRule? repeatRule,
    ReminderLeadTime? reminderLeadTime,
    List<String>? hints,
  }) {
    return ExtractionResult(
      documentId: documentId ?? this.documentId,
      title: title ?? this.title,
      dueAt: dueAt ?? this.dueAt,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      category: category ?? this.category,
      note: note ?? this.note,
      sourceSubtitle: sourceSubtitle ?? this.sourceSubtitle,
      repeatRule: repeatRule ?? this.repeatRule,
      reminderLeadTime: reminderLeadTime ?? this.reminderLeadTime,
      hints: hints ?? this.hints,
    );
  }
}
