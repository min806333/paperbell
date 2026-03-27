import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

enum StatusBadgeTone { primary, warning, success, neutral, error }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.tone = StatusBadgeTone.neutral,
  });

  final String label;
  final StatusBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, foregroundColor) = switch (tone) {
      StatusBadgeTone.primary => (
        AppColors.primaryContainer,
        AppColors.primary,
      ),
      StatusBadgeTone.warning => (
        AppColors.warningContainer,
        AppColors.warning,
      ),
      StatusBadgeTone.success => (
        AppColors.successContainer,
        AppColors.success,
      ),
      StatusBadgeTone.error => (AppColors.errorContainer, AppColors.error),
      StatusBadgeTone.neutral => (
        AppColors.surfaceVariant,
        AppColors.textSecondary,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
