import '../../../core/models/app_enums.dart';

class ReminderItem {
  const ReminderItem({
    required this.id,
    required this.documentId,
    required this.title,
    required this.category,
    required this.dueAt,
    required this.amount,
    required this.currency,
    required this.note,
    required this.repeatRule,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.sourceSubtitle,
    required this.reminderLeadDays,
  });

  final String id;
  final String documentId;
  final String title;
  final ReminderCategory category;
  final DateTime dueAt;
  final double? amount;
  final String? currency;
  final String? note;
  final ReminderRepeatRule repeatRule;
  final ReminderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String sourceSubtitle;
  final int reminderLeadDays;

  ReminderItem copyWith({
    String? id,
    String? documentId,
    String? title,
    ReminderCategory? category,
    DateTime? dueAt,
    double? amount,
    bool clearAmount = false,
    String? currency,
    String? note,
    bool clearNote = false,
    ReminderRepeatRule? repeatRule,
    ReminderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sourceSubtitle,
    int? reminderLeadDays,
  }) {
    return ReminderItem(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      title: title ?? this.title,
      category: category ?? this.category,
      dueAt: dueAt ?? this.dueAt,
      amount: clearAmount ? null : amount ?? this.amount,
      currency: currency ?? this.currency,
      note: clearNote ? null : note ?? this.note,
      repeatRule: repeatRule ?? this.repeatRule,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sourceSubtitle: sourceSubtitle ?? this.sourceSubtitle,
      reminderLeadDays: reminderLeadDays ?? this.reminderLeadDays,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'documentId': documentId,
      'title': title,
      'category': category.name,
      'dueAt': dueAt.toIso8601String(),
      'amount': amount,
      'currency': currency,
      'note': note,
      'repeatRule': repeatRule.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'sourceSubtitle': sourceSubtitle,
      'reminderLeadDays': reminderLeadDays,
    };
  }

  factory ReminderItem.fromMap(Map<String, Object?> map) {
    return ReminderItem(
      id: map['id']! as String,
      documentId: map['documentId']! as String,
      title: map['title']! as String,
      category: ReminderCategory.values.byName(map['category']! as String),
      dueAt: DateTime.parse(map['dueAt']! as String),
      amount: map['amount'] as double?,
      currency: map['currency'] as String?,
      note: map['note'] as String?,
      repeatRule: ReminderRepeatRule.values.byName(
        map['repeatRule']! as String,
      ),
      status: ReminderStatus.values.byName(map['status']! as String),
      createdAt: DateTime.parse(map['createdAt']! as String),
      updatedAt: DateTime.parse(map['updatedAt']! as String),
      sourceSubtitle: map['sourceSubtitle']! as String,
      reminderLeadDays: map['reminderLeadDays']! as int,
    );
  }

  double? get amountValue => amount;

  String? get currencyCode => currency;
}
