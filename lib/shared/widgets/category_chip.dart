import 'package:flutter/material.dart';

import '../../app/localization/app_strings.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/models/app_enums.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key, required this.category});

  final ReminderCategory category;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.forLocale(Localizations.localeOf(context));

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: category.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: 14, color: category.foregroundColor),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            strings.reminderCategoryLabel(category),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: category.foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
