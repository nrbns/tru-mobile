import 'package:flutter/material.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';

class PermissionsSetupScreen extends StatefulWidget {
  const PermissionsSetupScreen({super.key});

  @override
  State<PermissionsSetupScreen> createState() => _PermissionsSetupScreenState();
}

class _PermissionsSetupScreenState extends State<PermissionsSetupScreen> {
  final Map<String, bool> _permissions = {
    'Notifications': false,
    'Location': false,
    'Health Data': false,
    'Camera': false,
    'Microphone': false,
  };

  void _togglePermission(String key) {
    setState(() {
      _permissions[key] = !_permissions[key]!;
    });
  }

  void _handleContinue() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon:
                        const Icon(LucideIcons.arrowLeft, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Enable Permissions',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'These permissions help us provide a better experience',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            // Permissions List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _permissions.length,
                itemBuilder: (context, index) {
                  final key = _permissions.keys.elementAt(index);
                  final enabled = _permissions[key]!;
                  IconData icon;
                  String description;

                  switch (key) {
                    case 'Notifications':
                      icon = LucideIcons.bell;
                      description = 'Get reminders for practices and goals';
                      break;
                    case 'Location':
                      icon = LucideIcons.mapPin;
                      description = 'Track your activity and location';
                      break;
                    case 'Health Data':
                      icon = LucideIcons.activity;
                      description = 'Sync with health apps';
                      break;
                    case 'Camera':
                      icon = LucideIcons.camera;
                      description = 'Take photos for journal entries';
                      break;
                    case 'Microphone':
                      icon = LucideIcons.mic;
                      description = 'Record audio notes and meditations';
                      break;
                    default:
                      icon = LucideIcons.settings;
                      description = 'Permission for app features';
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AuraCard(
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary
                                .withAlpha((0.1 * 255).round()),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: AppColors.primary, size: 24),
                        ),
                        title: Text(
                          key,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          description,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        trailing: Switch(
                          value: enabled,
                          onChanged: (_) => _togglePermission(key),
                          activeThumbColor: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Continue Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
