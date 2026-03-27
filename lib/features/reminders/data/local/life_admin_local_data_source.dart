import 'package:sqflite/sqflite.dart';

import '../../../../core/models/app_enums.dart';
import '../../../import_flow/domain/document.dart';
import '../../../import_flow/domain/document_page.dart';
import '../../../import_flow/domain/document_preprocessing.dart';
import '../../domain/reminder_item.dart';
import '../life_admin_repository.dart';
import 'life_admin_database_service.dart';

abstract class LifeAdminLocalDataSource {
  Future<void> initialize();
  Future<bool> isEmpty();
  Future<bool> hasSeededDemoData();
  Future<void> markDemoDataSeeded();
  Future<AppDataState> loadState();
  Future<void> upsertDocument(Document document);
  Future<void> upsertReminder(ReminderItem reminder);
  Future<void> deleteReminder(String reminderId);
  Future<void> clearAll();
  Future<void> seedDemoData({
    required List<ReminderItem> reminders,
    required Map<String, Document> documents,
  });
}

class SqfliteLifeAdminLocalDataSource implements LifeAdminLocalDataSource {
  SqfliteLifeAdminLocalDataSource({
    required LifeAdminDatabaseService databaseService,
  }) : _databaseService = databaseService;

  static const _demoSeededKey = 'demo_seeded';

  final LifeAdminDatabaseService _databaseService;

  @override
  Future<void> initialize() async {
    await _databaseService.open();
  }

  @override
  Future<bool> isEmpty() async {
    final database = await _databaseService.open();
    final count =
        Sqflite.firstIntValue(
          await database.rawQuery('SELECT COUNT(*) FROM reminders'),
        ) ??
        0;
    return count == 0;
  }

  @override
  Future<bool> hasSeededDemoData() async {
    final database = await _databaseService.open();
    final rows = await database.query(
      'app_metadata',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [_demoSeededKey],
      limit: 1,
    );

    if (rows.isEmpty) {
      return false;
    }

    return rows.first['value'] == '1';
  }

  @override
  Future<void> markDemoDataSeeded() async {
    final database = await _databaseService.open();
    await database.insert('app_metadata', {
      'key': _demoSeededKey,
      'value': '1',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<AppDataState> loadState() async {
    final database = await _databaseService.open();
    final documentRows = await database.query(
      'documents',
      orderBy: 'created_at DESC',
    );
    final pageRows = await database.query(
      'document_pages',
      orderBy: 'page_number ASC',
    );
    final reminderRows = await database.query(
      'reminders',
      orderBy: 'due_at ASC, updated_at DESC',
    );

    final pagesByDocumentId = <String, List<DocumentPage>>{};
    for (final row in pageRows) {
      final documentId = row['document_id']! as String;
      pagesByDocumentId.putIfAbsent(documentId, () => []);
      pagesByDocumentId[documentId]!.add(
        DocumentPage(
          id: row['id']! as String,
          pageNumber: row['page_number']! as int,
          previewLabel: row['preview_label']! as String,
          helperText: row['helper_text']! as String,
        ),
      );
    }

    final documents = <String, Document>{};
    for (final row in documentRows) {
      final documentId = row['id']! as String;
      documents[documentId] = Document(
        id: documentId,
        sourceType: DocumentSourceType.values.byName(
          row['source_type']! as String,
        ),
        title: row['title']! as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          row['created_at']! as int,
        ),
        originalPath: row['original_path'] as String? ?? '',
        containsSensitive: (row['contains_sensitive']! as int) == 1,
        preprocessing: DocumentPreprocessing(
          rotationQuarterTurns:
              (row['rotation_quarter_turns'] as int?) ?? 0,
          cropInsetRatio: (row['crop_inset_ratio'] as num?)?.toDouble() ?? 0,
        ),
        pages: pagesByDocumentId[documentId] ?? const [],
      );
    }

    final reminders = [
      for (final row in reminderRows)
        ReminderItem(
          id: row['id']! as String,
          documentId: row['document_id']! as String,
          title: row['title']! as String,
          category: ReminderCategory.values.byName(row['category']! as String),
          dueAt: DateTime.fromMillisecondsSinceEpoch(row['due_at']! as int),
          amount: (row['amount'] as num?)?.toDouble(),
          currency: row['currency'] as String?,
          note: row['note'] as String?,
          repeatRule: ReminderRepeatRule.values.byName(
            (row['repeat_rule'] as String?) ?? ReminderRepeatRule.none.name,
          ),
          status: ReminderStatus.values.byName(row['status']! as String),
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            row['created_at']! as int,
          ),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(
            row['updated_at']! as int,
          ),
          sourceSubtitle: row['source_subtitle']! as String,
          reminderLeadDays: row['reminder_lead_days']! as int,
        ),
    ];

    return AppDataState(reminders: reminders, documents: documents);
  }

  @override
  Future<void> upsertDocument(Document document) async {
    final database = await _databaseService.open();
    await database.transaction((transaction) async {
      await _upsertDocumentTransaction(transaction, document);
    });
  }

  @override
  Future<void> upsertReminder(ReminderItem reminder) async {
    final database = await _databaseService.open();
    await _upsertReminderTransaction(database, reminder);
  }

  @override
  Future<void> deleteReminder(String reminderId) async {
    final database = await _databaseService.open();
    await database.transaction((transaction) async {
      final reminderRows = await transaction.query(
        'reminders',
        columns: ['document_id'],
        where: 'id = ?',
        whereArgs: [reminderId],
        limit: 1,
      );
      final documentId = reminderRows.isEmpty
          ? null
          : reminderRows.first['document_id'] as String?;

      await transaction.delete(
        'reminders',
        where: 'id = ?',
        whereArgs: [reminderId],
      );

      if (documentId == null) {
        return;
      }

      final remainingCount =
          Sqflite.firstIntValue(
            await transaction.rawQuery(
              'SELECT COUNT(*) FROM reminders WHERE document_id = ?',
              [documentId],
            ),
          ) ??
          0;

      if (remainingCount == 0) {
        await transaction.delete(
          'documents',
          where: 'id = ?',
          whereArgs: [documentId],
        );
      }
    });
  }

  @override
  Future<void> clearAll() async {
    final database = await _databaseService.open();
    await database.transaction((transaction) async {
      await transaction.delete('reminders');
      await transaction.delete('document_pages');
      await transaction.delete('documents');
    });
  }

  @override
  Future<void> seedDemoData({
    required List<ReminderItem> reminders,
    required Map<String, Document> documents,
  }) async {
    final database = await _databaseService.open();
    await database.transaction((transaction) async {
      for (final document in documents.values) {
        await _upsertDocumentTransaction(transaction, document);
      }

      for (final reminder in reminders) {
        await _upsertReminderTransaction(transaction, reminder);
      }
    });
  }

  Future<void> _upsertDocumentTransaction(
    DatabaseExecutor executor,
    Document document,
  ) async {
    await executor.insert('documents', {
      'id': document.id,
      'source_type': document.sourceType.name,
      'title': document.title,
      'original_path': document.originalPath.isEmpty
          ? null
          : document.originalPath,
      'created_at': document.createdAt.millisecondsSinceEpoch,
      'contains_sensitive': document.containsSensitive ? 1 : 0,
      'rotation_quarter_turns':
          document.preprocessing.normalizedRotationQuarterTurns,
      'crop_inset_ratio': document.preprocessing.normalizedCropInsetRatio,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await executor.delete(
      'document_pages',
      where: 'document_id = ?',
      whereArgs: [document.id],
    );

    for (final page in document.pages) {
      await executor.insert('document_pages', {
        'id': page.id,
        'document_id': document.id,
        'page_number': page.pageNumber,
        'preview_label': page.previewLabel,
        'helper_text': page.helperText,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> _upsertReminderTransaction(
    DatabaseExecutor executor,
    ReminderItem reminder,
  ) async {
    await executor.insert('reminders', {
      'id': reminder.id,
      'document_id': reminder.documentId,
      'title': reminder.title,
      'category': reminder.category.name,
      'due_at': reminder.dueAt.millisecondsSinceEpoch,
      'amount': reminder.amount,
      'currency': reminder.currency,
      'note': reminder.note,
      'repeat_rule': reminder.repeatRule.name,
      'status': reminder.status.name,
      'created_at': reminder.createdAt.millisecondsSinceEpoch,
      'updated_at': reminder.updatedAt.millisecondsSinceEpoch,
      'source_subtitle': reminder.sourceSubtitle,
      'reminder_lead_days': reminder.reminderLeadDays,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
