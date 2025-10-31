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
import 'config/design_system/theme_design.dart';

// Localization
import 'l10n/generated/app_localizations.dart';

// Widgets
import 'widgets/common/custom_bottom_nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  try {
    await SharedPreferences.getInstance();
    debugPrint('✅ SharedPreferences initialized successfully');
  } catch (e) {
    debugPrint('❌ Error initializing SharedPreferences: $e');
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
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
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
  int _currentIndex = 0;
  bool _showCamera = false;

  final List<Widget> _screens = const [
    HomeScreen(),
    ProgressScreen(),
    SummaryScreen(),
    SettingsScreen(),
  ];

  // Map bottom nav index to screen index (handling camera special case)
  int _getScreenIndex(int navIndex) {
    // Assuming 5 nav items: Home(0), Progress(1), Camera(2), Summary(3), Settings(4)
    if (navIndex == 2) return 0; // Camera - show home in background
    if (navIndex > 2) return navIndex - 1; // Adjust for camera offset
    return navIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Show screen, with bounds checking
          _screens[_getScreenIndex(_currentIndex).clamp(0, _screens.length - 1)],
          
          // Show camera overlay if index 2 selected
          if (_showCamera) 
            CameraScreen(
              onDismissed: () {
                setState(() {
                  _showCamera = false;
                  // Return to home screen
                  _currentIndex = 0;
                });
              },
            ),
          
          // Bottom navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNav(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                  _showCamera = (index == 2); // Camera is at index 2
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}