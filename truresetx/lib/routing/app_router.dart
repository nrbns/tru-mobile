import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import '../features/home/today_dashboard_pro.dart';
import '../features/lists/lists_screen.dart';
import '../features/lists/list_detail_screen.dart';
import '../features/lists/add_list_screen.dart';
import '../features/lists/add_item_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/lifeos/life_os_overview.dart';
import '../features/auth/auth_screen.dart';
import '../core/services/current_user_provider.dart';
import '../core/services/auth_service.dart';
import '../core/services/profile_service.dart';
import '../features/mood/mood_tracking_screen.dart';
import '../features/nutrition/food_tracking_screen.dart';
import '../features/nutrition/water_logging_screen.dart';
import '../features/nutrition/manual_food_input.dart';
import '../features/spiritual/spiritual_content_screen.dart';
import '../features/metrics/weight_logger_screen.dart';
import '../features/profile/profile_setup_screen.dart';
import '../features/profile/user_dashboard_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/devices/device_management_screen.dart';
import '../features/coach/ai_coach_chat_screen.dart';
import '../features/recommendations/recommendations_inbox.dart';
import '../features/recommendations/recommendation_detail_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'homeNav');
final _listsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'listsNav');
final _profileNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'profileNav');
final _lifeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'lifeNav');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/',
        redirect: (context, state) => '/home',
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffold(navShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
              GoRoute(
                path: '/today',
                name: 'today',
                builder: (context, state) => const TodayDashboardPro(),
              ),
              GoRoute(
                path: '/mood',
                name: 'mood',
                builder: (context, state) => const MoodTrackingScreen(),
              ),
              GoRoute(
                path: '/nutrition/food',
                name: 'food-tracking',
                builder: (context, state) => const FoodTrackingScreen(),
              ),
              GoRoute(
                path: '/nutrition/water',
                name: 'water-logging',
                builder: (context, state) => const WaterLoggingScreen(),
              ),
              GoRoute(
                path: '/nutrition/manual',
                name: 'manual-food-input',
                builder: (context, state) => ManualFoodInputScreen(
                  onFoodAdded: (_) {},
                ),
              ),
              GoRoute(
                path: '/spiritual',
                name: 'spiritual',
                builder: (context, state) => const SpiritualContentScreen(),
              ),
              GoRoute(
                path: '/metrics/weight',
                name: 'weight-logger',
                builder: (context, state) => const WeightLoggerScreen(),
              ),
              GoRoute(
                path: '/coach/chat',
                name: 'ai-coach',
                builder: (context, state) => const AICoachChatScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _listsNavigatorKey,
            routes: [
              GoRoute(
                path: '/lists',
                name: 'lists',
                builder: (context, state) => const ListsScreen(),
              ),
              GoRoute(
                path: '/lists/add',
                name: 'lists-add',
                builder: (context, state) => const AddListScreen(),
              ),
              GoRoute(
                path: '/lists/detail/:listId',
                name: 'list-detail',
                builder: (context, state) {
                  final listId = state.pathParameters['listId']!;
                  return ListDetailScreen(listId: listId);
                },
              ),
              GoRoute(
                path: '/lists/detail/:listId/add-item',
                name: 'add-item',
                builder: (context, state) {
                  final listId = state.pathParameters['listId']!;
                  return AddItemScreen(listId: listId);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
              GoRoute(
                path: '/profile/setup',
                name: 'profile-setup',
                builder: (context, state) => Consumer(
                  builder: (context, ref, _) {
                    final userId = ref.read(currentUserIdProvider);
                    final auth = ref.read(authServiceProvider);
                    if (userId == null || auth.userEmail == null) {
                      return const AuthScreen();
                    }
                    return ProfileSetupScreen(
                      userId: userId,
                      email: auth.userEmail!,
                    );
                  },
                ),
              ),
              GoRoute(
                path: '/profile/dashboard',
                name: 'profile-dashboard',
                builder: (context, state) => Consumer(
                  builder: (context, ref, _) {
                    final profileAsync = ref.watch(currentUserProfileProvider);
                    return profileAsync.when(
                      data: (profile) {
                        if (profile == null) return const ProfileScreen();
                        return UserDashboardScreen(profile: profile);
                      },
                      loading: () => const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, st) => Scaffold(
                        body: Center(child: Text('Error: $e')),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _lifeNavigatorKey,
            routes: [
              GoRoute(
                path: '/life-os',
                name: 'life-os',
                builder: (context, state) => const LifeOSOverview(),
              ),
              GoRoute(
                path: '/devices',
                name: 'devices',
                builder: (context, state) => const DeviceManagementScreen(),
              ),
              GoRoute(
                path: '/recommendations',
                name: 'recommendations',
                builder: (context, state) => Consumer(
                  builder: (context, ref, _) {
                    final userId = ref.read(currentUserIdProvider);
                    if (userId == null) return const AuthScreen();
                    return RecommendationsInbox();
                  },
                ),
              ),
              GoRoute(
                path: '/recommendation',
                name: 'recommendation',
                builder: (context, state) => RecommendationDetailScreen(),
              ),
              GoRoute(
                path: '/recommendation/:id',
                name: 'recommendation-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id'];
                  return RecommendationDetailScreen(id: id);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/add-list',
        redirect: (context, state) => '/lists/add',
      ),
    ],
  );
});

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.navShell});

  final StatefulNavigationShell navShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navShell.currentIndex,
        onDestinationSelected: (index) => navShell.goBranch(
          index,
          initialLocation: index == navShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_outlined),
            selectedIcon: Icon(Icons.list),
            label: 'Lists',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.eco_outlined),
            selectedIcon: Icon(Icons.eco),
            label: 'Life OS',
          ),
        ],
      ),
    );
  }
}
