import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gratitude_journal_service.dart';
import '../models/gratitude_journal_entry.dart';

final gratitudeJournalServiceProvider =
    Provider((ref) => GratitudeJournalService());

final gratitudeEntriesStreamProvider =
    StreamProvider.family<List<GratitudeJournalEntry>, int>((ref, limit) {
  final service = ref.watch(gratitudeJournalServiceProvider);
  return service.streamEntries(limit: limit);
});
