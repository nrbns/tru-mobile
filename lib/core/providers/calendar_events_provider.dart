import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/calendar_events_service.dart';
import '../models/calendar_event_model.dart';

/// Provider for CalendarEventsService
final calendarEventsServiceProvider = Provider((ref) => CalendarEventsService());

/// Provider for events in a month
final monthEventsProvider = FutureProvider.family<List<CalendarEventModel>, Map<String, dynamic>>((ref, params) async {
  final service = ref.watch(calendarEventsServiceProvider);
  final year = params['year'] as int;
  final month = params['month'] as int;
  final tradition = params['tradition'] as String?;
  final filterTypes = params['filterTypes'] as List<EventType>?;
  
  final startDate = DateTime(year, month, 1);
  final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
  
  return service.getEventsForDateRange(
    startDate: startDate,
    endDate: endDate,
    filterTypes: filterTypes,
    tradition: tradition,
  );
});

/// StreamProvider for real-time month events
final monthEventsStreamProvider = StreamProvider.family<List<CalendarEventModel>, Map<String, dynamic>>((ref, params) {
  final service = ref.watch(calendarEventsServiceProvider);
  final year = params['year'] as int;
  final month = params['month'] as int;
  final tradition = params['tradition'] as String?;
  
  return service.streamEventsForMonth(
    year: year,
    month: month,
    tradition: tradition,
  );
});

/// Provider for events on a specific date
final dateEventsProvider = FutureProvider.family<List<CalendarEventModel>, DateTime>((ref, date) async {
  final service = ref.watch(calendarEventsServiceProvider);
  return service.getEventsForDate(date);
});

/// Provider for upcoming events
final upcomingEventsProvider = FutureProvider.family<List<CalendarEventModel>, Map<String, dynamic>>((ref, params) async {
  final service = ref.watch(calendarEventsServiceProvider);
  final days = params['days'] as int? ?? 30;
  final filterTypes = params['filterTypes'] as List<EventType>?;
  
  return service.getUpcomingEvents(
    days: days,
    filterTypes: filterTypes,
  );
});

/// Provider for festivals
final festivalsProvider = FutureProvider.family<List<CalendarEventModel>, Map<String, dynamic>>((ref, params) async {
  final service = ref.watch(calendarEventsServiceProvider);
  final tradition = params['tradition'] as String?;
  final startDate = params['startDate'] as DateTime?;
  final endDate = params['endDate'] as DateTime?;
  
  return service.getFestivals(
    tradition: tradition,
    startDate: startDate,
    endDate: endDate,
  );
});

/// Provider for moon phases in a date range
final moonPhasesProvider = Provider.family<List<MoonPhaseData>, Map<String, DateTime>>((ref, params) {
  final service = ref.watch(calendarEventsServiceProvider);
  final startDate = params['start']!;
  final endDate = params['end']!;
  
  return service.getMoonPhases(startDate, endDate);
});

