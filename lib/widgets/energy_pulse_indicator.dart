import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/agent_providers.dart';
import '../core/services/energy_pulse_service.dart';

/// Energy Pulse Indicator - Mini visualization for dashboard
class EnergyPulseIndicator extends ConsumerWidget {
  const EnergyPulseIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pulseAsync = ref.watch(energyPulseProvider);

    return pulseAsync.when(
      data: (pulse) => GestureDetector(
        onTap: () => Navigator.of(context).pushNamed('/agent/energy-pulse'),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getColorForState(pulse.state).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getColorForState(pulse.state),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getColorForState(pulse.state),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Energy Pulse',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${(pulse.overallBalance * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getColorForState(pulse.state),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      loading: () => const SizedBox(
        width: 80,
        height: 40,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Color _getColorForState(PulseState state) {
    switch (state) {
      case PulseState.peak:
        return Colors.green;
      case PulseState.balanced:
        return Colors.blue;
      case PulseState.low:
        return Colors.orange;
      case PulseState.critical:
        return Colors.red;
    }
  }
}

