import 'package:app/app/navigation/app_routes.dart';
import 'package:app/app/theme/theme_mode_controller.dart';
import 'package:app/features/auth/presentation/login_screen.dart';
import 'package:app/features/auth/presentation/signup_screen.dart';
import 'package:app/features/explore/presentation/explore_screen.dart';
import 'package:app/features/home/presentation/home_screen.dart';
import 'package:app/features/marketplace/presentation/marketplace_screen.dart';
import 'package:app/features/messaging/presentation/messaging_screen.dart';
import 'package:app/features/groups/presentation/groups_screen.dart';
import 'package:app/features/cockpit/presentation/cockpit_directory_screen.dart';
import 'package:app/features/farm/presentation/farm_dashboard_screen.dart';
import 'package:app/features/bloodline/presentation/bloodline_registry_screen.dart';
import 'package:app/features/qr/presentation/qr_leg_bands_screen.dart';
import 'package:app/features/health/presentation/health_records_screen.dart';
import 'package:app/features/weight/presentation/weight_tracker_screen.dart';
import 'package:app/features/breeding/presentation/breeding_planner_screen.dart';
import 'package:app/features/learn/presentation/learn_hub_screen.dart';
import 'package:app/features/profile/presentation/profile_screen.dart';
import 'package:app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:app/features/splash/presentation/splash_screen.dart';
import 'package:app/features/news_feed/presentation/news_feed_screen.dart';
import 'package:app/features/subscription/presentation/subscription_screen.dart';
import 'package:flutter/material.dart';

class FarmBuzzApp extends StatefulWidget {
  const FarmBuzzApp({
    super.key,
    required this.theme,
    required this.darkTheme,
    required this.themeMode,
  });

  final ThemeData theme;
  final ThemeData darkTheme;
  final ThemeMode themeMode;

  @override
  State<FarmBuzzApp> createState() => _FarmBuzzAppState();
}

class _FarmBuzzAppState extends State<FarmBuzzApp> {
  @override
  void initState() {
    super.initState();
    ThemeModeController.setMode(widget.themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeModeController.mode,
      builder: (context, mode, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FarmBuzz',
        theme: widget.theme,
        darkTheme: widget.darkTheme,
        themeMode: mode,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.onboarding: (_) => const OnboardingScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.signup: (_) => const SignUpScreen(),
          AppRoutes.subscription: (_) => const SubscriptionScreen(),
          AppRoutes.newsFeed: (_) => const NewsFeedScreen(),
          AppRoutes.explore: (_) => const ExploreScreen(),
          AppRoutes.marketplace: (_) => const MarketplaceScreen(),
          AppRoutes.profile: (_) => const ProfileScreen(),
          AppRoutes.messaging: (_) => const MessagingScreen(),
          AppRoutes.groups: (_) => const GroupsScreen(),
          AppRoutes.cockpitDirectory: (_) => const CockpitDirectoryScreen(),
          AppRoutes.learnHub: (_) => const LearnHubScreen(),
          AppRoutes.farmDashboard: (_) => const FarmDashboardScreen(),
          AppRoutes.bloodlineRegistry: (_) => const BloodlineRegistryScreen(),
          AppRoutes.qrLegBands: (_) => const QrLegBandsScreen(),
          AppRoutes.healthRecords: (_) => const HealthRecordsScreen(),
          AppRoutes.weightTracker: (_) => const WeightTrackerScreen(),
          AppRoutes.breedingPlanner: (_) => const BreedingPlannerScreen(),
        },
      ),
    );
  }
}
