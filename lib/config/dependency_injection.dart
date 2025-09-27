// lib/config/dependency_injection.dart
// STEP 1: Simple setup using your EXISTING classes without any changes
import 'package:flutter/foundation.dart'; // ADD THIS for debugPrint
import 'package:get_it/get_it.dart';

// Import your existing classes (no changes needed to them)
import '../data/storage/local_storage.dart';
import '../data/services/api_service.dart';
import '../data/services/image_storage_service.dart';
import '../data/repositories/food_repository.dart';
import '../data/repositories/user_repository.dart';

final GetIt getIt = GetIt.instance;

/// Initialize dependencies using your EXISTING classes as-is
/// No changes needed to your current repositories or providers
Future<void> setupDependencyInjection() async {
  // === REGISTER YOUR EXISTING CLASSES AS SINGLETONS ===
  // This creates one instance that gets reused everywhere
  
  // Storage layer
  getIt.registerLazySingleton<LocalStorage>(() => LocalStorage());
  
  // Service layer  
  getIt.registerLazySingleton<FoodApiService>(() => FoodApiService());
  getIt.registerLazySingleton<ImageStorageService>(() => ImageStorageService());
  
  // Repository layer - using your existing constructors but now they get LocalStorage from DI
  getIt.registerLazySingleton<FoodRepository>(() => FoodRepository());
  getIt.registerLazySingleton<UserRepository>(() => UserRepository());
  
  debugPrint('✅ Basic dependency injection setup complete!');
}

/// Clean up when app closes
Future<void> disposeDependencyInjection() async {
  await getIt.reset();
  debugPrint('🧹 Dependencies cleaned up!');
}