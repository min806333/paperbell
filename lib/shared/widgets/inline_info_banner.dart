import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

enum InlineInfoBannerTone { info, warning, success, error }

class InlineInfoBanner extends StatelessWidget {
  const InlineInfoBanner({
    super.key,
    required this.message,
    this.tone = InlineInfoBannerTone.info,
    this.icon,
  });

  final String message;
  final InlineInfoBannerTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, foregroundColor, fallbackIcon) = switch (tone) {
      InlineInfoBannerTone.info => (
        AppColors.primaryContainer,
        AppColors.primary,
        Icons.verified_user_outlined,
      ),
      InlineInfoBannerTone.warning => (
        AppColors.warningContainer,
        AppColors.warning,
        Icons.info_outline,
      ),
      InlineInfoBannerTone.success => (
        AppColors.successContainer,
        AppColors.success,
        Icons.check_circle_outline,
      ),
      InlineInfoBannerTone.error => (
        AppColors.errorContainer,
        AppColors.error,
        Icons.error_outline,
      ),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? fallbackIcon, size: 20, color: foregroundColor),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: foregroundColor),
            ),
          ),
        ],
      ),
    );
  }
}
