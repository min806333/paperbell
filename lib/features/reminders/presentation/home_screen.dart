import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/localization/app_strings.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/models/app_enums.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/empty_state_card.dart';
import '../../../shared/widgets/inline_info_banner.dart';
import '../../../shared/widgets/list_filter_chips.dart';
import '../../../shared/widgets/reminder_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/summary_stat_card.dart';
import '../application/reminder_store.dart';
import '../domain/reminder_item.dart';

enum HomeFilter { all, today, thisWeek, completed }

enum HomeViewMode { list, calendar }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  HomeFilter _filter = HomeFilter.all;
  HomeViewMode _viewMode = HomeViewMode.list;
  late DateTime _calendarMonth;
  late DateTime _selectedCalendarDate;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final today = _dateOnly(DateTime.now());
    _calendarMonth = DateTime(today.year, today.month);
    _selectedCalendarDate = today;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final data = ref.watch(reminderStoreProvider);
    final locale = Localizations.localeOf(context);
    final strings = AppStrings.forLocale(locale);
    final now = DateTime.now();

    final activeReminders =
        data.reminders
            .where((reminder) => reminder.status != ReminderStatus.archived)
            .toList()
          ..sort((left, right) => left.dueAt.compareTo(right.dueAt));

    final visibleReminders = _applyFilter(activeReminders, now);
    final remindersByDate = _groupRemindersByDate(visibleReminders);
    final monthlyAmountSummary = _summarizeMonthlyAmounts(activeReminders, now);
    final selectedDate = _dateOnly(_selectedCalendarDate);
    final selectedDateIsToday = AppFormatters.isSameDay(selectedDate, now);
    final selectedDateReminders =
        List<ReminderItem>.from(remindersByDate[selectedDate] ?? const <ReminderItem>[])
          ..sort((left, right) => left.dueAt.compareTo(right.dueAt));
    final todayCount = activeReminders
        .where(
          (item) =>
              item.status == ReminderStatus.upcoming &&
              AppFormatters.isSameDay(item.dueAt, now),
        )
        .length;
    final weeklyCount = activeReminders
        .where(
          (item) =>
              item.status == ReminderStatus.upcoming &&
              AppFormatters.isThisWeek(item.dueAt, now),
        )
        .length;
    return SafeArea(
      child: ListView(
        key: const PageStorageKey<String>('home-screen'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          120,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryContainer, AppColors.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.homeHeroTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  strings.homeHeroSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                InlineInfoBanner(message: strings.settingsStorageBanner),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: SummaryStatCard(
                  title: strings.homeTodayStatTitle,
                  value: strings.summaryCountValue(todayCount),
                  subtitle: strings.homeTodayStatSubtitle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: SummaryStatCard(
                  title: strings.homeThisWeekStatTitle,
                  value: strings.summaryCountValue(weeklyCount),
                  subtitle: strings.homeThisWeekStatSubtitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _MonthlyEstimateCard(
            locale: locale,
            strings: strings,
            summary: monthlyAmountSummary,
          ),
          const SizedBox(height: AppSpacing.xl),
          _HomeViewModeToggle(
            selectedValue: _viewMode,
            onSelected: (value) => setState(() => _viewMode = value),
            listLabel: strings.homeListViewLabel,
            calendarLabel: strings.homeCalendarViewLabel,
          ),
          const SizedBox(height: AppSpacing.md),
          ListFilterChips<HomeFilter>(
            options: [
              FilterChipOption(
                value: HomeFilter.all,
                label: strings.filterAllLabel,
              ),
              FilterChipOption(
                value: HomeFilter.today,
                label: strings.filterTodayLabel,
              ),
              FilterChipOption(
                value: HomeFilter.thisWeek,
                label: strings.filterThisWeekLabel,
              ),
              FilterChipOption(
                value: HomeFilter.completed,
                label: strings.filterCompletedLabel,
              ),
            ],
            selectedValue: _filter,
            onSelected: (value) => setState(() => _filter = value),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (_viewMode == HomeViewMode.list) ...[
            SectionHeader(
              title: strings.homeUpcomingSectionTitle,
              subtitle: strings.homeUpcomingSectionSubtitle,
              trailing: _SectionCountPill(
                label: strings.summaryCountValue(visibleReminders.length),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (visibleReminders.isEmpty)
              EmptyStateCard(
                icon: Icons.inbox_outlined,
                title: strings.homeEmptyTitle,
                description: strings.homeEmptyDescription,
              )
            else
              for (final reminder in visibleReminders) ...[
                ReminderCard(
                  reminder: reminder,
                  onComplete: () {
                    _markComplete(reminder);
                  },
                  onSnooze: () {
                    _snooze(reminder);
                  },
                  onView: () => context.push('/reminders/${reminder.id}'),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
          ] else ...[
            SectionHeader(
              title: strings.homeCalendarSectionTitle,
              subtitle: strings.homeCalendarSectionSubtitle,
              trailing: _SectionCountPill(
                label: strings.summaryCountValue(visibleReminders.length),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _ReminderCalendarCard(
              locale: locale,
              month: _calendarMonth,
              selectedDate: selectedDate,
              showGoToTodayAction: !selectedDateIsToday,
              goToTodayLabel: strings.homeGoToTodayAction,
              reminderCounts: {
                for (final entry in remindersByDate.entries) entry.key: entry.value.length,
              },
              previousMonthTooltip: strings.homePreviousMonthAction,
              nextMonthTooltip: strings.homeNextMonthAction,
              onPreviousMonth: () => _changeCalendarMonth(-1, visibleReminders),
              onNextMonth: () => _changeCalendarMonth(1, visibleReminders),
              onGoToToday: _jumpToToday,
              onDateSelected: _selectCalendarDate,
            ),
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(
              title: AppFormatters.calendarDate(selectedDate, locale: locale),
              subtitle: strings.homeCalendarSelectedDateSubtitle(
                selectedDateReminders.length,
              ),
              trailing:
                  selectedDateIsToday
                      ? _ContextTag(
                        label: strings.todayRelativeLabel,
                        foregroundColor: AppColors.primary,
                        backgroundColor: AppColors.primaryContainer,
                      )
                      : null,
            ),
            const SizedBox(height: AppSpacing.md),
            if (selectedDateReminders.isEmpty)
              _CalendarSelectionEmptyState(
                title: strings.homeCalendarEmptyTitle,
                description: strings.homeCalendarEmptyDescription,
              )
            else
              for (final reminder in selectedDateReminders) ...[
                ReminderCard(
                  reminder: reminder,
                  onComplete: () {
                    _markComplete(reminder);
                  },
                  onSnooze: () {
                    _snooze(reminder);
                  },
                  onView: () => context.push('/reminders/${reminder.id}'),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
          ],
        ],
      ),
    );
  }

  Map<DateTime, List<ReminderItem>> _groupRemindersByDate(
    List<ReminderItem> reminders,
  ) {
    final grouped = <DateTime, List<ReminderItem>>{};
    for (final reminder in reminders) {
      final dateKey = _dateOnly(reminder.dueAt);
      grouped.putIfAbsent(dateKey, () => <ReminderItem>[]).add(reminder);
    }
    return grouped;
  }

  List<ReminderItem> _applyFilter(List<ReminderItem> reminders, DateTime now) {
    return reminders.where((reminder) {
      return switch (_filter) {
        HomeFilter.all => reminder.status != ReminderStatus.archived,
        HomeFilter.today =>
          reminder.status == ReminderStatus.upcoming &&
              AppFormatters.isSameDay(reminder.dueAt, now),
        HomeFilter.thisWeek =>
          reminder.status == ReminderStatus.upcoming &&
              AppFormatters.isThisWeek(reminder.dueAt, now),
        HomeFilter.completed => reminder.status == ReminderStatus.completed,
      };
    }).toList();
  }

  _MonthlyAmountSummary _summarizeMonthlyAmounts(
    List<ReminderItem> reminders,
    DateTime now,
  ) {
    final totals = <String?, double>{};
    for (final reminder in reminders) {
      if (reminder.status != ReminderStatus.upcoming ||
          !AppFormatters.isThisMonth(reminder.dueAt, now) ||
          reminder.amountValue == null) {
        continue;
      }

      final currencyCode = _normalizeCurrencyCode(reminder.currencyCode);
      totals[currencyCode] = (totals[currencyCode] ?? 0) + reminder.amountValue!;
    }

    final entries =
        totals.entries
            .map(
              (entry) => _MonthlyAmountEntry(
                currencyCode: entry.key,
                total: entry.value,
              ),
            )
            .toList()
          ..sort(
            (left, right) => _currencySortWeight(left.currencyCode).compareTo(
              _currencySortWeight(right.currencyCode),
            ),
          );

    return _MonthlyAmountSummary(entries: entries);
  }

  void _changeCalendarMonth(int offset, List<ReminderItem> reminders) {
    final nextMonth = DateTime(_calendarMonth.year, _calendarMonth.month + offset);
    final nextSelection = _preferredDateForMonth(nextMonth, reminders);

    setState(() {
      _calendarMonth = nextMonth;
      _selectedCalendarDate = nextSelection;
    });
  }

  void _selectCalendarDate(DateTime value) {
    final normalizedDate = _dateOnly(value);
    setState(() {
      _selectedCalendarDate = normalizedDate;
      _calendarMonth = DateTime(normalizedDate.year, normalizedDate.month);
    });
  }

  DateTime _preferredDateForMonth(DateTime month, List<ReminderItem> reminders) {
    final matchingDates =
        reminders
            .where(
              (reminder) =>
                  reminder.dueAt.year == month.year &&
                  reminder.dueAt.month == month.month,
            )
            .map((reminder) => _dateOnly(reminder.dueAt))
            .toList()
          ..sort((left, right) => left.compareTo(right));

    return matchingDates.isNotEmpty
        ? matchingDates.first
        : DateTime(month.year, month.month, 1);
  }

  void _jumpToToday() {
    final today = _dateOnly(DateTime.now());
    setState(() {
      _selectedCalendarDate = today;
      _calendarMonth = DateTime(today.year, today.month);
    });
  }

  String? _normalizeCurrencyCode(String? currencyCode) {
    final normalized = currencyCode?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  int _currencySortWeight(String? currencyCode) {
    return switch (currencyCode) {
      'KRW' => 0,
      'USD' => 1,
      null => 2,
      _ => 3,
    };
  }

  DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

  Future<void> _markComplete(ReminderItem reminder) async {
    await ref.read(reminderStoreProvider.notifier).completeReminder(reminder.id);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.forLocale(
            Localizations.localeOf(context),
          ).reminderMarkedCompleteMessage,
        ),
      ),
    );
  }

  Future<void> _snooze(ReminderItem reminder) async {
    final notificationNotice = await ref
        .read(reminderStoreProvider.notifier)
        .snoozeReminder(reminder.id);
    if (!mounted) {
      return;
    }
    final strings = AppStrings.forLocale(Localizations.localeOf(context));
    final feedbackMessage =
        notificationNotice == null
            ? strings.reminderSnoozedMessage
            : strings.reminderSnoozedWithNoticeMessage(notificationNotice);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(feedbackMessage)));
  }
}

class _HomeViewModeToggle extends StatelessWidget {
  const _HomeViewModeToggle({
    required this.selectedValue,
    required this.onSelected,
    required this.listLabel,
    required this.calendarLabel,
  });

  final HomeViewMode selectedValue;
  final ValueChanged<HomeViewMode> onSelected;
  final String listLabel;
  final String calendarLabel;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xxs),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: SegmentedButton<HomeViewMode>(
          showSelectedIcon: false,
          style: SegmentedButton.styleFrom(
            visualDensity: VisualDensity.compact,
          ),
          segments: [
            ButtonSegment<HomeViewMode>(
              value: HomeViewMode.list,
              icon: const Icon(Icons.view_list_rounded),
              label: Text(listLabel),
            ),
            ButtonSegment<HomeViewMode>(
              value: HomeViewMode.calendar,
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(calendarLabel),
            ),
          ],
          selected: {selectedValue},
          onSelectionChanged: (selection) {
            if (selection.isEmpty) {
              return;
            }
            onSelected(selection.first);
          },
        ),
      ),
    );
  }
}

class _MonthlyEstimateCard extends StatelessWidget {
  const _MonthlyEstimateCard({
    required this.locale,
    required this.strings,
    required this.summary,
  });

  final Locale locale;
  final AppStrings strings;
  final _MonthlyAmountSummary summary;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary);
    final valueStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
      color: AppColors.success,
      fontWeight: FontWeight.w800,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.homeMonthlyEstimateTitle, style: titleStyle),
            const SizedBox(height: AppSpacing.sm),
            if (summary.isSingleKnownCurrency)
              Text(
                AppFormatters.currency(
                  summary.entries.first.total,
                  currencyCode: summary.entries.first.currencyCode,
                  locale: locale,
                  emptyAmountLabel: strings.noAmountLabel,
                  unknownCurrencyLabel: strings.unknownCurrencyLabel,
                ),
                style: valueStyle,
              )
            else if (summary.entries.isEmpty)
              Text(
                strings.noAmountLabel,
                style: valueStyle?.copyWith(
                  fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                ),
              )
            else
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final entry in summary.entries)
                    _CurrencyTotalChip(
                      label: AppFormatters.currency(
                        entry.total,
                        currencyCode: entry.currencyCode,
                        locale: locale,
                        emptyAmountLabel: strings.noAmountLabel,
                        unknownCurrencyLabel: strings.unknownCurrencyLabel,
                      ),
                    ),
                ],
              ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              summary.shouldShowBreakdown
                  ? strings.homeMonthlyEstimateMixedSubtitle
                  : strings.homeMonthlyEstimateSubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyTotalChip extends StatelessWidget {
  const _CurrencyTotalChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.successContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.success,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MonthlyAmountSummary {
  const _MonthlyAmountSummary({required this.entries});

  final List<_MonthlyAmountEntry> entries;

  bool get isSingleKnownCurrency =>
      entries.length == 1 && entries.first.currencyCode != null;

  bool get shouldShowBreakdown =>
      entries.length > 1 || (entries.length == 1 && entries.first.currencyCode == null);
}

class _MonthlyAmountEntry {
  const _MonthlyAmountEntry({required this.currencyCode, required this.total});

  final String? currencyCode;
  final double total;
}

class _ReminderCalendarCard extends StatelessWidget {
  const _ReminderCalendarCard({
    required this.locale,
    required this.month,
    required this.selectedDate,
    required this.showGoToTodayAction,
    required this.goToTodayLabel,
    required this.reminderCounts,
    required this.previousMonthTooltip,
    required this.nextMonthTooltip,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onGoToToday,
    required this.onDateSelected,
  });

  final Locale locale;
  final DateTime month;
  final DateTime selectedDate;
  final bool showGoToTodayAction;
  final String goToTodayLabel;
  final Map<DateTime, int> reminderCounts;
  final String previousMonthTooltip;
  final String nextMonthTooltip;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onGoToToday;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final firstVisibleDay = _firstVisibleDayOfMonth(month);
    final visibleDays = List.generate(
      42,
      (index) => firstVisibleDay.add(Duration(days: index)),
    );
    final weekdayLabels = _weekdayLabels(locale);
    final today = DateTime.now();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                  tooltip: previousMonthTooltip,
                  onPressed: onPreviousMonth,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Text(
                    _monthLabel(locale, month),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                  tooltip: nextMonthTooltip,
                  onPressed: onNextMonth,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            if (showGoToTodayAction) ...[
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                  ),
                  onPressed: onGoToToday,
                  icon: const Icon(Icons.today_outlined, size: 18),
                  label: Text(goToTodayLabel),
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
            ],
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                for (final label in weekdayLabels)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                const cellSpacing = AppSpacing.xxs;
                final totalSpacing = cellSpacing * 6;
                final cellWidth =
                    (constraints.maxWidth - totalSpacing) / 7;
                final cellHeight = (cellWidth + 3).clamp(42.0, 50.0);

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visibleDays.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: cellSpacing,
                    crossAxisSpacing: cellSpacing,
                    mainAxisExtent: cellHeight,
                  ),
                  itemBuilder: (context, index) {
                    final day = visibleDays[index];
                    final reminderCount =
                        reminderCounts[DateTime(day.year, day.month, day.day)] ??
                        0;

                    return _CalendarDayCell(
                      date: day,
                      displayedMonth: month,
                      isSelected: AppFormatters.isSameDay(day, selectedDate),
                      isToday: AppFormatters.isSameDay(day, today),
                      reminderCount: reminderCount,
                      onTap: () => onDateSelected(day),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static DateTime _firstVisibleDayOfMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysFromSunday = firstDay.weekday % 7;
    return firstDay.subtract(Duration(days: daysFromSunday));
  }

  static String _monthLabel(Locale locale, DateTime month) {
    final localeName = locale.languageCode == 'en' ? 'en_US' : 'ko_KR';
    final pattern = locale.languageCode == 'en' ? 'MMMM y' : 'yyyy년 M월';
    return DateFormat(pattern, localeName).format(month);
  }

  static List<String> _weekdayLabels(Locale locale) {
    final localeName = locale.languageCode == 'en' ? 'en_US' : 'ko_KR';
    final pattern = locale.languageCode == 'en' ? 'EEE' : 'E';
    final sunday = DateTime(2024, 1, 7);
    final formatter = DateFormat(pattern, localeName);

    return List.generate(
      7,
      (index) => formatter.format(sunday.add(Duration(days: index))),
    );
  }
}

class _CalendarSelectionEmptyState extends StatelessWidget {
  const _CalendarSelectionEmptyState({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: const Icon(
                Icons.event_note_outlined,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.date,
    required this.displayedMonth,
    required this.isSelected,
    required this.isToday,
    required this.reminderCount,
    required this.onTap,
  });

  final DateTime date;
  final DateTime displayedMonth;
  final bool isSelected;
  final bool isToday;
  final int reminderCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCurrentMonth =
        date.year == displayedMonth.year && date.month == displayedMonth.month;
    final labelColor =
        isSelected
            ? AppColors.primary
            : isCurrentMonth
            ? AppColors.textPrimary
            : AppColors.textSecondary.withValues(alpha: 0.55);
    final borderColor =
        isSelected
            ? AppColors.primary
            : isToday
            ? AppColors.border
            : Colors.transparent;
    final backgroundColor =
        isSelected ? AppColors.primaryContainer : Colors.transparent;
    final indicatorColor = isSelected ? AppColors.primary : AppColors.success;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: labelColor,
                  fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                height: 14,
                child: Center(
                  child:
                      reminderCount == 0
                          ? const SizedBox.shrink()
                          : reminderCount == 1
                          ? Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: indicatorColor,
                              shape: BoxShape.circle,
                            ),
                          )
                          : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: indicatorColor,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Text(
                              '$reminderCount',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCountPill extends StatelessWidget {
  const _SectionCountPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ContextTag extends StatelessWidget {
  const _ContextTag({
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final String label;
  final Color foregroundColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
