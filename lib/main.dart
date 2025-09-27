// lib/main.dart - COMPLETE FIX FOR INFINITE LOOPS
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart'; // ADDED: Import provider
import 'config/design_system/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/progress_screen.dart' as progress;
import 'screens/camera_screen.dart';
import 'screens/exercise_screen.dart' as exercise;
import 'screens/settings_screen.dart';
import 'screens/summary_screen.dart';
import 'widgets/custom_bottom_nav.dart';
import 'widgets/custom_app_bar.dart';
import 'data/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ADDED: Import all providers
import 'providers/home_provider.dart';
import 'providers/progress_data.dart';
import 'providers/exercise_provider.dart';
import 'providers/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await dotenv.load();
  await SharedPreferences.getInstance();
  FoodApiService();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FOOD CAL',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const MainApp(),
        '/settings': (context) => const SettingsScreen(showBackButton: true),
        '/progress': (context) => const progress.ProgressScreen(),
        '/exercise': (context) => const exercise.ExerciseScreen(),
      },
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

  // FIXED: Create providers once and manage their lifecycle
  late HomeProvider _homeProvider;
  late ProgressData _progressProvider;
  late ExerciseProvider _exerciseProvider;
  late SettingsProvider _settingsProvider;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // FIXED: Initialize providers once
    _homeProvider = HomeProvider();
    _progressProvider = ProgressData();
    _exerciseProvider = ExerciseProvider();
    _settingsProvider = SettingsProvider();

    // FIXED: Initialize screens with provider-less versions
    _screens = [
      const _HomeScreenContent(),           // index 0
      const _ProgressScreenContent(),       // index 1  
      Container(),                          // index 2 - camera placeholder
      const _ExerciseScreenContent(),       // index 3
      const _SummaryScreenContent(),        // index 4
    ];

    // FIXED: Load data once during app initialization
    _loadInitialData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    // FIXED: Dispose all providers
    _homeProvider.dispose();
    _progressProvider.dispose();
    _exerciseProvider.dispose();
    _settingsProvider.dispose();
    super.dispose();
  }

  // FIXED: Load data once, not on every rebuild
  Future<void> _loadInitialData() async {
    await Future.wait([
      _homeProvider.loadData(),
      _progressProvider.loadUserData(),
      _exerciseProvider.loadData(),
      _settingsProvider.loadUserData(),
    ]);
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      _navigateToTransparentCamera();
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _navigateToTransparentCamera() async {
    setState(() {
      _isCameraOverlayOpen = true;
    });

    final result = await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => CameraScreen(
          onDismissed: () {
            setState(() {
              _isCameraOverlayOpen = false;
            });
            Navigator.of(context).pop();
          },
        ),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    );

    setState(() {
      _isCameraOverlayOpen = false;
    });

    if (result != null) {
      debugPrint('Camera result: $result');
    }
  }

  void _navigateToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(showBackButton: true),
      ),
    );
  }

  String _getCurrentPageSubtitle() {
    switch (_currentIndex) {
      case 0:
        return 'Daily Food Tracker';
      case 1:
        return 'Health Progress';
      case 3:
        return 'Fitness Tracker';
      case 4:
        return 'Analytics Dashboard';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // FIXED: Provide all providers at the top level
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HomeProvider>.value(value: _homeProvider),
        ChangeNotifierProvider<ProgressData>.value(value: _progressProvider),
        ChangeNotifierProvider<ExerciseProvider>.value(value: _exerciseProvider),
        ChangeNotifierProvider<SettingsProvider>.value(value: _settingsProvider),
      ],
      child: Scaffold(
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
      ),
    );
  }
}

// FIXED: Provider-less screen content widgets
class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        if (homeProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryBlue),
          );
        }
        
        return const HomeScreen();
      },
    );
  }
}

class _ProgressScreenContent extends StatelessWidget {
  const _ProgressScreenContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressData>(
      builder: (context, progressData, child) {
        if (progressData.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return const progress.ProgressScreen();
      },
    );
  }
}

class _ExerciseScreenContent extends StatelessWidget {
  const _ExerciseScreenContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<ExerciseProvider>(
      builder: (context, exerciseProvider, child) {
        if (exerciseProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return const exercise.ExerciseScreen();
      },
    );
  }
}

class _SummaryScreenContent extends StatelessWidget {
  const _SummaryScreenContent();

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, ExerciseProvider>(
      builder: (context, homeProvider, exerciseProvider, child) {
        if (homeProvider.isLoading || exerciseProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return const SummaryScreen();
      },
    );
  }
}