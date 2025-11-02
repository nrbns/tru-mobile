import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bio_spiritual_sync.dart';

class BioSpiritualSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference get _syncRef =>
      _firestore.collection('bio_spiritual_sync');

  Future<void> saveSyncData(BioSpiritualSyncData data) async {
    await _syncRef.add(data.toMap());
  }

  Future<BioSpiritualSyncData> computeRecommendations({
    required String userId,
    required int mood,
    String? cyclePhase,
    required int sleepQuality,
    required int stressScore,
  }) async {
    // Minimal heuristic-based placeholder
    final List<String> recs = [];
    String suggested = 'meditation';
    if (stressScore >= 7) {
      recs.add('Try 10 min breathing');
      suggested = 'relaxation meditation';
    }
    if (mood <= 3) {
      recs.add('Gratitude journaling');
    }
    if (sleepQuality <= 4) {
      recs.add('Gentle yoga before bed');
    }

    return BioSpiritualSyncData(
      userId: userId,
      mood: mood,
      cyclePhase: cyclePhase,
      sleepQuality: sleepQuality,
      stressScore: stressScore,
      recommendations: recs,
      suggestedPractice: suggested,
    );
  }
}
