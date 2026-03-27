import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_strings.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/data/mock_sample_data.dart';
import '../../../core/models/app_enums.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_page_scaffold.dart';
import '../../../shared/widgets/category_chip.dart';
import '../../../shared/widgets/document_preview_card.dart';
import '../../../shared/widgets/empty_state_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/status_badge.dart';
import '../application/reminder_store.dart';

class ReminderDetailScreen extends ConsumerWidget {
  const ReminderDetailScreen({super.key, required this.reminderId});

  final String reminderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.forLocale(Localizations.localeOf(context));
    final locale = Localizations.localeOf(context);
    final store = ref.watch(reminderStoreProvider.notifier);
    final reminder = store.reminderById(reminderId);

    if (reminder == null) {
      return AppPageScaffold(
        title: strings.reminderDetailTitle,
        child: EmptyStateCard(
          icon: Icons.search_off_outlined,
          title: strings.reminderDetailMissingTitle,
          description: strings.reminderDetailMissingDescription,
        ),
      );
    }

    final document = store.documentById(reminder.documentId);
    final statusTone = switch (reminder.status) {
      ReminderStatus.completed => StatusBadgeTone.success,
      ReminderStatus.archived => StatusBadgeTone.neutral,
      ReminderStatus.upcoming => StatusBadgeTone.primary,
    };
    final leadTime = ReminderLeadTime.values.firstWhere(
      (value) => value.daysBefore == reminder.reminderLeadDays,
      orElse: () => ReminderLeadTime.oneDayBefore,
    );

    return AppPageScaffold(
      title: strings.reminderDetailTitle,
      child: ListView(
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
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CategoryChip(category: reminder.category),
                    const SizedBox(width: AppSpacing.xs),
                    StatusBadge(
                      label: strings.reminderStatusLabel(reminder.status),
                      tone: statusTone,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  reminder.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  reminder.sourceSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  strings.dueDateSummary(
                    AppFormatters.dueDate(reminder.dueAt, locale: locale),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  AppFormatters.currency(
                    reminder.amount,
                    currencyCode: reminder.currencyCode,
                    locale: locale,
                    emptyAmountLabel: strings.noAmountLabel,
                    unknownCurrencyLabel: strings.unknownCurrencyLabel,
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (document != null) ...[
            SectionHeader(
              title: strings.sourceDocumentSectionTitle,
              subtitle: strings.sourceDocumentSectionSubtitle,
            ),
            const SizedBox(height: AppSpacing.md),
            DocumentPreviewCard(document: document),
            const SizedBox(height: AppSpacing.xl),
          ],
          SectionHeader(
            title: strings.savedInfoSectionTitle,
            subtitle: strings.savedInfoSectionSubtitle,
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _DetailRow(label: strings.titleFieldLabel, value: reminder.title),
                  const Divider(height: 24),
                  _DetailRow(
                    label: strings.dateFieldLabel,
                    value: AppFormatters.calendarDate(
                      reminder.dueAt,
                      locale: locale,
                    ),
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    label: strings.amountFieldLabel,
                    value: AppFormatters.currency(
                      reminder.amount,
                      currencyCode: reminder.currencyCode,
                      locale: locale,
                      emptyAmountLabel: strings.noAmountLabel,
                      unknownCurrencyLabel: strings.unknownCurrencyLabel,
                    ),
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    label: strings.categoryFieldLabel,
                    value: strings.reminderCategoryLabel(reminder.category),
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    label: strings.reminderTimingSectionTitle,
                    value: strings.reminderLeadTimeLabel(leadTime),
                  ),
                ],
              ),
            ),
          ),
          if (reminder.note != null && reminder.note!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.memoSectionTitle,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      reminder.note!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: strings.completeAction,
            onPressed: () async {
              await ref
                  .read(reminderStoreProvider.notifier)
                  .completeReminder(reminder.id);
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(strings.reminderMarkedCompleteMessage)),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: strings.snoozeAction,
                  onPressed: () async {
                    final notificationNotice = await ref
                        .read(reminderStoreProvider.notifier)
                        .snoozeReminder(reminder.id);
                    if (!context.mounted) {
                      return;
                    }
                    final feedbackMessage = notificationNotice == null
                        ? strings.reminderSnoozedMessage
                        : strings.reminderSnoozedWithNoticeMessage(
                            notificationNotice,
                          );
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(feedbackMessage)));
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: SecondaryButton(
                  label: strings.editAction,
                  onPressed: document == null
                      ? null
                      : () {
                          context.push(
                            '/import/confirm',
                            extra: MockSampleData.sessionFromReminder(
                              reminder: reminder,
                              document: document,
                            ),
                          );
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: Text(strings.deleteReminderDialogTitle),
                    content: Text(strings.deleteReminderDialogContent),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: Text(strings.cancelAction),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: Text(strings.deleteAction),
                      ),
                    ],
                  );
                },
              );

              if (!(confirmed ?? false) || !context.mounted) {
                return;
              }

              await ref
                  .read(reminderStoreProvider.notifier)
                  .deleteReminder(reminder.id);
              if (!context.mounted) {
                return;
              }
              context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(strings.deleteAction),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
