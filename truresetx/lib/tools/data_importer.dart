// Lightweight data importer: fetch rows from Supabase and write to Hive.
// This is intentionally small and safe: it supports dry-run and single-table
// imports. Extendable to multiple tables and Firestore fallback later.

import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DataImporter {
  final SupabaseClient supabase;
  final Box settingsBox;

  DataImporter({required this.supabase, required this.settingsBox});

  /// List available core tables the importer can handle.
  List<String> availableTables() => [
        'profiles',
        'mood_entries',
        'food_logs',
        'workouts',
        'lists',
      ];

  /// Fetch rows from a Supabase table with simple pagination.
  Future<List<Map<String, dynamic>>> fetchTable(String table, int offset,
      {int limit = 100}) async {
    final res =
        await supabase.from(table).select().range(offset, offset + limit - 1);
    // supabase select returns a List; convert it to List<Map<String, dynamic>>
    return List<Map<String, dynamic>>.from(
        (res as List).map((r) => Map<String, dynamic>.from(r)));
  }

  /// Import a single table into Hive under key `import.<table>`.
  /// If dryRun is true, nothing is persisted; returns the rows that would be written.
  Future<List<Map<String, dynamic>>> importTable(String table,
      {bool dryRun = true, int pageSize = 200}) async {
    if (!availableTables().contains(table)) {
      throw ArgumentError('Unsupported table: $table');
    }

    final List<Map<String, dynamic>> all = [];
    int offset = 0;
    while (true) {
      final page = await fetchTable(table, offset, limit: pageSize);
      if (page.isEmpty) break;
      all.addAll(page);
      offset += page.length;
      if (page.length < pageSize) break; // last page
    }

    if (dryRun) return all;

    final key = 'import.$table';
    // store as JSON-serializable list
    await settingsBox.put(key, jsonEncode(all));
    return all;
  }

  /// Convenience: import many tables sequentially. Returns map table->count.
  Future<Map<String, int>> importMany(List<String> tables,
      {bool dryRun = true}) async {
    final out = <String, int>{};
    for (final t in tables) {
      final rows = await importTable(t, dryRun: dryRun);
      out[t] = rows.length;
    }
    return out;
  }

  /// Read an import back from Hive (if persisted).
  List<dynamic>? readImported(String table) {
    final key = 'import.$table';
    final raw = settingsBox.get(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw as String);
      return decoded as List<dynamic>;
    } catch (_) {
      return null;
    }
  }
}

/// Simple runner used by e.g., a separate import entrypoint. Kept side-effect free
/// so it can be used in unit tests.
Future<DataImporter> createImporter({required Box settingsBox}) async {
  final client = Supabase.instance.client;
  return DataImporter(supabase: client, settingsBox: settingsBox);
}
