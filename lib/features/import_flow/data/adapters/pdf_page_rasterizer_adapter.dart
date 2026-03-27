import 'dart:io';
import 'dart:math' as math;

import '../../../../app/localization/app_strings.dart';
import 'package:flutter/services.dart';
import 'package:pdf_render_maintained/pdf_render.dart';

import '../../domain/document_preprocessing.dart';
import '../document_image_preprocessor.dart';

class RasterizedPdfPage {
  const RasterizedPdfPage({
    required this.pageNumber,
    required this.width,
    required this.height,
    required this.rgbaBytes,
  });

  final int pageNumber;
  final int width;
  final int height;
  final Uint8List rgbaBytes;
}

class RasterizedPdfDocument {
  const RasterizedPdfDocument({
    required this.pages,
    this.notices = const [],
  });

  final List<RasterizedPdfPage> pages;
  final List<String> notices;
}

abstract interface class PdfPageRasterizerAdapter {
  Future<int> getPageCount(String path);

  Future<RasterizedPdfDocument> rasterizeDocument({
    required String path,
    int maxPages = 3,
    DocumentPreprocessing preprocessing = const DocumentPreprocessing(),
  });
}

class PlaceholderPdfPageRasterizerAdapter implements PdfPageRasterizerAdapter {
  const PlaceholderPdfPageRasterizerAdapter();

  @override
  Future<int> getPageCount(String path) async {
    throw UnsupportedError('PDF 페이지 이미지는 아직 준비되지 않았습니다.');
  }

  @override
  Future<RasterizedPdfDocument> rasterizeDocument({
    required String path,
    int maxPages = 3,
    DocumentPreprocessing preprocessing = const DocumentPreprocessing(),
  }) async {
    throw UnsupportedError('PDF 페이지 이미지는 아직 준비되지 않았습니다.');
  }
}

class PdfRenderPageRasterizerAdapter implements PdfPageRasterizerAdapter {
  PdfRenderPageRasterizerAdapter({
    this.renderDpi = 180,
    DocumentImagePreprocessor? imagePreprocessor,
  }) : _imagePreprocessor = imagePreprocessor ?? DocumentImagePreprocessor();

  final double renderDpi;
  final DocumentImagePreprocessor _imagePreprocessor;

  @override
  Future<int> getPageCount(String path) async {
    final document = await _openDocument(path);
    try {
      return document.pageCount;
    } finally {
      await document.dispose();
    }
  }

  @override
  Future<RasterizedPdfDocument> rasterizeDocument({
    required String path,
    int maxPages = 3,
    DocumentPreprocessing preprocessing = const DocumentPreprocessing(),
  }) async {
    final document = await _openDocument(path);
    try {
      final pageCount = math.min(document.pageCount, math.max(1, maxPages));
      final pages = <RasterizedPdfPage>[];
      var didFallbackToOriginalRaster = false;

      for (var pageNumber = 1; pageNumber <= pageCount; pageNumber++) {
        final page = await document.getPage(pageNumber);
        final scale = renderDpi / 72.0;
        final renderWidth = (page.width * scale).round();
        final renderHeight = (page.height * scale).round();

        final renderedPage = await page.render(
          width: renderWidth,
          height: renderHeight,
          fullWidth: renderWidth.toDouble(),
          fullHeight: renderHeight.toDouble(),
          backgroundFill: true,
          allowAntialiasingIOS: true,
        );

        try {
          var rasterizedPage = RasterizedPdfPage(
            pageNumber: pageNumber,
            width: renderedPage.width,
            height: renderedPage.height,
            rgbaBytes: Uint8List.fromList(renderedPage.pixels),
          );

          if (preprocessing.hasEdits) {
            try {
              final transformedRaster = _imagePreprocessor.applyRgbaEdits(
                rgbaBytes: rasterizedPage.rgbaBytes,
                width: rasterizedPage.width,
                height: rasterizedPage.height,
                preprocessing: preprocessing,
              );
              rasterizedPage = RasterizedPdfPage(
                pageNumber: pageNumber,
                width: transformedRaster.width,
                height: transformedRaster.height,
                rgbaBytes: transformedRaster.rgbaBytes,
              );
            } catch (_) {
              didFallbackToOriginalRaster = true;
            }
          }

          pages.add(rasterizedPage);
        } finally {
          renderedPage.dispose();
        }
      }

      return RasterizedPdfDocument(
        pages: pages,
        notices: didFallbackToOriginalRaster
            ? [AppStrings.current.preprocessingPdfFallbackNotice]
            : const [],
      );
    } finally {
      await document.dispose();
    }
  }

  Future<PdfDocument> _openDocument(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw StateError('선택한 PDF 파일을 찾지 못했어요.');
    }

    try {
      return await PdfDocument.openFile(path);
    } on MissingPluginException {
      throw UnsupportedError('이 기기에서는 PDF 이미지 변환을 아직 지원하지 않아요.');
    } on PlatformException catch (error) {
      throw StateError(error.message ?? 'PDF 페이지를 준비하는 중에 문제가 생겼어요.');
    }
  }
}
