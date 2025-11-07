import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Calendar Service for managing user schedule and availability
class CalendarService {
  /// Get today's schedule
  Future<List<CalendarEvent>> getTodaySchedule(String userId) async {
    // Mock data - in production, this would fetch from calendar API
    return [
      CalendarEvent(
        id: '1',
        title: 'Team Meeting',
        start: DateTime.now().add(const Duration(hours: 2)),
        end: DateTime.now().add(const Duration(hours: 3)),
      ),
      CalendarEvent(
        id: '2',
        title: 'Lunch Break',
        start: DateTime.now().add(const Duration(hours: 5)),
        end: DateTime.now().add(const Duration(hours: 6)),
      ),
    ];
  }

  /// Check availability for time slot
  Future<bool> isAvailable(String userId, DateTime start, DateTime end) async {
    final events = await getTodaySchedule(userId);

    for (final event in events) {
      if (start.isBefore(event.end) && end.isAfter(event.start)) {
        return false;
      }
    }

    return true;
  }

  /// Get available time slots
  Future<List<TimeSlot>> getAvailableTimeSlots(
      String userId, int duration) async {
    final events = await getTodaySchedule(userId);
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59);

    final slots = <TimeSlot>[];
    DateTime current = now;

    // Sort events by start time
    events.sort((a, b) => a.start.compareTo(b.start));

    for (final event in events) {
      if (current.isBefore(event.start)) {
        final availableDuration = event.start.difference(current).inMinutes;
        if (availableDuration >= duration) {
          slots.add(TimeSlot(
            start: current,
            end: event.start,
            duration: availableDuration,
          ));
        }
      }
      current = event.end;
    }

    // Check time after last event
    if (current.isBefore(endOfDay)) {
      final availableDuration = endOfDay.difference(current).inMinutes;
      if (availableDuration >= duration) {
        slots.add(TimeSlot(
          start: current,
          end: endOfDay,
          duration: availableDuration,
        ));
      }
    }

    return slots;
  }

  /// Schedule wellness activity
  Future<bool> scheduleActivity(
      String userId, WellnessActivity activity) async {
    // Check if time slot is available
    final isAvailable =
        await this.isAvailable(userId, activity.start, activity.end);

    if (!isAvailable) {
      return false;
    }

    // In production, this would add to calendar
    print(
        'Scheduled ${activity.title} from ${activity.start} to ${activity.end}');
    return true;
  }

  /// Reschedule activity
  Future<bool> rescheduleActivity(String userId, String activityId,
      DateTime newStart, DateTime newEnd) async {
    // Check if new time slot is available
    final isAvailable = await this.isAvailable(userId, newStart, newEnd);

    if (!isAvailable) {
      return false;
    }

    // In production, this would update calendar
    print('Rescheduled activity $activityId to $newStart - $newEnd');
    return true;
  }

  /// Cancel activity
  Future<void> cancelActivity(String userId, String activityId) async {
    // In production, this would remove from calendar
    print('Cancelled activity $activityId');
  }

  /// Get weekly overview
  Future<WeeklyOverview> getWeeklyOverview(String userId) async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return WeeklyOverview(
      weekStart: weekStart,
      totalEvents: 15,
      wellnessActivities: 8,
      busyDays: ['Monday', 'Wednesday', 'Friday'],
      freeDays: ['Tuesday', 'Thursday'],
      averageAvailability: 0.7,
    );
  }

  /// Get optimal workout times
  Future<List<OptimalTime>> getOptimalWorkoutTimes(String userId) async {
    // Analyze user's schedule patterns to suggest optimal workout times
    // final overview = await getWeeklyOverview(userId); // TODO: Use this data
    final now = DateTime.now();

    return [
      OptimalTime(
        timeOfDay: 'morning',
        startTime: DateTime(now.year, now.month, now.day, 7, 0),
        endTime: DateTime(now.year, now.month, now.day, 8, 0),
        confidence: 0.9,
        reason: 'Consistent free time in morning',
      ),
      OptimalTime(
        timeOfDay: 'evening',
        startTime: DateTime(now.year, now.month, now.day, 18, 0),
        endTime: DateTime(now.year, now.month, now.day, 19, 0),
        confidence: 0.7,
        reason: 'Usually available after work',
      ),
    ];
  }

  /// Set recurring wellness activities
  Future<void> setRecurringActivity(
      String userId, RecurringActivity activity) async {
    // In production, this would set up recurring calendar events
    print('Set recurring ${activity.title} every ${activity.frequency}');
  }

  /// Get calendar integration status
  Future<CalendarIntegration> getIntegrationStatus(String userId) async {
    return CalendarIntegration(
      isConnected: true,
      provider: 'Google Calendar',
      lastSync: DateTime.now().subtract(const Duration(minutes: 5)),
      permissions: ['read', 'write'],
    );
  }

  /// Sync with calendar
  Future<void> syncCalendar(String userId) async {
    // In production, this would sync with external calendar
    print('Calendar synced for user: $userId');
  }
}

// Data Models
class CalendarEvent {
  CalendarEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    this.description,
    this.location,
  });
  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final String? description;
  final String? location;

  Duration get duration => end.difference(start);
}

class TimeSlot {
  // in minutes

  TimeSlot({
    required this.start,
    required this.end,
    required this.duration,
  });
  final DateTime start;
  final DateTime end;
  final int duration;
}

class WellnessActivity {
  WellnessActivity({
    required this.id,
    required this.title,
    required this.type,
    required this.start,
    required this.end,
    this.description,
    this.metadata,
  });
  final String id;
  final String title;
  final String type; // workout, meditation, meal, etc.
  final DateTime start;
  final DateTime end;
  final String? description;
  final Map<String, dynamic>? metadata;
}

class WeeklyOverview {
  WeeklyOverview({
    required this.weekStart,
    required this.totalEvents,
    required this.wellnessActivities,
    required this.busyDays,
    required this.freeDays,
    required this.averageAvailability,
  });
  final DateTime weekStart;
  final int totalEvents;
  final int wellnessActivities;
  final List<String> busyDays;
  final List<String> freeDays;
  final double averageAvailability;
}

class OptimalTime {
  OptimalTime({
    required this.timeOfDay,
    required this.startTime,
    required this.endTime,
    required this.confidence,
    required this.reason,
  });
  final String timeOfDay;
  final DateTime startTime;
  final DateTime endTime;
  final double confidence; // 0.0 to 1.0
  final String reason;
}

class RecurringActivity {
  RecurringActivity({
    required this.id,
    required this.title,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.frequency,
    required this.daysOfWeek,
    this.metadata,
  });
  final String id;
  final String title;
  final String type;
  final DateTime startTime;
  final DateTime endTime;
  final String frequency; // daily, weekly, etc.
  final List<String> daysOfWeek;
  final Map<String, dynamic>? metadata;
}

class CalendarIntegration {
  CalendarIntegration({
    required this.isConnected,
    required this.provider,
    required this.lastSync,
    required this.permissions,
  });
  final bool isConnected;
  final String provider;
  final DateTime lastSync;
  final List<String> permissions;
}

// Provider
final calendarServiceProvider = Provider<CalendarService>((ref) {
  return CalendarService();
});
