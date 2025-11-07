// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wisdom_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WisdomModel _$WisdomModelFromJson(Map<String, dynamic> json) {
  return _WisdomModel.fromJson(json);
}

/// @nodoc
mixin _$WisdomModel {
  String get id => throw _privateConstructorUsedError;
  String get source =>
      throw _privateConstructorUsedError; // Thirukkural, Gita, Rumi, etc.
  String get category =>
      throw _privateConstructorUsedError; // Patience, Love, Discipline, etc.
  String? get language =>
      throw _privateConstructorUsedError; // Tamil, Sanskrit, English, etc.
  String? get verse => throw _privateConstructorUsedError; // Original text
  String get translation =>
      throw _privateConstructorUsedError; // English translation
  String? get meaning =>
      throw _privateConstructorUsedError; // Extended meaning/explanation
  List<String>? get tags =>
      throw _privateConstructorUsedError; // discipline, calm, virtue
  List<String>? get moodFit =>
      throw _privateConstructorUsedError; // sad, angry, demotivated
  String? get audioUrl =>
      throw _privateConstructorUsedError; // Firebase Storage URL
  String get level =>
      throw _privateConstructorUsedError; // universal, beginner, advanced
  String? get author =>
      throw _privateConstructorUsedError; // For modern legends: Kalam, Vivekananda, etc.
  String? get era =>
      throw _privateConstructorUsedError; // Ancient, Modern, Contemporary
  String? get tradition => throw _privateConstructorUsedError;

  /// Serializes this WisdomModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WisdomModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WisdomModelCopyWith<WisdomModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WisdomModelCopyWith<$Res> {
  factory $WisdomModelCopyWith(
          WisdomModel value, $Res Function(WisdomModel) then) =
      _$WisdomModelCopyWithImpl<$Res, WisdomModel>;
  @useResult
  $Res call(
      {String id,
      String source,
      String category,
      String? language,
      String? verse,
      String translation,
      String? meaning,
      List<String>? tags,
      List<String>? moodFit,
      String? audioUrl,
      String level,
      String? author,
      String? era,
      String? tradition});
}

/// @nodoc
class _$WisdomModelCopyWithImpl<$Res, $Val extends WisdomModel>
    implements $WisdomModelCopyWith<$Res> {
  _$WisdomModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WisdomModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? source = null,
    Object? category = null,
    Object? language = freezed,
    Object? verse = freezed,
    Object? translation = null,
    Object? meaning = freezed,
    Object? tags = freezed,
    Object? moodFit = freezed,
    Object? audioUrl = freezed,
    Object? level = null,
    Object? author = freezed,
    Object? era = freezed,
    Object? tradition = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      verse: freezed == verse
          ? _value.verse
          : verse // ignore: cast_nullable_to_non_nullable
              as String?,
      translation: null == translation
          ? _value.translation
          : translation // ignore: cast_nullable_to_non_nullable
              as String,
      meaning: freezed == meaning
          ? _value.meaning
          : meaning // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      moodFit: freezed == moodFit
          ? _value.moodFit
          : moodFit // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      audioUrl: freezed == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      author: freezed == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String?,
      era: freezed == era
          ? _value.era
          : era // ignore: cast_nullable_to_non_nullable
              as String?,
      tradition: freezed == tradition
          ? _value.tradition
          : tradition // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WisdomModelImplCopyWith<$Res>
    implements $WisdomModelCopyWith<$Res> {
  factory _$$WisdomModelImplCopyWith(
          _$WisdomModelImpl value, $Res Function(_$WisdomModelImpl) then) =
      __$$WisdomModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String source,
      String category,
      String? language,
      String? verse,
      String translation,
      String? meaning,
      List<String>? tags,
      List<String>? moodFit,
      String? audioUrl,
      String level,
      String? author,
      String? era,
      String? tradition});
}

/// @nodoc
class __$$WisdomModelImplCopyWithImpl<$Res>
    extends _$WisdomModelCopyWithImpl<$Res, _$WisdomModelImpl>
    implements _$$WisdomModelImplCopyWith<$Res> {
  __$$WisdomModelImplCopyWithImpl(
      _$WisdomModelImpl _value, $Res Function(_$WisdomModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of WisdomModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? source = null,
    Object? category = null,
    Object? language = freezed,
    Object? verse = freezed,
    Object? translation = null,
    Object? meaning = freezed,
    Object? tags = freezed,
    Object? moodFit = freezed,
    Object? audioUrl = freezed,
    Object? level = null,
    Object? author = freezed,
    Object? era = freezed,
    Object? tradition = freezed,
  }) {
    return _then(_$WisdomModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      verse: freezed == verse
          ? _value.verse
          : verse // ignore: cast_nullable_to_non_nullable
              as String?,
      translation: null == translation
          ? _value.translation
          : translation // ignore: cast_nullable_to_non_nullable
              as String,
      meaning: freezed == meaning
          ? _value.meaning
          : meaning // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      moodFit: freezed == moodFit
          ? _value._moodFit
          : moodFit // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      audioUrl: freezed == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      author: freezed == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String?,
      era: freezed == era
          ? _value.era
          : era // ignore: cast_nullable_to_non_nullable
              as String?,
      tradition: freezed == tradition
          ? _value.tradition
          : tradition // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WisdomModelImpl extends _WisdomModel {
  const _$WisdomModelImpl(
      {required this.id,
      required this.source,
      required this.category,
      this.language,
      this.verse,
      required this.translation,
      this.meaning,
      final List<String>? tags,
      final List<String>? moodFit,
      this.audioUrl,
      this.level = 'universal',
      this.author,
      this.era,
      this.tradition})
      : _tags = tags,
        _moodFit = moodFit,
        super._();

  factory _$WisdomModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WisdomModelImplFromJson(json);

  @override
  final String id;
  @override
  final String source;
// Thirukkural, Gita, Rumi, etc.
  @override
  final String category;
// Patience, Love, Discipline, etc.
  @override
  final String? language;
// Tamil, Sanskrit, English, etc.
  @override
  final String? verse;
// Original text
  @override
  final String translation;
// English translation
  @override
  final String? meaning;
// Extended meaning/explanation
  final List<String>? _tags;
// Extended meaning/explanation
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

// discipline, calm, virtue
  final List<String>? _moodFit;
// discipline, calm, virtue
  @override
  List<String>? get moodFit {
    final value = _moodFit;
    if (value == null) return null;
    if (_moodFit is EqualUnmodifiableListView) return _moodFit;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

// sad, angry, demotivated
  @override
  final String? audioUrl;
// Firebase Storage URL
  @override
  @JsonKey()
  final String level;
// universal, beginner, advanced
  @override
  final String? author;
// For modern legends: Kalam, Vivekananda, etc.
  @override
  final String? era;
// Ancient, Modern, Contemporary
  @override
  final String? tradition;

  @override
  String toString() {
    return 'WisdomModel(id: $id, source: $source, category: $category, language: $language, verse: $verse, translation: $translation, meaning: $meaning, tags: $tags, moodFit: $moodFit, audioUrl: $audioUrl, level: $level, author: $author, era: $era, tradition: $tradition)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WisdomModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.verse, verse) || other.verse == verse) &&
            (identical(other.translation, translation) ||
                other.translation == translation) &&
            (identical(other.meaning, meaning) || other.meaning == meaning) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(other._moodFit, _moodFit) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.era, era) || other.era == era) &&
            (identical(other.tradition, tradition) ||
                other.tradition == tradition));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      source,
      category,
      language,
      verse,
      translation,
      meaning,
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(_moodFit),
      audioUrl,
      level,
      author,
      era,
      tradition);

  /// Create a copy of WisdomModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WisdomModelImplCopyWith<_$WisdomModelImpl> get copyWith =>
      __$$WisdomModelImplCopyWithImpl<_$WisdomModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WisdomModelImplToJson(
      this,
    );
  }
}

abstract class _WisdomModel extends WisdomModel {
  const factory _WisdomModel(
      {required final String id,
      required final String source,
      required final String category,
      final String? language,
      final String? verse,
      required final String translation,
      final String? meaning,
      final List<String>? tags,
      final List<String>? moodFit,
      final String? audioUrl,
      final String level,
      final String? author,
      final String? era,
      final String? tradition}) = _$WisdomModelImpl;
  const _WisdomModel._() : super._();

  factory _WisdomModel.fromJson(Map<String, dynamic> json) =
      _$WisdomModelImpl.fromJson;

  @override
  String get id;
  @override
  String get source; // Thirukkural, Gita, Rumi, etc.
  @override
  String get category; // Patience, Love, Discipline, etc.
  @override
  String? get language; // Tamil, Sanskrit, English, etc.
  @override
  String? get verse; // Original text
  @override
  String get translation; // English translation
  @override
  String? get meaning; // Extended meaning/explanation
  @override
  List<String>? get tags; // discipline, calm, virtue
  @override
  List<String>? get moodFit; // sad, angry, demotivated
  @override
  String? get audioUrl; // Firebase Storage URL
  @override
  String get level; // universal, beginner, advanced
  @override
  String? get author; // For modern legends: Kalam, Vivekananda, etc.
  @override
  String? get era; // Ancient, Modern, Contemporary
  @override
  String? get tradition;

  /// Create a copy of WisdomModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WisdomModelImplCopyWith<_$WisdomModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WisdomReflectionModel _$WisdomReflectionModelFromJson(
    Map<String, dynamic> json) {
  return _WisdomReflectionModel.fromJson(json);
}

/// @nodoc
mixin _$WisdomReflectionModel {
  String get id => throw _privateConstructorUsedError;
  String get wisdomId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get reflectionText => throw _privateConstructorUsedError;
  int? get moodBefore => throw _privateConstructorUsedError;
  int? get moodAfter => throw _privateConstructorUsedError;
  List<String>? get insights => throw _privateConstructorUsedError;
  bool get appliedToday =>
      throw _privateConstructorUsedError; // User applied wisdom in daily life
  DateTime? get reflectedAt => throw _privateConstructorUsedError;

  /// Serializes this WisdomReflectionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WisdomReflectionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WisdomReflectionModelCopyWith<WisdomReflectionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WisdomReflectionModelCopyWith<$Res> {
  factory $WisdomReflectionModelCopyWith(WisdomReflectionModel value,
          $Res Function(WisdomReflectionModel) then) =
      _$WisdomReflectionModelCopyWithImpl<$Res, WisdomReflectionModel>;
  @useResult
  $Res call(
      {String id,
      String wisdomId,
      String userId,
      String? reflectionText,
      int? moodBefore,
      int? moodAfter,
      List<String>? insights,
      bool appliedToday,
      DateTime? reflectedAt});
}

/// @nodoc
class _$WisdomReflectionModelCopyWithImpl<$Res,
        $Val extends WisdomReflectionModel>
    implements $WisdomReflectionModelCopyWith<$Res> {
  _$WisdomReflectionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WisdomReflectionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? wisdomId = null,
    Object? userId = null,
    Object? reflectionText = freezed,
    Object? moodBefore = freezed,
    Object? moodAfter = freezed,
    Object? insights = freezed,
    Object? appliedToday = null,
    Object? reflectedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      wisdomId: null == wisdomId
          ? _value.wisdomId
          : wisdomId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      reflectionText: freezed == reflectionText
          ? _value.reflectionText
          : reflectionText // ignore: cast_nullable_to_non_nullable
              as String?,
      moodBefore: freezed == moodBefore
          ? _value.moodBefore
          : moodBefore // ignore: cast_nullable_to_non_nullable
              as int?,
      moodAfter: freezed == moodAfter
          ? _value.moodAfter
          : moodAfter // ignore: cast_nullable_to_non_nullable
              as int?,
      insights: freezed == insights
          ? _value.insights
          : insights // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      appliedToday: null == appliedToday
          ? _value.appliedToday
          : appliedToday // ignore: cast_nullable_to_non_nullable
              as bool,
      reflectedAt: freezed == reflectedAt
          ? _value.reflectedAt
          : reflectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WisdomReflectionModelImplCopyWith<$Res>
    implements $WisdomReflectionModelCopyWith<$Res> {
  factory _$$WisdomReflectionModelImplCopyWith(
          _$WisdomReflectionModelImpl value,
          $Res Function(_$WisdomReflectionModelImpl) then) =
      __$$WisdomReflectionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String wisdomId,
      String userId,
      String? reflectionText,
      int? moodBefore,
      int? moodAfter,
      List<String>? insights,
      bool appliedToday,
      DateTime? reflectedAt});
}

/// @nodoc
class __$$WisdomReflectionModelImplCopyWithImpl<$Res>
    extends _$WisdomReflectionModelCopyWithImpl<$Res,
        _$WisdomReflectionModelImpl>
    implements _$$WisdomReflectionModelImplCopyWith<$Res> {
  __$$WisdomReflectionModelImplCopyWithImpl(_$WisdomReflectionModelImpl _value,
      $Res Function(_$WisdomReflectionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of WisdomReflectionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? wisdomId = null,
    Object? userId = null,
    Object? reflectionText = freezed,
    Object? moodBefore = freezed,
    Object? moodAfter = freezed,
    Object? insights = freezed,
    Object? appliedToday = null,
    Object? reflectedAt = freezed,
  }) {
    return _then(_$WisdomReflectionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      wisdomId: null == wisdomId
          ? _value.wisdomId
          : wisdomId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      reflectionText: freezed == reflectionText
          ? _value.reflectionText
          : reflectionText // ignore: cast_nullable_to_non_nullable
              as String?,
      moodBefore: freezed == moodBefore
          ? _value.moodBefore
          : moodBefore // ignore: cast_nullable_to_non_nullable
              as int?,
      moodAfter: freezed == moodAfter
          ? _value.moodAfter
          : moodAfter // ignore: cast_nullable_to_non_nullable
              as int?,
      insights: freezed == insights
          ? _value._insights
          : insights // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      appliedToday: null == appliedToday
          ? _value.appliedToday
          : appliedToday // ignore: cast_nullable_to_non_nullable
              as bool,
      reflectedAt: freezed == reflectedAt
          ? _value.reflectedAt
          : reflectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WisdomReflectionModelImpl implements _WisdomReflectionModel {
  const _$WisdomReflectionModelImpl(
      {required this.id,
      required this.wisdomId,
      required this.userId,
      this.reflectionText,
      this.moodBefore,
      this.moodAfter,
      final List<String>? insights,
      this.appliedToday = false,
      this.reflectedAt})
      : _insights = insights;

  factory _$WisdomReflectionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WisdomReflectionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String wisdomId;
  @override
  final String userId;
  @override
  final String? reflectionText;
  @override
  final int? moodBefore;
  @override
  final int? moodAfter;
  final List<String>? _insights;
  @override
  List<String>? get insights {
    final value = _insights;
    if (value == null) return null;
    if (_insights is EqualUnmodifiableListView) return _insights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final bool appliedToday;
// User applied wisdom in daily life
  @override
  final DateTime? reflectedAt;

  @override
  String toString() {
    return 'WisdomReflectionModel(id: $id, wisdomId: $wisdomId, userId: $userId, reflectionText: $reflectionText, moodBefore: $moodBefore, moodAfter: $moodAfter, insights: $insights, appliedToday: $appliedToday, reflectedAt: $reflectedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WisdomReflectionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.wisdomId, wisdomId) ||
                other.wisdomId == wisdomId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.reflectionText, reflectionText) ||
                other.reflectionText == reflectionText) &&
            (identical(other.moodBefore, moodBefore) ||
                other.moodBefore == moodBefore) &&
            (identical(other.moodAfter, moodAfter) ||
                other.moodAfter == moodAfter) &&
            const DeepCollectionEquality().equals(other._insights, _insights) &&
            (identical(other.appliedToday, appliedToday) ||
                other.appliedToday == appliedToday) &&
            (identical(other.reflectedAt, reflectedAt) ||
                other.reflectedAt == reflectedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      wisdomId,
      userId,
      reflectionText,
      moodBefore,
      moodAfter,
      const DeepCollectionEquality().hash(_insights),
      appliedToday,
      reflectedAt);

  /// Create a copy of WisdomReflectionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WisdomReflectionModelImplCopyWith<_$WisdomReflectionModelImpl>
      get copyWith => __$$WisdomReflectionModelImplCopyWithImpl<
          _$WisdomReflectionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WisdomReflectionModelImplToJson(
      this,
    );
  }
}

abstract class _WisdomReflectionModel implements WisdomReflectionModel {
  const factory _WisdomReflectionModel(
      {required final String id,
      required final String wisdomId,
      required final String userId,
      final String? reflectionText,
      final int? moodBefore,
      final int? moodAfter,
      final List<String>? insights,
      final bool appliedToday,
      final DateTime? reflectedAt}) = _$WisdomReflectionModelImpl;

  factory _WisdomReflectionModel.fromJson(Map<String, dynamic> json) =
      _$WisdomReflectionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get wisdomId;
  @override
  String get userId;
  @override
  String? get reflectionText;
  @override
  int? get moodBefore;
  @override
  int? get moodAfter;
  @override
  List<String>? get insights;
  @override
  bool get appliedToday; // User applied wisdom in daily life
  @override
  DateTime? get reflectedAt;

  /// Create a copy of WisdomReflectionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WisdomReflectionModelImplCopyWith<_$WisdomReflectionModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
