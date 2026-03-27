import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_admin_assistant/core/models/app_enums.dart';
import 'package:life_admin_assistant/features/import_flow/data/adapters/pdf_text_document_parser_adapter.dart';
import 'package:life_admin_assistant/features/import_flow/data/parsing/recognized_document_text.dart';
import 'package:life_admin_assistant/features/import_flow/data/shared_document_import_service.dart';
import 'package:life_admin_assistant/features/import_flow/domain/document.dart';
import 'package:life_admin_assistant/features/import_flow/domain/import_result.dart';

void main() {
  late Directory tempDirectory;

  setUp(() {
    tempDirectory = Directory.systemTemp.createTempSync(
      'life-admin-shared-import-test',
    );
  });

  tearDown(() {
    if (tempDirectory.existsSync()) {
      tempDirectory.deleteSync(recursive: true);
    }
  });

  test('공유된 이미지를 기존 리뷰 문서로 변환한다', () async {
    final imageFile = File('${tempDirectory.path}/maintenance_notice.jpg')
      ..writeAsBytesSync([1, 2, 3]);
    final bridge = _FakeSharedDocumentPlatformBridge(
      latestPayloads: [
        SharedDocumentPayload(
          path: imageFile.path,
          mimeType: 'image/jpeg',
          fileName: '관리비 안내.jpg',
        ),
      ],
    );
    final service = PlatformSharedDocumentImportService(platformBridge: bridge);

    final result = await service.loadLatestSharedImportIfAny();

    expect(bridge.markHandledCallCount, 1);
    expect(result, isA<ImportSuccess>());

    final document = (result as ImportSuccess).document;
    expect(document.sourceType, DocumentSourceType.shareSheet);
    expect(document.title, '관리비 안내');
    expect(document.originalPath, imageFile.path);
  });

  test('공유된 PDF는 검사 결과를 살려서 가져온다', () async {
    final pdfFile = File('${tempDirectory.path}/renewal_notice.pdf')
      ..writeAsStringSync('placeholder');
    final bridge = _FakeSharedDocumentPlatformBridge(
      latestPayloads: [
        SharedDocumentPayload(
          path: pdfFile.path,
          mimeType: 'application/pdf',
          fileName: '보험 갱신.pdf',
        ),
      ],
    );
    final pdfParserAdapter = _FakePdfTextDocumentParserAdapter(
      inspection: const PdfDocumentInspection(pageCount: 4, title: '보험 갱신 안내'),
    );
    final service = PlatformSharedDocumentImportService(
      platformBridge: bridge,
      pdfParserAdapter: pdfParserAdapter,
    );

    final result = await service.loadLatestSharedImportIfAny();

    expect(result, isA<ImportSuccess>());
    expect(pdfParserAdapter.inspectCallCount, 1);

    final document = (result as ImportSuccess).document;
    expect(document.sourceType, DocumentSourceType.pdf);
    expect(document.title, '보험 갱신 안내');
    expect(document.pages.length, 4);
  });

  test('지원하지 않는 공유 타입은 차분하게 실패를 돌려준다', () async {
    final noteFile = File('${tempDirectory.path}/notice.txt')
      ..writeAsStringSync('hello');
    final bridge = _FakeSharedDocumentPlatformBridge(
      latestPayloads: [
        SharedDocumentPayload(
          path: noteFile.path,
          mimeType: 'text/plain',
          fileName: '안내.txt',
        ),
      ],
    );
    final service = PlatformSharedDocumentImportService(platformBridge: bridge);

    final result = await service.loadLatestSharedImportIfAny();

    expect(result, isA<ImportFailure>());
    expect(
      (result as ImportFailure).message,
      contains('이미지나 PDF만 차분하게 가져올 수 있어요'),
    );
  });

  test('같은 공유 payload는 한 번만 처리한다', () async {
    final imageFile = File('${tempDirectory.path}/subscription.png')
      ..writeAsBytesSync([1, 2, 3]);
    final payload = SharedDocumentPayload(
      path: imageFile.path,
      mimeType: 'image/png',
      fileName: '넷플릭스.png',
    );
    final bridge = _FakeSharedDocumentPlatformBridge();
    final service = PlatformSharedDocumentImportService(platformBridge: bridge);

    final resultsFuture = service.watchIncomingImports().toList();

    bridge.emit([payload]);
    bridge.emit([payload]);
    await bridge.close();

    final results = await resultsFuture;

    expect(results, hasLength(1));
    expect(results.single, isA<ImportSuccess>());
  });
}

class _FakeSharedDocumentPlatformBridge
    implements SharedDocumentPlatformBridge {
  _FakeSharedDocumentPlatformBridge({this.latestPayloads = const []});

  final List<SharedDocumentPayload> latestPayloads;
  final StreamController<List<SharedDocumentPayload>> _controller =
      StreamController<List<SharedDocumentPayload>>();
  int markHandledCallCount = 0;

  void emit(List<SharedDocumentPayload> payloads) {
    _controller.add(payloads);
  }

  Future<void> close() {
    return _controller.close();
  }

  @override
  Future<List<SharedDocumentPayload>> getLatestSharedDocuments() async {
    return latestPayloads;
  }

  @override
  Future<void> markLatestSharedDocumentsHandled() async {
    markHandledCallCount += 1;
  }

  @override
  Stream<List<SharedDocumentPayload>> watchIncomingSharedDocuments() {
    return _controller.stream;
  }
}

class _FakePdfTextDocumentParserAdapter
    implements PdfTextDocumentParserAdapter {
  _FakePdfTextDocumentParserAdapter({required this.inspection});

  final PdfDocumentInspection inspection;
  int inspectCallCount = 0;

  @override
  Future<RecognizedDocumentText> extractDocumentText(Document document) async {
    return const RecognizedDocumentText(rawText: '', lines: []);
  }

  @override
  Future<PdfDocumentInspection> inspectDocument(String path) async {
    inspectCallCount += 1;
    return inspection;
  }
}
