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

  // Initialize dependency injection - MUST AWAIT THIS!
  await setupDependencyInjection();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()..loadData()),
        ChangeNotifierProvider(create: (_) => ExerciseProvider()..loadData()),
        ChangeNotifierProvider(create: (_) => ProgressData()..loadUserData()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()..loadLanguage()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadGradient()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'Food Cal',
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
              '/settings': (context) => const SettingsScreen(),
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
  bool _isCameraOverlayOpen = false;

  // 4 actual screens (Camera is an overlay, not a screen)
  final List<Widget> _screens = const [
    HomeScreen(),      // Index 0
    ProgressScreen(),  // Index 1
    SummaryScreen(),   // Index 2
    SettingsScreen(),  // Index 3
  ];

  void _onItemTapped(int index) {
    // Handle the 5-tab bottom nav indices
    // Home: 0, Progress: 1, Camera: 2, Summary: 3, Settings: 4
    
    if (index == 2) {
      // Camera tap - show overlay
      _showCameraOverlay();
    } else {
      // Convert bottom nav index to screen index
      // Bottom nav: 0, 1, 2(camera), 3, 4
      // Screens: 0, 1, 2(summary), 3(settings)
      int screenIndex;
      if (index < 2) {
        screenIndex = index; // Home and Progress map directly
      } else if (index == 3) {
        screenIndex = 2; // Summary
      } else {
        screenIndex = 3; // Settings
      }
      
      setState(() {
        _currentIndex = screenIndex;
        _isCameraOverlayOpen = false;
      });
    }
  }

  void _showCameraOverlay() {
    setState(() {
      _isCameraOverlayOpen = true;
    });

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return CameraScreen(
            onDismissed: () {
              if (mounted) {
                setState(() {
                  _isCameraOverlayOpen = false;
                });
              }
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
        currentIndex: _convertScreenIndexToNavIndex(_currentIndex),
        isCameraOverlayOpen: _isCameraOverlayOpen,
        onTap: _onItemTapped,
      ),
    );
  }

  // Convert screen index back to bottom nav index for highlighting
  int _convertScreenIndexToNavIndex(int screenIndex) {
    // Screens: 0(Home), 1(Progress), 2(Summary), 3(Settings)
    // Bottom nav: 0(Home), 1(Progress), 2(Camera), 3(Summary), 4(Settings)
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
}