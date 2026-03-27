import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/bootstrap/app_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR');
  await initializeDateFormatting('en_US');
  final overrides = await createAppOverrides();

  runApp(
    ProviderScope(overrides: overrides, child: const LifeAdminAssistantApp()),
  );
}
