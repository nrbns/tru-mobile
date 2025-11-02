import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Dream Analyzer: Interprets dreams symbolically (spiritual/psychological)
class DreamAnalyzer {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  DreamAnalyzer(this._db, this._auth);

  String? get _uid => _auth.currentUser?.uid;

  /// Analyze dream content and provide interpretations
  Future<DreamAnalysis> analyzeDream({
    required String dreamContent,
    required String? beliefSystem, // 'vedic', 'psychology', 'jungian', etc.
    Map<String, dynamic>? emotions, // Emotions during/after dream
  }) async {
    // Extract key symbols and themes
    final symbols = _extractSymbols(dreamContent);
    final themes = _extractThemes(dreamContent);

    // Generate interpretation based on belief system
    final interpretation = await _generateInterpretation(
      symbols: symbols,
      themes: themes,
      beliefSystem: beliefSystem ?? 'psychology',
      emotions: emotions,
    );

    // Save dream log
    if (_uid != null) {
      await _db.collection('users').doc(_uid).collection('dream_logs').add({
        'content': dreamContent,
        'symbols': symbols,
        'themes': themes,
        'interpretation': interpretation.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }

    return interpretation;
  }

  /// Extract symbolic elements from dream text
  List<String> _extractSymbols(String content) {
    final lower = content.toLowerCase();
    final symbols = <String>[];

    // Common dream symbols
    final symbolKeywords = {
      'water': ['water', 'ocean', 'river', 'rain', 'flood'],
      'animals': ['dog', 'cat', 'snake', 'bird', 'lion', 'wolf'],
      'vehicles': ['car', 'bus', 'plane', 'train', 'bike'],
      'buildings': ['house', 'room', 'building', 'tower', 'door'],
      'people': ['family', 'friend', 'stranger', 'child', 'parent'],
      'nature': ['tree', 'forest', 'mountain', 'flower', 'sky'],
    };

    for (final entry in symbolKeywords.entries) {
      if (entry.value.any((keyword) => lower.contains(keyword))) {
        symbols.add(entry.key);
      }
    }

    return symbols;
  }

  /// Extract emotional themes
  List<String> _extractThemes(String content) {
    final lower = content.toLowerCase();
    final themes = <String>[];

    if (lower.contains('fear') || lower.contains('scared') || lower.contains('chase')) {
      themes.add('fear');
    }
    if (lower.contains('happy') || lower.contains('joy') || lower.contains('laugh')) {
      themes.add('joy');
    }
    if (lower.contains('confusion') || lower.contains('lost') || lower.contains('unknown')) {
      themes.add('uncertainty');
    }
    if (lower.contains('flight') || lower.contains('fly') || lower.contains('soar')) {
      themes.add('freedom');
    }

    return themes;
  }

  /// Generate interpretation based on belief system
  Future<DreamAnalysis> _generateInterpretation({
    required List<String> symbols,
    required List<String> themes,
    required String beliefSystem,
    Map<String, dynamic>? emotions,
  }) async {
    final interpretations = <String>[];
    final spiritualInsights = <String>[];
    final psychologicalInsights = <String>[];

    if (beliefSystem == 'vedic') {
      // Vedic interpretation
      if (symbols.contains('water')) {
        spiritualInsights.add('Water in Vedic tradition represents emotions and the subconscious. Consider your emotional state.');
      }
      if (symbols.contains('animals')) {
        spiritualInsights.add('Animals may represent primal instincts or karmic lessons.');
      }
    } else if (beliefSystem == 'jungian') {
      // Jungian archetypal interpretation
      if (symbols.contains('water')) {
        psychologicalInsights.add('Water often symbolizes the unconscious mind. This dream may reflect hidden emotions.');
      }
      if (symbols.contains('animals')) {
        psychologicalInsights.add('Animals can represent instinctual aspects of the psyche.');
      }
    } else {
      // General psychological interpretation
      if (themes.contains('fear')) {
        psychologicalInsights.add('Fear in dreams often relates to anxiety about real-life situations.');
      }
      if (themes.contains('freedom')) {
        psychologicalInsights.add('Flight/freedom dreams may indicate a desire for liberation or escape.');
      }
    }

    return DreamAnalysis(
      symbols: symbols,
      themes: themes,
      spiritualInterpretation: spiritualInsights.isNotEmpty ? spiritualInsights.join(' ') : null,
      psychologicalInterpretation: psychologicalInsights.isNotEmpty ? psychologicalInsights.join(' ') : null,
      recommendations: _generateRecommendations(symbols, themes),
      timestamp: DateTime.now(),
    );
  }

  List<String> _generateRecommendations(List<String> symbols, List<String> themes) {
    final recommendations = <String>[];

    if (themes.contains('fear')) {
      recommendations.add('Consider journaling about your fears or practicing stress-reduction techniques.');
    }
    if (symbols.contains('water')) {
      recommendations.add('Pay attention to your emotional state; water often relates to feelings.');
    }

    return recommendations;
  }
}

class DreamAnalysis {
  final List<String> symbols;
  final List<String> themes;
  final String? spiritualInterpretation;
  final String? psychologicalInterpretation;
  final List<String> recommendations;
  final DateTime timestamp;

  DreamAnalysis({
    required this.symbols,
    required this.themes,
    this.spiritualInterpretation,
    this.psychologicalInterpretation,
    required this.recommendations,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'symbols': symbols,
      'themes': themes,
      'spiritual_interpretation': spiritualInterpretation,
      'psychological_interpretation': psychologicalInterpretation,
      'recommendations': recommendations,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}

