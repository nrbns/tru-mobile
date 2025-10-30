import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/yoga_service.dart';

final yogaServiceProvider = Provider((ref) => YogaService());

final yogaSessionsProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>((ref, params) async {
  final service = ref.watch(yogaServiceProvider);
  return service.getYogaSessions(
    level: params['level'] as String?,
    focus: params['focus'] as String?,
    limit: params['limit'] as int? ?? 20,
  );
});
