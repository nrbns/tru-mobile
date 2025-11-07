// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/config/env_runtime.dart';
import 'core/config/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tools/data_importer.dart';

/// Lightweight import runner. Run with `flutter run -t lib/main_import.dart`.
/// By default this performs a dry-run (no writes). To persist results set the
/// Hive key `import.persist` to true in the `settings` box before running.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvRuntime.init();
  await Hive.initFlutter();
  final settings = await Hive.openBox('settings');

  // initialize Supabase using same Environment helpers as the app
  await Supabase.initialize(
    url: Environment.supabaseUrl,
    anonKey: Environment.supabaseAnonKey,
  );

  final importer = await createImporter(settingsBox: settings);

  final persist = settings.get('import.persist', defaultValue: false) as bool;
  final tables = importer.availableTables();

  debugPrint('Importer: tables=${tables.join(', ')} dryRun=${!persist}');

  final result = await importer.importMany(tables, dryRun: !persist);

  debugPrint('Import results:');
  for (final e in result.entries) {
    debugPrint(' - ${e.key}: ${e.value} rows');
  }

  // close and exit
  await settings.close();
  // allow process to finish
  Future.delayed(
      const Duration(milliseconds: 200), () => debugPrint('Importer finished'));
}
