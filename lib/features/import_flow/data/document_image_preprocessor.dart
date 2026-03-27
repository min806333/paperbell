import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../app/localization/app_strings.dart';
import '../domain/document.dart';
import '../domain/document_preprocessing.dart';

class PreparedImageInput {
  const PreparedImageInput({
    required this.path,
    this.warningMessage,
  });

  final String path;
  final String? warningMessage;
}

class TransformedRgbaImage {
  const TransformedRgbaImage({
    required this.width,
    required this.height,
    required this.rgbaBytes,
  });

  final int width;
  final int height;
  final Uint8List rgbaBytes;
}

class DocumentImagePreprocessor {
  DocumentImagePreprocessor({
    Future<Directory> Function()? temporaryDirectoryProvider,
  }) : _temporaryDirectoryProvider =
           temporaryDirectoryProvider ?? getTemporaryDirectory;

  final Future<Directory> Function() _temporaryDirectoryProvider;

  Future<PreparedImageInput> prepareImageInput(Document document) async {
    if (!document.preprocessing.hasEdits ||
        document.originalPath.isEmpty ||
        document.originalPath.startsWith('/mock/')) {
      return PreparedImageInput(path: document.originalPath);
    }

    final file = File(document.originalPath);
    if (!await file.exists()) {
      return PreparedImageInput(
        path: document.originalPath,
        warningMessage: _fallbackWarningMessage,
      );
    }

    try {
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        return PreparedImageInput(
          path: document.originalPath,
          warningMessage: _fallbackWarningMessage,
        );
      }

      final transformed = applyEdits(
        source: decoded,
        preprocessing: document.preprocessing,
      );

      final directory = await _temporaryDirectoryProvider();
      final outputDirectory = Directory(
        p.join(directory.path, 'life-admin-document-preprocessing'),
      );
      if (!await outputDirectory.exists()) {
        await outputDirectory.create(recursive: true);
      }

      final outputPath = p.join(
        outputDirectory.path,
        '${document.id}-${document.preprocessing.normalizedRotationQuarterTurns}-${_cropSuffix(document.preprocessing)}.png',
      );

      await File(outputPath).writeAsBytes(
        img.encodePng(transformed),
        flush: true,
      );

      return PreparedImageInput(path: outputPath);
    } catch (_) {
      return PreparedImageInput(
        path: document.originalPath,
        warningMessage: _fallbackWarningMessage,
      );
    }
  }

  img.Image applyEdits({
    required img.Image source,
    required DocumentPreprocessing preprocessing,
  }) {
    var current = source;

    if (preprocessing.normalizedRotationQuarterTurns != 0) {
      current = img.copyRotate(
        current,
        angle: preprocessing.rotationDegrees.toDouble(),
      );
    }

    final cropInsetRatio = preprocessing.normalizedCropInsetRatio;
    if (cropInsetRatio <= 0) {
      return current;
    }

    final maxInsetX = ((current.width / 2).floor() - 1).clamp(0, current.width);
    final maxInsetY =
        ((current.height / 2).floor() - 1).clamp(0, current.height);
    final insetX = (current.width * cropInsetRatio).round().clamp(0, maxInsetX);
    final insetY =
        (current.height * cropInsetRatio).round().clamp(0, maxInsetY);
    final croppedWidth = current.width - (insetX * 2);
    final croppedHeight = current.height - (insetY * 2);

    if (croppedWidth < 24 || croppedHeight < 24) {
      return current;
    }

    return img.copyCrop(
      current,
      x: insetX,
      y: insetY,
      width: croppedWidth,
      height: croppedHeight,
    );
  }

  TransformedRgbaImage applyRgbaEdits({
    required Uint8List rgbaBytes,
    required int width,
    required int height,
    required DocumentPreprocessing preprocessing,
  }) {
    if (!preprocessing.hasEdits) {
      return TransformedRgbaImage(
        width: width,
        height: height,
        rgbaBytes: rgbaBytes,
      );
    }

    final raster = img.Image.fromBytes(
      width: width,
      height: height,
      bytes: rgbaBytes.buffer,
      numChannels: 4,
      order: img.ChannelOrder.rgba,
    );
    final transformed = applyEdits(source: raster, preprocessing: preprocessing);
    return TransformedRgbaImage(
      width: transformed.width,
      height: transformed.height,
      rgbaBytes: Uint8List.fromList(
        transformed.getBytes(order: img.ChannelOrder.rgba),
      ),
    );
  }

  String _cropSuffix(DocumentPreprocessing preprocessing) {
    return (preprocessing.normalizedCropInsetRatio * 1000).round().toString();
  }

  String get _fallbackWarningMessage =>
      AppStrings.current.preprocessingImageFallbackNotice;
}
