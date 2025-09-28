// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

// App configuration
import 'config/design_system/theme.dart';
import 'config/dependency_injection.dart';

// Providers
import 'providers/home_provider.dart';
import 'providers/exercise_provider.dart';
import 'providers/progress_data.dart';
import 'providers/settings_provider.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/progress_screen.dart' as progress;
import 'screens/camera_screen.dart';
import 'screens/exercise_screen.dart' as exercise;
import 'screens/settings_screen.dart';
import 'screens/summary_screen.dart';

// Widgets
import 'widgets/custom_bottom_nav.dart';
import 'widgets/custom_app_bar.dart';

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
    // This is more critical - you might want to show an error screen
  }

  try {
    // 🚀 SETUP DEPENDENCY INJECTION
    await setupDependencyInjection();
    debugPrint('✅ Dependency injection setup complete');
  } catch (e) {
    debugPrint('❌ Error setting up dependency injection: $e');
    // This is critical - the app won't work without DI
  }

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ FIXED: Wrap MaterialApp with MultiProvider to provide app-level providers
    return MultiProvider(
      providers: [
        // Create providers once at app level
        ChangeNotifierProvider(
          create: (_) => HomeProvider()..loadData(),
          lazy: false, // Load immediately
        ),
        ChangeNotifierProvider(
          create: (_) => ExerciseProvider()..loadData(),
          lazy: false, // Load immediately
        ),
        ChangeNotifierProvider(
          create: (_) => ProgressData()..loadUserData(),
          lazy: false, // Load immediately
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadUserData(),
          lazy: true, // Load when needed
        ),
      ],
      child: MaterialApp(
        title: 'FOOD LLM',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const MainApp(),
          '/settings': (context) => const SettingsScreen(),
          '/progress': (context) => const progress.ProgressScreen(),
          '/exercise': (context) => const exercise.ExerciseScreen(),
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

    // Initialize screens list
    _screens = [
      const HomeScreen(),
      const progress.ProgressScreen(),
      Container(), // Camera screen handled separately via navigation
      const exercise.ExerciseScreen(),
      const SummaryScreen(),
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
        return 'Progress Tracker';
      case 3:
        return 'Exercise Tracker';
      case 4:
        return 'Analytics Dashboard';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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