import 'package:flutter/material.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import '../theme/app_colors.dart';

/// Interactive Body Map Widget - MuscleWiki-style
/// Tap muscle groups to select/deselect
class BodyMapWidget extends StatefulWidget {
  final List<String>? initialSelection;
  final ValueChanged<List<String>>? onSelectionChanged;
  final bool multiSelect;

  const BodyMapWidget({
    super.key,
    this.initialSelection,
    this.onSelectionChanged,
    this.multiSelect = true,
  });

  @override
  State<BodyMapWidget> createState() => _BodyMapWidgetState();
}

class _BodyMapWidgetState extends State<BodyMapWidget> {
  final Set<String> _selectedMuscleGroups = {};

  final Map<String, MuscleGroup> _muscleGroups = {
    'chest': MuscleGroup(
        name: 'Chest', region: MuscleRegion.upper, icon: LucideIcons.heart),
    'back': MuscleGroup(
        name: 'Back', region: MuscleRegion.upper, icon: LucideIcons.arrowDown),
    'shoulders': MuscleGroup(
        name: 'Shoulders', region: MuscleRegion.upper, icon: LucideIcons.user),
    'biceps': MuscleGroup(
        name: 'Biceps', region: MuscleRegion.upper, icon: LucideIcons.zap),
    'triceps': MuscleGroup(
        name: 'Triceps',
        region: MuscleRegion.upper,
        icon: LucideIcons.activity),
    'forearms': MuscleGroup(
        name: 'Forearms', region: MuscleRegion.upper, icon: LucideIcons.hand),
    'abs': MuscleGroup(
        name: 'Abs', region: MuscleRegion.core, icon: LucideIcons.circle),
    'obliques': MuscleGroup(
        name: 'Obliques', region: MuscleRegion.core, icon: LucideIcons.circle),
    'quads': MuscleGroup(
        name: 'Quads',
        region: MuscleRegion.lower,
        icon: LucideIcons.trendingUp),
    'hamstrings': MuscleGroup(
        name: 'Hamstrings',
        region: MuscleRegion.lower,
        icon: LucideIcons.trendingDown),
    'glutes': MuscleGroup(
        name: 'Glutes', region: MuscleRegion.lower, icon: LucideIcons.square),
    'calves': MuscleGroup(
        name: 'Calves',
        region: MuscleRegion.lower,
        icon: LucideIcons.arrowDown),
    'cardio': MuscleGroup(
        name: 'Cardio', region: MuscleRegion.full, icon: LucideIcons.zap),
    'full body': MuscleGroup(
        name: 'Full Body',
        region: MuscleRegion.full,
        icon: LucideIcons.activity),
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialSelection != null) {
      _selectedMuscleGroups.addAll(widget.initialSelection!);
    }
  }

  void _toggleMuscleGroup(String muscleGroup) {
    setState(() {
      if (_selectedMuscleGroups.contains(muscleGroup)) {
        _selectedMuscleGroups.remove(muscleGroup);
      } else {
        if (!widget.multiSelect) {
          _selectedMuscleGroups.clear();
        }
        _selectedMuscleGroups.add(muscleGroup);
      }
    });
    widget.onSelectionChanged?.call(_selectedMuscleGroups.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Muscle Groups',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          // Muscle group chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _muscleGroups.entries.map((entry) {
              final isSelected = _selectedMuscleGroups.contains(entry.key);
              return GestureDetector(
                onTap: () => _toggleMuscleGroup(entry.key),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.primaryGradient : null,
                    color: isSelected ? null : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        entry.value.icon,
                        size: 18,
                        color:
                            isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.value.name,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selectedMuscleGroups.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primary.withAlpha((0.3 * 255).round())),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.checkCircle,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedMuscleGroups.length} muscle group(s) selected',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum MuscleRegion { upper, core, lower, full }

class MuscleGroup {
  final String name;
  final MuscleRegion region;
  final IconData icon;

  MuscleGroup({
    required this.name,
    required this.region,
    required this.icon,
  });
}
