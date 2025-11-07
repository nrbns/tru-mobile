// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CalendarEventModelImpl _$$CalendarEventModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CalendarEventModelImpl(
      id: json['id'] as String,
      type: $enumDecode(_$EventTypeEnumMap, json['type']),
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      tradition: json['tradition'] as String?,
      region: json['region'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      icon: json['icon'] as String?,
      isRecurring: json['isRecurring'] as bool? ?? false,
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      priority: (json['priority'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CalendarEventModelImplToJson(
        _$CalendarEventModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$EventTypeEnumMap[instance.type]!,
      'date': instance.date.toIso8601String(),
      'title': instance.title,
      'description': instance.description,
      'tradition': instance.tradition,
      'region': instance.region,
      'metadata': instance.metadata,
      'icon': instance.icon,
      'isRecurring': instance.isRecurring,
      'endDate': instance.endDate?.toIso8601String(),
      'priority': instance.priority,
    };

const _$EventTypeEnumMap = {
  EventType.festival: 'festival',
  EventType.fullMoon: 'full_moon',
  EventType.newMoon: 'new_moon',
  EventType.firstQuarter: 'first_quarter',
  EventType.lastQuarter: 'last_quarter',
  EventType.eclipse: 'eclipse',
  EventType.solstice: 'solstice',
  EventType.equinox: 'equinox',
  EventType.meteorShower: 'meteor_shower',
  EventType.astrologicalTransit: 'astrological_transit',
  EventType.nakshatra: 'nakshatra',
  EventType.tithi: 'tithi',
  EventType.rahuKalam: 'rahu_kalam',
  EventType.abhijitMuhurat: 'abhijit_muhurat',
};
