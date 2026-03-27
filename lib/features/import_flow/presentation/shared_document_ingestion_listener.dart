import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/navigation/app_router.dart';
import '../data/document_service_providers.dart';
import '../domain/import_result.dart';

class SharedDocumentIngestionListener extends ConsumerStatefulWidget {
  const SharedDocumentIngestionListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SharedDocumentIngestionListener> createState() =>
      _SharedDocumentIngestionListenerState();
}

class _SharedDocumentIngestionListenerState
    extends ConsumerState<SharedDocumentIngestionListener> {
  StreamSubscription<ImportResult>? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startListening();
    });
  }

  Future<void> _startListening() async {
    final service = ref.read(sharedDocumentImportServiceProvider);
    ImportResult? initialImport;
    try {
      initialImport = await service.loadLatestSharedImportIfAny();
    } catch (_) {
      initialImport = null;
    }
    if (!mounted) {
      return;
    }

    await _handleImportResult(initialImport);
    _subscription = service.watchIncomingImports().listen((result) {
      _handleImportResult(result);
    }, onError: (Object error, StackTrace stackTrace) {});
  }

  Future<void> _handleImportResult(ImportResult? result) async {
    if (!mounted || result == null) {
      return;
    }

    switch (result) {
      case ImportSuccess(:final document):
        await ref
            .read(appRouterProvider)
            .push('/import/review', extra: document);
      case ImportFailure():
        return;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
