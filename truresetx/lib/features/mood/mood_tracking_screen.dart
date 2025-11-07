import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:truresetx/data/providers/backend_providers.dart';
import 'package:truresetx/core/services/supabase_edge_functions.dart';
import 'package:truresetx/core/services/current_user_provider.dart';
import 'package:truresetx/data/models/mood_models.dart';
import 'package:truresetx/core/widgets/error_state.dart';

class MoodTrackingScreen extends ConsumerStatefulWidget {
  const MoodTrackingScreen({super.key});

  @override
  ConsumerState<MoodTrackingScreen> createState() => _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends ConsumerState<MoodTrackingScreen> {
  int _currentQuestionIndex = 0;
  final Map<int, int> _answers = {};
  // Field reserved for future submit state handling
  // ignore: unused_field
  bool _isSubmitting = false;

  // === realtime subscription ===
  StreamSubscription<dynamic>? _moodRealtimeSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startRealtimeListen();
    });
  }

  @override
  void dispose() {
    _stopRealtimeListen();
    _moodRealtimeSub?.cancel();
    super.dispose();
  }

  void _startRealtimeListen() {
    final service = ref.read(supabaseEdgeFunctionsProvider);
    final userId = ref.read(currentUserIdProvider);

    if (userId == null) return;

    try {
      _moodRealtimeSub = service.subscribeToMoodLogs(userId).listen(
        (event) {
          try {
            final moodLog = _parseRealtimePayloadToMoodLog(event);
            if (moodLog != null) {
              ref.read(moodLogsProvider.notifier).addOrUpdateMoodLog(moodLog);
            }
          } catch (_) {}
        },
        onError: (err) {
          // ignore or log
        },
      );
    } catch (_) {}
  }

  void _stopRealtimeListen() {
    final service = ref.read(supabaseEdgeFunctionsProvider);
    final userId = ref.read(currentUserIdProvider);
    try {
      if (userId != null) {
        service.unsubscribeFromMoodLogs(userId);
      }
    } catch (_) {}
    _moodRealtimeSub?.cancel();
    _moodRealtimeSub = null;
  }

  MoodLog? _parseRealtimePayloadToMoodLog(dynamic payload) {
    try {
      Map<String, dynamic> data;
      if (payload is Map && payload['new'] != null) {
        data = Map<String, dynamic>.from(payload['new'] as Map);
      } else if (payload is Map) {
        data = Map<String, dynamic>.from(payload);
      } else {
        return null;
      }

      // Our model uses fromJson (json_serializable)
      return MoodLog.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final who5Items = ref.watch(who5ItemsProvider);
    final moodLogs = ref.watch(moodLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracking'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showMoodHistory(moodLogs),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: who5Items.when(
        data: (items) => _buildAssessment(items),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState(
          message: 'Failed to load assessment',
          details: error.toString(),
          onRetry: () => ref.invalidate(who5ItemsProvider),
        ),
      ),
    );
  }

  Widget _buildAssessment(List<Who5Item> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text('No assessment items available'),
      );
    }

    final currentItem = items[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / items.length;

    return Column(
      children: [
        // Progress indicator
        _buildProgressIndicator(progress),

        // Question
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Question header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withAlpha((0.1 * 255).round()),
                        Colors.purple.withAlpha((0.1 * 255).round())
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.blue.withAlpha((0.3 * 255).round())),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Question ${_currentQuestionIndex + 1} of ${items.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentItem.question,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (currentItem.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          currentItem.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Answer options
                _buildAnswerOptions(currentItem),

                const Spacer(),

                // Navigation buttons
                _buildNavigationButtons(items.length),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WHO-5 Wellbeing Assessment',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(Who5Item item) {
    return Column(
      children: item.scale.asMap().entries.map((entry) {
        final index = entry.key;
        final value = entry.value;
        final isSelected = _answers[_currentQuestionIndex] == value;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _selectAnswer(value),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue.withAlpha((0.1 * 255).round())
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.blue : Colors.grey[300],
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.scaleLabels[index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? Colors.blue : Colors.black87,
                          ),
                        ),
                        if (value > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: List.generate(
                                5,
                                (i) => Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(right: 4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: i < value
                                            ? Colors.blue
                                            : Colors.grey[300],
                                      ),
                                    )),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationButtons(int totalQuestions) {
    return Row(
      children: [
        if (_currentQuestionIndex > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: _previousQuestion,
              child: const Text('Previous'),
            ),
          ),
        if (_currentQuestionIndex > 0) const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _answers.containsKey(_currentQuestionIndex)
                ? _nextQuestion
                : null,
            child: Text(
              _currentQuestionIndex == totalQuestions - 1 ? 'Submit' : 'Next',
            ),
          ),
        ),
      ],
    );
  }

  void _selectAnswer(int value) {
    setState(() {
      _answers[_currentQuestionIndex] = value;
    });
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < 4) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _submitAssessment();
    }
  }

  Future<void> _submitAssessment() async {
    if (_answers.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final service = ref.read(supabaseEdgeFunctionsProvider);

      // Calculate scores
      final rawScore = _answers.values.reduce((a, b) => a + b);
      final percentage = (rawScore / 25 * 100).round();

      final assessmentData = {
        'date': DateTime.now().toIso8601String().split('T')[0],
        'who5_raw': rawScore,
        'who5_pct': percentage,
        'energy': _calculateEnergyLevel(),
        'stress': _calculateStressLevel(),
        'answers': _answers,
      };

      await service.submitWho5Answers(answers: assessmentData);

      // Create mood log
      final moodLog = MoodLog(
        id: DateTime.now().millisecondsSinceEpoch,
        userId: 'current-user', // This would come from auth
        date: DateTime.now(),
        who5Raw: rawScore,
        who5Pct: percentage,
        energy: _calculateEnergyLevel(),
        stress: _calculateStressLevel(),
        notes: null,
      );

      ref.read(moodLogsProvider.notifier).addMoodLog(moodLog);

      if (mounted) {
        Navigator.pop(context);
        _showAssessmentResults(percentage, rawScore);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting assessment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  int _calculateEnergyLevel() {
    // Simple calculation based on WHO-5 score
    final score = _answers.values.reduce((a, b) => a + b);
    if (score >= 20) return 8;
    if (score >= 15) return 6;
    if (score >= 10) return 4;
    if (score >= 5) return 2;
    return 1;
  }

  int _calculateStressLevel() {
    // Inverse relationship with WHO-5 score
    final score = _answers.values.reduce((a, b) => a + b);
    if (score >= 20) return 2;
    if (score >= 15) return 4;
    if (score >= 10) return 6;
    if (score >= 5) return 8;
    return 9;
  }

  void _showAssessmentResults(int percentage, int rawScore) {
    final category = _getMoodCategory(percentage);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            const Text('Assessment Complete'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your wellbeing score: $percentage%'),
            const SizedBox(height: 16),
            Text(
              'Category: ${category.name}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              _getAssessmentMessage(percentage),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            if (percentage < 60) ...[
              const Text(
                'Recommendations:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._getRecommendations(percentage).map((rec) => Text('• $rec')),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showMoodHistory(ref.read(moodLogsProvider));
            },
            child: const Text('View History'),
          ),
        ],
      ),
    );
  }

  MoodCategory _getMoodCategory(int percentage) {
    if (percentage >= 80) return MoodCategory.excellent;
    if (percentage >= 60) return MoodCategory.good;
    if (percentage >= 40) return MoodCategory.fair;
    if (percentage >= 20) return MoodCategory.poor;
    return MoodCategory.veryPoor;
  }

  String _getAssessmentMessage(int percentage) {
    if (percentage >= 80) {
      return 'You\'re feeling great! Keep up the positive mindset and healthy habits.';
    } else if (percentage >= 60) {
      return 'You\'re doing well overall. Consider what\'s working for you and build on those positive aspects.';
    } else if (percentage >= 40) {
      return 'You might be going through a challenging time. Remember, this too shall pass. Consider reaching out for support.';
    } else if (percentage >= 20) {
      return 'It seems like you\'re struggling. Please consider reaching out to friends, family, or a healthcare professional.';
    } else {
      return 'Please consider speaking with a healthcare professional about your wellbeing. You don\'t have to go through this alone.';
    }
  }

  List<String> _getRecommendations(int percentage) {
    final recommendations = <String>[];

    if (percentage < 60) {
      recommendations.addAll([
        'Try some gentle exercise or a short walk',
        'Practice deep breathing or meditation',
        'Connect with friends or family',
        'Get adequate sleep (7-9 hours)',
      ]);
    }

    if (percentage < 40) {
      recommendations.addAll([
        'Consider professional mental health support',
        'Maintain a regular routine',
        'Limit alcohol and caffeine',
        'Practice gratitude journaling',
      ]);
    }

    return recommendations;
  }

  void _showMoodHistory(List<MoodLog> moodLogs) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mood History'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: moodLogs.isEmpty
              ? const Center(
                  child: Text(
                      'No mood logs yet. Complete an assessment to see your history.'),
                )
              : ListView.builder(
                  itemCount: moodLogs.length,
                  itemBuilder: (context, index) {
                    final log = moodLogs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(
                              int.parse(log.moodColor.replaceAll('#', '0xFF'))),
                          child: Text(
                            log.moodEmoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        title: Text(
                          '${log.date.day}/${log.date.month}/${log.date.year}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Score: ${log.who5Pct}%'),
                            Text('Energy: ${log.energyLevel.name}'),
                            Text('Stress: ${log.stressLevel.name}'),
                          ],
                        ),
                        trailing: Text(
                          log.moodCategory.name.toUpperCase(),
                          style: TextStyle(
                            color: Color(int.parse(
                                log.moodColor.replaceAll('#', '0xFF'))),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
