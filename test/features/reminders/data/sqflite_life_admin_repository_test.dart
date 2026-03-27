import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_admin_assistant/core/models/app_enums.dart';
import 'package:life_admin_assistant/features/import_flow/domain/document.dart';
import 'package:life_admin_assistant/features/import_flow/domain/document_page.dart';
import 'package:life_admin_assistant/features/reminders/data/local/life_admin_database_service.dart';
import 'package:life_admin_assistant/features/reminders/data/local/life_admin_local_data_source.dart';
import 'package:life_admin_assistant/features/reminders/data/sqflite_life_admin_repository.dart';
import 'package:life_admin_assistant/features/reminders/domain/reminder_item.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Directory tempDirectory;
  late String databasePath;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'life_admin_assistant_test_',
    );
    databasePath = p.join(tempDirectory.path, 'life_admin_assistant.db');
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test(
    'sqflite repository persists reminders across restarts and does not reseed after clearAll',
    () async {
      Future<
        ({
          SqfliteLifeAdminRepository repository,
          LifeAdminDatabaseService databaseService,
        })
      >
      buildRepository() async {
        final databaseService = LifeAdminDatabaseService(
          databaseFactory: databaseFactoryFfi,
          databasePathBuilder: () async => databasePath,
        );
        final repository = SqfliteLifeAdminRepository(
          localDataSource: SqfliteLifeAdminLocalDataSource(
            databaseService: databaseService,
          ),
        );
        await repository.initialize();
        return (repository: repository, databaseService: databaseService);
      }

      final firstRepository = await buildRepository();
      expect(
        firstRepository.repository.loadInitialState().reminders,
        isNotEmpty,
      );

      final now = DateTime(2026, 3, 25, 9);
      final document = Document(
        id: 'doc-test-1',
        sourceType: DocumentSourceType.pdf,
        title: '보험 갱신 안내문',
        createdAt: now,
        originalPath: '/mock/test/insurance_renewal.pdf',
        containsSensitive: true,
        pages: const [
          DocumentPage(
            id: 'doc-test-1-page-1',
            pageNumber: 1,
            previewLabel: '갱신 요약',
            helperText: '1페이지',
          ),
        ],
      );
      final reminder = ReminderItem(
        id: 'reminder-test-1',
        documentId: document.id,
        title: '보험 갱신',
        category: ReminderCategory.insurance,
        dueAt: now.add(const Duration(days: 7)),
        amount: 129000,
        currency: 'KRW',
        note: '보장 변경 여부 확인',
        repeatRule: ReminderRepeatRule.yearly,
        status: ReminderStatus.upcoming,
        createdAt: now,
        updatedAt: now,
        sourceSubtitle: '보험 안내문',
        reminderLeadDays: 3,
      );

      final savedState = await firstRepository.repository.upsertReminder(
        firstRepository.repository.loadInitialState(),
        reminder: reminder,
        document: document,
      );

      expect(
        savedState.reminders.any((item) => item.id == reminder.id),
        isTrue,
      );

      await firstRepository.databaseService.close();

      final restartedRepository = await buildRepository();
      expect(
        restartedRepository.repository.loadInitialState().reminders.any(
          (item) => item.id == reminder.id,
        ),
        isTrue,
      );

      await restartedRepository.repository.clearAll();
      await restartedRepository.databaseService.close();

      final clearedRepository = await buildRepository();
      expect(
        clearedRepository.repository.loadInitialState().reminders,
        isEmpty,
      );
      expect(
        clearedRepository.repository.loadInitialState().documents,
        isEmpty,
      );

      await clearedRepository.databaseService.close();
    },
  );
}
