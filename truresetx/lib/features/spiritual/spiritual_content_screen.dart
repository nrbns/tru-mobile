import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/backend_providers.dart';
import '../../data/models/spiritual_models.dart';
import '../../core/services/tts_service.dart';

class SpiritualContentScreen extends ConsumerStatefulWidget {
  const SpiritualContentScreen({super.key});

  @override
  ConsumerState<SpiritualContentScreen> createState() =>
      _SpiritualContentScreenState();
}

class _SpiritualContentScreenState extends ConsumerState<SpiritualContentScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedChapter = 1;
  int _selectedVerse = 1;
  bool _isTtsPlaying = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiritual Content'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.menu_book), text: 'Gita'),
            Tab(icon: Icon(Icons.lightbulb), text: 'Wisdom'),
            Tab(icon: Icon(Icons.trending_up), text: 'Progress'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGitaTab(),
          _buildWisdomTab(),
          _buildProgressTab(),
        ],
      ),
    );
  }

  Widget _buildGitaTab() {
    final params = {'chapter': _selectedChapter, 'verse': _selectedVerse};
    final verseAsync = ref.watch(gitaVerseStreamProvider(params));

    return Column(
      children: [
        _buildVerseSelector(),
        Expanded(
          child: verseAsync.when(
            data: (verse) => _buildVerseContent(verse),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error loading verse: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildVerseSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha((0.1 * 255).round()),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Chapter',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<int>(
                      value: _selectedChapter,
                      isExpanded: true,
                      items: List.generate(18, (index) => index + 1)
                          .map((chapter) => DropdownMenuItem(
                              value: chapter, child: Text('Chapter $chapter')))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedChapter = value!;
                          _selectedVerse = 1;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Verse',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<int>(
                      value: _selectedVerse,
                      isExpanded: true,
                      items: List.generate(50, (index) => index + 1)
                          .map((verse) => DropdownMenuItem(
                              value: verse, child: Text('Verse $verse')))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedVerse = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => setState(() {}),
                icon: const Icon(Icons.refresh),
                label: const Text('Load Verse'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final tts = ref.read(ttsServiceProvider);
                  setState(() => _isTtsPlaying = true);
                  await tts
                      .speak('Loading verse $_selectedChapter:$_selectedVerse');
                  setState(() => _isTtsPlaying = false);
                },
                icon: const Icon(Icons.volume_up),
                label: const Text('Announce'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerseContent(GitaVerse verse) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _verseHeader(verse),
          const SizedBox(height: 16),
          _textCard('Sanskrit', verse.sanskrit, fontFamily: 'serif'),
          const SizedBox(height: 12),
          _textCard('Translation', verse.translation),
          if (verse.transliteration != null) ...[
            const SizedBox(height: 12),
            _textCard('Transliteration', verse.transliteration!),
          ],
          if (verse.commentary != null) ...[
            const SizedBox(height: 12),
            _textCard('Commentary', verse.commentary!),
          ],
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(spiritualProgressProvider.notifier).readVerse();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Verse marked as read!'),
                      backgroundColor: Colors.green));
                },
                icon: const Icon(Icons.check),
                label: const Text('Mark as Read'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final tts = ref.read(ttsServiceProvider);
                  setState(() => _isTtsPlaying = true);
                  await tts.speak(verse.translation);
                  setState(() => _isTtsPlaying = false);
                },
                icon: Icon(_isTtsPlaying ? Icons.stop : Icons.play_arrow),
                label: Text(_isTtsPlaying ? 'Stop' : 'Listen'),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _verseHeader(GitaVerse verse) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.orange.withAlpha(25), Colors.red.withAlpha(20)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(verse.reference,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange)),
          const SizedBox(height: 8),
          Text(verse.chapterTitle, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _textCard(String title, String text, {String? fontFamily}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 8),
        Text(text, style: TextStyle(fontSize: 16, fontFamily: fontFamily)),
      ]),
    );
  }

  Widget _buildWisdomTab() {
    final wisdomAsync = ref.watch(wisdomStreamProvider);
    return wisdomAsync.when(
      data: (wisdom) => _buildWisdomContent(wisdom),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading wisdom: $e')),
    );
  }

  Widget _buildWisdomContent(WisdomItem wisdom) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 6)
              ]),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(wisdom.categoryIcon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(wisdom.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)))
            ]),
            const SizedBox(height: 12),
            Text(wisdom.body,
                style: const TextStyle(fontSize: 16, height: 1.5)),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          OutlinedButton.icon(
              onPressed: () {
                ref
                    .read(spiritualProgressProvider.notifier)
                    .completeWisdomItem();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Wisdom item marked complete'),
                    backgroundColor: Colors.green));
              },
              icon: const Icon(Icons.check),
              label: const Text('Mark Complete')),
          const SizedBox(width: 12),
          ElevatedButton.icon(
              onPressed: () async {
                await ref.read(ttsServiceProvider).speak(wisdom.body);
              },
              icon: const Icon(Icons.volume_up),
              label: const Text('Listen')),
        ])
      ]),
    );
  }

  Widget _buildProgressTab() {
    final progressAsync = ref.watch(spiritualProgressStreamProvider);
    final progressNotifier = ref.watch(spiritualProgressProvider);

    return progressAsync.when(
      data: (_) => _buildProgressContent(progressNotifier),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading progress: $e')),
    );
  }

  Widget _buildProgressContent(SpiritualProgress? progress) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.purple.withAlpha(25),
                Colors.blue.withAlpha(25)
              ]),
              borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            const Text('Spiritual Progress',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (progress != null) ...[
              Text('${progress.streakEmoji} ${progress.streak} day streak',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                      value: progress.overallProgress,
                      strokeWidth: 8,
                      valueColor: const AlwaysStoppedAnimation(Colors.purple))),
              const SizedBox(height: 8),
              Text('${progress.progressPercentage}% Complete',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ] else ...[
              const Text(
                  'No progress yet — begin by reading a verse or completing a wisdom item!',
                  style: TextStyle(color: Colors.grey)),
            ]
          ]),
        ),
        const SizedBox(height: 12),
        if (progress != null) ...[
          _buildProgressSection(
              'Wisdom Items',
              progress.wisdomCompletionRate,
              '${progress.completedItems}/${progress.totalWisdomItems}',
              Colors.blue),
          const SizedBox(height: 12),
          _buildProgressSection('Sacred Verses', progress.verseCompletionRate,
              '${progress.readVerses}/${progress.totalVerses}', Colors.green),
        ]
      ]),
    );
  }

  Widget _buildProgressSection(
      String title, double progress, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 4)
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(count,
              style: TextStyle(color: color, fontWeight: FontWeight.bold))
        ]),
        const SizedBox(height: 8),
        LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(color)),
      ]),
    );
  }
}
