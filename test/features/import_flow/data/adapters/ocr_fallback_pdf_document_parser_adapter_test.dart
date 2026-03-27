import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_admin_assistant/core/models/app_enums.dart';
import 'package:life_admin_assistant/features/import_flow/data/adapters/mlkit_document_parser_adapter.dart';
import 'package:life_admin_assistant/features/import_flow/data/adapters/pdf_page_rasterizer_adapter.dart';
import 'package:life_admin_assistant/features/import_flow/data/adapters/pdf_text_document_parser_adapter.dart';
import 'package:life_admin_assistant/features/import_flow/data/parsing/recognized_document_text.dart';
import 'package:life_admin_assistant/features/import_flow/domain/document.dart';
import 'package:life_admin_assistant/features/import_flow/domain/document_page.dart';
import 'package:life_admin_assistant/features/import_flow/domain/document_preprocessing.dart';

void main() {
  Document buildPdfDocument({DocumentPreprocessing? preprocessing}) {
    return Document(
      id: 'doc-pdf-1',
      sourceType: DocumentSourceType.pdf,
      title: '관리비 안내문',
      createdAt: DateTime(2026, 3, 25),
      originalPath: '/tmp/test.pdf',
      containsSensitive: true,
      preprocessing: preprocessing ?? const DocumentPreprocessing(),
      pages: const [
        DocumentPage(
          id: 'page-1',
          pageNumber: 1,
          previewLabel: 'PDF 문서',
          helperText: '1페이지',
        ),
      ],
    );
  }

  test('uses text layer only when it already has enough text', () async {
    final textAdapter = _FakePdfTextAdapter(
      inspection: const PdfDocumentInspection(pageCount: 2, title: '관리비 안내'),
      extraction: const RecognizedDocumentText(
        rawText: '관리비 납부 안내\n납부기한 2026년 4월 25일\n납부금액 87,000원',
        lines: [
          RecognizedLineCandidate(text: '관리비 납부 안내'),
          RecognizedLineCandidate(text: '납부기한 2026년 4월 25일'),
          RecognizedLineCandidate(text: '납부금액 87,000원'),
        ],
        pageCount: 2,
        suggestedTitle: '관리비 안내',
      ),
    );
    final rasterizer = _FakePdfPageRasterizerAdapter();
    final ocrAdapter = _FakeMlKitDocumentParserAdapter();

    final adapter = OcrFallbackPdfDocumentParserAdapter(
      textAdapter: textAdapter,
      rasterizerAdapter: rasterizer,
      ocrAdapter: ocrAdapter,
    );

    final result = await adapter.extractDocumentText(buildPdfDocument());

    expect(result.rawText, contains('납부기한'));
    expect(rasterizer.rasterizeCallCount, 0);
    expect(ocrAdapter.bitmapCallCount, 0);
  });

  test('falls back to OCR when text layer is empty', () async {
    final textAdapter = _FakePdfTextAdapter(
      inspection: const PdfDocumentInspection(pageCount: 4, title: '보험 갱신 안내'),
      extraction: const RecognizedDocumentText(
        rawText: '',
        lines: [],
        pageCount: 4,
        suggestedTitle: '보험 갱신 안내',
      ),
    );
    final rasterizer = _FakePdfPageRasterizerAdapter(
      document: RasterizedPdfDocument(
        pages: [
          RasterizedPdfPage(
            pageNumber: 1,
            width: 100,
            height: 200,
            rgbaBytes: Uint8List(0),
          ),
          RasterizedPdfPage(
            pageNumber: 2,
            width: 100,
            height: 200,
            rgbaBytes: Uint8List(0),
          ),
        ],
      ),
    );
    final ocrAdapter = _FakeMlKitDocumentParserAdapter(
      bitmapResults: const [
        RecognizedDocumentText(
          rawText: '보험 갱신 안내\n갱신일 2026년 9월 30일',
          lines: [
            RecognizedLineCandidate(text: '보험 갱신 안내'),
            RecognizedLineCandidate(text: '갱신일 2026년 9월 30일'),
          ],
        ),
        RecognizedDocumentText(
          rawText: '보험료 128,400원',
          lines: [RecognizedLineCandidate(text: '보험료 128,400원')],
        ),
      ],
    );

    final adapter = OcrFallbackPdfDocumentParserAdapter(
      textAdapter: textAdapter,
      rasterizerAdapter: rasterizer,
      ocrAdapter: ocrAdapter,
      maxOcrPages: 3,
    );

    final result = await adapter.extractDocumentText(buildPdfDocument());

    expect(result.rawText, contains('갱신일'));
    expect(result.rawText, contains('보험료'));
    expect(result.pageCount, 4);
    expect(rasterizer.lastMaxPages, 3);
    expect(ocrAdapter.bitmapCallCount, 2);
  });

  test('uses raster OCR path first when review edits exist', () async {
    final textAdapter = _FakePdfTextAdapter(
      extraction: const RecognizedDocumentText(
        rawText: 'text layer should not win first',
        lines: [RecognizedLineCandidate(text: 'text layer should not win first')],
      ),
    );
    final rasterizer = _FakePdfPageRasterizerAdapter(
      document: RasterizedPdfDocument(
        pages: [
          RasterizedPdfPage(
            pageNumber: 1,
            width: 80,
            height: 120,
            rgbaBytes: Uint8List(0),
          ),
        ],
      ),
    );
    final ocrAdapter = _FakeMlKitDocumentParserAdapter(
      bitmapResults: const [
        RecognizedDocumentText(
          rawText: '회전된 스캔 본문에서 날짜 정보를 다시 읽었습니다',
          lines: [
            RecognizedLineCandidate(text: '회전된 스캔 본문에서 날짜 정보를 다시 읽었습니다'),
          ],
        ),
      ],
    );

    final adapter = OcrFallbackPdfDocumentParserAdapter(
      textAdapter: textAdapter,
      rasterizerAdapter: rasterizer,
      ocrAdapter: ocrAdapter,
    );

    final result = await adapter.extractDocumentText(
      buildPdfDocument(
        preprocessing: const DocumentPreprocessing(
          rotationQuarterTurns: 1,
          cropInsetRatio: 0.08,
        ),
      ),
    );

    expect(rasterizer.lastPreprocessing.normalizedRotationQuarterTurns, 1);
    expect(rasterizer.lastPreprocessing.normalizedCropInsetRatio, 0.08);
    expect(result.rawText, '회전된 스캔 본문에서 날짜 정보를 다시 읽었습니다');
    expect(
      result.notices,
      contains('회전하거나 다듬은 내용이 인식에 반영되도록 PDF를 이미지 기준으로 다시 읽었어요.'),
    );
  });

  test('inspectDocument uses rasterizer page count when text inspect fails', () async {
    final textAdapter = _FakePdfTextAdapter(
      inspectionError: StateError('inspect failed'),
    );
    final rasterizer = _FakePdfPageRasterizerAdapter(pageCount: 5);
    final ocrAdapter = _FakeMlKitDocumentParserAdapter();

    final adapter = OcrFallbackPdfDocumentParserAdapter(
      textAdapter: textAdapter,
      rasterizerAdapter: rasterizer,
      ocrAdapter: ocrAdapter,
    );

    final inspection = await adapter.inspectDocument('/tmp/test.pdf');

    expect(inspection.pageCount, 5);
  });

  test('throws when neither text layer nor OCR returns usable text', () async {
    final textAdapter = _FakePdfTextAdapter(
      extraction: const RecognizedDocumentText(rawText: '', lines: []),
    );
    final rasterizer = _FakePdfPageRasterizerAdapter(
      document: RasterizedPdfDocument(
        pages: [
          RasterizedPdfPage(
            pageNumber: 1,
            width: 100,
            height: 200,
            rgbaBytes: Uint8List(0),
          ),
        ],
      ),
    );
    final ocrAdapter = _FakeMlKitDocumentParserAdapter(
      bitmapResults: const [RecognizedDocumentText(rawText: '', lines: [])],
    );

    final adapter = OcrFallbackPdfDocumentParserAdapter(
      textAdapter: textAdapter,
      rasterizerAdapter: rasterizer,
      ocrAdapter: ocrAdapter,
    );

    await expectLater(
      () => adapter.extractDocumentText(buildPdfDocument()),
      throwsA(isA<StateError>()),
    );
  });
}

class _FakePdfTextAdapter implements PdfTextDocumentParserAdapter {
  _FakePdfTextAdapter({
    this.inspection = const PdfDocumentInspection(pageCount: 1),
    this.extraction = const RecognizedDocumentText(rawText: '', lines: []),
    this.inspectionError,
  });

  final PdfDocumentInspection inspection;
  final RecognizedDocumentText extraction;
  final Object? inspectionError;

  @override
  Future<RecognizedDocumentText> extractDocumentText(Document document) async {
    return extraction;
  }

  @override
  Future<PdfDocumentInspection> inspectDocument(String path) async {
    if (inspectionError != null) {
      throw inspectionError!;
    }
    return inspection;
  }
}

class _FakePdfPageRasterizerAdapter implements PdfPageRasterizerAdapter {
  _FakePdfPageRasterizerAdapter({
    this.pageCount = 1,
    this.document = const RasterizedPdfDocument(pages: []),
  });

  final int pageCount;
  final RasterizedPdfDocument document;
  int rasterizeCallCount = 0;
  int? lastMaxPages;
  DocumentPreprocessing lastPreprocessing = const DocumentPreprocessing();

  @override
  Future<int> getPageCount(String path) async => pageCount;

  @override
  Future<RasterizedPdfDocument> rasterizeDocument({
    required String path,
    int maxPages = 3,
    DocumentPreprocessing preprocessing = const DocumentPreprocessing(),
  }) async {
    rasterizeCallCount += 1;
    lastMaxPages = maxPages;
    lastPreprocessing = preprocessing;
    return document;
  }
}

class _FakeMlKitDocumentParserAdapter implements MlKitDocumentParserAdapter {
  _FakeMlKitDocumentParserAdapter({this.bitmapResults = const []});

  final List<RecognizedDocumentText> bitmapResults;
  int bitmapCallCount = 0;

  @override
  Future<RecognizedDocumentText> extractBitmapText({
    required Uint8List bitmapData,
    required int width,
    required int height,
    String? suggestedTitle,
  }) async {
    final index = bitmapCallCount;
    bitmapCallCount += 1;
    if (index < bitmapResults.length) {
      return bitmapResults[index];
    }
    return const RecognizedDocumentText(rawText: '', lines: []);
  }

  @override
  Future<RecognizedDocumentText> extractDocumentText(Document document) async {
    return const RecognizedDocumentText(rawText: '', lines: []);
  }
}
