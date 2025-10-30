import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/providers/yoga_provider.dart';

class YogaRoutineScreen extends ConsumerStatefulWidget {
  const YogaRoutineScreen({super.key});

  @override
  ConsumerState<YogaRoutineScreen> createState() => _YogaRoutineScreenState();
}

class _YogaRoutineScreenState extends ConsumerState<YogaRoutineScreen> {
  String? _level;
  String? _focus;

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(yogaSessionsProvider({
      'level': _level,
      'focus': _focus,
      'limit': 20,
    }));

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
                    child: Text('Yoga Routines', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  DropdownButton<String?>(
                    value: _level,
                    hint: const Text('Level'),
                    dropdownColor: AppColors.surface,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                      DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
                      DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                    ],
                    onChanged: (v) => setState(() => _level = v),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String?>(
                    value: _focus,
                    hint: const Text('Focus'),
                    dropdownColor: AppColors.surface,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(value: 'flexibility', child: Text('Flexibility')),
                      DropdownMenuItem(value: 'strength', child: Text('Strength')),
                      DropdownMenuItem(value: 'relaxation', child: Text('Relaxation')),
                    ],
                    onChanged: (v) => setState(() => _focus = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: sessionsAsync.when(
                data: (sessions) => ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sessions.length,
                  itemBuilder: (context, i) {
                    final s = sessions[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AuraCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text((s['name'] ?? 'Yoga Session') as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Text('${s['duration'] ?? 20} min • ${(s['level'] ?? 'beginner')} • ${(s['focus'] ?? 'relaxation')}',
                                style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
