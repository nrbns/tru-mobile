import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Spirit Engine - Spiritual alignment based on belief system
class SpiritEngine {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final String? _uid;

  SpiritEngine(this._db, this._auth) : _uid = _auth.currentUser?.uid;

  /// Get user's spiritual path
  Future<SpiritualPath> getSpiritualPath() async {
    if (_uid == null) {
      return SpiritualPath(philosophy: PhilosophyMode.neutral, level: 1);
    }

    final userDoc = await _db.collection('users').doc(_uid).get();
    final data = userDoc.data() ?? {};

    final philosophyStr = data['spiritual_philosophy'] as String? ?? 'neutral';
    final level = (data['spiritual_level'] as num?)?.toInt() ?? 1;

    return SpiritualPath(
      philosophy: PhilosophyMode.values.firstWhere(
        (p) => p.name == philosophyStr,
        orElse: () => PhilosophyMode.neutral,
      ),
      level: level,
    );
  }

  /// Generate spiritual guidance based on context
  Future<SpiritualGuidance> generateGuidance({
    required SpiritualPath path,
    required double stressLevel,
    required String dominantEmotion,
    String? timeOfDay,
  }) async {
    final hour = DateTime.now().hour;
    final isMorning = hour >= 5 && hour < 12;
    // final isEvening = hour >= 18 && hour < 22; // Reserved for future use

    String practiceType = 'meditation';
    String content = '';
    int duration = 10;

    switch (path.philosophy) {
      case PhilosophyMode.vedic:
        if (stressLevel > 0.7) {
          practiceType = 'mantra';
          content = 'Om Namah Shivaya';
          duration = 5;
        } else if (isMorning) {
          practiceType = 'pranayama';
          content = 'Morning breath of fire (Kapalabhati)';
          duration = 10;
        } else {
          practiceType = 'dharma_reflection';
          content = 'Reflect on your actions today and their karmic impact.';
        }

      case PhilosophyMode.stoic:
        if (stressLevel > 0.7 || dominantEmotion == 'anxious') {
          practiceType = 'quote_contemplation';
          content = '"What disturbs you is not the event, but your judgment of it." - Marcus Aurelius';
          duration = 5;
        } else {
          practiceType = 'evening_examination';
          content = 'Practice evening examination of the day\'s events.';
          duration = 15;
        }

      case PhilosophyMode.zen:
        practiceType = 'mindfulness_break';
        content = '1-minute mindful breathing - focus only on the breath.';
        duration = 1;

      case PhilosophyMode.buddhist:
        practiceType = 'loving_kindness';
        content = 'Metta meditation - send loving-kindness to yourself and others.';
        duration = 10;

      case PhilosophyMode.atheist:
        practiceType = 'cbt_reframing';
        content = 'Cognitive reframing exercise - identify and challenge negative thoughts.';
        duration = 10;

      case PhilosophyMode.neutral:
        practiceType = 'guided_relaxation';
        content = 'Simple breathing exercise for stress relief.';
        duration = 5;
    }

    return SpiritualGuidance(
      practiceType: practiceType,
      content: content,
      duration: duration,
      philosophy: path.philosophy,
    );
  }

  /// Get mantra/library content based on philosophy
  Future<List<String>> getPhilosophyContent(PhilosophyMode philosophy) async {
    switch (philosophy) {
      case PhilosophyMode.vedic:
        return [
          'Om Namah Shivaya',
          'Om Mani Padme Hum',
          'Hare Krishna',
          'Gayatri Mantra',
        ];
      case PhilosophyMode.stoic:
        return [
          '"The impediment to action advances action." - Marcus Aurelius',
          '"We suffer more in imagination than in reality." - Seneca',
          '"The only way to deal with an unfree world is to become so absolutely free." - Camus',
        ];
      case PhilosophyMode.zen:
        return [
          'Breath in, breath out. That is all.',
          'The present moment is the only moment.',
          'Let go of attachments.',
        ];
      case PhilosophyMode.buddhist:
        return [
          'May all beings be happy.',
          'Everything is impermanent.',
          'Compassion for all sentient beings.',
        ];
      case PhilosophyMode.atheist:
        return [
          'You are the author of your own meaning.',
          'Reason and evidence guide understanding.',
          'Human connection is sacred enough.',
        ];
      case PhilosophyMode.neutral:
        return [
          'Take a deep breath.',
          'You are here, in this moment.',
          'Everything is okay, right now.',
        ];
    }
  }
}

enum PhilosophyMode {
  vedic,
  stoic,
  zen,
  buddhist,
  atheist,
  neutral,
}

class SpiritualPath {
  final PhilosophyMode philosophy;
  final int level; // 1-10

  SpiritualPath({
    required this.philosophy,
    required this.level,
  });
}

class SpiritualGuidance {
  final String practiceType;
  final String content;
  final int duration; // minutes
  final PhilosophyMode philosophy;

  SpiritualGuidance({
    required this.practiceType,
    required this.content,
    required this.duration,
    required this.philosophy,
  });
}

