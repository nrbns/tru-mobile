import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/calendar_event_model.dart';

/// Service for calendar events: festivals, moon phases, astrology, astronomical events
class CalendarEventsService {
  // Some platforms or future features may access Firestore indirectly;
  // keep the instance available. Suppress unused-field analyzer noise until
  // the service expands.
  // ignore: unused_field
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _eventsRef =>
      _firestore.collection('calendar_events');

  /// Get moon phase for a given date
  /// Uses Meeus algorithm for accurate moon phase calculation
  static MoonPhaseData getMoonPhase(DateTime date) {
    // Julian Day Number
    final jd = _toJulianDate(date);

    // Days since last new moon (Jan 6, 2000 18:14 UTC)
    final daysSinceNewMoon = (jd - 2451549.5) % 29.530588853;

    // Calculate moon age
    final moonAge = daysSinceNewMoon;

    // Determine phase
    MoonPhase phase;
    String phaseName;
    String emoji;
    double illumination;

    if (moonAge < 1.84566) {
      phase = MoonPhase.newMoon;
      phaseName = "New Moon";
      emoji = "🌑";
      illumination = 0.0;
    } else if (moonAge < 5.53699) {
      phase = MoonPhase.waxingCrescent;
      phaseName = "Waxing Crescent";
      emoji = "🌒";
      illumination = moonAge / 7.38;
    } else if (moonAge < 9.22831) {
      phase = MoonPhase.firstQuarter;
      phaseName = "First Quarter";
      emoji = "🌓";
      illumination = 0.5;
    } else if (moonAge < 12.91963) {
      phase = MoonPhase.waxingGibbous;
      phaseName = "Waxing Gibbous";
      emoji = "🌔";
      illumination = 0.5 + (moonAge - 9.23) / 7.38;
    } else if (moonAge < 16.61096) {
      phase = MoonPhase.fullMoon;
      phaseName = "Full Moon";
      emoji = "🌕";
      illumination = 1.0;
    } else if (moonAge < 20.30228) {
      phase = MoonPhase.waningGibbous;
      phaseName = "Waning Gibbous";
      emoji = "🌖";
      illumination = 1.0 - (moonAge - 16.61) / 7.38;
    } else if (moonAge < 23.99361) {
      phase = MoonPhase.lastQuarter;
      phaseName = "Last Quarter";
      emoji = "🌗";
      illumination = 0.5;
    } else {
      phase = MoonPhase.waningCrescent;
      phaseName = "Waning Crescent";
      emoji = "🌘";
      illumination = (29.53 - moonAge) / 7.38;
    }

    // Clamp illumination
    illumination = illumination.clamp(0.0, 1.0);

    return MoonPhaseData(
      date: date,
      phase: phase,
      illumination: illumination,
      phaseName: phaseName,
      emoji: emoji,
    );
  }

  /// Convert DateTime to Julian Date
  static double _toJulianDate(DateTime date) {
    final year = date.year;
    final month = date.month;
    final day = date.day +
        (date.hour + date.minute / 60.0 + date.second / 3600.0) / 24.0;

    if (month <= 2) {
      final adjustedYear = year - 1;
      final adjustedMonth = month + 12;
      return (365.25 * (adjustedYear + 4716)).floorToDouble() +
          (30.6001 * (adjustedMonth + 1)).floorToDouble() +
          day -
          1524.5;
    }

    return (365.25 * (year + 4716)).floorToDouble() +
        (30.6001 * (month + 1)).floorToDouble() +
        day -
        1524.5;
  }

  /// Get events for a date range
  Future<List<CalendarEventModel>> getEventsForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    List<EventType>? filterTypes,
    String? tradition,
    String? region,
  }) async {
    try {
      Query query = _eventsRef
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      if (tradition != null) {
        query = query.where('tradition', isEqualTo: tradition);
      }

      if (region != null) {
        query = query.where('region', isEqualTo: region);
      }

      final snapshot = await query.get();
      var events = snapshot.docs
          .map((doc) => CalendarEventModel.fromFirestore(doc))
          .toList();

      // Filter by type if specified
      if (filterTypes != null && filterTypes.isNotEmpty) {
        events = events.where((e) => filterTypes.contains(e.type)).toList();
      }

      // Add moon phase events
      final moonEvents = _generateMoonPhaseEvents(startDate, endDate);
      events.addAll(moonEvents);

      // Sort by date and priority
      events.sort((a, b) {
        final dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;
        return (b.priority ?? 0).compareTo(a.priority ?? 0);
      });

      return events;
    } catch (e) {
      print('Error fetching calendar events: $e');
      // Return at least moon phase events
      return _generateMoonPhaseEvents(startDate, endDate);
    }
  }

  /// Generate moon phase events for a date range
  List<CalendarEventModel> _generateMoonPhaseEvents(
    DateTime startDate,
    DateTime endDate,
  ) {
    final events = <CalendarEventModel>[];
    final currentDate =
        DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    MoonPhase? previousPhase;
    DateTime? previousDate;

    var date = currentDate;
    while (date.isBefore(end) || date.isAtSameMomentAs(end)) {
      final moonData = getMoonPhase(date);

      // Only create events for phase transitions (new, first quarter, full, last quarter)
      if (moonData.phase == MoonPhase.newMoon ||
          moonData.phase == MoonPhase.firstQuarter ||
          moonData.phase == MoonPhase.fullMoon ||
          moonData.phase == MoonPhase.lastQuarter) {
        if (previousPhase != moonData.phase || previousDate == null) {
          events.add(CalendarEventModel(
            id: 'moon_${date.millisecondsSinceEpoch}',
            type: _moonPhaseToEventType(moonData.phase),
            date: date,
            title: moonData.phaseName,
            description:
                'Moon illumination: ${(moonData.illumination * 100).toStringAsFixed(0)}%',
            tradition: 'Universal',
            region: 'Global',
            metadata: {
              'illumination': moonData.illumination,
              'emoji': moonData.emoji,
              'phase': moonData.phase.name,
            },
            icon: moonData.emoji,
            priority: moonData.phase == MoonPhase.fullMoon ? 10 : 5,
          ));
        }

        previousPhase = moonData.phase;
        previousDate = date;
      }

      date = date.add(const Duration(days: 1));
    }

    return events;
  }

  EventType _moonPhaseToEventType(MoonPhase phase) {
    switch (phase) {
      case MoonPhase.newMoon:
        return EventType.newMoon;
      case MoonPhase.firstQuarter:
        return EventType.firstQuarter;
      case MoonPhase.fullMoon:
        return EventType.fullMoon;
      case MoonPhase.lastQuarter:
        return EventType.lastQuarter;
      default:
        return EventType.festival;
    }
  }

  /// Get events for a specific date
  Future<List<CalendarEventModel>> getEventsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(
          const Duration(seconds: 1),
        );

    return getEventsForDateRange(
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  /// Stream events for a month
  Stream<List<CalendarEventModel>> streamEventsForMonth({
    required int year,
    required int month,
    List<EventType>? filterTypes,
    String? tradition,
  }) {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    return _eventsRef
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .snapshots()
        .map((snapshot) {
      var events = snapshot.docs
          .map((doc) => CalendarEventModel.fromFirestore(doc))
          .toList();

      if (tradition != null) {
        events = events.where((e) => e.tradition == tradition).toList();
      }

      if (filterTypes != null && filterTypes.isNotEmpty) {
        events = events.where((e) => filterTypes.contains(e.type)).toList();
      }

      // Add moon phase events (non-streamable, so we do it once)
      final moonEvents = _generateMoonPhaseEvents(startDate, endDate);
      events.addAll(moonEvents);

      events.sort((a, b) {
        final dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;
        return (b.priority ?? 0).compareTo(a.priority ?? 0);
      });

      return events;
    });
  }

  /// Get upcoming events (next N days)
  Future<List<CalendarEventModel>> getUpcomingEvents({
    int days = 30,
    List<EventType>? filterTypes,
  }) async {
    final startDate = DateTime.now();
    final endDate = startDate.add(Duration(days: days));

    return getEventsForDateRange(
      startDate: startDate,
      endDate: endDate,
      filterTypes: filterTypes,
    );
  }

  /// Get festivals for a specific tradition
  Future<List<CalendarEventModel>> getFestivals({
    String? tradition,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final start = startDate ?? DateTime.now();
    final end = endDate ?? start.add(const Duration(days: 365));

    return getEventsForDateRange(
      startDate: start,
      endDate: end,
      filterTypes: [EventType.festival],
      tradition: tradition,
    );
  }

  /// Get moon phases for a date range
  List<MoonPhaseData> getMoonPhases(DateTime startDate, DateTime endDate) {
    final phases = <MoonPhaseData>[];
    var date = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    while (date.isBefore(end) || date.isAtSameMomentAs(end)) {
      phases.add(getMoonPhase(date));
      date = date.add(const Duration(days: 1));
    }

    return phases;
  }
}
