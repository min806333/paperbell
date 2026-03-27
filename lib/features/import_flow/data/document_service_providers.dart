import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'document_import_service.dart';
import 'document_parser_service.dart';
import 'mock_document_import_service.dart';
import 'mock_document_parser_service.dart';
import 'shared_document_import_service.dart';

final documentImportServiceProvider = Provider<DocumentImportService>(
  (ref) => MockDocumentImportService(),
);

final documentParserServiceProvider = Provider<DocumentParserService>(
  (ref) => MockDocumentParserService(),
);

final sharedDocumentImportServiceProvider =
    Provider<SharedDocumentImportService>(
      (ref) => const NoopSharedDocumentImportService(),
    );
