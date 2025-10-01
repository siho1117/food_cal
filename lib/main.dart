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
import 'screens/exercise_screen.dart' as exercise;
import 'screens/settings_screen.dart';

// Widgets
import 'widgets/common/custom_bottom_nav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await dotenv.load(fileName: '.env');
    debugPrint('✅ Environment file loaded successfully');
  } catch (e) {
    debugPrint('⚠️ Warning: Could not load .env file: $e');
  }

  try {
    await SharedPreferences.getInstance();
    debugPrint('✅ SharedPreferences initialized successfully');
  } catch (e) {
    debugPrint('❌ Error initializing SharedPreferences: $e');
  }

  try {
    await setupDependencyInjection();
    debugPrint('✅ Dependency injection setup complete');
  } catch (e) {
    debugPrint('❌ Error setting up dependency injection: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create LanguageProvider at top level and load saved language
    return ChangeNotifierProvider(
      create: (_) => LanguageProvider()..loadLanguage(),
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MultiProvider(
            providers: [
              // Existing providers
              ChangeNotifierProvider(
                create: (_) => HomeProvider()..loadData(),
                lazy: false,
              ),
              ChangeNotifierProvider(
                create: (_) => ExerciseProvider()..loadData(),
                lazy: false,
              ),
              ChangeNotifierProvider(
                create: (_) => ProgressData()..loadUserData(),
                lazy: false,
              ),
              ChangeNotifierProvider(
                create: (_) => SettingsProvider()..loadUserData(),
                lazy: true,
              ),
            ],
            child: MaterialApp(
              title: 'FOOD LLM',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              
              // Localization configuration
              locale: languageProvider.currentLocale,
              supportedLocales: const [
                Locale('en'),           // English
                Locale('zh', 'CN'),     // Simplified Chinese
                Locale('zh', 'TW'),     // Traditional Chinese
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              localeResolutionCallback: (locale, supportedLocales) {
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale?.languageCode &&
                      supportedLocale.countryCode == locale?.countryCode) {
                    return supportedLocale;
                  }
                }
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale?.languageCode) {
                    return supportedLocale;
                  }
                }
                return supportedLocales.first;
              },
              
              // Existing routes
              home: const SplashScreen(),
              routes: {
                '/home': (context) => const MainApp(),
                '/settings': (context) => const SettingsScreen(),
                '/progress': (context) => const progress.ProgressScreen(),
                '/exercise': (context) => const exercise.ExerciseScreen(),
              },
            ),
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

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const progress.ProgressScreen(),
    CameraScreen(onDismissed: () {}), // Fixed: Added required parameter
    const exercise.ExerciseScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        isCameraOverlayOpen: false, // Fixed: Added required parameter
        onTap: _onItemTapped,
      ),
    );
  }
}