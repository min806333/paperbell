import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_admin_assistant/app/app.dart';

void main() {
  testWidgets(
    'first launch asks for language, shows privacy notice, then opens app shell',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: LifeAdminAssistantApp()),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('English'), findsOneWidget);

      await tester.tap(find.textContaining('English'));
      await tester.pumpAndSettle();

      expect(find.text('Privacy and data notice'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Archive'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    },
  );
}
