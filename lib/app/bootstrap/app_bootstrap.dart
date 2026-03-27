import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/locale_preference_service.dart';
import '../../features/import_flow/data/adapter_backed_document_parser_service.dart';
import '../../features/import_flow/data/adapters/image_picker_import_adapter.dart';
import '../../features/import_flow/data/adapters/mlkit_document_parser_adapter.dart';
import '../../features/import_flow/data/adapters/pdf_import_adapter.dart';
import '../../features/import_flow/data/adapters/pdf_page_rasterizer_adapter.dart';
import '../../features/import_flow/data/adapters/pdf_text_document_parser_adapter.dart';
import '../../features/import_flow/data/document_service_providers.dart';
import '../../features/import_flow/data/method_channel_shared_document_bridge.dart';
import '../../features/import_flow/data/mock_document_parser_service.dart';
import '../../features/import_flow/data/platform_document_import_service.dart';
import '../../features/import_flow/data/resilient_document_parser_service.dart';
import '../../features/import_flow/data/shared_document_import_service.dart';
import '../../features/reminders/data/local/life_admin_database_service.dart';
import '../../features/reminders/data/local/life_admin_local_data_source.dart';
import '../../features/reminders/data/mock_life_admin_repository.dart';
import '../../features/reminders/data/sqflite_life_admin_repository.dart';
import '../../features/reminders/services/reminder_notification_scheduler.dart';

Future<List<Override>> createAppOverrides() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  final localePreferenceService = SharedPreferencesLocalePreferenceService(
    sharedPreferences,
  );
  final localDataSource = SqfliteLifeAdminLocalDataSource(
    databaseService: LifeAdminDatabaseService(),
  );
  final repository = SqfliteLifeAdminRepository(
    localDataSource: localDataSource,
  );
  await repository.initialize();

  final notificationScheduler = _supportsNotificationScheduling()
      ? FlutterLocalReminderNotificationScheduler()
      : const NoopReminderNotificationScheduler();

  await notificationScheduler.initialize();
  await notificationScheduler.syncAll(repository.loadInitialState().reminders);

  final overrides = <Override>[
    localePreferenceServiceProvider.overrideWithValue(localePreferenceService),
    lifeAdminRepositoryProvider.overrideWithValue(repository),
    reminderNotificationSchedulerProvider.overrideWithValue(
      notificationScheduler,
    ),
  ];

  final imageParserAdapter = _supportsRealOcr()
      ? MlKitTextRecognitionDocumentParserAdapter()
      : const PlaceholderMlKitDocumentParserAdapter();
  final pdfPageRasterizerAdapter = _supportsRealPdfParsing()
      ? PdfRenderPageRasterizerAdapter()
      : const PlaceholderPdfPageRasterizerAdapter();
  final pdfParserAdapter = _supportsRealPdfParsing()
      ? OcrFallbackPdfDocumentParserAdapter(
          textAdapter: const PdfTextPluginDocumentParserAdapter(),
          rasterizerAdapter: pdfPageRasterizerAdapter,
          ocrAdapter: imageParserAdapter,
        )
      : const PlaceholderPdfTextDocumentParserAdapter();
  final sharedDocumentImportService = _supportsShareSheetIngestion()
      ? PlatformSharedDocumentImportService(
          platformBridge: MethodChannelSharedDocumentBridge(),
          pdfParserAdapter: _supportsRealPdfParsing() ? pdfParserAdapter : null,
        )
      : const NoopSharedDocumentImportService();

  overrides.add(
    sharedDocumentImportServiceProvider.overrideWithValue(
      sharedDocumentImportService,
    ),
  );

  if (_supportsRealDocumentImport()) {
    overrides.add(
      documentImportServiceProvider.overrideWithValue(
        PlatformDocumentImportService(
          imageAdapter: PermissionAwareImagePickerImportAdapter(),
          pdfAdapter: FilePickerPdfDocumentImportAdapter(
            parserAdapter: _supportsRealPdfParsing() ? pdfParserAdapter : null,
          ),
        ),
      ),
    );
  }

  if (_supportsRealOcr()) {
    overrides.add(
      documentParserServiceProvider.overrideWithValue(
        ResilientDocumentParserService(
          primaryParser: AdapterBackedDocumentParserService(
            imageParserAdapter: imageParserAdapter,
            pdfParserAdapter: pdfParserAdapter,
          ),
          mockParser: MockDocumentParserService(),
        ),
      ),
    );
  }

  return overrides;
}

bool _supportsNotificationScheduling() {
  if (kIsWeb) {
    return false;
  }

  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;
}

bool _supportsRealDocumentImport() {
  if (kIsWeb) {
    return false;
  }

  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

bool _supportsRealOcr() {
  if (kIsWeb) {
    return false;
  }

  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

bool _supportsRealPdfParsing() {
  if (kIsWeb) {
    return false;
  }

  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

bool _supportsShareSheetIngestion() {
  if (kIsWeb) {
    return false;
  }

  return defaultTargetPlatform == TargetPlatform.android;
}
