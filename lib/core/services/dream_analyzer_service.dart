import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/dream_analysis.dart';
import 'agent_engines/spirit_engine.dart';

/// Dream Analyzer Service - Interprets dreams symbolically
class DreamAnalyzerService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final SpiritEngine _spiritEngine;
  final String? _uid;

  DreamAnalyzerService(this._db, this._auth)
      : _spiritEngine = SpiritEngine(_db, _auth),
        _uid = _auth.currentUser?.uid;

  /// Analyze dream with symbolic interpretation
  Future<DreamInterpretation> analyzeDream(String dreamText) async {
    final spiritualPath = await _spiritEngine.getSpiritualPath();

    // Extract themes (simplified - would use NLP)
    final themes = _extractThemes(dreamText);

    // Generate interpretations based on philosophy
    String symbolicMeaning = _generateSymbolicMeaning(dreamText, themes);
    String psychologicalMeaning = _generatePsychologicalMeaning(dreamText, themes);
    String? spiritualMeaning = _generateSpiritualMeaning(dreamText, themes, spiritualPath.philosophy);

    // Suggest action based on interpretation
    final suggestedAction = _suggestAction(themes, spiritualPath.philosophy);

    return DreamInterpretation(
      symbolicMeaning: symbolicMeaning,
      psychologicalMeaning: psychologicalMeaning,
      spiritualMeaning: spiritualMeaning,
      themes: themes,
      suggestedAction: suggestedAction,
    );
  }

  /// Save dream entry
  Future<void> saveDream(DreamEntry dream) async {
    if (_uid == null) return;
    await _db.collection('users').doc(_uid).collection('dreams').add(dream.toJson());
  }

  List<String> _extractThemes(String text) {
    final lower = text.toLowerCase();
    final themes = <String>[];

    if (lower.contains('water') || lower.contains('ocean') || lower.contains('river')) {
      themes.add('emotion');
    }
    if (lower.contains('flight') || lower.contains('flying') || lower.contains('air')) {
      themes.add('freedom');
    }
    if (lower.contains('dark') || lower.contains('shadow') || lower.contains('night')) {
      themes.add('unconscious');
    }
    if (lower.contains('death') || lower.contains('ending')) {
      themes.add('transformation');
    }
    if (lower.contains('child') || lower.contains('baby')) {
      themes.add('innocence');
    }

    return themes.isEmpty ? ['general'] : themes;
  }

  String _generateSymbolicMeaning(String text, List<String> themes) {
    if (themes.contains('emotion')) {
      return 'Water in dreams often represents emotional flow and depth. This may reflect your current emotional state or unconscious feelings.';
    }
    if (themes.contains('freedom')) {
      return 'Flying or air symbolizes liberation and transcendence. You may be seeking freedom in some area of your life.';
    }
    if (themes.contains('transformation')) {
      return 'Endings in dreams often signal new beginnings. This could indicate a significant change or transition.';
    }
    return 'This dream may carry personal symbolic meaning based on your unique experiences and current life context.';
  }

  String _generatePsychologicalMeaning(String text, List<String> themes) {
    return 'From a psychological perspective, this dream likely reflects your subconscious processing of recent events, emotions, or unresolved thoughts. Dreams help integrate daily experiences into long-term memory and emotional regulation.';
  }

  String? _generateSpiritualMeaning(String text, List<String> themes, PhilosophyMode philosophy) {
    switch (philosophy) {
      case PhilosophyMode.vedic:
        return 'In Vedic tradition, dreams are messages from the deeper self (Atman). This may be guidance on your dharma or karmic patterns.';
      case PhilosophyMode.stoic:
        return 'Stoics view dreams as mental exercises. This reflection can help you practice acceptance and examine your judgments.';
      case PhilosophyMode.zen:
        return 'In Zen, dreams are illusions like waking life. Notice the impermanence and return to the present moment.';
      case PhilosophyMode.buddhist:
        return 'Dreams in Buddhism reflect the mind\'s conditioning. This offers insight into attachments and the nature of reality.';
      case PhilosophyMode.atheist:
        return 'Dreams are the brain\'s way of processing information. This is valuable psychological data about your mental state.';
      case PhilosophyMode.neutral:
        return 'Dreams can offer insights into your inner world, regardless of philosophical framework.';
    }
  }

  String _suggestAction(List<String> themes, PhilosophyMode philosophy) {
    if (themes.contains('emotion')) {
      return 'Consider journaling about your feelings or a meditation focused on emotional awareness.';
    }
    if (themes.contains('transformation')) {
      return 'Reflect on what is ending in your life and what new beginnings are emerging.';
    }
    return 'Write down your dream and reflect on its personal meaning throughout the day.';
  }
}

