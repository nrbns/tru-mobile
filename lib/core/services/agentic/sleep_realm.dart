import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_audio/just_audio.dart';

/// Sleep Realm: Lucid dreaming soundscapes + subconscious journaling
class SleepRealm {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final AudioPlayer _audioPlayer = AudioPlayer();

  SleepRealm(this._db, this._auth);

  String? get _uid => _auth.currentUser?.uid;

  /// Generate sleep soundscape for lucid dreaming
  Future<SleepSoundscape> generateSoundscape({
    required double stressLevel,
    String? preferredStyle, // 'nature', 'binaural', 'ambient', 'guided'
  }) async {
    String style = preferredStyle ?? _recommendStyle(stressLevel);
    
    final tracks = await _getSoundscapeTracks(style);
    
    return SleepSoundscape(
      style: style,
      tracks: tracks,
      duration: Duration(hours: 8), // Full night
      guidedIntro: style == 'guided' ? _generateGuidedIntro() : null,
      lucidDreamingCues: stressLevel < 0.5 ? _generateLucidCues() : null,
    );
  }

  /// Subconscious journaling: prompts for dream state
  Future<List<String>> generateSubconsciousPrompts({
    String? beliefSystem,
  }) async {
    final prompts = <String>[];

    if (beliefSystem == 'vedic') {
      prompts.add('Before sleep, set an intention: What do you seek to understand?');
      prompts.add('As you drift, visualize a sacred space. What appears?');
    } else if (beliefSystem == 'psychology') {
      prompts.add('What unresolved emotions might surface in your dreams tonight?');
      prompts.add('Set a dream question: What guidance do you need?');
    } else {
      prompts.add('What would you like to explore in your sleep?');
      prompts.add('Before sleep, reflect on today. What stands out?');
    }

    return prompts;
  }

  /// Play sleep soundscape
  Future<void> playSoundscape(SleepSoundscape soundscape) async {
    if (soundscape.tracks.isEmpty) return;

    // Queue tracks for continuous playback
    final playlist = ConcatenatingAudioSource(
      children: soundscape.tracks.map((track) => AudioSource.uri(Uri.parse(track.url))).toList(),
    );

    await _audioPlayer.setAudioSource(playlist);
    await _audioPlayer.setLoopMode(LoopMode.all);
    await _audioPlayer.setVolume(0.3); // Lower volume for sleep
    await _audioPlayer.play();
  }

  /// Stop soundscape
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  String _recommendStyle(double stress) {
    if (stress > 0.7) return 'nature'; // Nature sounds for high stress
    if (stress > 0.4) return 'binaural'; // Binaural beats for moderate stress
    return 'guided'; // Guided for low stress (can focus on lucid dreaming)
  }

  Future<List<SleepTrack>> _getSoundscapeTracks(String style) async {
    // TODO: Load from Firestore or asset URLs
    // Mock tracks for now
    return [
      SleepTrack(
        name: 'Deep Sleep ${style}',
        url: 'assets/audio/sleep/$style/track1.mp3',
        duration: Duration(minutes: 30),
      ),
      SleepTrack(
        name: 'Dream State ${style}',
        url: 'assets/audio/sleep/$style/track2.mp3',
        duration: Duration(minutes: 30),
      ),
    ];
  }

  String? _generateGuidedIntro() {
    return 'Close your eyes. Take three deep breaths. As you relax, imagine yourself in a peaceful garden. Each breath takes you deeper into tranquility...';
  }

  List<String>? _generateLucidCues() {
    return [
      'Reality check: Look at your hands. Count your fingers.',
      'Set intention: "I will recognize I am dreaming."',
      'Visualization: Imagine a door. Behind it is your dream world.',
    ];
  }

  /// Log dream state entry
  Future<void> logDreamState({
    required String state, // 'awake', 'drifting', 'dreaming', 'lucid', 'waking'
    DateTime? timestamp,
  }) async {
    if (_uid == null) return;

    await _db.collection('users').doc(_uid).collection('sleep_logs').add({
      'state': state,
      'timestamp': (timestamp ?? DateTime.now()).millisecondsSinceEpoch,
    });
  }
}

class SleepSoundscape {
  final String style;
  final List<SleepTrack> tracks;
  final Duration duration;
  final String? guidedIntro;
  final List<String>? lucidDreamingCues;

  SleepSoundscape({
    required this.style,
    required this.tracks,
    required this.duration,
    this.guidedIntro,
    this.lucidDreamingCues,
  });
}

class SleepTrack {
  final String name;
  final String url;
  final Duration duration;

  SleepTrack({
    required this.name,
    required this.url,
    required this.duration,
  });
}

