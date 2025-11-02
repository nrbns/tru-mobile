import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/faith_ai_chat_service.dart';

final faithAIChatServiceProvider = Provider((ref) => FaithAIChatService());

final faithAIChatResponseProvider =
    FutureProvider.family<String, Map<String, String?>>((ref, params) async {
  final service = ref.watch(faithAIChatServiceProvider);
  return service.chat(
      message: params['message'] ?? '', tradition: params['tradition']);
});
