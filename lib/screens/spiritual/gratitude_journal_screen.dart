import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/providers/gratitude_provider.dart';

class GratitudeJournalScreen extends ConsumerStatefulWidget {
  const GratitudeJournalScreen({super.key});

  @override
  ConsumerState<GratitudeJournalScreen> createState() =>
      _GratitudeJournalScreenState();
}

class _GratitudeJournalScreenState
    extends ConsumerState<GratitudeJournalScreen> {
  final TextEditingController _textController = TextEditingController();
  String _type = 'gratitude';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(gratitudeEntriesStreamProvider(100));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gratitude Journal',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Morning gratitude and night reflections',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AuraCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Gratitude'),
                          selected: _type == 'gratitude',
                          onSelected: (_) =>
                              setState(() => _type = 'gratitude'),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Reflection'),
                          selected: _type == 'reflection',
                          onSelected: (_) =>
                              setState(() => _type = 'reflection'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _textController,
                      minLines: 3,
                      maxLines: 6,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Write your thoughts...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () async {
                          final text = _textController.text.trim();
                          if (text.isEmpty) return;
                          final service =
                              ref.read(gratitudeJournalServiceProvider);
                          await service.addEntry(type: _type, text: text);
                          _textController.clear();
                        },
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: entriesAsync.when(
                data: (entries) {
                  if (entries.isEmpty) {
                    return Center(
                      child: Text('No entries yet',
                          style: TextStyle(color: Colors.grey[400])),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final e = entries[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AuraCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.type == 'reflection'
                                    ? 'Night Reflection'
                                    : 'Gratitude',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                e.text,
                                style: TextStyle(
                                    color: Colors.grey[300], height: 1.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                e.date.toLocal().toString(),
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Text('Error: $err',
                      style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
