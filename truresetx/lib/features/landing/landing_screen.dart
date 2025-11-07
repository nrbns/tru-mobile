import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A simple, modern landing screen with a hero and CTA that opens the main app.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo / mark (SVG from assets)
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(31),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/logo.svg',
                        width: 56,
                        height: 56,
                        colorFilter: ColorFilter.mode(
                            theme.colorScheme.primary, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('TruResetX',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    'A human-centered Life OS — resilience, coaching, and simple daily routines.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(179),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // CTA buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/app'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Open the App'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () async {
                          // Open the external landing reference in a new tab when available.
                          // Use Navigator fallback to /home when running as an app without url launcher.
                          try {
                            // Prefer to navigate to the in-app home as a fallback.
                            Navigator.of(context).pushNamed('/home');
                          } catch (_) {
                            Navigator.of(context).pushNamed('/home');
                          }
                        },
                        child: const Text('Explore features'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Small feature bullets
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _FeatureChip(label: 'Privacy-first'),
                      _FeatureChip(label: 'Realtime coaching'),
                      _FeatureChip(label: 'Multi-backend auth'),
                      _FeatureChip(label: 'Personalized plans'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }
}
