// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ✅ ADDED THIS LINE

// Screens
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/settings_screen.dart';

// Widgets
import 'widgets/common/quick_actions_dialog.dart';
import 'widgets/common/custom_bottom_nav.dart';

// Providers
import 'providers/home_provider.dart';
import 'providers/exercise_provider.dart';
import 'providers/progress_data.dart';
import 'providers/settings_provider.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/navigation_provider.dart';

// Config
import 'config/design_system/theme_design.dart';

// Services
import 'services/app_initialization_service.dart';

// Localization
import 'l10n/generated/app_localizations.dart';

// Global navigator key for accessing navigator from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ ADDED: Load .env file before anything else
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('✅ .env file loaded successfully');
  } catch (e) {
    debugPrint('❌ Error loading .env file: $e');
  }

  // Initialize SharedPreferences
  try {
    await SharedPreferences.getInstance();
    debugPrint('✅ SharedPreferences initialized successfully');
  } catch (e) {
    debugPrint('❌ Error initializing SharedPreferences: $e');
  }

  // Initialize app (includes cleaning up old food card images)
  try {
    await AppInitializationService.initialize();
  } catch (e) {
    debugPrint('❌ Error during app initialization: $e');
  }

  runApp(const FoodTrackerApp());
}

class FoodTrackerApp extends StatelessWidget {
  const FoodTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadGradient()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()..loadLanguage()),
        ChangeNotifierProvider(create: (_) => HomeProvider()..loadData()),
        ChangeNotifierProvider(create: (_) => ExerciseProvider()..loadData()),
        ChangeNotifierProvider(create: (_) => ProgressData()..loadUserData()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..loadUserData()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Food Tracker',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            locale: languageProvider.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('zh', 'CN'),
              Locale('zh', 'TW'),
            ],
            home: const SplashScreen(),
            routes: {
              '/home': (context) => const MainScreen(),
              '/settings': (context) => const SettingsScreen(showBackButton: true),
            },
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const List<Widget> _screens = [
    HomeScreen(),
    ProgressScreen(),
    SummaryScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Listen to navigation changes and refresh data accordingly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
      navigationProvider.addListener(_onNavigationChanged);
    });
  }

  @override
  void dispose() {
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    navigationProvider.removeListener(_onNavigationChanged);
    super.dispose();
  }

  /// Called whenever navigation index changes
  /// Refreshes data for the newly visible page
  void _onNavigationChanged() {
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    final currentIndex = navigationProvider.currentIndex;

    // Refresh data for the current page to ensure it shows latest values
    switch (currentIndex) {
      case 0: // Home
        Provider.of<HomeProvider>(context, listen: false).refreshData();
        break;
      case 1: // Progress
        Provider.of<ExerciseProvider>(context, listen: false).refreshData();
        Provider.of<ProgressData>(context, listen: false).refreshData();
        break;
      case 3: // Summary (index 3, not 2 because camera is 2)
        // Summary page refreshes automatically via Consumer widgets
        break;
      case 4: // Settings
        Provider.of<SettingsProvider>(context, listen: false).refreshData();
        break;
    }
  }

  // Map bottom nav index to screen index (handling camera special case)
  int _getScreenIndex(int navIndex) {
    // Nav items: Home(0), Progress(1), Camera(2), Summary(3), Settings(4)
    if (navIndex == 2) return 0; // Camera - show home in background
    if (navIndex > 2) return navIndex - 1; // Adjust for camera offset
    return navIndex;
  }

  void _handleNavTap(BuildContext context, int index) {
    if (index == 2) {
      // Show Quick Actions dialog instead of navigating
      showQuickActionsDialog(context);
      // Don't change index - stay on current screen
    } else {
      // Use NavigationProvider to change the index
      Provider.of<NavigationProvider>(context, listen: false).navigateTo(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        final currentIndex = navProvider.currentIndex;

        return Scaffold(
          body: Stack(
            children: [
              // Show current screen, with bounds checking
              _screens[_getScreenIndex(currentIndex).clamp(0, _screens.length - 1)],

              // Bottom navigation
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: CustomBottomNav(
                  currentIndex: currentIndex,
                  onTap: (index) => _handleNavTap(context, index),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}