import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/agent_providers.dart';
import '../../core/models/dream_analysis.dart';

/// Dream Analyzer Screen - Log and interpret dreams
class DreamAnalyzerScreen extends ConsumerStatefulWidget {
  const DreamAnalyzerScreen({super.key});

  @override
  ConsumerState<DreamAnalyzerScreen> createState() => _DreamAnalyzerScreenState();
}

class _DreamAnalyzerScreenState extends ConsumerState<DreamAnalyzerScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dreamService = ref.watch(dreamAnalyzerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream Analyzer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log Your Dream',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textController,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Describe your dream...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                if (_textController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please describe your dream')),
                  );
                  return;
                }

                final interpretation = await dreamService.analyzeDream(_textController.text);
                
                // Save dream
                final userId = ref.read(firebaseAuthProvider).currentUser?.uid ?? '';
                final dream = DreamEntry(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  userId: userId,
                  dreamText: _textController.text,
                  loggedAt: DateTime.now(),
                  interpretation: interpretation.spiritualMeaning ?? interpretation.psychologicalMeaning,
                );
                await dreamService.saveDream(dream);

                if (mounted) {
                  final navContext = context;
                  Navigator.of(navContext).push(
                    MaterialPageRoute(
                      builder: (_) => DreamInterpretationScreen(interpretation: interpretation),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Analyze Dream'),
            ),
            const SizedBox(height: 24),
            Text(
              'Recent Dreams',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            // TODO: Stream recent dreams from Firestore
            const Text('No dreams logged yet.'),
          ],
        ),
      ),
    );
  }
}

class DreamInterpretationScreen extends StatelessWidget {
  final DreamInterpretation interpretation;

  const DreamInterpretationScreen({
    super.key,
    required this.interpretation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream Interpretation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (interpretation.symbolicMeaning.isNotEmpty) ...[
              _buildSection(
                context,
                'Symbolic Meaning',
                interpretation.symbolicMeaning,
                Icons.lightbulb,
              ),
              const SizedBox(height: 24),
            ],
            if (interpretation.psychologicalMeaning.isNotEmpty) ...[
              _buildSection(
                context,
                'Psychological Interpretation',
                interpretation.psychologicalMeaning,
                Icons.psychology,
              ),
              const SizedBox(height: 24),
            ],
            if (interpretation.spiritualMeaning != null && interpretation.spiritualMeaning!.isNotEmpty) ...[
              _buildSection(
                context,
                'Spiritual Interpretation',
                interpretation.spiritualMeaning!,
                Icons.spa,
              ),
              const SizedBox(height: 24),
            ],
            if (interpretation.themes.isNotEmpty) ...[
              Text(
                'Themes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: interpretation.themes.map((theme) => Chip(
                      label: Text(theme),
                      backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    )).toList(),
              ),
              const SizedBox(height: 24),
            ],
            if (interpretation.suggestedAction.isNotEmpty) ...[
              _buildSection(
                context,
                'Recommendations',
                interpretation.suggestedAction,
                Icons.check_circle,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

