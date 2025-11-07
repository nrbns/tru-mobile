import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wisdom_model.freezed.dart';
part 'wisdom_model.g.dart';

@freezed
class WisdomModel with _$WisdomModel {
  // Private constructor so we can add custom methods (e.g., toFirestore)
  const WisdomModel._();
  const factory WisdomModel({
    required String id,
    required String source, // Thirukkural, Gita, Rumi, etc.
    required String category, // Patience, Love, Discipline, etc.
    String? language, // Tamil, Sanskrit, English, etc.
    String? verse, // Original text
    required String translation, // English translation
    String? meaning, // Extended meaning/explanation
    List<String>? tags, // discipline, calm, virtue
    List<String>? moodFit, // sad, angry, demotivated
    String? audioUrl, // Firebase Storage URL
    @Default('universal') String level, // universal, beginner, advanced
    String? author, // For modern legends: Kalam, Vivekananda, etc.
    String? era, // Ancient, Modern, Contemporary
    String? tradition, // Hindu, Buddhist, Christian, Islamic, Secular, etc.
  }) = _WisdomModel;

  factory WisdomModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return WisdomModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  factory WisdomModel.fromJson(Map<String, dynamic> json) =>
      _$WisdomModelFromJson(json);

  Map<String, dynamic> toFirestore() {
    final map = toJson();
    map.remove('id');
    return map;
  }
}

@freezed
class WisdomReflectionModel with _$WisdomReflectionModel {
  const factory WisdomReflectionModel({
    required String id,
    required String wisdomId,
    required String userId,
    String? reflectionText,
    int? moodBefore,
    int? moodAfter,
    List<String>? insights,
    @Default(false) bool appliedToday, // User applied wisdom in daily life
    DateTime? reflectedAt,
  }) = _WisdomReflectionModel;

  factory WisdomReflectionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return WisdomReflectionModel.fromJson({
      'id': doc.id,
      ...data,
      'reflectedAt': (data['reflectedAt'] as Timestamp?)?.toDate(),
    });
  }

  factory WisdomReflectionModel.fromJson(Map<String, dynamic> json) =>
      _$WisdomReflectionModelFromJson(json);
}
