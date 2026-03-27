class DocumentPreprocessing {
  const DocumentPreprocessing({
    this.rotationQuarterTurns = 0,
    this.cropInsetRatio = 0,
  });

  static const double maxCropInsetRatio = 0.18;

  final int rotationQuarterTurns;
  final double cropInsetRatio;

  int get normalizedRotationQuarterTurns {
    final remainder = rotationQuarterTurns % 4;
    return remainder < 0 ? remainder + 4 : remainder;
  }

  int get rotationDegrees => normalizedRotationQuarterTurns * 90;

  double get normalizedCropInsetRatio {
    return cropInsetRatio.clamp(0.0, maxCropInsetRatio).toDouble();
  }

  bool get hasEdits {
    return normalizedRotationQuarterTurns != 0 ||
        normalizedCropInsetRatio > 0.001;
  }

  bool get requiresRasterizedPdfOcr => hasEdits;

  DocumentPreprocessing copyWith({
    int? rotationQuarterTurns,
    double? cropInsetRatio,
  }) {
    return DocumentPreprocessing(
      rotationQuarterTurns:
          rotationQuarterTurns ?? this.rotationQuarterTurns,
      cropInsetRatio: cropInsetRatio ?? this.cropInsetRatio,
    );
  }
}
