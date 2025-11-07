// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CalendarEventModel _$CalendarEventModelFromJson(Map<String, dynamic> json) {
  return _CalendarEventModel.fromJson(json);
}

/// @nodoc
mixin _$CalendarEventModel {
  String get id => throw _privateConstructorUsedError;
  EventType get type => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get tradition =>
      throw _privateConstructorUsedError; // e.g., 'Hinduism', 'Buddhism', 'Christianity', 'Universal'
  String? get region =>
      throw _privateConstructorUsedError; // e.g., 'India', 'Global'
  Map<String, dynamic> get metadata =>
      throw _privateConstructorUsedError; // Additional data (nakshatra, tithi, etc.)
  String? get icon => throw _privateConstructorUsedError; // Icon identifier
  bool get isRecurring => throw _privateConstructorUsedError;
  DateTime? get endDate =>
      throw _privateConstructorUsedError; // For multi-day events
  int? get priority => throw _privateConstructorUsedError;

  /// Serializes this CalendarEventModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CalendarEventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CalendarEventModelCopyWith<CalendarEventModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalendarEventModelCopyWith<$Res> {
  factory $CalendarEventModelCopyWith(
          CalendarEventModel value, $Res Function(CalendarEventModel) then) =
      _$CalendarEventModelCopyWithImpl<$Res, CalendarEventModel>;
  @useResult
  $Res call(
      {String id,
      EventType type,
      DateTime date,
      String title,
      String? description,
      String? tradition,
      String? region,
      Map<String, dynamic> metadata,
      String? icon,
      bool isRecurring,
      DateTime? endDate,
      int? priority});
}

/// @nodoc
class _$CalendarEventModelCopyWithImpl<$Res, $Val extends CalendarEventModel>
    implements $CalendarEventModelCopyWith<$Res> {
  _$CalendarEventModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CalendarEventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? date = null,
    Object? title = null,
    Object? description = freezed,
    Object? tradition = freezed,
    Object? region = freezed,
    Object? metadata = null,
    Object? icon = freezed,
    Object? isRecurring = null,
    Object? endDate = freezed,
    Object? priority = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as EventType,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      tradition: freezed == tradition
          ? _value.tradition
          : tradition // ignore: cast_nullable_to_non_nullable
              as String?,
      region: freezed == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      isRecurring: null == isRecurring
          ? _value.isRecurring
          : isRecurring // ignore: cast_nullable_to_non_nullable
              as bool,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      priority: freezed == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CalendarEventModelImplCopyWith<$Res>
    implements $CalendarEventModelCopyWith<$Res> {
  factory _$$CalendarEventModelImplCopyWith(_$CalendarEventModelImpl value,
          $Res Function(_$CalendarEventModelImpl) then) =
      __$$CalendarEventModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      EventType type,
      DateTime date,
      String title,
      String? description,
      String? tradition,
      String? region,
      Map<String, dynamic> metadata,
      String? icon,
      bool isRecurring,
      DateTime? endDate,
      int? priority});
}

/// @nodoc
class __$$CalendarEventModelImplCopyWithImpl<$Res>
    extends _$CalendarEventModelCopyWithImpl<$Res, _$CalendarEventModelImpl>
    implements _$$CalendarEventModelImplCopyWith<$Res> {
  __$$CalendarEventModelImplCopyWithImpl(_$CalendarEventModelImpl _value,
      $Res Function(_$CalendarEventModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CalendarEventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? date = null,
    Object? title = null,
    Object? description = freezed,
    Object? tradition = freezed,
    Object? region = freezed,
    Object? metadata = null,
    Object? icon = freezed,
    Object? isRecurring = null,
    Object? endDate = freezed,
    Object? priority = freezed,
  }) {
    return _then(_$CalendarEventModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as EventType,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      tradition: freezed == tradition
          ? _value.tradition
          : tradition // ignore: cast_nullable_to_non_nullable
              as String?,
      region: freezed == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      icon: freezed == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      isRecurring: null == isRecurring
          ? _value.isRecurring
          : isRecurring // ignore: cast_nullable_to_non_nullable
              as bool,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      priority: freezed == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CalendarEventModelImpl extends _CalendarEventModel {
  const _$CalendarEventModelImpl(
      {required this.id,
      required this.type,
      required this.date,
      required this.title,
      this.description,
      this.tradition,
      this.region,
      final Map<String, dynamic> metadata = const {},
      this.icon,
      this.isRecurring = false,
      this.endDate,
      this.priority})
      : _metadata = metadata,
        super._();

  factory _$CalendarEventModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalendarEventModelImplFromJson(json);

  @override
  final String id;
  @override
  final EventType type;
  @override
  final DateTime date;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String? tradition;
// e.g., 'Hinduism', 'Buddhism', 'Christianity', 'Universal'
  @override
  final String? region;
// e.g., 'India', 'Global'
  final Map<String, dynamic> _metadata;
// e.g., 'India', 'Global'
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

// Additional data (nakshatra, tithi, etc.)
  @override
  final String? icon;
// Icon identifier
  @override
  @JsonKey()
  final bool isRecurring;
  @override
  final DateTime? endDate;
// For multi-day events
  @override
  final int? priority;

  @override
  String toString() {
    return 'CalendarEventModel(id: $id, type: $type, date: $date, title: $title, description: $description, tradition: $tradition, region: $region, metadata: $metadata, icon: $icon, isRecurring: $isRecurring, endDate: $endDate, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalendarEventModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.tradition, tradition) ||
                other.tradition == tradition) &&
            (identical(other.region, region) || other.region == region) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.isRecurring, isRecurring) ||
                other.isRecurring == isRecurring) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.priority, priority) ||
                other.priority == priority));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      date,
      title,
      description,
      tradition,
      region,
      const DeepCollectionEquality().hash(_metadata),
      icon,
      isRecurring,
      endDate,
      priority);

  /// Create a copy of CalendarEventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CalendarEventModelImplCopyWith<_$CalendarEventModelImpl> get copyWith =>
      __$$CalendarEventModelImplCopyWithImpl<_$CalendarEventModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalendarEventModelImplToJson(
      this,
    );
  }
}

abstract class _CalendarEventModel extends CalendarEventModel {
  const factory _CalendarEventModel(
      {required final String id,
      required final EventType type,
      required final DateTime date,
      required final String title,
      final String? description,
      final String? tradition,
      final String? region,
      final Map<String, dynamic> metadata,
      final String? icon,
      final bool isRecurring,
      final DateTime? endDate,
      final int? priority}) = _$CalendarEventModelImpl;
  const _CalendarEventModel._() : super._();

  factory _CalendarEventModel.fromJson(Map<String, dynamic> json) =
      _$CalendarEventModelImpl.fromJson;

  @override
  String get id;
  @override
  EventType get type;
  @override
  DateTime get date;
  @override
  String get title;
  @override
  String? get description;
  @override
  String?
      get tradition; // e.g., 'Hinduism', 'Buddhism', 'Christianity', 'Universal'
  @override
  String? get region; // e.g., 'India', 'Global'
  @override
  Map<String, dynamic> get metadata; // Additional data (nakshatra, tithi, etc.)
  @override
  String? get icon; // Icon identifier
  @override
  bool get isRecurring;
  @override
  DateTime? get endDate; // For multi-day events
  @override
  int? get priority;

  /// Create a copy of CalendarEventModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CalendarEventModelImplCopyWith<_$CalendarEventModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MoonPhaseData {
  DateTime get date => throw _privateConstructorUsedError;
  MoonPhase get phase => throw _privateConstructorUsedError;
  double get illumination => throw _privateConstructorUsedError; // 0.0 to 1.0
  String get phaseName =>
      throw _privateConstructorUsedError; // e.g., "Full Moon", "New Moon"
  DateTime? get exactTime =>
      throw _privateConstructorUsedError; // Exact time of phase change
  String? get emoji => throw _privateConstructorUsedError;

  /// Create a copy of MoonPhaseData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MoonPhaseDataCopyWith<MoonPhaseData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MoonPhaseDataCopyWith<$Res> {
  factory $MoonPhaseDataCopyWith(
          MoonPhaseData value, $Res Function(MoonPhaseData) then) =
      _$MoonPhaseDataCopyWithImpl<$Res, MoonPhaseData>;
  @useResult
  $Res call(
      {DateTime date,
      MoonPhase phase,
      double illumination,
      String phaseName,
      DateTime? exactTime,
      String? emoji});
}

/// @nodoc
class _$MoonPhaseDataCopyWithImpl<$Res, $Val extends MoonPhaseData>
    implements $MoonPhaseDataCopyWith<$Res> {
  _$MoonPhaseDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MoonPhaseData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? phase = null,
    Object? illumination = null,
    Object? phaseName = null,
    Object? exactTime = freezed,
    Object? emoji = freezed,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as MoonPhase,
      illumination: null == illumination
          ? _value.illumination
          : illumination // ignore: cast_nullable_to_non_nullable
              as double,
      phaseName: null == phaseName
          ? _value.phaseName
          : phaseName // ignore: cast_nullable_to_non_nullable
              as String,
      exactTime: freezed == exactTime
          ? _value.exactTime
          : exactTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      emoji: freezed == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MoonPhaseDataImplCopyWith<$Res>
    implements $MoonPhaseDataCopyWith<$Res> {
  factory _$$MoonPhaseDataImplCopyWith(
          _$MoonPhaseDataImpl value, $Res Function(_$MoonPhaseDataImpl) then) =
      __$$MoonPhaseDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      MoonPhase phase,
      double illumination,
      String phaseName,
      DateTime? exactTime,
      String? emoji});
}

/// @nodoc
class __$$MoonPhaseDataImplCopyWithImpl<$Res>
    extends _$MoonPhaseDataCopyWithImpl<$Res, _$MoonPhaseDataImpl>
    implements _$$MoonPhaseDataImplCopyWith<$Res> {
  __$$MoonPhaseDataImplCopyWithImpl(
      _$MoonPhaseDataImpl _value, $Res Function(_$MoonPhaseDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of MoonPhaseData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? phase = null,
    Object? illumination = null,
    Object? phaseName = null,
    Object? exactTime = freezed,
    Object? emoji = freezed,
  }) {
    return _then(_$MoonPhaseDataImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as MoonPhase,
      illumination: null == illumination
          ? _value.illumination
          : illumination // ignore: cast_nullable_to_non_nullable
              as double,
      phaseName: null == phaseName
          ? _value.phaseName
          : phaseName // ignore: cast_nullable_to_non_nullable
              as String,
      exactTime: freezed == exactTime
          ? _value.exactTime
          : exactTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      emoji: freezed == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$MoonPhaseDataImpl implements _MoonPhaseData {
  const _$MoonPhaseDataImpl(
      {required this.date,
      required this.phase,
      required this.illumination,
      required this.phaseName,
      this.exactTime,
      this.emoji});

  @override
  final DateTime date;
  @override
  final MoonPhase phase;
  @override
  final double illumination;
// 0.0 to 1.0
  @override
  final String phaseName;
// e.g., "Full Moon", "New Moon"
  @override
  final DateTime? exactTime;
// Exact time of phase change
  @override
  final String? emoji;

  @override
  String toString() {
    return 'MoonPhaseData(date: $date, phase: $phase, illumination: $illumination, phaseName: $phaseName, exactTime: $exactTime, emoji: $emoji)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MoonPhaseDataImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.illumination, illumination) ||
                other.illumination == illumination) &&
            (identical(other.phaseName, phaseName) ||
                other.phaseName == phaseName) &&
            (identical(other.exactTime, exactTime) ||
                other.exactTime == exactTime) &&
            (identical(other.emoji, emoji) || other.emoji == emoji));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, date, phase, illumination, phaseName, exactTime, emoji);

  /// Create a copy of MoonPhaseData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MoonPhaseDataImplCopyWith<_$MoonPhaseDataImpl> get copyWith =>
      __$$MoonPhaseDataImplCopyWithImpl<_$MoonPhaseDataImpl>(this, _$identity);
}

abstract class _MoonPhaseData implements MoonPhaseData {
  const factory _MoonPhaseData(
      {required final DateTime date,
      required final MoonPhase phase,
      required final double illumination,
      required final String phaseName,
      final DateTime? exactTime,
      final String? emoji}) = _$MoonPhaseDataImpl;

  @override
  DateTime get date;
  @override
  MoonPhase get phase;
  @override
  double get illumination; // 0.0 to 1.0
  @override
  String get phaseName; // e.g., "Full Moon", "New Moon"
  @override
  DateTime? get exactTime; // Exact time of phase change
  @override
  String? get emoji;

  /// Create a copy of MoonPhaseData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MoonPhaseDataImplCopyWith<_$MoonPhaseDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
