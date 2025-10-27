// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/settings_screen.dart';

// Providers
import 'providers/home_provider.dart';
import 'providers/exercise_provider.dart';
import 'providers/progress_data.dart';
import 'providers/settings_provider.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';

// Config
import 'config/design_system/theme.dart';
import 'config/dependency_injection.dart';

// Localization
import 'l10n/generated/app_localizations.dart';

// Widgets
import 'widgets/common/custom_bottom_nav.dart';
import 'widgets/common/custom_app_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  try {
    await SharedPreferences.getInstance();
    debugPrint('✅ SharedPreferences initialized successfully');
  } catch (e) {
    debugPrint('❌ Error initializing SharedPreferences: $e');
  }

  // Initialize dependency injection
  await setupDependencyInjection();
  debugPrint('✅ Dependency Injection initialized');

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
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'Food Tracker',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
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
  int _currentIndex = 0;

  // 4 actual screens (Camera is an overlay, not a screen)
  final List<Widget> _screens = const [
    HomeScreen(),      // Index 0
    ProgressScreen(),  // Index 1
    SummaryScreen(),   // Index 2
    SettingsScreen(),  // Index 3
  ];

  void _onItemTapped(int navIndex) {
    debugPrint('🔵 Nav tapped: index $navIndex');
    
    // Bottom nav indices: 0(Home), 1(Progress), 2(Camera), 3(Summary), 4(Settings)
    // Screen indices:     0(Home), 1(Progress),           2(Summary), 3(Settings)
    
    if (navIndex == 2) {
      // Camera tap - show overlay
      _showCameraOverlay();
      return;
    }

    // Map nav index to screen index
    final screenIndex = _mapNavToScreen(navIndex);
    debugPrint('🔵 Mapped to screen index: $screenIndex');
    
    setState(() {
      _currentIndex = screenIndex;
    });
  }

  /// Map bottom nav index to screen array index
  int _mapNavToScreen(int navIndex) {
    switch (navIndex) {
      case 0:
        return 0; // Home
      case 1:
        return 1; // Progress
      case 3:
        return 2; // Summary
      case 4:
        return 3; // Settings
      default:
        debugPrint('⚠️ Unexpected nav index: $navIndex');
        return 0;
    }
  }

  /// Map screen index to nav index for highlighting
  int _mapScreenToNav(int screenIndex) {
    switch (screenIndex) {
      case 0:
        return 0; // Home
      case 1:
        return 1; // Progress
      case 2:
        return 3; // Summary
      case 3:
        return 4; // Settings
      default:
        return 0;
    }
  }

  void _showCameraOverlay() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return CameraScreen(
            onDismissed: () {
              // Camera dismissed, no state change needed
            },
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  String _getCurrentPageSubtitle() {
    switch (_currentIndex) {
      case 0:
        return 'Daily Nutrition';
      case 1:
        return 'Activity & Progress';
      case 2:
        return 'Analytics Dashboard';
      case 3:
        return 'App Settings';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔵 Building with currentIndex: $_currentIndex');
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        currentPage: _getCurrentPageSubtitle(),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _screens[_currentIndex],
      ),
      extendBody: true,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _mapScreenToNav(_currentIndex),
        onTap: _onItemTapped,
      ),
    );
  }
}