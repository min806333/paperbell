import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../../../core/models/app_enums.dart';
import '../../domain/document.dart';
import '../document_image_preprocessor.dart';
import '../parsing/recognized_document_text.dart';

abstract interface class MlKitDocumentParserAdapter {
  Future<RecognizedDocumentText> extractDocumentText(Document document);

  Future<RecognizedDocumentText> extractBitmapText({
    required Uint8List bitmapData,
    required int width,
    required int height,
    String? suggestedTitle,
  });
}

class PlaceholderMlKitDocumentParserAdapter
    implements MlKitDocumentParserAdapter {
  const PlaceholderMlKitDocumentParserAdapter();

  @override
  Future<RecognizedDocumentText> extractDocumentText(Document document) async {
    throw UnsupportedError('ML Kit 기반 OCR 파서는 아직 연결되지 않았습니다.');
  }

  @override
  Future<RecognizedDocumentText> extractBitmapText({
    required Uint8List bitmapData,
    required int width,
    required int height,
    String? suggestedTitle,
  }) async {
    throw UnsupportedError('ML Kit 기반 OCR 파서는 아직 연결되지 않았습니다.');
  }
}

class MlKitTextRecognitionDocumentParserAdapter
    implements MlKitDocumentParserAdapter {
  MlKitTextRecognitionDocumentParserAdapter({
    DocumentImagePreprocessor? imagePreprocessor,
  }) : _imagePreprocessor = imagePreprocessor ?? DocumentImagePreprocessor();

  final DocumentImagePreprocessor _imagePreprocessor;

  @override
  Future<RecognizedDocumentText> extractDocumentText(Document document) async {
    if (!_supportsTextRecognition) {
      throw UnsupportedError('이 기기에서는 자동 인식을 아직 지원하지 않아요.');
    }

    if (document.sourceType == DocumentSourceType.pdf) {
      throw UnsupportedError('PDF 문서는 PDF 텍스트 추출 경로를 먼저 사용해요.');
    }

    if (document.originalPath.isEmpty) {
      throw StateError('불러온 문서 경로가 비어 있어요.');
    }

    final preparedInput = await _imagePreprocessor.prepareImageInput(document);
    final file = File(preparedInput.path);
    if (!await file.exists()) {
      throw StateError('원본 문서를 찾지 못했어요.');
    }

    final recognized = await _extractFromInputImage(
      InputImage.fromFilePath(file.path),
      suggestedTitle: document.title,
    );

    if (preparedInput.warningMessage == null) {
      return recognized;
    }

    return recognized.copyWith(
      notices: [...recognized.notices, preparedInput.warningMessage!],
    );
  }

  @override
  Future<RecognizedDocumentText> extractBitmapText({
    required Uint8List bitmapData,
    required int width,
    required int height,
    String? suggestedTitle,
  }) {
    if (!_supportsTextRecognition) {
      throw UnsupportedError('이 기기에서는 자동 인식을 아직 지원하지 않아요.');
    }

    return _extractFromInputImage(
      InputImage.fromBitmap(bitmap: bitmapData, width: width, height: height),
      suggestedTitle: suggestedTitle,
    );
  }

  bool get _supportsTextRecognition {
    if (kIsWeb) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  TextRecognitionScript get _preferredScript {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return TextRecognitionScript.korean;
    }

    return TextRecognitionScript.latin;
  }

  Future<RecognizedDocumentText> _extractFromInputImage(
    InputImage inputImage, {
    String? suggestedTitle,
  }) async {
    final recognizer = TextRecognizer(script: _preferredScript);
    try {
      final recognizedText = await recognizer.processImage(inputImage);
      final lines = [
        for (final block in recognizedText.blocks)
          for (final line in block.lines)
            RecognizedLineCandidate(
              text: line.text,
              confidence: line.confidence,
            ),
      ];

      return RecognizedDocumentText(
        rawText: recognizedText.text,
        lines: lines,
        suggestedTitle: suggestedTitle,
      );
    } finally {
      await recognizer.close();
    }
  }
}
