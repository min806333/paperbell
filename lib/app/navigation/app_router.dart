import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/mock_sample_data.dart';
import '../../core/models/app_enums.dart';
import '../../features/import_flow/domain/document.dart';
import '../../features/import_flow/domain/import_session.dart';
import '../../features/import_flow/presentation/document_review_screen.dart';
import '../../features/import_flow/presentation/extraction_confirm_screen.dart';
import '../../features/reminders/presentation/archive_screen.dart';
import '../../features/reminders/presentation/home_screen.dart';
import '../../features/reminders/presentation/reminder_detail_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import 'app_shell_scaffold.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/archive',
                builder: (context, state) => const ArchiveScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/import/review',
        builder: (context, state) {
          final document = state.extra;
          if (document is! Document) {
            return DocumentReviewScreen(
              document: MockSampleData.buildImportedDocument(
                DocumentSourceType.camera,
              ),
            );
          }

          return DocumentReviewScreen(document: document);
        },
      ),
      GoRoute(
        path: '/import/confirm',
        builder: (context, state) {
          final session = state.extra as ImportSession?;
          return ExtractionConfirmScreen(
            session: session ?? _fallbackSession(),
          );
        },
      ),
      GoRoute(
        path: '/reminders/:id',
        builder: (context, state) {
          return ReminderDetailScreen(reminderId: state.pathParameters['id']!);
        },
      ),
    ],
  );
});

ImportSession _fallbackSession() {
  final document = MockSampleData.buildImportedDocument(
    DocumentSourceType.camera,
  );
  return ImportSession(
    document: document,
    extraction: MockSampleData.extractionForDocument(document),
  );
}
