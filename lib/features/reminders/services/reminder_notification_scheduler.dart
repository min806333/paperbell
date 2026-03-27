import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../app/localization/app_strings.dart';
import '../../../core/models/app_enums.dart';
import '../domain/reminder_item.dart';

enum NotificationPermissionStatus { granted, denied, unknown, notSupported }

class NotificationSyncFeedback {
  const NotificationSyncFeedback({this.notice});

  final String? notice;
}

abstract class ReminderNotificationScheduler {
  Future<void> initialize();
  Future<void> syncAll(Iterable<ReminderItem> reminders);
  Future<NotificationSyncFeedback> syncReminder(
    ReminderItem reminder, {
    bool promptForPermissions = true,
  });
  Future<void> cancelReminder(String reminderId);
  Future<void> cancelAll();
}

final reminderNotificationSchedulerProvider =
    Provider<ReminderNotificationScheduler>(
      (ref) => const NoopReminderNotificationScheduler(),
    );

class NoopReminderNotificationScheduler
    implements ReminderNotificationScheduler {
  const NoopReminderNotificationScheduler();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> syncAll(Iterable<ReminderItem> reminders) async {}

  @override
  Future<NotificationSyncFeedback> syncReminder(
    ReminderItem reminder, {
    bool promptForPermissions = true,
  }) async {
    return const NotificationSyncFeedback();
  }

  @override
  Future<void> cancelReminder(String reminderId) async {}

  @override
  Future<void> cancelAll() async {}
}

class FlutterLocalReminderNotificationScheduler
    implements ReminderNotificationScheduler {
  FlutterLocalReminderNotificationScheduler({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _channelId = 'life_admin_reminders';

  final FlutterLocalNotificationsPlugin _plugin;

  bool _initialized = false;

  String get _channelName => AppStrings.current.notificationChannelName;
  String get _channelDescription =>
      AppStrings.current.notificationChannelDescription;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tz_data.initializeTimeZones();
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(initializationSettings);

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.defaultImportance,
      ),
    );

    _initialized = true;
  }

  @override
  Future<void> syncAll(Iterable<ReminderItem> reminders) async {
    await initialize();
    await _plugin.cancelAll();

    for (final reminder in reminders) {
      if (reminder.status == ReminderStatus.upcoming) {
        await syncReminder(reminder, promptForPermissions: false);
      }
    }
  }

  @override
  Future<NotificationSyncFeedback> syncReminder(
    ReminderItem reminder, {
    bool promptForPermissions = true,
  }) async {
    await initialize();

    final scheduledAt = _buildScheduledAt(reminder);
    if (scheduledAt == null) {
      await cancelReminder(reminder.id);
      return const NotificationSyncFeedback();
    }

    final permissionStatus = await _ensurePermissionStatus(
      promptForPermissions: promptForPermissions,
    );

    if (permissionStatus == NotificationPermissionStatus.denied) {
      await cancelReminder(reminder.id);
      return NotificationSyncFeedback(
        notice: AppStrings.current.notificationPermissionDeniedNotice,
      );
    }

    if (permissionStatus == NotificationPermissionStatus.notSupported) {
      return const NotificationSyncFeedback();
    }

    await cancelReminder(reminder.id);

    await _plugin.zonedSchedule(
      _notificationId(reminder.id),
      reminder.title,
      AppStrings.current.notificationBody(reminder.sourceSubtitle),
      tz.TZDateTime.from(scheduledAt, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: const DarwinNotificationDetails(),
        macOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: reminder.id,
    );

    return const NotificationSyncFeedback();
  }

  @override
  Future<void> cancelReminder(String reminderId) async {
    await initialize();
    await _plugin.cancel(_notificationId(reminderId));
  }

  @override
  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }

  DateTime? _buildScheduledAt(ReminderItem reminder) {
    if (reminder.status != ReminderStatus.upcoming) {
      return null;
    }

    final now = DateTime.now();
    final minimumFuture = now.add(const Duration(minutes: 1));
    final reminderBase = DateTime(
      reminder.dueAt.year,
      reminder.dueAt.month,
      reminder.dueAt.day,
      9,
    );
    final dueDayCutoff = DateTime(
      reminder.dueAt.year,
      reminder.dueAt.month,
      reminder.dueAt.day,
      18,
    );

    if (!dueDayCutoff.isAfter(minimumFuture)) {
      return null;
    }

    var scheduledAt = reminderBase.subtract(
      Duration(days: reminder.reminderLeadDays),
    );

    if (scheduledAt.isBefore(minimumFuture)) {
      scheduledAt = minimumFuture;
    }

    return scheduledAt;
  }

  Future<NotificationPermissionStatus> _ensurePermissionStatus({
    required bool promptForPermissions,
  }) async {
    if (kIsWeb) {
      return NotificationPermissionStatus.notSupported;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final enabled = await androidPlugin?.areNotificationsEnabled() ?? true;
      if (enabled) {
        return NotificationPermissionStatus.granted;
      }
      if (!promptForPermissions) {
        return NotificationPermissionStatus.denied;
      }
      final granted = await androidPlugin?.requestNotificationsPermission();
      return granted == true
          ? NotificationPermissionStatus.granted
          : NotificationPermissionStatus.denied;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      if (!promptForPermissions) {
        return NotificationPermissionStatus.unknown;
      }

      final iosPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final macosPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();

      final granted =
          await iosPlugin?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          await macosPlugin?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          true;

      return granted
          ? NotificationPermissionStatus.granted
          : NotificationPermissionStatus.denied;
    }

    return NotificationPermissionStatus.notSupported;
  }

  int _notificationId(String reminderId) {
    var hash = 0x811C9DC5;
    for (final codeUnit in reminderId.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }
}
