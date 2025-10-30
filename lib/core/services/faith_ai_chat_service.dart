import 'package:cloud_functions/cloud_functions.dart';

class FaithAIChatService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<String> chat({required String message, String? tradition}) async {
    final callable = _functions.httpsCallable('faithAIChat');
    final res = await callable.call({
      'message': message,
      'tradition': tradition,
    });
    final data = res.data as Map;
    return data['content'] as String? ?? '';
  }
}
