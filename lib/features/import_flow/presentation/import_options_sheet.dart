import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_strings.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/models/app_enums.dart';
import '../../../shared/widgets/inline_info_banner.dart';
import '../data/document_service_providers.dart';
import '../domain/import_result.dart';

class ImportOptionsSheet extends ConsumerWidget {
  const ImportOptionsSheet({super.key, required this.hostContext});

  final BuildContext hostContext;

  Future<void> _handleImport(
    BuildContext context,
    WidgetRef ref,
    DocumentSourceType sourceType,
  ) async {
    final strings = AppStrings.forLocale(Localizations.localeOf(hostContext));
    Navigator.of(context).pop();

    final result = switch (sourceType) {
      DocumentSourceType.shareSheet =>
        await ref
                .read(sharedDocumentImportServiceProvider)
                .loadLatestSharedImportIfAny() ??
            ImportFailure(
              message: strings.recentSharedDocumentMissingMessage,
            ),
      _ => await ref
          .read(documentImportServiceProvider)
          .importDocument(sourceType),
    };

    if (!hostContext.mounted) {
      return;
    }

    switch (result) {
      case ImportSuccess(:final document):
        hostContext.push('/import/review', extra: document);
      case ImportFailure(:final message, :final cancelled):
        if (cancelled) {
          return;
        }
        ScaffoldMessenger.of(
          hostContext,
        ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.forLocale(Localizations.localeOf(context));

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.importSheetTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            strings.importSheetSubtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(height: 1.45),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final sourceType in DocumentSourceType.values) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(sourceType.icon)),
              title: Text(strings.documentSourceLabel(sourceType)),
              subtitle: Text(strings.documentSourceHelperText(sourceType)),
              onTap: () => _handleImport(context, ref, sourceType),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          const SizedBox(height: AppSpacing.sm),
          InlineInfoBanner(message: strings.importSheetBanner),
        ],
      ),
    );
  }
}
