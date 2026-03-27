import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:life_admin_assistant/core/models/app_enums.dart';
import 'package:life_admin_assistant/features/import_flow/data/document_image_preprocessor.dart';
import 'package:life_admin_assistant/features/import_flow/domain/document.dart';
import 'package:life_admin_assistant/features/import_flow/domain/document_page.dart';
import 'package:life_admin_assistant/features/import_flow/domain/document_preprocessing.dart';

void main() {
  late Directory tempDirectory;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'life-admin-image-preprocessor-test',
    );
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('creates a transformed temp image when review edits exist', () async {
    final originalPath = '${tempDirectory.path}/source.png';
    final sourceImage = img.Image(width: 120, height: 80);
    img.fill(sourceImage, color: img.ColorRgb8(255, 255, 255));
    await File(originalPath).writeAsBytes(img.encodePng(sourceImage));

    final preprocessor = DocumentImagePreprocessor(
      temporaryDirectoryProvider: () async => tempDirectory,
    );
    final document = _buildDocument(
      path: originalPath,
      preprocessing: const DocumentPreprocessing(
        rotationQuarterTurns: 1,
        cropInsetRatio: 0.1,
      ),
    );

    final result = await preprocessor.prepareImageInput(document);

    expect(result.warningMessage, isNull);
    expect(result.path, isNot(originalPath));
    expect(await File(result.path).exists(), isTrue);

    final transformed = img.decodeImage(await File(result.path).readAsBytes())!;
    expect(transformed.width, 64);
    expect(transformed.height, 96);
  });

  test('falls back to original path with a calm warning when source is missing', () async {
    final preprocessor = DocumentImagePreprocessor(
      temporaryDirectoryProvider: () async => tempDirectory,
    );
    final document = _buildDocument(
      path: '${tempDirectory.path}/missing.png',
      preprocessing: const DocumentPreprocessing(rotationQuarterTurns: 1),
    );

    final result = await preprocessor.prepareImageInput(document);

    expect(result.path, document.originalPath);
    expect(result.warningMessage, isNotNull);
  });
}

Document _buildDocument({
  required String path,
  DocumentPreprocessing preprocessing = const DocumentPreprocessing(),
}) {
  return Document(
    id: 'doc-image-1',
    sourceType: DocumentSourceType.photoLibrary,
    title: '테스트 이미지',
    createdAt: DateTime(2026, 3, 27),
    originalPath: path,
    containsSensitive: true,
    preprocessing: preprocessing,
    pages: const [
      DocumentPage(
        id: 'page-1',
        pageNumber: 1,
        previewLabel: '테스트 이미지',
        helperText: '1페이지',
      ),
    ],
  );
}
