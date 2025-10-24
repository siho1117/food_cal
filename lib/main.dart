// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// App configuration
import 'config/design_system/theme.dart';
import 'config/dependency_injection.dart';

// Providers
import 'providers/home_provider.dart';
import 'providers/exercise_provider.dart';
import 'providers/progress_data.dart';
import 'providers/settings_provider.dart';
import 'providers/language_provider.dart';

// Localization
import 'l10n/generated/app_localizations.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/progress_screen.dart' as progress;
import 'screens/camera_screen.dart';
// REMOVED: import 'screens/exercise_screen.dart' as exercise;
import 'screens/settings_screen.dart';
import 'screens/summary_screen.dart';

// Widgets
import 'widgets/common/custom_bottom_nav.dart';
import 'widgets/common/custom_app_bar.dart';

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // CRITICAL: Lock app to portrait mode only - prevents landscape rotation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    // Load .env file with error handling
    await dotenv.load(fileName: '.env');
    debugPrint('✅ Environment file loaded successfully');
  } catch (e) {
    debugPrint('⚠️ Warning: Could not load .env file: $e');
    // Continue execution - app should work without .env in production
  }

  try {
    // Initialize SharedPreferences
    await SharedPreferences.getInstance();
    debugPrint('✅ SharedPreferences initialized successfully');
  } catch (e) {
    debugPrint('❌ Error initializing SharedPreferences: $e');
    // This is more critical - you might want to show an error screen here
  }

  // Initialize dependency injection
  setupDependencyInjection();

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
              '/home': (context) => const MainApp(),
              '/settings': (context) => const SettingsScreen(),
              '/progress': (context) => const progress.ProgressScreen(),
              // REMOVED: '/exercise' route - now part of progress screen
            },
          );
        },
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isCameraOverlayOpen = false;
  late AnimationController _animationController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialize screens list (4 screens now - exercise removed)
    _screens = [
      const HomeScreen(),                     // Index 0
      const progress.ProgressScreen(),        // Index 1 (now has both Progress + Exercise)
      Container(),                            // Index 2 (Camera - handled separately)
      const SummaryScreen(),                  // Index 3 (was index 4)
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      // Camera tap - toggle overlay
      setState(() {
        _isCameraOverlayOpen = !_isCameraOverlayOpen;
      });
      
      if (_isCameraOverlayOpen) {
        // Navigate to camera screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CameraScreen(
              onDismissed: () {
                setState(() {
                  _isCameraOverlayOpen = false;
                });
              },
            ),
          ),
        ).then((_) {
          // Ensure overlay state is reset when returning
          if (mounted) {
            setState(() {
              _isCameraOverlayOpen = false;
            });
          }
        });
      }
    } else {
      setState(() {
        _currentIndex = index;
        _isCameraOverlayOpen = false;
      });
    }
  }

  void _navigateToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  String _getCurrentPageSubtitle() {
    switch (_currentIndex) {
      case 0:
        return 'Daily Nutrition';
      case 1:
        return 'Activity & Progress'; // UPDATED: now includes exercise
      case 3:
        return 'Analytics Dashboard';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        onSettingsTap: _navigateToSettings,
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
        currentIndex: _currentIndex,
        isCameraOverlayOpen: _isCameraOverlayOpen,
        onTap: _onItemTapped,
        onCameraCapture: null,
      ),
    );
  }
}