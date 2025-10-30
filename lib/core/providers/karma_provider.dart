import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/karma_log_service.dart';

final karmaLogServiceProvider = Provider((ref) => KarmaLogService());

final karmaLogsStreamProvider = StreamProvider.family<List<Map<String, dynamic>>, int>((ref, limit) {
  final service = ref.watch(karmaLogServiceProvider);
  return service.streamLogs(limit: limit);
});
