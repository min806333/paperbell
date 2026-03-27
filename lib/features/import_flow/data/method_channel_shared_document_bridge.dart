import 'package:flutter/services.dart';

import 'shared_document_import_service.dart';

class MethodChannelSharedDocumentBridge
    implements SharedDocumentPlatformBridge {
  MethodChannelSharedDocumentBridge({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  }) : _methodChannel =
           methodChannel ??
           const MethodChannel('life_admin_assistant/share_intent'),
       _eventChannel =
           eventChannel ??
           const EventChannel('life_admin_assistant/share_intent_events');

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  @override
  Future<List<SharedDocumentPayload>> getLatestSharedDocuments() async {
    try {
      final response = await _methodChannel.invokeMethod<List<dynamic>>(
        'getLatestSharedMedia',
      );
      return _parsePayloads(response);
    } on PlatformException {
      return const [];
    } on MissingPluginException {
      return const [];
    }
  }

  @override
  Future<void> markLatestSharedDocumentsHandled() async {
    try {
      await _methodChannel.invokeMethod<void>('markLatestSharedMediaHandled');
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }

  @override
  Stream<List<SharedDocumentPayload>> watchIncomingSharedDocuments() {
    return _eventChannel
        .receiveBroadcastStream()
        .handleError((Object error, StackTrace stackTrace) {})
        .map((event) => _parsePayloads(event is List<dynamic> ? event : null));
  }

  List<SharedDocumentPayload> _parsePayloads(List<dynamic>? rawPayloads) {
    if (rawPayloads == null) {
      return const [];
    }

    return [
      for (final rawPayload in rawPayloads)
        if (rawPayload is Map)
          SharedDocumentPayload(
            path: rawPayload['path'] as String? ?? '',
            mimeType: rawPayload['mimeType'] as String?,
            fileName: rawPayload['fileName'] as String?,
          ),
    ];
  }
}
