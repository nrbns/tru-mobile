import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/affirmations_healing_service.dart';
import '../models/affirmation.dart';

final affirmationsServiceProvider =
    Provider((ref) => AffirmationsHealingService());

final affirmationsStreamProvider =
    StreamProvider.family<List<Affirmation>, Map<String, String?>>(
        (ref, params) {
  final service = ref.watch(affirmationsServiceProvider);
  return service.streamAffirmations(
    category: params['category'],
    type: params['type'],
  );
});
