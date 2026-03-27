import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_strings.dart';
import '../../../app/localization/locale_controller.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/inline_info_banner.dart';
import '../../../shared/widgets/section_header.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeState = ref.watch(appLocaleControllerProvider);
    final strings = AppStrings.forLocale(localeState.locale);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          children: [
            SectionHeader(
              title: strings.languageSelectionTitle,
              subtitle: strings.languageSelectionSubtitle,
            ),
            const SizedBox(height: AppSpacing.xl),
            Card(
              child: Column(
                children: [
                  _LanguageOptionTile(
                    label: strings.languageOptionKorean,
                    selected: localeState.language == AppLanguage.korean,
                    onTap: () {
                      ref
                          .read(appLocaleControllerProvider.notifier)
                          .selectLanguage(AppLanguage.korean);
                    },
                  ),
                  const Divider(height: 1),
                  _LanguageOptionTile(
                    label: strings.languageOptionEnglish,
                    selected: localeState.language == AppLanguage.english,
                    onTap: () {
                      ref
                          .read(appLocaleControllerProvider.notifier)
                          .selectLanguage(AppLanguage.english);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            InlineInfoBanner(message: strings.languageSelectionHint),
          ],
        ),
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      title: Text(label),
      trailing: selected ? const Icon(Icons.check_circle_rounded) : null,
      onTap: onTap,
    );
  }
}
