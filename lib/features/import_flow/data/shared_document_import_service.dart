import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../app/localization/app_strings.dart';
import '../../../core/models/app_enums.dart';
import '../domain/import_result.dart';
import 'adapters/pdf_text_document_parser_adapter.dart';
import 'imported_document_factory.dart';

class SharedDocumentPayload {
  const SharedDocumentPayload({
    required this.path,
    this.mimeType,
    this.fileName,
  });

  final String path;
  final String? mimeType;
  final String? fileName;
}

abstract interface class SharedDocumentPlatformBridge {
  Future<List<SharedDocumentPayload>> getLatestSharedDocuments();

  Future<void> markLatestSharedDocumentsHandled();

  Stream<List<SharedDocumentPayload>> watchIncomingSharedDocuments();
}

abstract class SharedDocumentImportService {
  Future<ImportResult?> loadLatestSharedImportIfAny();

  Stream<ImportResult> watchIncomingImports();
}

class NoopSharedDocumentImportService implements SharedDocumentImportService {
  const NoopSharedDocumentImportService();

  @override
  Future<ImportResult?> loadLatestSharedImportIfAny() async => null;

  @override
  Stream<ImportResult> watchIncomingImports() => const Stream.empty();
}

class PlatformSharedDocumentImportService
    implements SharedDocumentImportService {
  PlatformSharedDocumentImportService({
    required SharedDocumentPlatformBridge platformBridge,
    PdfTextDocumentParserAdapter? pdfParserAdapter,
  }) : _platformBridge = platformBridge,
       _pdfParserAdapter = pdfParserAdapter;

  final SharedDocumentPlatformBridge _platformBridge;
  final PdfTextDocumentParserAdapter? _pdfParserAdapter;
  final Set<String> _handledSignatures = <String>{};
  Stream<ImportResult>? _incomingImports;

  @override
  Future<ImportResult?> loadLatestSharedImportIfAny() async {
    final payloads = await _platformBridge.getLatestSharedDocuments();
    if (payloads.isEmpty) {
      return null;
    }

    await _platformBridge.markLatestSharedDocumentsHandled();
    return _mapPayloadsToImportResult(payloads);
  }

  @override
  Stream<ImportResult> watchIncomingImports() {
    return _incomingImports ??= _platformBridge
        .watchIncomingSharedDocuments()
        .asyncMap((payloads) async {
          return _mapPayloadsToImportResult(payloads);
        })
        .where((result) => result != null)
        .cast<ImportResult>();
  }

  Future<ImportResult?> _mapPayloadsToImportResult(
    List<SharedDocumentPayload> payloads,
  ) async {
    final strings = AppStrings.current;
    final supportedPayload = payloads.firstWhere(
      _isSupportedPayload,
      orElse: () => const SharedDocumentPayload(path: ''),
    );

    if (supportedPayload.path.isEmpty) {
      return ImportFailure(message: strings.unsupportedSharedPayloadMessage);
    }

    final signature = _buildSignature(supportedPayload);
    if (_handledSignatures.contains(signature)) {
      return null;
    }

    final file = File(supportedPayload.path);
    if (!await file.exists()) {
      return ImportFailure(message: strings.sharedDocumentMissingMessage);
    }

    _handledSignatures.add(signature);

    if (_isPdfPayload(supportedPayload)) {
      return _importPdfPayload(supportedPayload);
    }

    return ImportSuccess(
      ImportedDocumentFactory.fromImagePath(
        path: supportedPayload.path,
        sourceType: DocumentSourceType.shareSheet,
        fileName: supportedPayload.fileName,
      ),
    );
  }

  Future<ImportResult> _importPdfPayload(SharedDocumentPayload payload) async {
    PdfDocumentInspection? inspection;
    if (_pdfParserAdapter != null) {
      try {
        inspection = await _pdfParserAdapter.inspectDocument(payload.path);
      } catch (_) {
        inspection = null;
      }
    }

    return ImportSuccess(
      ImportedDocumentFactory.fromPdfPath(
        path: payload.path,
        fileName: payload.fileName,
        pageCount: inspection?.pageCount,
        titleOverride: inspection?.title,
      ),
    );
  }

  bool _isSupportedPayload(SharedDocumentPayload payload) {
    return _isPdfPayload(payload) || _isImagePayload(payload);
  }

  bool _isPdfPayload(SharedDocumentPayload payload) {
    final mimeType = payload.mimeType?.toLowerCase() ?? '';
    final extension = p.extension(payload.path).toLowerCase();
    return mimeType == 'application/pdf' || extension == '.pdf';
  }

  bool _isImagePayload(SharedDocumentPayload payload) {
    final mimeType = payload.mimeType?.toLowerCase() ?? '';
    final extension = p.extension(payload.path).toLowerCase();
    return mimeType.startsWith('image/') ||
        const ['.jpg', '.jpeg', '.png', '.webp', '.heic'].contains(extension);
  }

  String _buildSignature(SharedDocumentPayload payload) {
    return '${payload.mimeType}|${payload.path}|${payload.fileName}';
  }
}
