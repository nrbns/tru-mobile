import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/providers/karma_provider.dart';
import '../../core/models/karma_log.dart';

class KarmaTrackerScreen extends ConsumerStatefulWidget {
  const KarmaTrackerScreen({super.key});

  @override
  ConsumerState<KarmaTrackerScreen> createState() => _KarmaTrackerScreenState();
}

class _KarmaTrackerScreenState extends ConsumerState<KarmaTrackerScreen> {
  final TextEditingController _activity = TextEditingController();
  String _category = 'virtue';
  int _impact = 1;

  @override
  void dispose() {
    _activity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(karmaLogsStreamProvider(50));

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
                    child: Text('Karma Tracker',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600)),
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
                    TextField(
                      controller: _activity,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Activity (e.g., helped a friend)',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        DropdownButton<String>(
                          value: _category,
                          dropdownColor: AppColors.surface,
                          items: const [
                            DropdownMenuItem(
                                value: 'virtue', child: Text('Virtue')),
                            DropdownMenuItem(
                                value: 'discipline', child: Text('Discipline')),
                            DropdownMenuItem(
                                value: 'service', child: Text('Service')),
                          ],
                          onChanged: (v) =>
                              setState(() => _category = v ?? 'virtue'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Slider(
                            value: _impact.toDouble(),
                            min: -10,
                            max: 10,
                            divisions: 20,
                            label: '$_impact',
                            onChanged: (v) =>
                                setState(() => _impact = v.round()),
                          ),
                        ),
                        Text('$_impact',
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () async {
                          final text = _activity.text.trim();
                          if (text.isEmpty) return;
                          final service = ref.read(karmaLogServiceProvider);
                          final log = KarmaLog(
                            userId: '', // Will be set by service
                            activity: text,
                            impactScore: _impact,
                            reflection: null,
                            timestamp: DateTime.now(),
                            category: _category,
                          );
                          await service.addLog(log);
                          _activity.clear();
                          setState(() => _impact = 1); // Reset slider
                        },
                        child: const Text('Log'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: logsAsync.when(
                data: (logs) => ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: logs.length,
                  itemBuilder: (context, i) {
                    final log = logs[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AuraCard(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.secondary
                                    .withAlpha((0.2 * 255).round()),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('${log['impactScore']}',
                                  style: const TextStyle(
                                      color: AppColors.secondary)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(log['activity'] as String? ?? '',
                                  style: const TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 12),
                            Text(log['category'] as String? ?? '',
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                    child: Text('Error: $e',
                        style: const TextStyle(color: Colors.red))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
