import 'package:cloud_functions/cloud_functions.dart';

class SpiritualFeedService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<Map<String, dynamic>> getDailyFeed() async {
    final callable = _functions.httpsCallable('generateDailySpiritualFeed');
    final res = await callable.call();
    return Map<String, dynamic>.from(res.data as Map);
  }
}
