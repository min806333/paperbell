import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_pdf_text/flutter_pdf_text.dart';

import '../../../../app/localization/app_strings.dart';
import '../../domain/document.dart';
import '../parsing/recognized_document_text.dart';
import 'mlkit_document_parser_adapter.dart';
import 'pdf_page_rasterizer_adapter.dart';

class PdfDocumentInspection {
  const PdfDocumentInspection({required this.pageCount, this.title});

  final int pageCount;
  final String? title;
}

abstract interface class PdfTextDocumentParserAdapter {
  Future<PdfDocumentInspection> inspectDocument(String path);

  Future<RecognizedDocumentText> extractDocumentText(Document document);
}

class PlaceholderPdfTextDocumentParserAdapter
    implements PdfTextDocumentParserAdapter {
  const PlaceholderPdfTextDocumentParserAdapter();

  @override
  Future<PdfDocumentInspection> inspectDocument(String path) async {
    throw UnsupportedError('PDF 텍스트 추출은 아직 연결되지 않았습니다.');
  }

  @override
  Future<RecognizedDocumentText> extractDocumentText(Document document) async {
    throw UnsupportedError('PDF 텍스트 추출은 아직 연결되지 않았습니다.');
  }
}

class PdfTextPluginDocumentParserAdapter
    implements PdfTextDocumentParserAdapter {
  const PdfTextPluginDocumentParserAdapter();

  @override
  Future<PdfDocumentInspection> inspectDocument(String path) async {
    final doc = await _openDocument(path);
    return PdfDocumentInspection(
      pageCount: doc.length,
      title: _cleanTitle(doc.info.title),
    );
  }

  @override
  Future<RecognizedDocumentText> extractDocumentText(Document document) async {
    if (document.originalPath.isEmpty) {
      throw StateError('PDF 경로가 비어 있어요.');
    }

    final doc = await _openDocument(document.originalPath);
    final lines = <RecognizedLineCandidate>[];
    final pageTexts = <String>[];

    for (final page in doc.pages) {
      final pageText = (await page.text).trim();
      if (pageText.isEmpty) {
        continue;
      }
      pageTexts.add(pageText);

      for (final line in pageText.split(RegExp(r'\r?\n'))) {
        final cleanedLine = line.trim();
        if (cleanedLine.isNotEmpty) {
          lines.add(RecognizedLineCandidate(text: cleanedLine));
        }
      }
    }

    return RecognizedDocumentText(
      rawText: pageTexts.join('\n'),
      lines: lines,
      pageCount: doc.length,
      suggestedTitle: _cleanTitle(doc.info.title),
    );
  }

  Future<PDFDoc> _openDocument(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw StateError('선택한 PDF 파일을 찾지 못했어요.');
    }

    try {
      return await PDFDoc.fromPath(path);
    } on MissingPluginException {
      throw UnsupportedError('이 기기에서는 PDF 텍스트 추출을 아직 지원하지 않아요.');
    } on PlatformException catch (error) {
      throw StateError(error.message ?? 'PDF를 읽는 중에 문제가 생겼어요.');
    }
  }

  String? _cleanTitle(String? title) {
    final cleaned = title?.trim();
    if (cleaned == null || cleaned.isEmpty) {
      return null;
    }
    return cleaned;
  }
}

class OcrFallbackPdfDocumentParserAdapter
    implements PdfTextDocumentParserAdapter {
  OcrFallbackPdfDocumentParserAdapter({
    required PdfTextDocumentParserAdapter textAdapter,
    required PdfPageRasterizerAdapter rasterizerAdapter,
    required MlKitDocumentParserAdapter ocrAdapter,
    this.maxOcrPages = 3,
    this.minimumMeaningfulCharacterCount = 10,
  }) : _textAdapter = textAdapter,
       _rasterizerAdapter = rasterizerAdapter,
       _ocrAdapter = ocrAdapter;

  final PdfTextDocumentParserAdapter _textAdapter;
  final PdfPageRasterizerAdapter _rasterizerAdapter;
  final MlKitDocumentParserAdapter _ocrAdapter;
  final int maxOcrPages;
  final int minimumMeaningfulCharacterCount;

  @override
  Future<PdfDocumentInspection> inspectDocument(String path) async {
    try {
      return await _textAdapter.inspectDocument(path);
    } catch (_) {
      final pageCount = await _rasterizerAdapter.getPageCount(path);
      return PdfDocumentInspection(pageCount: pageCount);
    }
  }

  @override
  Future<RecognizedDocumentText> extractDocumentText(Document document) async {
    if (document.preprocessing.requiresRasterizedPdfOcr) {
      return _extractEditedPdfText(document);
    }

    RecognizedDocumentText? textLayerResult;
    PdfDocumentInspection? inspection;

    try {
      textLayerResult = await _textAdapter.extractDocumentText(document);
      inspection = PdfDocumentInspection(
        pageCount: textLayerResult.pageCount ?? document.pages.length,
        title: textLayerResult.suggestedTitle,
      );
      if (_hasMeaningfulText(textLayerResult)) {
        return textLayerResult;
      }
    } catch (_) {
      inspection = await _safeInspect(document.originalPath);
    }

    final ocrResult = await _extractScannedPdfText(
      document: document,
      inspection: inspection,
    );

    if (_hasMeaningfulText(ocrResult)) {
      return ocrResult;
    }

    if (textLayerResult != null && _hasAnyText(textLayerResult)) {
      return textLayerResult;
    }

    if (_hasAnyText(ocrResult)) {
      return ocrResult;
    }

    throw StateError('PDF에서 읽을 수 있는 문자를 충분히 찾지 못했어요.');
  }

  Future<RecognizedDocumentText> _extractEditedPdfText(Document document) async {
    final inspection = await _safeInspect(document.originalPath);
    final ocrResult = await _extractScannedPdfText(
      document: document,
      inspection: inspection,
    );

    if (_hasMeaningfulText(ocrResult)) {
      return ocrResult.copyWith(
        notices: [
          ...ocrResult.notices,
          AppStrings.current.preprocessingPdfOcrNotice,
        ],
      );
    }

    try {
      final textLayerResult = await _textAdapter.extractDocumentText(document);
      if (_hasAnyText(textLayerResult)) {
        return textLayerResult.copyWith(
          notices: [
            ...textLayerResult.notices,
            AppStrings.current.preprocessingPdfTextFallbackNotice,
          ],
        );
      }
    } catch (_) {
      // Fall through to the OCR result or final error below.
    }

    if (_hasAnyText(ocrResult)) {
      return ocrResult;
    }

    throw StateError('PDF에서 읽을 수 있는 문자를 충분히 찾지 못했어요.');
  }

  Future<RecognizedDocumentText> _extractScannedPdfText({
    required Document document,
    required PdfDocumentInspection? inspection,
  }) async {
    final rasterizedDocument = await _rasterizerAdapter.rasterizeDocument(
      path: document.originalPath,
      maxPages: maxOcrPages,
      preprocessing: document.preprocessing,
    );

    final rawTexts = <String>[];
    final lines = <RecognizedLineCandidate>[];

    for (final page in rasterizedDocument.pages) {
      final recognizedPage = await _ocrAdapter.extractBitmapText(
        bitmapData: page.rgbaBytes,
        width: page.width,
        height: page.height,
        suggestedTitle: inspection?.title ?? document.title,
      );

      final cleanedPageText = recognizedPage.rawText.trim();
      if (cleanedPageText.isNotEmpty) {
        rawTexts.add(cleanedPageText);
      }
      lines.addAll(recognizedPage.lines);
    }

    return RecognizedDocumentText(
      rawText: rawTexts.join('\n'),
      lines: lines,
      pageCount: inspection?.pageCount ?? document.pages.length,
      suggestedTitle: inspection?.title,
      notices: rasterizedDocument.notices,
    );
  }

  Future<PdfDocumentInspection?> _safeInspect(String path) async {
    try {
      return await inspectDocument(path);
    } catch (_) {
      return null;
    }
  }

  bool _hasMeaningfulText(RecognizedDocumentText result) {
    final compactText = result.rawText.replaceAll(RegExp(r'\s+'), '');
    final hasUsefulLine = result.lines.any(
      (line) => line.text.trim().length >= 4,
    );
    return compactText.length >= minimumMeaningfulCharacterCount &&
        hasUsefulLine;
  }

  bool _hasAnyText(RecognizedDocumentText result) {
    return result.rawText.trim().isNotEmpty || result.lines.isNotEmpty;
  }
}
