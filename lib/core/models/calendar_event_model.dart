import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'calendar_event_model.freezed.dart';
part 'calendar_event_model.g.dart';

enum EventType {
  @JsonValue('festival')
  festival,
  @JsonValue('full_moon')
  fullMoon,
  @JsonValue('new_moon')
  newMoon,
  @JsonValue('first_quarter')
  firstQuarter,
  @JsonValue('last_quarter')
  lastQuarter,
  @JsonValue('eclipse')
  eclipse,
  @JsonValue('solstice')
  solstice,
  @JsonValue('equinox')
  equinox,
  @JsonValue('meteor_shower')
  meteorShower,
  @JsonValue('astrological_transit')
  astrologicalTransit,
  @JsonValue('nakshatra')
  nakshatra,
  @JsonValue('tithi')
  tithi,
  @JsonValue('rahu_kalam')
  rahuKalam,
  @JsonValue('abhijit_muhurat')
  abhijitMuhurat,
}

enum MoonPhase {
  @JsonValue('new_moon')
  newMoon,
  @JsonValue('waxing_crescent')
  waxingCrescent,
  @JsonValue('first_quarter')
  firstQuarter,
  @JsonValue('waxing_gibbous')
  waxingGibbous,
  @JsonValue('full_moon')
  fullMoon,
  @JsonValue('waning_gibbous')
  waningGibbous,
  @JsonValue('last_quarter')
  lastQuarter,
  @JsonValue('waning_crescent')
  waningCrescent,
}

@freezed
class CalendarEventModel with _$CalendarEventModel {
  // Private constructor to allow adding instance methods (toFirestore)
  const CalendarEventModel._();
  const factory CalendarEventModel({
    required String id,
    required EventType type,
    required DateTime date,
    required String title,
    String? description,
    String?
        tradition, // e.g., 'Hinduism', 'Buddhism', 'Christianity', 'Universal'
    String? region, // e.g., 'India', 'Global'
    @Default({})
    Map<String, dynamic> metadata, // Additional data (nakshatra, tithi, etc.)
    String? icon, // Icon identifier
    @Default(false) bool isRecurring,
    DateTime? endDate, // For multi-day events
    int? priority, // For sorting/display
  }) = _CalendarEventModel;

  factory CalendarEventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CalendarEventModel.fromJson({
      'id': doc.id,
      ...data,
      'date': (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      'endDate': (data['endDate'] as Timestamp?)?.toDate(),
      'type': _stringToEventType(data['type'] as String? ?? 'festival'),
    });
  }

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventModelFromJson(json);

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    if (json['date'] is DateTime) {
      json['date'] = Timestamp.fromDate(json['date'] as DateTime);
    }
    if (json['endDate'] is DateTime?) {
      json['endDate'] = json['endDate'] != null
          ? Timestamp.fromDate(json['endDate'] as DateTime)
          : null;
    }
    json['type'] = _eventTypeToString(type);
    return json;
  }

  static EventType _stringToEventType(String str) {
    switch (str.toLowerCase()) {
      case 'fullmoon':
      case 'full_moon':
        return EventType.fullMoon;
      case 'newmoon':
      case 'new_moon':
        return EventType.newMoon;
      case 'firstquarter':
      case 'first_quarter':
        return EventType.firstQuarter;
      case 'lastquarter':
      case 'last_quarter':
        return EventType.lastQuarter;
      case 'eclipse':
        return EventType.eclipse;
      case 'solstice':
        return EventType.solstice;
      case 'equinox':
        return EventType.equinox;
      case 'meteorshower':
      case 'meteor_shower':
        return EventType.meteorShower;
      case 'astrologicaltransit':
      case 'astrological_transit':
        return EventType.astrologicalTransit;
      case 'nakshatra':
        return EventType.nakshatra;
      case 'tithi':
        return EventType.tithi;
      case 'rahukalam':
      case 'rahu_kalam':
        return EventType.rahuKalam;
      case 'abhijitmuhurat':
      case 'abhijit_muhurat':
        return EventType.abhijitMuhurat;
      default:
        return EventType.festival;
    }
  }

  static String _eventTypeToString(EventType type) {
    switch (type) {
      case EventType.fullMoon:
        return 'full_moon';
      case EventType.newMoon:
        return 'new_moon';
      case EventType.firstQuarter:
        return 'first_quarter';
      case EventType.lastQuarter:
        return 'last_quarter';
      case EventType.eclipse:
        return 'eclipse';
      case EventType.solstice:
        return 'solstice';
      case EventType.equinox:
        return 'equinox';
      case EventType.meteorShower:
        return 'meteor_shower';
      case EventType.astrologicalTransit:
        return 'astrological_transit';
      case EventType.nakshatra:
        return 'nakshatra';
      case EventType.tithi:
        return 'tithi';
      case EventType.rahuKalam:
        return 'rahu_kalam';
      case EventType.abhijitMuhurat:
        return 'abhijit_muhurat';
      default:
        return 'festival';
    }
  }
}

/// Moon phase data for a specific date
@freezed
class MoonPhaseData with _$MoonPhaseData {
  const factory MoonPhaseData({
    required DateTime date,
    required MoonPhase phase,
    required double illumination, // 0.0 to 1.0
    required String phaseName, // e.g., "Full Moon", "New Moon"
    DateTime? exactTime, // Exact time of phase change
    String? emoji, // Moon phase emoji
  }) = _MoonPhaseData;
}
