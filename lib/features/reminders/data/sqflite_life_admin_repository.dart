import '../../../core/data/mock_sample_data.dart';
import '../../import_flow/domain/document.dart';
import '../domain/reminder_item.dart';
import 'life_admin_repository.dart';
import 'local/life_admin_local_data_source.dart';

class SqfliteLifeAdminRepository implements LifeAdminRepository {
  SqfliteLifeAdminRepository({
    required LifeAdminLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final LifeAdminLocalDataSource _localDataSource;

  AppDataState _currentState = const AppDataState(reminders: [], documents: {});

  Future<void> initialize() async {
    await _localDataSource.initialize();

    final isEmpty = await _localDataSource.isEmpty();
    final hasSeededDemoData = await _localDataSource.hasSeededDemoData();

    if (isEmpty && !hasSeededDemoData) {
      await _localDataSource.seedDemoData(
        reminders: MockSampleData.seededReminders(),
        documents: MockSampleData.seededDocuments(),
      );
      await _localDataSource.markDemoDataSeeded();
    } else if (!hasSeededDemoData) {
      await _localDataSource.markDemoDataSeeded();
    }

    _currentState = await _localDataSource.loadState();
  }

  @override
  AppDataState loadInitialState() => _currentState;

  @override
  Future<AppDataState> upsertReminder(
    AppDataState current, {
    required ReminderItem reminder,
    required Document document,
  }) async {
    await _localDataSource.upsertDocument(document);
    await _localDataSource.upsertReminder(reminder);
    _currentState = await _localDataSource.loadState();
    return _currentState;
  }

  @override
  Future<AppDataState> updateReminder(
    AppDataState current,
    ReminderItem reminder,
  ) async {
    await _localDataSource.upsertReminder(reminder);
    _currentState = await _localDataSource.loadState();
    return _currentState;
  }

  @override
  Future<AppDataState> deleteReminder(
    AppDataState current,
    String reminderId,
  ) async {
    await _localDataSource.deleteReminder(reminderId);
    _currentState = await _localDataSource.loadState();
    return _currentState;
  }

  @override
  Future<AppDataState> clearAll() async {
    await _localDataSource.clearAll();
    _currentState = await _localDataSource.loadState();
    return _currentState;
  }
}
