import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_strings.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/models/app_enums.dart';
import '../../../shared/widgets/empty_state_card.dart';
import '../../../shared/widgets/list_filter_chips.dart';
import '../../../shared/widgets/reminder_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../application/reminder_store.dart';

enum ArchiveFilter {
  all,
  utilities,
  subscription,
  insurance,
  completed,
  archived,
}

class ArchiveScreen extends ConsumerStatefulWidget {
  const ArchiveScreen({super.key});

  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen> {
  ArchiveFilter _filter = ArchiveFilter.all;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final reminders = ref.watch(reminderStoreProvider).reminders;
    final strings = AppStrings.forLocale(Localizations.localeOf(context));

    final filtered =
        reminders.where((reminder) {
            final matchesQuery =
                _query.isEmpty ||
                reminder.title.contains(_query) ||
                reminder.sourceSubtitle.contains(_query);
            final matchesFilter = switch (_filter) {
              ArchiveFilter.all => true,
              ArchiveFilter.utilities =>
                reminder.category == ReminderCategory.utilities,
              ArchiveFilter.subscription =>
                reminder.category == ReminderCategory.subscription,
              ArchiveFilter.insurance =>
                reminder.category == ReminderCategory.insurance,
              ArchiveFilter.completed =>
                reminder.status == ReminderStatus.completed,
              ArchiveFilter.archived =>
                reminder.status == ReminderStatus.archived,
            };

            return matchesQuery && matchesFilter;
          }).toList()
          ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          120,
        ),
        children: [
          SectionHeader(
            title: strings.archiveTitle,
            subtitle: strings.archiveSubtitle,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            onChanged: (value) => setState(() => _query = value.trim()),
            decoration: InputDecoration(
              hintText: strings.archiveSearchHint,
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ListFilterChips<ArchiveFilter>(
            options: [
              FilterChipOption(
                value: ArchiveFilter.all,
                label: strings.filterAllLabel,
              ),
              FilterChipOption(
                value: ArchiveFilter.utilities,
                label: strings.filterUtilitiesLabel,
              ),
              FilterChipOption(
                value: ArchiveFilter.subscription,
                label: strings.filterSubscriptionLabel,
              ),
              FilterChipOption(
                value: ArchiveFilter.insurance,
                label: strings.filterInsuranceLabel,
              ),
              FilterChipOption(
                value: ArchiveFilter.completed,
                label: strings.filterCompletedLabel,
              ),
              FilterChipOption(
                value: ArchiveFilter.archived,
                label: strings.filterArchivedLabel,
              ),
            ],
            selectedValue: _filter,
            onSelected: (value) => setState(() => _filter = value),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (filtered.isEmpty)
            EmptyStateCard(
              icon: Icons.archive_outlined,
              title: strings.archiveEmptyTitle,
              description: strings.archiveEmptyDescription,
            )
          else
            for (final reminder in filtered) ...[
              ReminderCard(
                reminder: reminder,
                onComplete: () {
                  _completeReminder(reminder.id);
                },
                onSnooze: () {
                  _snoozeReminder(reminder.id);
                },
                onView: () => context.push('/reminders/${reminder.id}'),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
        ],
      ),
    );
  }

  Future<void> _completeReminder(String reminderId) async {
    await ref.read(reminderStoreProvider.notifier).completeReminder(reminderId);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(content: Text(AppStrings.forLocale(Localizations.localeOf(context)).reminderMarkedCompleteMessage)),
    );
  }

  Future<void> _snoozeReminder(String reminderId) async {
    final notificationNotice = await ref
        .read(reminderStoreProvider.notifier)
        .snoozeReminder(reminderId);
    if (!mounted) {
      return;
    }
    final strings = AppStrings.forLocale(Localizations.localeOf(context));
    final feedbackMessage = notificationNotice == null
        ? strings.reminderSnoozedMessage
        : strings.reminderSnoozedWithNoticeMessage(notificationNotice);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(feedbackMessage)));
  }
}
