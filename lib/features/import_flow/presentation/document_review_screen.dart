import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_strings.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/models/app_enums.dart';
import '../../../shared/widgets/app_page_scaffold.dart';
import '../../../shared/widgets/document_preview_card.dart';
import '../../../shared/widgets/inline_info_banner.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../../../shared/widgets/section_header.dart';
import '../data/document_service_providers.dart';
import '../domain/document.dart';
import '../domain/document_preprocessing.dart';
import '../domain/import_session.dart';

class DocumentReviewScreen extends ConsumerStatefulWidget {
  const DocumentReviewScreen({super.key, required this.document});

  final Document document;

  @override
  ConsumerState<DocumentReviewScreen> createState() =>
      _DocumentReviewScreenState();
}

class _DocumentReviewScreenState extends ConsumerState<DocumentReviewScreen> {
  int _selectedPageIndex = 0;
  late int _rotationTurns;
  late double _cropInsetRatio;
  bool _isParsing = false;

  @override
  void initState() {
    super.initState();
    _rotationTurns = widget.document.preprocessing.normalizedRotationQuarterTurns;
    _cropInsetRatio = widget.document.preprocessing.normalizedCropInsetRatio;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.forLocale(Localizations.localeOf(context));
    final currentPage = widget.document.pages[_selectedPageIndex];
    final rotationDegrees = (_rotationTurns % 4) * 90;
    final cropPercent = (_cropInsetRatio * 100).round();

    return AppPageScaffold(
      title: strings.documentReviewTitle,
      child: Stack(
        children: [
          ListView(
            children: [
              SectionHeader(
                title: strings.documentReviewHeaderTitle,
                subtitle: strings.documentReviewHeaderSubtitle,
              ),
              const SizedBox(height: AppSpacing.md),
              InlineInfoBanner(message: strings.reviewProcessingInfoBanner),
              const SizedBox(height: AppSpacing.md),
              DocumentPreviewCard(
                document: _buildReviewDocument(),
                page: currentPage,
                expanded: true,
              ),
              const SizedBox(height: AppSpacing.md),
              if (_rotationTurns != 0 || _cropInsetRatio > 0) ...[
                if (_rotationTurns != 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Text(
                      strings.reviewRotationLabel(rotationDegrees),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                if (_cropInsetRatio > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Text(
                      strings.reviewCropLabel(cropPercent),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.document.pages.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final page = widget.document.pages[index];
                    final isSelected = index == _selectedPageIndex;

                    return InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      onTap: () => setState(() => _selectedPageIndex = index),
                      child: Container(
                        width: 112,
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryContainer
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              page.helperText,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                            ),
                            const Spacer(),
                            Text(
                              page.previewLabel,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                strings.cropAdjustmentTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.sm),
              _CropAdjustmentCard(
                message: strings.reviewCropHelperMessage,
                cropInsetRatio: _cropInsetRatio,
              ),
              const SizedBox(height: AppSpacing.sm),
              Slider(
                value: _cropInsetRatio,
                min: 0,
                max: DocumentPreprocessing.maxCropInsetRatio,
                divisions: 6,
                label: strings.reviewCropLabel(cropPercent),
                onChanged: (value) => setState(() => _cropInsetRatio = value),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: strings.rotateAction,
                      onPressed: () => setState(() => _rotationTurns += 1),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: SecondaryButton(
                      label:
                          widget.document.sourceType == DocumentSourceType.camera
                          ? strings.retakeAction
                          : strings.reselectAction,
                      onPressed: () => context.pop(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              PrimaryButton(
                label: strings.continueAction,
                onPressed: _continueToExtraction,
              ),
            ],
          ),
          if (_isParsing)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.18),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(AppSpacing.xl),
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          strings.parsingInProgressTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          strings.parsingInProgressSubtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _continueToExtraction() async {
    setState(() => _isParsing = true);

    final reviewedDocument = _buildReviewDocument();
    final extraction = await ref
        .read(documentParserServiceProvider)
        .parseDocument(reviewedDocument);

    if (!mounted) {
      return;
    }

    setState(() => _isParsing = false);

    context.push(
      '/import/confirm',
      extra: ImportSession(document: reviewedDocument, extraction: extraction),
    );
  }

  Document _buildReviewDocument() {
    return widget.document.copyWith(
      preprocessing: DocumentPreprocessing(
        rotationQuarterTurns: _rotationTurns,
        cropInsetRatio: _cropInsetRatio,
      ),
    );
  }
}

class _CropAdjustmentCard extends StatelessWidget {
  const _CropAdjustmentCard({
    required this.message,
    required this.cropInsetRatio,
  });

  final String message;
  final double cropInsetRatio;

  @override
  Widget build(BuildContext context) {
    final inset =
        lerpDouble(
          14,
          40,
          cropInsetRatio / DocumentPreprocessing.maxCropInsetRatio,
        ) ??
        14;

    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(inset),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          for (final alignment in const [
            Alignment.topLeft,
            Alignment.topRight,
            Alignment.bottomLeft,
            Alignment.bottomRight,
          ])
            Align(
              alignment: alignment,
              child: Container(
                width: 28,
                height: 28,
                margin: EdgeInsets.all(inset),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
