import 'document.dart';

sealed class ImportResult {
  const ImportResult();
}

class ImportSuccess extends ImportResult {
  const ImportSuccess(this.document);

  final Document document;
}

class ImportFailure extends ImportResult {
  const ImportFailure({
    required this.message,
    this.permissionDenied = false,
    this.cancelled = false,
  });

  final String message;
  final bool permissionDenied;
  final bool cancelled;
}
