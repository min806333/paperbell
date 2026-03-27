import 'package:flutter/material.dart';

import '../../app/localization/app_strings.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/models/app_enums.dart';
import '../../features/import_flow/domain/document.dart';
import '../../features/import_flow/domain/document_page.dart';
import 'status_badge.dart';

class DocumentPreviewCard extends StatelessWidget {
  const DocumentPreviewCard({
    super.key,
    required this.document,
    this.page,
    this.expanded = false,
  });

  final Document document;
  final DocumentPage? page;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final previewPage = page ?? document.pages.first;
    final strings = AppStrings.forLocale(Localizations.localeOf(context));

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryContainer, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: expanded ? 52 : 44,
                height: expanded ? 52 : 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  document.sourceType.icon,
                  color: AppColors.primary,
                  size: expanded ? 24 : 22,
                ),
              ),
              const Spacer(),
              if (document.containsSensitive)
                StatusBadge(
                  label: strings.localOnlyProcessingBadge,
                  tone: StatusBadgeTone.primary,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(document.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            previewPage.previewLabel,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                previewPage.helperText,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: AppSpacing.md),
              Icon(
                Icons.folder_open_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  strings.documentSourceLabel(document.sourceType),
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (expanded) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Text(
                strings.documentPreviewPlaceholderMessage,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
