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
        '/camera': (context) => const CameraScreen(),
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

    // Initialize screens with the camera screen key
    _screens = [
      const HomeScreen(),
      const progress.ProgressScreen(),
      CameraScreen(key: _cameraScreenKey),
      const exercise.ExerciseScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    // If we're already on the camera screen (index 2) and user taps camera button again,
    // trigger the capture method
    if (_currentIndex == 2 && index == 2) {
      _onCameraCapture();
      return;
    }

    // Reset animation when tab changes
    _animationController.reset();
    _animationController.forward();

    setState(() {
      _currentIndex = index;
    });
  }

  void _onCameraCapture() {
    // Call the capture method on the camera screen
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
        return 'Food Recognition';
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
      appBar: _currentIndex == 2
          ? null // No app bar for camera screen
          : CustomAppBar(
              onSettingsTap: _navigateToSettings,
              currentPage: _getCurrentPageSubtitle(), // Pass the current page subtitle
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
      extendBody: true, // Important for curved navigation bar
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        onCameraCapture: null,
      ),
    );
  }
}