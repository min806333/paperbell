import '../../../core/models/app_enums.dart';

class ExtractedField<T> {
  const ExtractedField({
    required this.value,
    required this.state,
    this.rawText,
    this.isAutoSuggested = true,
    this.confidence,
  });

  final T? value;
  final ExtractedFieldState state;
  final String? rawText;
  final bool isAutoSuggested;
  final double? confidence;

  bool get hasValue => value != null;
}
