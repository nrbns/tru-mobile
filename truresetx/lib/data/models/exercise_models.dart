import 'package:json_annotation/json_annotation.dart';

part 'exercise_models.g.dart';

@JsonSerializable()
class Exercise {
  Exercise({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.equipment,
    this.videoUrl,
    required this.cues,
    required this.arErrRules,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);

  final int id;
  final String name;
  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final List<String> equipment;
  final String? videoUrl;
  final List<String> cues;
  final Map<String, dynamic> arErrRules;

  Map<String, dynamic> toJson() => _$ExerciseToJson(this);

  /// Get all muscles (primary + secondary)
  List<String> get allMuscles => [primaryMuscle, ...secondaryMuscles];

  /// Get equipment requirements as string
  String get equipmentString {
    if (equipment.isEmpty) return 'Bodyweight';
    return equipment.join(', ');
  }

  /// Get cues as formatted string
  String get cuesString => cues.join(' • ');

  /// Get AR error rules for specific error type
  Map<String, dynamic>? getErrorRule(String errorType) {
    return arErrRules[errorType] as Map<String, dynamic>?;
  }

  /// Check if exercise requires specific equipment
  bool requiresEquipment(String equipmentName) {
    return equipment.contains(equipmentName);
  }

  /// Check if exercise targets specific muscle
  bool targetsMuscle(String muscleName) {
    return allMuscles.any((muscle) => 
      muscle.toLowerCase().contains(muscleName.toLowerCase()));
  }
}

@JsonSerializable()
class ExerciseList {
  ExerciseList({
    required this.exercises,
    required this.totalCount,
    this.filteredMuscle,
  });

  factory ExerciseList.fromJson(Map<String, dynamic> json) => _$ExerciseListFromJson(json);

  final List<Exercise> exercises;
  final int totalCount;
  final String? filteredMuscle;

  Map<String, dynamic> toJson() => _$ExerciseListToJson(this);

  /// Get exercises by muscle group
  List<Exercise> getExercisesByMuscle(String muscle) {
    return exercises.where((exercise) => 
      exercise.targetsMuscle(muscle)).toList();
  }

  /// Get exercises by equipment
  List<Exercise> getExercisesByEquipment(String equipment) {
    return exercises.where((exercise) => 
      exercise.requiresEquipment(equipment)).toList();
  }

  /// Get bodyweight exercises only
  List<Exercise> get bodyweightExercises {
    return exercises.where((exercise) => 
      exercise.equipment.isEmpty).toList();
  }
}

@JsonSerializable()
class ARErrorRule {
  ARErrorRule({
    required this.condition,
    required this.countIfRepsOver,
    required this.cue,
    this.threshold,
  });

  factory ARErrorRule.fromJson(Map<String, dynamic> json) => _$ARErrorRuleFromJson(json);

  final String condition;
  final double countIfRepsOver;
  final String cue;
  final double? threshold;

  Map<String, dynamic> toJson() => _$ARErrorRuleToJson(this);

  /// Check if error should be counted based on rep percentage
  bool shouldCountError(double repPercentage) {
    return repPercentage >= countIfRepsOver;
  }

  /// Get formatted condition description
  String get conditionDescription {
    switch (condition) {
      case 'depth_low':
        return 'Insufficient depth';
      case 'knee_valgus':
        return 'Knee valgus (knees caving in)';
      case 'hip_shift':
        return 'Hip shift or lateral movement';
      case 'tempo_fast':
        return 'Too fast tempo';
      case 'rom_short':
        return 'Short range of motion';
      case 'hips_sag':
        return 'Hips sagging';
      case 'scap_wing':
        return 'Scapular winging';
      case 'knee_travel':
        return 'Knee traveling too far forward';
      case 'balance_loss':
        return 'Loss of balance';
      case 'hip_drop':
        return 'Hip dropping';
      default:
        return condition.replaceAll('_', ' ').toUpperCase();
    }
  }
}

@JsonSerializable()
class ExerciseCategory {
  ExerciseCategory({
    required this.name,
    required this.muscles,
    required this.exercises,
    this.icon,
    this.color,
  });

  factory ExerciseCategory.fromJson(Map<String, dynamic> json) => _$ExerciseCategoryFromJson(json);

  final String name;
  final List<String> muscles;
  final List<Exercise> exercises;
  final String? icon;
  final String? color;

  Map<String, dynamic> toJson() => _$ExerciseCategoryToJson(this);

  /// Get exercise count
  int get exerciseCount => exercises.length;

  /// Get primary muscle
  String get primaryMuscle => muscles.isNotEmpty ? muscles.first : '';

  /// Check if category contains specific exercise
  bool containsExercise(String exerciseName) {
    return exercises.any((exercise) => 
      exercise.name.toLowerCase() == exerciseName.toLowerCase());
  }
}

/// Common muscle groups for exercise categorization
class MuscleGroups {
  static const List<String> upperBody = [
    'chest',
    'anterior_deltoid',
    'posterior_deltoid',
    'lateral_deltoid',
    'triceps',
    'biceps',
    'forearms',
    'lats',
    'rhomboids',
    'traps',
  ];

  static const List<String> lowerBody = [
    'quadriceps',
    'hamstrings',
    'glutes',
    'calves',
    'hip_flexors',
    'adductors',
    'abductors',
  ];

  static const List<String> core = [
    'core',
    'abs',
    'obliques',
    'lower_back',
    'erector_spinae',
  ];

  static const List<String> fullBody = [
    'full_body',
    'cardio',
    'functional',
  ];

  /// Get muscle group category
  static String getMuscleGroupCategory(String muscle) {
    if (upperBody.contains(muscle)) return 'Upper Body';
    if (lowerBody.contains(muscle)) return 'Lower Body';
    if (core.contains(muscle)) return 'Core';
    if (fullBody.contains(muscle)) return 'Full Body';
    return 'Other';
  }

  /// Get all muscle groups
  static List<String> get allMuscleGroups => [
    ...upperBody,
    ...lowerBody,
    ...core,
    ...fullBody,
  ];
}

/// Common equipment types
class EquipmentTypes {
  static const List<String> bodyweight = [];
  static const List<String> dumbbells = ['dumbbells', 'dumbbell'];
  static const List<String> barbells = ['barbell', 'barbells'];
  static const List<String> machines = ['machine', 'cable', 'pulley'];
  static const List<String> bands = ['resistance_band', 'band', 'resistance_bands'];
  static const List<String> kettlebells = ['kettlebell', 'kettlebells'];
  static const List<String> cardio = ['treadmill', 'bike', 'elliptical', 'rower'];

  /// Get equipment category
  static String getEquipmentCategory(String equipment) {
    if (dumbbells.contains(equipment)) return 'Dumbbells';
    if (barbells.contains(equipment)) return 'Barbells';
    if (machines.contains(equipment)) return 'Machines';
    if (bands.contains(equipment)) return 'Resistance Bands';
    if (kettlebells.contains(equipment)) return 'Kettlebells';
    if (cardio.contains(equipment)) return 'Cardio Equipment';
    return 'Other';
  }
}
