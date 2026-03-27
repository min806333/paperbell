import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_strings.dart';
import '../../../app/localization/locale_controller.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/models/app_enums.dart';
import '../../../core/utils/formatters.dart';
import '../../../features/settings/application/settings_controller.dart';
import '../../../shared/widgets/app_page_scaffold.dart';
import '../../../shared/widgets/document_preview_card.dart';
import '../../../shared/widgets/inline_info_banner.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../reminders/application/reminder_store.dart';
import '../../reminders/domain/reminder_item.dart';
import '../data/document_service_providers.dart';
import '../domain/extracted_field.dart';
import '../domain/import_session.dart';

class ExtractionConfirmScreen extends ConsumerStatefulWidget {
  const ExtractionConfirmScreen({super.key, required this.session});

  final ImportSession session;

  @override
  ConsumerState<ExtractionConfirmScreen> createState() =>
      _ExtractionConfirmScreenState();
}

class _ExtractionConfirmScreenState
    extends ConsumerState<ExtractionConfirmScreen> {
  late ImportSession _session;
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _memoController;

  DateTime? _selectedDate;
  String? _selectedCurrencyCode;
  late ReminderCategory _selectedCategory;
  late ReminderRepeatRule _repeatRule;
  late ReminderLeadTime _leadTime;
  bool _isRepeating = false;
  bool _isSaving = false;
  bool _isReparsing = false;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    _titleController = TextEditingController();
    _amountController = TextEditingController();
    _memoController = TextEditingController();
    _applySession(_session, useSettingsFallback: true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final extraction = _session.extraction;
    final locale = Localizations.localeOf(context);
    final strings = AppStrings.forLocale(locale);

    return AppPageScaffold(
      title: strings.extractionConfirmTitle,
      child: ListView(
        children: [
          Card(
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              title: Text(
                strings.sourcePreviewTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                strings.sourcePreviewSubtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.45,
                ),
              ),
              children: [
                DocumentPreviewCard(
                  document: _session.document,
                  expanded: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final hint in extraction.hints) ...[
            InlineInfoBanner(message: hint),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (extraction.dueAt.value == null) ...[
            InlineInfoBanner(
              message: strings.missingDateNotice,
              tone: InlineInfoBannerTone.warning,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (extraction.amount.value == null) ...[
            InlineInfoBanner(
              message: strings.missingAmountNotice,
              tone: InlineInfoBannerTone.warning,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          _FieldCard<String>(
            label: strings.titleFieldLabel,
            field: extraction.title,
            child: TextField(
              controller: _titleController,
              decoration: InputDecoration(hintText: strings.titleFieldHint),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _FieldCard<DateTime>(
            label: strings.dateFieldLabel,
            field: extraction.dueAt,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              onTap: _pickDate,
              child: Ink(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: _selectedDate == null
                        ? AppColors.warning
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? strings.dateFieldPlaceholder
                            : AppFormatters.calendarDate(
                                _selectedDate!,
                                locale: locale,
                              ),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: _selectedDate == null
                              ? AppColors.warning
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(Icons.calendar_month_outlined),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _FieldCard<double>(
            label: strings.amountFieldLabel,
            field: extraction.amountValue,
            child: TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(hintText: strings.amountFieldHint),
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (_amountController.text.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.currencySelectorTitle,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (_selectedCurrencyCode == null &&
                        extraction.amountValue.value != null &&
                        extraction.currencyCode.value == null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        strings.uncertainCurrencyHelper,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        ChoiceChip(
                          label: Text(strings.currencyKrwLabel),
                          selected: _selectedCurrencyCode == 'KRW',
                          onSelected: (selected) {
                            setState(() {
                              _selectedCurrencyCode = selected ? 'KRW' : null;
                            });
                          },
                        ),
                        ChoiceChip(
                          label: Text(strings.currencyUsdLabel),
                          selected: _selectedCurrencyCode == 'USD',
                          onSelected: (selected) {
                            setState(() {
                              _selectedCurrencyCode = selected ? 'USD' : null;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          _FieldCard<ReminderCategory>(
            label: strings.categoryFieldLabel,
            field: extraction.category,
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final category in ReminderCategory.values)
                  ChoiceChip(
                    label: Text(strings.reminderCategoryLabel(category)),
                    selected: _selectedCategory == category,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = category),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _FieldCard<String>(
            label: strings.memoFieldLabel,
            field: extraction.note,
            child: TextField(
              controller: _memoController,
              maxLines: 3,
              decoration: InputDecoration(hintText: strings.memoFieldHint),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.repeatSectionTitle,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SwitchListTile.adaptive(
                    value: _isRepeating,
                    contentPadding: EdgeInsets.zero,
                    title: Text(strings.repeatToggleTitle),
                    subtitle: Text(strings.repeatToggleSubtitle),
                    onChanged: (value) => setState(() => _isRepeating = value),
                  ),
                  if (_isRepeating) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final rule in [
                          ReminderRepeatRule.monthly,
                          ReminderRepeatRule.yearly,
                          ReminderRepeatRule.custom,
                        ])
                          ChoiceChip(
                            label: Text(strings.reminderRepeatRuleLabel(rule)),
                            selected: _repeatRule == rule,
                            onSelected: (_) => setState(() => _repeatRule = rule),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.reminderTimingSectionTitle,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<ReminderLeadTime>(
                    initialValue: _leadTime,
                    items: [
                      for (final leadTime in ReminderLeadTime.values)
                        DropdownMenuItem(
                          value: leadTime,
                          child: Text(strings.reminderLeadTimeLabel(leadTime)),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _leadTime = value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: strings.saveAction,
            isLoading: _isSaving,
            onPressed: _selectedDate == null ? null : _saveReminder,
          ),
          const SizedBox(height: AppSpacing.sm),
          SecondaryButton(
            label: _isReparsing ? strings.reparsingAction : strings.reparseAction,
            onPressed: _isReparsing ? null : _reparse,
          ),
        ],
      ),
    );
  }

  void _applySession(
    ImportSession session, {
    bool useSettingsFallback = false,
  }) {
    final extraction = session.extraction;
    final settings = ref.read(settingsControllerProvider);
    final strings = AppStrings.forLocale(
      ref.read(appLocaleControllerProvider).locale,
    );

    _titleController.text = extraction.title.value ?? strings.defaultReminderTitle;
    _amountController.text = extraction.amountValue.value == null
        ? ''
        : extraction.amountValue.value!.toStringAsFixed(
            extraction.amountValue.value! % 1 == 0 ? 0 : 2,
          );
    _selectedCurrencyCode =
        extraction.currencyCode.value ?? session.existingReminder?.currencyCode;
    _memoController.text = extraction.note.value ?? '';
    _selectedDate = extraction.dueAt.value;
    _selectedCategory = extraction.category.value ?? ReminderCategory.other;
    _repeatRule = extraction.repeatRule;
    _isRepeating = extraction.repeatRule != ReminderRepeatRule.none;
    _leadTime =
        useSettingsFallback &&
            extraction.reminderLeadTime == ReminderLeadTime.sameDay
        ? settings.defaultLeadTime
        : extraction.reminderLeadTime;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      locale: Localizations.localeOf(context),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveReminder() async {
    if (_selectedDate == null) {
      return;
    }

    setState(() => _isSaving = true);

    final strings = AppStrings.forLocale(Localizations.localeOf(context));
    final now = DateTime.now();
    final existing = _session.existingReminder;
    final normalizedAmount = _amountController.text.trim().replaceAll(',', '');
    final amount = normalizedAmount.isEmpty
        ? null
        : double.tryParse(normalizedAmount);

    final reminder = ReminderItem(
      id:
          _session.existingReminderId ??
          'reminder-${now.microsecondsSinceEpoch}',
      documentId: _session.document.id,
      title: _titleController.text.trim().isEmpty
          ? strings.untitledReminderFallback
          : _titleController.text.trim(),
      category: _selectedCategory,
      dueAt: _selectedDate!,
      amount: amount,
      currency: amount == null ? null : _selectedCurrencyCode,
      note: _memoController.text.trim().isEmpty
          ? null
          : _memoController.text.trim(),
      repeatRule: _isRepeating ? _repeatRule : ReminderRepeatRule.none,
      status: existing?.status ?? ReminderStatus.upcoming,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      sourceSubtitle: _session.extraction.sourceSubtitle,
      reminderLeadDays: _leadTime.daysBefore,
    );

    final notificationNotice = await ref
        .read(reminderStoreProvider.notifier)
        .saveReminder(reminder: reminder, document: _session.document);

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);

    final feedbackMessage = notificationNotice == null
        ? strings.reminderSavedMessage
        : strings.reminderSavedWithNoticeMessage(notificationNotice);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(feedbackMessage)));
    context.go('/');
  }

  Future<void> _reparse() async {
    setState(() => _isReparsing = true);

    final extraction = await ref
        .read(documentParserServiceProvider)
        .parseDocument(_session.document);

    if (!mounted) {
      return;
    }

    final updatedSession = ImportSession(
      document: _session.document,
      extraction: extraction,
      existingReminderId: _session.existingReminderId,
      existingReminder: _session.existingReminder,
    );

    setState(() {
      _session = updatedSession;
      _applySession(updatedSession);
      _isReparsing = false;
    });
  }
}

class _FieldCard<T> extends StatelessWidget {
  const _FieldCard({
    required this.label,
    required this.field,
    required this.child,
  });

  final String label;
  final ExtractedField<T> field;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.forLocale(Localizations.localeOf(context));
    final badgeLabel = strings.extractedFieldStateLabel(field.state);
    final tone = switch (field.state) {
      ExtractedFieldState.suggested => StatusBadgeTone.primary,
      ExtractedFieldState.needsConfirmation => StatusBadgeTone.warning,
      ExtractedFieldState.confirmed => StatusBadgeTone.success,
      ExtractedFieldState.missing => StatusBadgeTone.neutral,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: AppSpacing.xs),
                if (badgeLabel != null)
                  StatusBadge(label: badgeLabel, tone: tone),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}
