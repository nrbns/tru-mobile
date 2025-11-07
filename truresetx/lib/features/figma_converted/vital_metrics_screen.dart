import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class VitalMetricsScreen extends StatelessWidget {
  const VitalMetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vital Metrics'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              SvgPicture.asset('assets/icons/logo.svg', width: 32, height: 32),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Placeholder cards matching the Figma layout; replace with real widgets and assets.
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(
                4,
                (i) => SizedBox(
                  width: (MediaQuery.of(context).size.width - 64) / 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Metric ${i + 1}',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text('Value',
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Notes', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Short contextual explanation and actions.'),
          ],
        ),
      ),
    );
  }
}
