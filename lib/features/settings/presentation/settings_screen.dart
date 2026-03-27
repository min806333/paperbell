import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/config/app_branding.dart';
import '../../../app/localization/app_strings.dart';
import '../../../app/localization/locale_controller.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/models/app_enums.dart';
import '../../../shared/widgets/inline_info_banner.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/setting_row.dart';
import '../../reminders/application/reminder_store.dart';
import '../application/donation_purchase_controller.dart';
import '../application/settings_controller.dart';
import '../domain/donation_product.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> _openContactEmail(BuildContext context, AppStrings strings) async {
    final mailUri = Uri(
      scheme: 'mailto',
      path: AppBranding.contactEmail,
      queryParameters: {
        'subject': strings.contactEmailSubject,
        'body': strings.contactEmailBodyTemplate,
      },
    );

    try {
      final launched = await launchUrl(
        mailUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.contactLaunchError)),
        );
      }
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.contactLaunchError)));
    }
  }

  Future<void> _openPrivacyPolicyUrl(
    BuildContext context,
    AppStrings strings,
    Uri policyUri,
  ) async {
    try {
      final launched = await launchUrl(
        policyUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.privacyPolicyLaunchError)),
        );
      }
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.privacyPolicyLaunchError)),
      );
    }
  }

  Future<void> _showPrivacyNoticeDialog(
    BuildContext context,
    AppStrings strings,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(strings.privacyTitle),
          content: SingleChildScrollView(
            child: Text('${strings.privacyBody}\n\n${strings.privacyCaution}'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(strings.confirmAction),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    AppLanguage currentLanguage,
  ) async {
    final selectedLanguage = await showDialog<AppLanguage>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(strings.languageDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(strings.languageOptionKorean),
                trailing: currentLanguage == AppLanguage.korean
                    ? const Icon(Icons.check_circle_rounded)
                    : null,
                onTap: () =>
                    Navigator.of(dialogContext).pop(AppLanguage.korean),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(strings.languageOptionEnglish),
                trailing: currentLanguage == AppLanguage.english
                    ? const Icon(Icons.check_circle_rounded)
                    : null,
                onTap: () =>
                    Navigator.of(dialogContext).pop(AppLanguage.english),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(strings.cancelAction),
            ),
          ],
        );
      },
    );

    if (selectedLanguage == null) {
      return;
    }

    await ref
        .read(appLocaleControllerProvider.notifier)
        .selectLanguage(selectedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<DonationPurchaseState>(
      donationPurchaseControllerProvider,
      (previous, next) {
        final previousId = previous?.feedback?.id;
        final nextFeedback = next.feedback;
        if (nextFeedback == null || nextFeedback.id == previousId || !mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(nextFeedback.message)),
        );
      },
    );

    final settings = ref.watch(settingsControllerProvider);
    final reminderCount = ref.watch(reminderStoreProvider).reminders.length;
    final localeState = ref.watch(appLocaleControllerProvider);
    final donationState = ref.watch(donationPurchaseControllerProvider);
    final strings = AppStrings.forLocale(localeState.locale);
    final privacyPolicyUrl = AppBranding.privacyPolicyUrlForLocale(
      localeState.locale,
    );

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
            title: strings.settingsTitle,
            subtitle: strings.settingsSubtitle,
          ),
          const SizedBox(height: AppSpacing.md),
          InlineInfoBanner(message: strings.settingsStorageBanner),
          const SizedBox(height: AppSpacing.xl),
          Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.settingsDefaultReminderTiming,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DropdownButtonFormField<ReminderLeadTime>(
                        initialValue: settings.defaultLeadTime,
                        items: [
                          for (final leadTime in ReminderLeadTime.values)
                            DropdownMenuItem(
                              value: leadTime,
                              child: Text(
                                strings.reminderLeadTimeLabel(leadTime),
                              ),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(settingsControllerProvider.notifier)
                                .updateLeadTime(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                SettingRow(
                  title: strings.settingsLanguageTitle,
                  subtitle: strings.settingsLanguageSubtitle(
                    strings.languageName(localeState.language),
                  ),
                  trailing: const Icon(Icons.translate_outlined),
                  onTap: () => _showLanguageDialog(
                    context,
                    ref,
                    strings,
                    localeState.language,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _AppInfoSection(
            strings: strings,
            privacyPolicyUrl: privacyPolicyUrl,
            onOpenPrivacyNotice: () => _showPrivacyNoticeDialog(context, strings),
            onOpenPrivacyPolicy: privacyPolicyUrl == null
                ? null
                : () => _openPrivacyPolicyUrl(
                    context,
                    strings,
                    Uri.parse(privacyPolicyUrl),
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          _DonationSection(
            strings: strings,
            state: donationState,
            onSelectDonation: (product) {
              ref
                  .read(donationPurchaseControllerProvider.notifier)
                  .startPurchase(product);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _PrivacyNoticeSection(
            strings: strings,
            onOpenPrivacyPolicy: privacyPolicyUrl == null
                ? null
                : () => _openPrivacyPolicyUrl(
                    context,
                    strings,
                    Uri.parse(privacyPolicyUrl),
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          _ContactSection(
            strings: strings,
            onSendInquiry: () => _openContactEmail(context, strings),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Column(
              children: [
                SettingRow(
                  title: strings.settingsAppLockTitle,
                  subtitle: strings.settingsAppLockSubtitle,
                  trailing: Switch.adaptive(
                    value: settings.appLockEnabled,
                    onChanged: (value) {
                      ref
                          .read(settingsControllerProvider.notifier)
                          .toggleAppLock(value);
                    },
                  ),
                ),
                const Divider(height: 1),
                SettingRow(
                  title: strings.settingsLocalStorageTitle,
                  subtitle: strings.settingsLocalStorageSubtitle(reminderCount),
                  trailing: const Icon(Icons.devices_outlined),
                ),
                const Divider(height: 1),
                SettingRow(
                  title: strings.settingsDataExportTitle,
                  subtitle: strings.settingsDataExportSubtitle,
                  trailing: StatusPlaceholder(label: strings.preparingLabel),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(strings.settingsDataExportPreparingMessage),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Column(
              children: [
                SettingRow(
                  title: strings.cloudOptionTitle,
                  subtitle: strings.cloudOptionSubtitle,
                  trailing: StatusPlaceholder(label: strings.mvpExcludedLabel),
                ),
                const Divider(height: 1),
                SettingRow(
                  title: strings.clearLocalDataTitle,
                  subtitle: strings.clearLocalDataSubtitle,
                  destructive: true,
                  trailing: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: Text(strings.clearLocalDataDialogTitle),
                          content: Text(strings.clearLocalDataDialogContent),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              child: Text(strings.cancelAction),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                              child: Text(strings.deleteAction),
                            ),
                          ],
                        );
                      },
                    );

                    if (!(confirmed ?? false) || !context.mounted) {
                      return;
                    }

                    await ref.read(reminderStoreProvider.notifier).clearAll();
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(strings.clearedLocalDataMessage)),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonationSection extends StatelessWidget {
  const _DonationSection({
    required this.strings,
    required this.state,
    required this.onSelectDonation,
  });

  final AppStrings strings;
  final DonationPurchaseState state;
  final ValueChanged<DonationProduct> onSelectDonation;

  @override
  Widget build(BuildContext context) {
    final isBusy = state.purchasingProduct != null;
    final statusMessage = state.isLoading
        ? strings.donationStoreLoadingMessage
        : (!state.isStoreAvailable ? strings.donationStoreUnavailableMessage : null);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.donationTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              strings.donationDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                FilledButton.tonal(
                  onPressed: isBusy
                      ? null
                      : () => onSelectDonation(DonationProduct.small),
                  child: Text(strings.donationOptionOne),
                ),
                FilledButton.tonal(
                  onPressed: isBusy
                      ? null
                      : () => onSelectDonation(DonationProduct.medium),
                  child: Text(strings.donationOptionTwo),
                ),
                FilledButton.tonal(
                  onPressed: isBusy
                      ? null
                      : () => onSelectDonation(DonationProduct.large),
                  child: Text(strings.donationOptionSupport),
                ),
              ],
            ),
            if (statusMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                statusMessage,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AppInfoSection extends StatelessWidget {
  const _AppInfoSection({
    required this.strings,
    required this.privacyPolicyUrl,
    required this.onOpenPrivacyNotice,
    required this.onOpenPrivacyPolicy,
  });

  final AppStrings strings;
  final String? privacyPolicyUrl;
  final VoidCallback onOpenPrivacyNotice;
  final VoidCallback? onOpenPrivacyPolicy;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.aboutSectionTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: const Icon(
                    Icons.description_rounded,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.appTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        strings.aboutSectionDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                StatusPlaceholder(label: strings.aboutLocalFirstBadge),
                StatusPlaceholder(label: strings.aboutPrivacyFirstBadge),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${strings.aboutVersionTitle}  ${AppBranding.versionLabel}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onOpenPrivacyNotice,
                  icon: const Icon(Icons.shield_outlined),
                  label: Text(strings.aboutPrivacyEntryLabel),
                ),
                if (privacyPolicyUrl != null && onOpenPrivacyPolicy != null)
                  FilledButton.tonalIcon(
                    onPressed: onOpenPrivacyPolicy,
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: Text(strings.privacyPolicyActionLabel),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyNoticeSection extends StatelessWidget {
  const _PrivacyNoticeSection({
    required this.strings,
    this.onOpenPrivacyPolicy,
  });

  final AppStrings strings;
  final VoidCallback? onOpenPrivacyPolicy;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.privacyTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              strings.privacyBody,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            InlineInfoBanner(
              message: strings.privacyCaution,
              tone: InlineInfoBannerTone.warning,
              icon: Icons.lock_outline_rounded,
            ),
            if (onOpenPrivacyPolicy != null) ...[
              const SizedBox(height: AppSpacing.md),
              FilledButton.tonalIcon(
                onPressed: onOpenPrivacyPolicy,
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(strings.privacyPolicyActionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({
    required this.strings,
    required this.onSendInquiry,
  });

  final AppStrings strings;
  final VoidCallback onSendInquiry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.contactTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              strings.contactBody,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.mail_outline_rounded,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      AppBranding.contactEmail,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.tonalIcon(
              onPressed: onSendInquiry,
              icon: const Icon(Icons.send_outlined),
              label: Text(strings.contactSendLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusPlaceholder extends StatelessWidget {
  const StatusPlaceholder({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
