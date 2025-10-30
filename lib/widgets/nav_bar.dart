import 'package:flutter/material.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import '../theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/app_state_provider.dart';
import 'package:go_router/go_router.dart';

class NavBar extends ConsumerWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(appStateProvider).currentTab;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: LucideIcons.home,
                label: 'Home',
                route: '/home',
                isActive: currentTab == 'home',
                onTap: () {
                  ref.read(appStateProvider.notifier).setCurrentTab('home');
                  context.go('/home');
                },
              ),
              _NavItem(
                icon: LucideIcons.brain,
                label: 'Mind',
                route: '/mind',
                isActive: currentTab == 'mind',
                onTap: () {
                  ref.read(appStateProvider.notifier).setCurrentTab('mind');
                  context.go('/mind');
                },
              ),
              _NavItem(
                icon: LucideIcons.heart,
                label: 'Spirit',
                route: '/spirit',
                isActive: currentTab == 'spirit',
                onTap: () {
                  ref.read(appStateProvider.notifier).setCurrentTab('spirit');
                  context.go('/spirit');
                },
              ),
              _NavItem(
                icon: LucideIcons.nutrition,
                label: 'Nutrition',
                route: '/home/nutrition',
                isActive: currentTab == 'nutrition',
                onTap: () {
                  ref
                      .read(appStateProvider.notifier)
                      .setCurrentTab('nutrition');
                  context.go('/home/nutrition');
                },
              ),
              _NavItem(
                icon: LucideIcons.user,
                label: 'Profile',
                route: '/profile',
                isActive: currentTab == 'profile',
                onTap: () {
                  ref.read(appStateProvider.notifier).setCurrentTab('profile');
                  context.go('/profile');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
