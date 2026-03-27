import 'package:flutter/material.dart';

import '../../app/localization/app_strings.dart';

class FloatingImportButton extends StatelessWidget {
  const FloatingImportButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.forLocale(Localizations.localeOf(context));

    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: Text(strings.addImportAction),
    );
  }
}
