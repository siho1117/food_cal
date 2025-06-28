// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemChrome
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/design_system/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/progress_screen.dart' as progress;
import 'screens/camera_screen.dart';
import 'screens/exercise_screen.dart' as exercise;
import 'screens/settings_screen.dart';
import 'widgets/custom_bottom_nav.dart';
import 'widgets/custom_app_bar.dart';
import 'data/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Load environment variables before the app starts
Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations to portrait only - most important line for fixing orientation issues!
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Load .env file
  await dotenv.load();

  // Initialize SharedPreferences
  await SharedPreferences.getInstance();

  // Pre-initialize the API service singleton
  FoodApiService();

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FOOD CAL',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      // Define routes for navigation
      routes: {
        '/home': (context) => const MainApp(),
        '/settings': (context) => const SettingsScreen(),
        '/progress': (context) => const progress.ProgressScreen(),
        '/exercise': (context) => const exercise.ExerciseScreen(),
        // Camera route removed - handled with transparent overlay
      },
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Camera controller reference to call camera capture
  final GlobalKey<CameraScreenState> _cameraScreenKey =
      GlobalKey<CameraScreenState>();

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Initialize screens - KEEP ALL 5 SCREENS for simplicity
    _screens = [
      const HomeScreen(),                    // index 0
      const progress.ProgressScreen(),       // index 1
      Container(),                           // index 2 - placeholder for camera (never used)
      const exercise.ExerciseScreen(),       // index 3
      const SettingsScreen(),                // index 4
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    // Handle camera tap (index 2) with transparent navigation
    if (index == 2) {
      _navigateToTransparentCamera();
      return; // DON'T change _currentIndex - this is the key!
    }

    // For all other tabs, change normally
    _animationController.reset();
    _animationController.forward();

    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToTransparentCamera() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false, // This makes the route transparent
        barrierDismissible: true, // Allow dismissing by tapping outside
        pageBuilder: (context, animation, secondaryAnimation) {
          return CameraScreen(key: _cameraScreenKey);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
      ),
    );
    // No need for .then() - _currentIndex never changes!
  }

  void _onCameraCapture() {
    // Call the capture method on the camera screen if it's currently showing
    _cameraScreenKey.currentState?.capturePhoto();
  }

  void _navigateToSettings() {
    setState(() {
      _currentIndex = 4; // Index for settings screen
    });
  }
  
  // Method to get the current page subtitle based on the active tab
  String _getCurrentPageSubtitle() {
    switch (_currentIndex) {
      case 0:
        return 'Daily Summary';
      case 1:
        return 'Health Metrics';
      case 2:
        return 'Food Recognition'; // Won't be used since camera doesn't change _currentIndex
      case 3:
        return 'Activity Tracker';
      case 4:
        return 'User Preferences';
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
        child: _screens[_currentIndex], // Direct mapping - no complex logic needed!
      ),
      extendBody: true, // Important for curved navigation bar
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        onCameraCapture: null,
      ),
    );
  }
}