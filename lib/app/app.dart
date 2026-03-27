import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/import_flow/presentation/shared_document_ingestion_listener.dart';
import '../features/settings/presentation/language_selection_screen.dart';
import 'localization/app_strings.dart';
import 'localization/locale_controller.dart';
import 'navigation/app_router.dart';
import 'onboarding/privacy_notice_controller.dart';
import 'theme/app_theme.dart';

class LifeAdminAssistantApp extends ConsumerStatefulWidget {
  const LifeAdminAssistantApp({super.key});

  @override
  ConsumerState<LifeAdminAssistantApp> createState() =>
      _LifeAdminAssistantAppState();
}

class _LifeAdminAssistantAppState extends ConsumerState<LifeAdminAssistantApp> {
  bool _privacyDialogShownThisSession = false;
  bool _privacyDialogScheduled = false;

  void _schedulePrivacyNoticeDialog(
    GoRouter router,
    AppLocaleState localeState,
    bool privacyAcknowledged,
  ) {
    if (!localeState.hasSelectedLanguage ||
        privacyAcknowledged ||
        _privacyDialogShownThisSession ||
        _privacyDialogScheduled) {
      return;
    }

    _privacyDialogScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _privacyDialogScheduled = false;
      if (!mounted) {
        return;
      }

      final latestLocaleState = ref.read(appLocaleControllerProvider);
      final latestAcknowledged = ref.read(privacyNoticeControllerProvider);
      final navigatorContext = router.routerDelegate.navigatorKey.currentContext;
      if (!latestLocaleState.hasSelectedLanguage ||
          latestAcknowledged ||
          _privacyDialogShownThisSession ||
          navigatorContext == null) {
        return;
      }

      _privacyDialogShownThisSession = true;
      final strings = AppStrings.forLocale(latestLocaleState.locale);
      final action = await showDialog<_PrivacyNoticeAction>(
        context: navigatorContext,
        barrierDismissible: true,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(strings.privacyTitle),
            content: SingleChildScrollView(
              child: Text(
                '${strings.privacyBody}\n\n${strings.privacyCaution}',
                style: Theme.of(
                  dialogContext,
                ).textTheme.bodyMedium?.copyWith(height: 1.55),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(
                  dialogContext,
                ).pop(_PrivacyNoticeAction.closeOnly),
                child: Text(strings.confirmAction),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.of(
                  dialogContext,
                ).pop(_PrivacyNoticeAction.dismissForever),
                child: Text(strings.dontShowAgainAction),
              ),
            ],
          );
        },
      );

      if (action == _PrivacyNoticeAction.dismissForever) {
        await ref
            .read(privacyNoticeControllerProvider.notifier)
            .dismissForever();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final localeState = ref.watch(appLocaleControllerProvider);
    final privacyAcknowledged = ref.watch(privacyNoticeControllerProvider);
    final strings = AppStrings.forLocale(localeState.locale);

    return MaterialApp.router(
      title: strings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: localeState.locale,
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        _schedulePrivacyNoticeDialog(
          router,
          localeState,
          privacyAcknowledged,
        );

        final routedChild = SharedDocumentIngestionListener(
          child: child ?? const SizedBox.shrink(),
        );
        if (localeState.hasSelectedLanguage) {
          return routedChild;
        }
        return Stack(
          children: [
            routedChild,
            const LanguageSelectionScreen(),
          ],
        );
      },
      routerConfig: router,
    );
  }
}

enum _PrivacyNoticeAction { closeOnly, dismissForever }
