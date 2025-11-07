import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/today_service.dart';
import '../models/today_model.dart';

final todayServiceProvider = Provider<TodayService>((ref) {
  return TodayService();
});

final todayStreamProvider = StreamProvider<TodayModel>((ref) {
  final todayService = ref.watch(todayServiceProvider);
  return todayService.streamToday();
});

final todayProvider = FutureProvider<TodayModel>((ref) async {
  final todayService = ref.watch(todayServiceProvider);
  return await todayService.getToday();
});
