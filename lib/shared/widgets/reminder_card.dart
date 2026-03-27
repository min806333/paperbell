import 'package:flutter/material.dart';

import '../../app/localization/app_strings.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/models/app_enums.dart';
import '../../core/utils/formatters.dart';
import '../../features/reminders/domain/reminder_item.dart';
import 'category_chip.dart';
import 'status_badge.dart';

class ReminderCard extends StatelessWidget {
  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onComplete,
    required this.onSnooze,
    required this.onView,
  });

  final ReminderItem reminder;
  final VoidCallback onComplete;
  final VoidCallback onSnooze;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final strings = AppStrings.forLocale(locale);
    final statusTone = switch (reminder.status) {
      ReminderStatus.upcoming => StatusBadgeTone.primary,
      ReminderStatus.completed => StatusBadgeTone.success,
      ReminderStatus.archived => StatusBadgeTone.neutral,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        reminder.sourceSubtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                StatusBadge(
                  label: strings.reminderStatusLabel(reminder.status),
                  tone: statusTone,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                CategoryChip(category: reminder.category),
                StatusBadge(
                  label: AppFormatters.relativeLabel(
                    reminder.dueAt,
                    DateTime.now(),
                    locale: locale,
                    todayLabel: strings.todayRelativeLabel,
                    tomorrowLabel: strings.tomorrowRelativeLabel,
                  ),
                  tone: StatusBadgeTone.neutral,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(AppFormatters.dueDate(reminder.dueAt, locale: locale)),
                const SizedBox(width: AppSpacing.md),
                const Icon(
                  Icons.payments_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    AppFormatters.currency(
                      reminder.amount,
                      currencyCode: reminder.currencyCode,
                      locale: locale,
                      emptyAmountLabel: strings.noAmountLabel,
                      unknownCurrencyLabel: strings.unknownCurrencyLabel,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                TextButton(
                  onPressed: onComplete,
                  child: Text(strings.completeAction),
                ),
                TextButton(
                  onPressed: onSnooze,
                  child: Text(strings.snoozeAction),
                ),
                TextButton(
                  onPressed: onView,
                  child: Text(strings.viewDetailAction),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
